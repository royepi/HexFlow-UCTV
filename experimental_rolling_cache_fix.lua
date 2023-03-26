-- HexFlow Launcher Custom version 1.1
-- based on VitaHEX's HexFlow Launcher v0.5 + SwitchView UI v0.1.2 + jimbob4000's Retroflow v5.0.2
-- https://www.patreon.com/vitahex
-- Want to make your own version? Right-click the vpk and select "Open with... Winrar" and edit the index.lua inside.

local oneLoopTimer = Timer.new()	 --Startup speed timer, view result in menu>about
local oneLoopTime = 0
local functionTime = 0
local applistReadTime = 0
local sortTime = 0

dofile("app0:addons/threads.lua")
local working_dir = "ux0:/app"
local appversion = "1.1"
function System.currentDirectory(dir)
    if dir == nil then
        return working_dir --"ux0:/app"
    else
        working_dir = dir
    end
end

Network.init()	 -- Uses the Retroflow cover archive: more homebrew covers and it's just more complete in general.
local onlineCovers = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/PSVita/"
local onlineCoversPSP = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/PSP/"
local onlineCoversPSX = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/PS1/"

Sound.init()
local click = Sound.open("app0:/DATA/click2.ogg")
local sndMusic = click--temp
local imgCoverTmp = Graphics.loadImage("app0:/DATA/noimg.png")
local backTmp = Graphics.loadImage("app0:/DATA/noimg.png")
local btnX = Graphics.loadImage("app0:/DATA/x.png")
local btnT = Graphics.loadImage("app0:/DATA/t.png")
local btnS = Graphics.loadImage("app0:/DATA/s.png")
local btnO = Graphics.loadImage("app0:/DATA/o.png")
local btnD = Graphics.loadImage("app0:/DATA/d.png")			  --@@ NEW!
local imgWifi = Graphics.loadImage("app0:/DATA/wifi.png")
local imgBattery = Graphics.loadImage("app0:/DATA/bat.png")
local imgCacheIcon = Graphics.loadImage("app0:/DATA/cache_icon_25x25.png")
local imgBack = Graphics.loadImage("app0:/DATA/back_01.jpg")
local imgFloor = Graphics.loadImage("app0:/DATA/floor.png")
Graphics.setImageFilters(imgFloor, FILTER_LINEAR, FILTER_LINEAR)

local RetroflowAssetsAreLoaded = false					  --@@ NEW!
local SwitchviewAssetsAreLoaded = false

-- Footer button margins
local btnMargin = 44	 --Retroflow: 64. HEXFlow: ~46
local btnImgWidth = 20
--local btnImgWidth = Graphics.getImageWidth("app0:/DATA/x.png") --20

-- Footer button X coordinates. Calculated in changeLanguage(). Alts are for start menu.
local label1AltImgX = 0
local label2AltImgX = 0
local label1AltX = 0
local label2AltX = 0
local label1ImgX = 0
local label2ImgX = 0
local label3ImgX = 0
local label4ImgX = 0
local label1X = 0
local label2X = 0
local label3X = 0
local label4X = 0
local toggle1X = nil
local toggle2X = nil

local spin_allowance = 0
local bottomMenu = false
local menuSel = 1
local render_distance = 8
local ovrrd_str = ""		 --@@ NEW!

--@@ NEW! Generates a switch statement out of the contents of a folder as an extremely-faster alternative for System.DoesFileExist()
--@@ (string) dir input example:  "ux0:/data/HexFlow/COVERS/PSVITA/"
--@@ format after listdirectory:  {[1]={["directory"]=true, ["size"]=31457280, ["name"]="PSCE00001"}, [2]={...}...}
--@@ (table) output example:	  {["PCSE00001.png"]=true, ["PCSE00002.png"]=true, ["Rayman Origins.png"]=true, ...}
function switch_generator(dir)
    local switch_output = {}
    for _, v in pairs(System.listDirectory(dir) or {}) do	 --@@ this "or {}" makes it not crash in case the "dir" is a folder that doesn't exist.
	if v.name then
	    switch_output[v.name]=true
	end
    end
    return switch_output
end

-- Speed related settings	 --@@ Moved here now for faster startup with RetroFlow enabled.
local cpu_speed = 444
System.setBusSpeed(222)
System.setGpuSpeed(222)
System.setGpuXbarSpeed(166)
System.setCpuSpeed(cpu_speed)

function OneShotPrint(my_func)	 --@@ Moved here now.
    local loadingCacheImg = Graphics.loadImage("app0:/DATA/oneshot_cache_write.png")
    Graphics.termBlend()  -- End main loop blending if still running
    Graphics.initBlend()
    local black = Color.new(0, 0, 0)	 --@@ NEW!
    Screen.clear(black)
    Graphics.drawImage(0, 0, loadingCacheImg)
    Graphics.drawImage(587, 496, imgCacheIcon)
    Graphics.termBlend()
    Screen.flip()
    Graphics.freeImage(loadingCacheImg)
end

local cur_dir = "ux0:/data/HexFlow/"
local covers_psv = "ux0:/data/HexFlow/COVERS/PSVITA/"
local covers_psp = "ux0:/data/HexFlow/COVERS/PSP/"
local covers_psx = "ux0:/data/HexFlow/COVERS/PSX/"

-- Create directories
System.createDirectory("ux0:/data/HexFlow/")
System.createDirectory("ux0:/data/HexFlow/COVERS/")
System.createDirectory(covers_psv)
System.createDirectory(covers_psp)
System.createDirectory(covers_psx)

local cur_quick_dir = switch_generator(cur_dir)		 --@@ NEW!

if not cur_quick_dir["overrides.dat"] then		 --@@ NEW! Faster than System.doesFileExist(cur_dir .. "/overrides.dat")
    local file_over = System.openFile(cur_dir .. "/overrides.dat", FCREATE)
    System.writeFile(file_over, " ", 1)
    System.closeFile(file_over)
end

if not cur_quick_dir["lastplayedgame.dat"] then		 --@@ NEW!
    local file_over = System.openFile(cur_dir .. "/lastplayedgame.dat", FCREATE)
    System.writeFile(file_over, " ", 1)
    System.closeFile(file_over)
end

--@@ these locals are usually lower, but showView is used for RetroFlow integration so they're here now.
local menuX = 0
local menuY = 0
local showMenu = 0
local showCat = 1 -- Category: 0 = all, 1 = games, 2 = homebrews, 3 = psp, 4 = psx, 5 = custom
local showView = 0
local arcadeMerge = 1			 --@@ NEW!

function appt_hotfix(apptype)	 --@@ NEW! Moved here now because it's needed for Retro overrides.
    if apptype == 2 then
	return 3
    elseif apptype == 3 then
	return 4
    elseif apptype == 0 or apptype == 4 then
	return 2
    else		 --@@ vita, all Retro ROM's.
	return apptype
    end
end

-- load 3D models and textures
local modBackground = Render.loadObject("app0:/DATA/planebg.obj", imgBack)		 --@@ Moved here now.
local modDefaultBackground = Render.loadObject("app0:/DATA/planebg.obj", imgBack)	 --@@ Moved here now.
local modFloor = Render.loadObject("app0:/DATA/planefloor.obj", imgFloor)		 --@@ Moved here now.

local imgBox = Graphics.loadImage("app0:/DATA/vita_cover.png")
local imgBoxPSP = Graphics.loadImage("app0:/DATA/psp_cover.png")
local imgBoxPSX = Graphics.loadImage("app0:/DATA/psx_cover.png")

local modBox = Render.loadObject("app0:/DATA/box.obj", imgBox)
local modCover = Render.loadObject("app0:/DATA/cover.obj", imgCoverTmp)
local modBoxNoref = Render.loadObject("app0:/DATA/box_noreflx.obj", imgBox)
local modCoverNoref = Render.loadObject("app0:/DATA/cover_noreflx.obj", imgCoverTmp)

local modBoxPSP = Render.loadObject("app0:/DATA/boxpsp.obj", imgBoxPSP)
local modCoverPSP = Render.loadObject("app0:/DATA/coverpsp.obj", imgCoverTmp)
local modBoxPSPNoref = Render.loadObject("app0:/DATA/boxpsp_noreflx.obj", imgBoxPSP)
local modCoverPSPNoref = Render.loadObject("app0:/DATA/coverpsp_noreflx.obj", imgCoverTmp)

local modBoxPSX = Render.loadObject("app0:/DATA/boxpsx.obj", imgBoxPSX)
local modCoverPSX = Render.loadObject("app0:/DATA/coverpsx.obj", imgCoverTmp)
local modBoxPSXNoref = Render.loadObject("app0:/DATA/boxpsx_noreflx.obj", imgBoxPSX)
local modCoverPSXNoref = Render.loadObject("app0:/DATA/coverpsx_noreflx.obj", imgCoverTmp)

local modCoverHbr = Render.loadObject("app0:/DATA/cover_square.obj", imgCoverTmp)
local modCoverHbrNoref = Render.loadObject("app0:/DATA/cover_square_noreflx.obj", imgCoverTmp)

function load_RetroFlow()	 --@@ NEW!
    modCoverN64 = Render.loadObject("app0:/DATA/covern64.obj", imgCoverTmp)
    modCoverN64Noref = Render.loadObject("app0:/DATA/covern64_noreflx.obj", imgCoverTmp)

    modCoverNES = Render.loadObject("app0:/DATA/covernes.obj", imgCoverTmp)
    modCoverNESNoref = Render.loadObject("app0:/DATA/covernes_noreflx.obj", imgCoverTmp)

    modCoverGB = Render.loadObject("app0:/DATA/covergb.obj", imgCoverTmp)
    modCoverGBNoref = Render.loadObject("app0:/DATA/covergb_noreflx.obj", imgCoverTmp)

    modCoverMD = Render.loadObject("app0:/DATA/covermd.obj", imgCoverTmp)
    modCoverMDNoref = Render.loadObject("app0:/DATA/covermd_noreflx.obj", imgCoverTmp)

    modCoverTAPE = Render.loadObject("app0:/DATA/covertape.obj", imgCoverTmp)
    modCoverTAPENoref = Render.loadObject("app0:/DATA/covertape_noreflx.obj", imgCoverTmp)

    modCoverATARI = Render.loadObject("app0:/DATA/coveratari.obj", imgCoverTmp)
    modCoverATARINoref = Render.loadObject("app0:/DATA/coveratari_noreflx.obj", imgCoverTmp)

    modCoverLYNX = Render.loadObject("app0:/DATA/coverlynx.obj", imgCoverTmp)
    modCoverLYNXNoref = Render.loadObject("app0:/DATA/coverlynx_noreflx.obj", imgCoverTmp)

    function launch_retroarch(romfile, def_core_name)					 --@@ NEW! Credit RetroFlow
	System.executeUri("psgm:play?titleid=RETROVITA" .. "&param=" .. def_core_name .. "&param2=" .. romfile)
	System.exit()
    end

    function launch_DaedalusX64(romfile)							 --@@ NEW! Credit RetroFlow
	System.executeUri("psgm:play?titleid=DEDALOX64" .. "&param=" .. romfile)
	System.exit()
    end

    function launch_Flycast(romfile)							 --@@ NEW! Credit RetroFlow
	System.executeUri("psgm:play?titleid=FLYCASTDC" .. "&param=" .. romfile)
	System.exit()
    end

    function launch_Fake08(romfile) 							 --@@ NEW!
	romfile = romfile:gsub("ux0:", "ux0:/", 1)
	System.executeUri("psgm:play?titleid=FAKE00008" .. "&param=" .. romfile)
	System.exit()
    end

    function launch_NooDS(romfile) 								 --@@ NEW! Requires NooDS Launcher (experimental and very slow). Normal NooDS has direct launch but I couldn't figure out how to make it work. I don't really care to know until it runs at a good speed.
	System.createDirectory("ux0:/data/noods")
	local file_over = System.openFile("ux0:/data/noods/retroflow.ini", FCREATE)		 --@@ open retroflow.ini or create if it doesn't exist.
	io.open("ux0:/data/noods/retroflow.ini","w"):close()				 --@@ clear retroflow.ini data.
	romfile = "ndsPath=" .. romfile .. "\n"						 --@@ NooDS launcher's funky format. (Note: NOT THE SAME AS NORMAL NOODS DIRECT LAUNCH FORMAT).
	System.writeFile(file_over, romfile, romfile:len())
	System.closeFile(file_over)
	--@@if doesAppExist("NOODSLNCR") then						 --@@ This command requires an updated Lua Player Plus binary.
	if System.doesFileExist("ux0:/app/NOODSLNCR/eboot.bin") then
	    System.launchApp("NOODSLNCR")
	    System.exit()									 --@@ This has to be right next to system.launchapp to do a confirmation-less launch.
	else
	    System.exit()
	end
    end

    function xRomDirLookup(rdir)
	if rdir == 2 then return	 ""	 --@@working_adr_partition
	elseif rdir == 3 then return     "ux0:data/RetroFlow/ROMS/Sony - PlayStation - RetroArch/"
	elseif rdir == 4 then return     "ux0:data/RetroFlow/ROMS/Sony - PlayStation - RetroArch/"
	elseif rdir == 5 then return     "ux0:data/RetroFlow/ROMS/Nintendo - Nintendo 64/"
	elseif rdir == 6 then return     "ux0:data/RetroFlow/ROMS/Nintendo - Super Nintendo Entertainment System/"
	elseif rdir == 7 then return     "ux0:data/RetroFlow/ROMS/Nintendo - Nintendo Entertainment System/"
	elseif rdir == 8 then return     "ux0:data/RetroFlow/ROMS/Nintendo - Nintendo DS/"
	elseif rdir == 9 then return     "ux0:data/RetroFlow/ROMS/Nintendo - Game Boy Advance/"
	elseif rdir == 10 then return    "ux0:data/RetroFlow/ROMS/Nintendo - Game Boy Color/"
	elseif rdir == 11 then return    "ux0:data/RetroFlow/ROMS/Nintendo - Game Boy/"
	elseif rdir == 12 then return    "ux0:data/RetroFlow/ROMS/Sega - Dreamcast/"
	elseif rdir == 13 then return    "ux0:data/RetroFlow/ROMS/Sega - Mega-CD - Sega CD/"
	elseif rdir == 14 then return    "ux0:data/RetroFlow/ROMS/Sega - 32X/"
	elseif rdir == 15 then return    "ux0:data/RetroFlow/ROMS/Sega - Mega Drive - Genesis/"
	elseif rdir == 16 then return    "ux0:data/RetroFlow/ROMS/Sega - Master System - Mark III/"
	elseif rdir == 17 then return    "ux0:data/RetroFlow/ROMS/Sega - Game Gear/"
	elseif rdir == 18 then return    "ux0:data/RetroFlow/ROMS/NEC - TurboGrafx 16/"
	elseif rdir == 19 then return    "ux0:data/RetroFlow/ROMS/NEC - TurboGrafx CD/"
	elseif rdir == 20 then return    "ux0:data/RetroFlow/ROMS/NEC - PC Engine/"
	elseif rdir == 21 then return    "ux0:data/RetroFlow/ROMS/NEC - PC Engine CD/"
	elseif rdir == 22 then return    "ux0:data/RetroFlow/ROMS/Commodore - Amiga/"
	elseif rdir == 23 then return    "ux0:data/RetroFlow/ROMS/Commodore - 64/"
	elseif rdir == 24 then return    "ux0:data/RetroFlow/ROMS/Bandai - WonderSwan Color/"
	elseif rdir == 25 then return    "ux0:data/RetroFlow/ROMS/Bandai - WonderSwan/"
	elseif rdir == 26 then return    "ux0:p8carts/"
	elseif rdir == 27 then return    "ux0:data/RetroFlow/ROMS/Microsoft - MSX2/"
	elseif rdir == 28 then return    "ux0:data/RetroFlow/ROMS/Microsoft - MSX/"
	elseif rdir == 29 then return    "ux0:data/RetroFlow/ROMS/Sinclair - ZX Spectrum/"
	elseif rdir == 30 then return    "ux0:data/RetroFlow/ROMS/Atari - 7800/"
	elseif rdir == 31 then return    "ux0:data/RetroFlow/ROMS/Atari - 5200/"
	elseif rdir == 32 then return    "ux0:data/RetroFlow/ROMS/Atari - 2600/"
	elseif rdir == 33 then return    "ux0:data/RetroFlow/ROMS/Atari - Lynx/"
	elseif rdir == 34 then return    "ux0:data/RetroFlow/ROMS/Coleco - ColecoVision/"
	elseif rdir == 35 then return    "ux0:data/RetroFlow/ROMS/GCE - Vectrex/"
	elseif rdir == 36 then return    "ux0:data/RetroFlow/ROMS/FBA 2012/"
	elseif rdir == 37 then return    "ux0:data/RetroFlow/ROMS/MAME 2003 Plus/"
	elseif rdir == 38 then return    "ux0:data/RetroFlow/ROMS/MAME 2000/"
	elseif rdir == 39 then return    "ux0:data/RetroFlow/ROMS/SNK - Neo Geo - FBA 2012/"
	elseif rdir == 40 then return    "ux0:data/RetroFlow/ROMS/SNK - Neo Geo Pocket Color/"
	end
    end

    function xSIconLookup(square_apptype)		 --@@ NEW! For placeholder icons in Triangle Menu and SwitchView
	if square_apptype == 2 then	 return "app0:/DATA/icon_psp.png"		 --@@ 2
	elseif square_apptype == 3 then	 return "app0:/DATA/icon_psx.png"		 --@@ 3
	elseif square_apptype == 4 then	 return "app0:/DATA/icon_psx.png"		 --@@ 4
	elseif square_apptype == 5 then	 return "app0:/DATA/icon_n64.png"		 --@@ 5
	elseif square_apptype == 6 then	 return "app0:/DATA/icon_snes.png"		 --@@ 6
	elseif square_apptype == 7 then	 return "app0:/DATA/icon_nes.png"		 --@@ 7
	elseif square_apptype == 8 then	 return "app0:/DATA/icon_nds.png"		 --@@ 8
	elseif square_apptype == 9 then	 return "app0:/DATA/icon_gba.png"		 --@@ 9
	elseif square_apptype == 10 then     return "app0:/DATA/icon_gbc.png"		 --@@ 10
	elseif square_apptype == 11 then     return "app0:/DATA/icon_gb.png"		 --@@ 11
	elseif square_apptype == 12 then     return "app0:/DATA/icon_dreamcast_eur.png"	 --@@ 12
	elseif square_apptype == 13 then     return "app0:/DATA/icon_sega_cd.png"		 --@@ 13
	elseif square_apptype == 14 then     return "app0:/DATA/icon_32x.png"		 --@@ 14
	elseif square_apptype == 15 then     return "app0:/DATA/icon_md_usa.png"		 --@@ 15 @@ Mega Drive - Genesis
	elseif square_apptype == 16 then     return "app0:/DATA/icon_sms.png"		 --@@ 16
	elseif square_apptype == 17 then     return "app0:/DATA/icon_gg.png"		 --@@ 17
	elseif square_apptype == 18 then     return "app0:/DATA/icon_tg16.png"		 --@@ 18
	elseif square_apptype == 19 then     return "app0:/DATA/icon_tgcd.png"		 --@@ 19
	elseif square_apptype == 20 then     return "app0:/DATA/icon_pce.png"		 --@@ 20
	elseif square_apptype == 21 then     return "app0:/DATA/icon_pcecd.png"		 --@@ 21
	elseif square_apptype == 22 then     return "app0:/DATA/icon_amiga.png"		 --@@ 22
	elseif square_apptype == 23 then     return "app0:/DATA/icon_c64.png"		 --@@ 23
	elseif square_apptype == 24 then     return "app0:/DATA/icon_wswan_col.png"		 --@@ 24
	elseif square_apptype == 25 then     return "app0:/DATA/icon_wswan.png"		 --@@ 25
	elseif square_apptype == 26 then     return "app0:/DATA/icon_pico8.png"		 --@@ 26
	elseif square_apptype == 27 then     return "app0:/DATA/icon_msx2.png"		 --@@ 27
	elseif square_apptype == 28 then     return "app0:/DATA/icon_msx1.png"		 --@@ 28
	elseif square_apptype == 29 then     return "app0:/DATA/icon_zxs.png"		 --@@ 29
	elseif square_apptype == 30 then     return "app0:/DATA/icon_atari_7800.png"	 --@@ 30
	elseif square_apptype == 31 then     return "app0:/DATA/icon_atari_5200.png"	 --@@ 31
	elseif square_apptype == 32 then     return "app0:/DATA/icon_atari_2600.png"	 --@@ 32
	elseif square_apptype == 33 then     return "app0:/DATA/icon_atari_lynx.png"	 --@@ 33
	elseif square_apptype == 34 then     return "app0:/DATA/icon_colecovision.png"	 --@@ 34
	elseif square_apptype == 35 then     return "app0:/DATA/icon_vectrex.png"		 --@@ 35
	elseif square_apptype == 36 then     return "app0:/DATA/icon_fba.png"		 --@@ 36
	elseif square_apptype == 37 then     return "app0:/DATA/icon_mame_2003p.png"	 --@@ 37
	elseif square_apptype == 38 then     return "app0:/DATA/icon_mame.png"		 --@@ 38
	elseif square_apptype == 39 then     return "app0:/DATA/icon_neogeo.png"		 --@@ 39
	elseif square_apptype == 40 then     return "app0:/DATA/icon_ngpc.png"		 --@@ 40
	else				 return "app0:/DATA/icon_homebrew.png"
	end
    end

    function xTrueIconLookup(tr_apptype)		 --@@ NEW! This is super lazy and doesn't even work for Vita/PSP/PSX lol
	return xSIconLookup(tr_apptype):gsub("app0:/DATA/icon", "app0:/DATA/missing_cover")
    end

    function Basic_Filter_Check(tmp_extension)	 --@@ NEW!
	if tmp_extension ~= ".sav"			 --@@ RetroArch/NooDS save file
	and tmp_extension ~= ".srm"
	and tmp_extension ~= ".mpk"
	and tmp_extension ~= ".eep"
	and tmp_extension ~= ".st0"
	and tmp_extension ~= ".sta"
	and tmp_extension ~= ".sr0"
	and tmp_extension ~= ".ss0"
	and tmp_extension ~= "tore"			 --@@ folder info file: DS_Store
	and tmp_extension:sub(-2) ~= "._"		 --@@ temporary file created if a file transfer fails.
	and tmp_extension:sub(-3) ~= ".db" then	 --@@ folder info file: Thumbs.db
	    return "pass"
	end
    end

    function Read_Rom_Dir(tmpap, filter_list)				  --@@ NEW!
	local tmp_rom_dir = xRomDirLookup(tmpap)
	local tmp_table_in = System.listDirectory(tmp_rom_dir) or {}	  --@@ defaults to empty table {} in case a rom directory doesn't exist.
	local tmp_table_out_1 = {}
	local coverspath = tmp_rom_dir:gsub("/ROMS/", "/COVERS/")		  --@@ Example: "ux0:data/RetroFlow/COVERS/Nintendo - Game Boy"
	local tmp_covers_list = {}
	local custom_path = ""

	if tmpap == 3 then
	    coverspath = covers_psx
	    tmp_covers_list = cover_dir_psx
	else
	    tmp_covers_list = switch_generator(coverspath)
	end

	for _, v in pairs(tmp_table_in) do
	    for __, filter in ipairs(filter_list or {false}) do		  --@@ default filter is boolean "false"
		if v.directory then
		    if filter and filter == "folder" then
			v.apptitle = v.name
		    else
			break						  --@@ ignore folders unless we're actually looking for them.
		    end
		elseif filter and v.name:sub(-filter:len()) == filter then
		    v.apptitle = v.name:sub(1, -filter:len()-1)		  --@@ Super_Disc_Box.p8.png --> Super_Disc_Box
		elseif not filter and v.name:match("%.") and Basic_Filter_Check(v.name:sub(-4)) then
		    v.apptitle = v.name:match("(.+)%..+$")			  --@@ Donkey_Kong.n64 --> Donkey_Kong @@ cuts off everything after the last "." but it wouldn't work for pico-8 (since it does FILENAME.p8.png)
		else
		    goto next_filter
		end
		v.app_type = tmpap
		v.launch_type = tmpap
		v.icon = imgCoverTmp
		custom_path = (v.name:match("(.+)%..+$") or v.name) .. ".png" --@@ take filename and either cut off everything after "." OR if there's no "." use the whole filename. Works for normal roms AND lets pico-8 detect itself as a cover.
		table.insert(files_table, v)
		table.insert(tmp_table_out_1, v)
		if tmp_covers_list[custom_path] then
		    v.icon_path = coverspath .. custom_path
		elseif showView==5 or showView==6 then
		    v.icon_path = xSIconLookup(tmpap)			  --@@ special square placeholder icons for SwitchView.
		else
		    v.icon_path = xTrueIconLookup(tmpap)
		end
		::next_filter::
	    end
	end
	table.sort(tmp_table_out_1, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
	return tmp_table_out_1
    end

    n64_table =		 Read_Rom_Dir(5)			     --@@, "ux0:data/RetroFlow/ROMS/Nintendo - Nintendo 64")				 @@ .n64 .z64 .v64
    snes_table =	 Read_Rom_Dir(6)			     --@@, "ux0:data/RetroFlow/ROMS/Nintendo - Super Nintendo Entertainment System")	 @@ .sfc .smc .fig
    nes_table =		 Read_Rom_Dir(7)			     --@@, "ux0:data/RetroFlow/ROMS/Nintendo - Nintendo Entertainment System")		 @@ .nes .fds .unf .unif
    nds_table =		 Read_Rom_Dir(8, {".nds"})		     --@@, "ux0:data/RetroFlow/ROMS/Nintendo - Nintendo DS")
    gba_table =		 Read_Rom_Dir(9)			     --@@, "ux0:data/RetroFlow/ROMS/Nintendo - Game Boy Advance")			 @@ .gba
    gbc_table =		 Read_Rom_Dir(10)			     --@@, "ux0:data/RetroFlow/ROMS/Nintendo - Game Boy Color")				 @@ .gbc
    gb_table =		 Read_Rom_Dir(11)			     --@@, "ux0:/data/RetroFlow/ROMS/Nintendo - Game Boy")				 @@ .gb
    dreamcast_table =	 Read_Rom_Dir(12, {".cdi", ".gdi", ".cue"})  --@@, "ux0:data/RetroFlow/ROMS/Sega - Dreamcast")
    sega_cd_table =	 Read_Rom_Dir(13, {".chd", ".cue"})	     --@@, "ux0:data/RetroFlow/ROMS/Sega - Mega-CD - Sega CD")
    s32x_table =	 Read_Rom_Dir(14)			     --@@, "ux0:data/RetroFlow/ROMS/Sega - 32X")
    md_table =		 Read_Rom_Dir(15)			     --@@, "ux0:data/RetroFlow/ROMS/Sega - Mega Drive - Genesis")			 @@ .md .gen .smd
    sms_table =		 Read_Rom_Dir(16)			     --@@, "ux0:data/RetroFlow/ROMS/Sega - Master System - Mark III")			 @@ .sms
    gg_table =		 Read_Rom_Dir(17)			     --@@, "ux0:data/RetroFlow/ROMS/Sega - Game Gear")					 @@ .gg
    tg16_table =	 Read_Rom_Dir(18)			     --@@, "ux0:data/RetroFlow/ROMS/NEC - TurboGrafx 16")
    tgcd_table =	 Read_Rom_Dir(19, {".chd", ".cue"})	     --@@, "ux0:data/RetroFlow/ROMS/NEC - TurboGrafx CD")
    pce_table =		 Read_Rom_Dir(20)			     --@@, "ux0:data/RetroFlow/ROMS/NEC - PC Engine")
    pcecd_table =	 Read_Rom_Dir(21, {".chd", ".cue"})	     --@@, "ux0:data/RetroFlow/ROMS/NEC - PC Engine CD")
    amiga_table =	 Read_Rom_Dir(22)			     --@@, "ux0:data/RetroFlow/ROMS/Commodore - Amiga")					 @@ .adf
    c64_table =		 Read_Rom_Dir(23)			     --@@, "ux0:data/RetroFlow/ROMS/Commodore - 64")					 @@ .t64
    wswan_col_table =	 Read_Rom_Dir(24)			     --@@, "ux0:data/RetroFlow/ROMS/Bandai - WonderSwan Color")				 @@ .ws
    wswan_table =	 Read_Rom_Dir(25)			     --@@, "ux0:data/RetroFlow/ROMS/Bandai - WonderSwan")				 @@ .ws
    pico8_table =	 Read_Rom_Dir(26, {".p8.png"})		     --@@, "ux0:p8carts")
    msx2_table =	 Read_Rom_Dir(27)			     --@@, "ux0:data/RetroFlow/ROMS/Microsoft - MSX2")
    msx1_table =	 Read_Rom_Dir(28)			     --@@, "ux0:data/RetroFlow/ROMS/Microsoft - MSX")
    zxs_table =		 Read_Rom_Dir(29)			     --@@, "ux0:data/RetroFlow/ROMS/Sinclair - ZX Spectrum")
    atari_7800_table =	 Read_Rom_Dir(30)			     --@@, "ux0:data/RetroFlow/ROMS/Atari - 7800")					 @@ .a78
    atari_5200_table =	 Read_Rom_Dir(31)			     --@@, "ux0:data/RetroFlow/ROMS/Atari - 5200")					 @@ .a52
    atari_2600_table =	 Read_Rom_Dir(32)			     --@@, "ux0:data/RetroFlow/ROMS/Atari - 2600")					 @@ .a26
    atari_lynx_table =	 Read_Rom_Dir(33)			     --@@, "ux0:data/RetroFlow/ROMS/Atari - Lynx")					 @@ .lnx
    colecovision_table = Read_Rom_Dir(34)			     --@@, "ux0:data/RetroFlow/ROMS/Coleco - ColecoVision")
    vectrex_table =	 Read_Rom_Dir(35)			     --@@, "ux0:data/RetroFlow/ROMS/GCE - Vectrex")
    if arcadeMerge == 1 then
	fba_table = TableConcat(TableConcat(Read_Rom_Dir(36), Read_Rom_Dir(37)), TableConcat(Read_Rom_Dir(38), Read_Rom_Dir(39)))
	mame_2003_plus_table = {}
	mame_2000_table = {}
	neogeo_table = {}
	table.sort(fba_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    else
	fba_table =		 Read_Rom_Dir(36)		     --@@, "ux0:data/RetroFlow/ROMS/FBA 2012")
	mame_2003_plus_table =	 Read_Rom_Dir(37)		     --@@, "ux0:data/RetroFlow/ROMS/MAME 2003 Plus")
	mame_2000_table =	 Read_Rom_Dir(38)		     --@@, "ux0:data/RetroFlow/ROMS/MAME 2000")
	neogeo_table =		 Read_Rom_Dir(39)		     --@@, "ux0:data/RetroFlow/ROMS/SNK - Neo Geo - FBA 2012")
    end
    ngpc_table =	 Read_Rom_Dir(40)			     --@@, "ux0:data/RetroFlow/ROMS/SNK - Neo Geo Pocket Color")			 @@ .ngp .ngc

    RetroflowAssetsAreLoaded = true
end

function load_SwitchView()
    fnt23_5 = Font.load("app0:/DATA/font.woff")				 --@@ NEW! Now using .woff instead of .ttf for speed - Credit to RetroFlow
    Font.setPixelSizes(fnt23_5, 23.5)
    imgCart = Graphics.loadImage("app0:/DATA/cart.png")
    --imgAvatar = Graphics.loadImage("app0:/AVATARS/AV01.png")		 --@@ Has an actual file now but still unused.
    --@@imgCont = Graphics.loadImage("app0:/DATA/cont.png")		 --@@ new but unused
    --@@img4Square = Graphics.loadImage("app0:/DATA/foursquare.png")	 --@@ new but unused
    imgFloor2 = Graphics.loadImage("app0:/DATA/floor2.png")		 --@@ NEW!
    btnMenu1 = Graphics.loadImage("app0:/DATA/btm1.png")
    btnMenu2 = Graphics.loadImage("app0:/DATA/btm2.png")
    btnMenu3 = Graphics.loadImage("app0:/DATA/btm3.png")
    btnMenu4 = Graphics.loadImage("app0:/DATA/btm4.png")
    btnMenu5 = Graphics.loadImage("app0:/DATA/btm5.png")
    btnMenu6 = Graphics.loadImage("app0:/DATA/btm6.png")
    btnMenuSel = Graphics.loadImage("app0:/DATA/selct.png")
    SwitchviewAssetsAreLoaded = true
end

--@@local modBackground = Render.loadObject("app0:/DATA/planebg.obj", imgBack)		 --@@ MOVED
--@@local modDefaultBackground = Render.loadObject("app0:/DATA/planebg.obj", imgBack)	 --@@ MOVED
--@@local modFloor = Render.loadObject("app0:/DATA/planefloor.obj", imgFloor)		 --@@ MOVED

--@@local img_path = ""

--@@ NEW! Now using .woff instead of .ttf for speed - Credit to RetroFlow
local fnt15 = Font.load("app0:/DATA/font.woff")
local fnt20 = Font.load("app0:/DATA/font.woff")
local fnt22 = Font.load("app0:/DATA/font.woff")
local fnt25 = Font.load("app0:/DATA/font.woff")

Font.setPixelSizes(fnt15, 15)
Font.setPixelSizes(fnt20, 20)
Font.setPixelSizes(fnt22, 22)
Font.setPixelSizes(fnt25, 25)

function sanitize(some_data)			 --@@ NEW! Stronger sanitization, now in function form for easy use.
    some_data = tostring(some_data)
    return some_data:gsub("\n", " "):gsub("\t", " ")
end

--@@local menuX = 0	 --@@ MOVED!
--@@local menuY = 0
--@@local showMenu = 0
--@@local showCat = 1 -- Category: 0 = all, 1 = games, 2 = homebrews, 3 = psp, 4 = psx, 5 = custom
--@@local showView = 0

local info = System.extractSfo("app0:/sce_sys/param.sfo")
local app_version = info.version
local app_title = info.title
local app_short_title = info.short_title --@@ NEW! Now using Rinnegatamante's short title bugfix.
--@@sanitized_title = app_title		 --@@ Function sanitize() is now used instead, saving a local.
local app_category = info.category
local app_titleid = info.titleid
local app_titleid_psx = 0
local app_size = 0
local psx_serial = "-"

local master_index = 1
local p = 1
local oldpad = 0
local delayTouch = 8.0
local delayButton = 8.0
local hideBoxes = 0.2		 --@@ used to be 1
local tmp_move = 0		 --@@ NEW! For less crashy code in analog stick movement.
local prvRotY = 0

local gettingCovers = false
local scanComplete = false
local hasTyped = false		 --@@ NEW!

-- Init Colors
local black = Color.new(0, 0, 0)
local grey = Color.new(45, 45, 45)
local darkalpha = Color.new(40, 40, 40, 180)
local lightgrey = Color.new(58, 58, 58)
local white = Color.new(255, 255, 255)
local red = Color.new(190, 0, 0)
local blue = Color.new(2, 72, 158)
local yellow = Color.new(225, 184, 0)
local green = Color.new(79, 152, 37)
local purple = Color.new(151, 0, 185)
local orange = Color.new(220, 120, 0)
local darkpurple = Color.new(77, 4, 160)
local lightblue = Color.new(67,178,255)
local greyalpha = Color.new(45, 45, 45, 180)
local bg = Color.new(153, 217, 234)
local themeCol = Color.new(2, 72, 158)

local targetX = 0
local floorY = 0	 --@@ NEW!
local xstart = 0
local ystart = 0
local space = 1

local icon_height = 1	 --@@ NEW!
local icon_width = 1	 --@@ NEW!

local touchdown = 0
local tap_target = 0	 --@@ NEW!
local tap_zones = {}	 --@@ NEW!

local startCovers = false
local inPreview = false
local apptype = 0
local appdir = ""
local getCovers = 1 --1 PSV, 2 Homebrews, 3 PSP, 4 PS1
local getBGround = 1 --1 Custom, 2 Citylights, 3 Aurora, 4 "Wood 1", 5 "Wood 2", 6 Dark, 7 Marble
local BGroundText = "-"
local tmpappcat = 0
local background_brackets = true

local prevX = 0
local prevZ = 0
local prevRot = 0

--local total_all = 0
--local total_games = 0
--local total_homebrews = 0
--local total_pspemu = 0
--local total_roms = 0
local total_apps = 0
local curTotal = 0	 --@@ used to be 1

-- Settings
local startCategory = 1
local setReflections = 1
local setSounds = 1
local musicLoop = 1
local themeColor = 0 -- 0 blue, 1 red, 2 yellow, 3 green, 4 grey, 5 black, 7 orange, 6 purple, 8 darkpurple. (reorder hack) 
local menuItems = 3 
local setBackground = 1 
local setLanguage = 0 
local showHomebrews = 0 
local setSwitch = 0
local setRetroFlow = 0
local hideEmptyCats = 0
local dCategoryButton = 0
--@@local smoothView = 0
--@@local superSkip = 1
local View5VitaCropTop = 1
local lockView = 0
local arcadeMerge = 0		 --@@ New but unused. Replaces other unused setting "proTriangleMenu"

function write_config()
    local file_config = System.openFile(cur_dir .. "/config.dat", FCREATE)
--@@writeLanguage, writeBackground = nil, nil
--@@if setLanguage == 10 then writeLanguage = "C" end
--@@if setBackground == 10 then writeBackground = "W"
--@@elseif setBackground == 11 then writeBackground = "P"
--@@elseif setBackground == 12 then writeBackground = "Q"
--@@elseif setBackground == 13 then writeBackground = "M" end
--@@System.writeFile(file_config, startCategory .. setReflections .. setSounds .. themeColor .. (writeBackground or setBackground) .. (writeLanguage or setLanguage) .. showView .. showHomebrews .. musicLoop .. setSwitch .. hideEmptyCats .. dCategoryButton .. View5VitaCropTop .. setRetroFlow .. lockView .. proTriangleMenu, 16)
    System.writeFile(file_config, startCategory .. setReflections .. setSounds .. themeColor .. setBackground .. setLanguage .. showView .. showHomebrews .. musicLoop .. setSwitch .. hideEmptyCats .. dCategoryButton .. View5VitaCropTop .. setRetroFlow .. lockView .. arcadeMerge, 16)
    System.closeFile(file_config)
end

function stringSplit(inputstr, sep)
    if sep == nil then
	sep = "%s" --all "space"-type characters
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
	table.insert(t, str)
    end
    return t
end

function readBin(filename, allow_iso_scan)
    local path_game = nil
    if System.doesFileExist(filename) and string.match(filename, ".bin") then
	local inp = assert(io.open(filename, "rb"), "Failed to open boot.bin")
	inp:seek("set",64)				 --@@ NEW! skip the unnecessary first 64 "format identification" characters.
	local data = inp:read("*all"):gsub("%c", "")	 --@@ NEW! example: "ux0:pspemu/psp/game/slus00453/eboot.pbp" @@ gsub %c removes the "padding" characters. @@ Reverted from v1.0 back to v0.9 style.
	inp:close()

	--@@if string.sub(data, 67, 67) == "0" then	 -- ux0
	--@@    path_game = string.sub(data, 85, 93)	 -- example: "slus00453"
	--@@elseif string.sub(data, 68, 68) == "0" then	 -- uma0  (memory card #2)
	--@@    path_game = string.sub(data, 86, 94)	 -- example: "slus00453"
	--@@end

	--@@ NEW! The below 15 lines of code simplify the above 5 and supports .iso files now!
	if data:sub(-10):upper() == "/EBOOT.PBP" then
	    path_game = string.sub(data, -19, -11)	 --@@ cuts the "slus00453" out of "ux0:pspemu/psp/game/slus00453/eboot.pbp"
	elseif allow_iso_scan == true
	 and data:sub(-4):upper() == ".ISO"
	 and System.doesFileExist(data) then		 --@@ example: "ux0:pspemu/ISO/Dantes_Inferno.iso"
	    inp = assert(io.open(data), "Failed to open PSP .iso file")
	    inp:seek("set",33651)
	    path_game = inp:read(10)
	    inp:close()
	    if path_game ~= nil then
		path_game = path_game:gsub("-", "")
	    else
		path_game = "-"
	    end
	end
    end
    if path_game and not path_game:match("%W") then	 -- Only return valid path_game that DON'T have NON-alphanumeric characters.
	return path_game:upper()			 -- Example: SLUS00453
    else
	return "-"					 -- "-" debug character allows cleaner code in function OverrideCategory()
    end
end


if cur_quick_dir["config.dat"] then		 --@@ NEW! Faster than System.doesFileExist(cur_dir .. "/config.dat")
    local file_config = System.openFile(cur_dir .. "/config.dat", FREAD)
    local filesize = System.sizeFile(file_config)
    local str = System.readFile(file_config, filesize)
    System.closeFile(file_config)
    
    --@@local getCategory = tonumber(string.sub(str, 1, 1)); if getCategory ~= nil then startCategory = getCategory end
    --@@local getReflections = tonumber(string.sub(str, 2, 2)); if getReflections ~= nil then setReflections = getReflections end
    --@@local getSounds = tonumber(string.sub(str, 3, 3)); if getSounds ~= nil then setSounds = getSounds end
    --@@local getthemeColor = tonumber(string.sub(str, 4, 4)); if getthemeColor ~= nil then themeColor = getthemeColor end
    --@@local getBackground = tonumber(string.sub(str, 5, 5)); if getBackground ~= nil then setBackground = getBackground end
    --@@if not (string.sub(str, 5, 5) ~= "P") then setBackground = 11 end
    --@@if not (string.sub(str, 5, 5) ~= "Q") then setBackground = 12 end
    --@@if not (string.sub(str, 5, 5) ~= "M") then setBackground = 13 end
    --@@local getLanguage = tonumber(string.sub(str, 6, 6)); if getLanguage ~= nil then setLanguage = getLanguage end
    --@@if not (string.sub(str, 6, 6) ~= "C") then setLanguage = 10 end
    --@@local getView = tonumber(string.sub(str, 7, 7)); if getView ~= nil then showView = getView end
    --@@local getHomebrews = tonumber(string.sub(str, 8, 8)); if getHomebrews ~= nil then showHomebrews = getHomebrews end
    --@@local getMusicLoop = tonumber(string.sub(str, 9, 9)); if getMusicLoop ~= nil then musicLoop = getMusicLoop end
    --@@local getSwitch = tonumber(string.sub(str, 10, 10)); if getSwitch ~= nil then setSwitch = getSwitch end
    --@@local getHempCats = tonumber(string.sub(str, 11, 11)); if getHempCats ~= nil then hideEmptyCats = getHempCats end
    --@@local getCButton = tonumber(string.sub(str, 12, 12)); if getCButton ~= nil then dCategoryButton = getCButton end
    --@@local getV5CropTop = tonumber(string.sub(str, 13, 13)); if getV5CropTop ~= nil then View5VitaCropTop = getV5CropTop end
    --@@local getRetroFlow = tonumber(string.sub(str, 14, 14)); if getRetroFlow ~= nil then setRetroFlow = getRetroFlow end
    --@@local getLockView = tonumber(string.sub(str, 15, 15)); if getLockView ~= nil then lockView = getLockView end
    --@@local getTriMenu = tonumber(string.sub(str, 16, 16)); if getTriMenu ~= nil then proTriangleMenu = getTriMenu end

    --@@ NEW! Cleaned up the above code by now using "or" to fix bugged settings.
    startCategory =	 tonumber(string.sub(str, 1, 1)) or startCategory
    setReflections =	 tonumber(string.sub(str, 2, 2)) or setReflections
    setSounds =		 tonumber(string.sub(str, 3, 3)) or setSounds
    themeColor =	 tonumber(string.sub(str, 4, 4)) or themeColor
    setBackground =	 tonumber(string.sub(str, 5, 5)) or setBackground
    setLanguage =	 tonumber(string.sub(str, 6, 6)) or setLanguage
    showView =		 tonumber(string.sub(str, 7, 7)) or showView
    showHomebrews =	 tonumber(string.sub(str, 8, 8)) or showHomebrews
    musicLoop =		 tonumber(string.sub(str, 9, 9)) or musicLoop
    setSwitch =		 tonumber(string.sub(str, 10, 10)) or setSwitch
    hideEmptyCats =	 tonumber(string.sub(str, 11, 11)) or hideEmptyCats
    dCategoryButton =	 tonumber(string.sub(str, 12, 12)) or dCategoryButton
    View5VitaCropTop =	 tonumber(string.sub(str, 13, 13)) or View5VitaCropTop
    setRetroFlow =	 tonumber(string.sub(str, 14, 14)) or setRetroFlow
    lockView =		 tonumber(string.sub(str, 15, 15)) or lockView
    arcadeMerge =	 tonumber(string.sub(str, 16, 16)) or arcadeMerge
else
    write_config()
end
if showView == 5 then
    if setSwitch ~= 1 then	 --@@ NEW! Ribbonless SwitchView has been removed
	showView = 0		 --@@ NEW! (If you wanted to try it, use V1.0.1 and go in SwitchView, then lock view and disable SwitchView)
    else			 --@@ NEW!
	load_SwitchView()	 --@@ NEW!
    end				 --@@ NEW!
end
--@@if dCategoryButton == 1 then
--@@    btnD = Graphics.loadImage("app0:/DATA/d.png")
--@@    btDIsLoaded = true
--@@end
    
showCat = startCategory

-- Custom Backgrounds
function ApplyBackground()
    imgCustomBack = imgBack
    if (setBackground >= 10) and (setBackground < 99) and (System.doesFileExist("app0:/DATA/back_" .. setBackground .. ".png")) then
	imgCustomBack = Graphics.loadImage("app0:/DATA/back_" .. setBackground .. ".png")	 -- default BG's "back_10.png" through "back_12.png"
    elseif (setBackground > 1.5) and (setBackground < 10) and (System.doesFileExist("app0:/DATA/back_0" .. setBackground .. ".png")) then
	imgCustomBack = Graphics.loadImage("app0:/DATA/back_0" .. setBackground .. ".png")	 -- default BG's "back_02.png" through "back_08.png"
    elseif System.doesFileExist("ux0:/data/HexFlow/Background.png") then
	imgCustomBack = Graphics.loadImage("ux0:/data/HexFlow/Background.png")			 -- custom png
    elseif System.doesFileExist("ux0:/data/HexFlow/Background.jpg") then
	imgCustomBack = Graphics.loadImage("ux0:/data/HexFlow/Background.jpg")			 -- custom jpg
    end

    Graphics.setImageFilters(imgCustomBack, FILTER_LINEAR, FILTER_LINEAR)
    Render.useTexture(modBackground, imgCustomBack)
end
ApplyBackground()

-- Custom Music
function play_music()
    if setSounds == 1 then
	if System.doesFileExist(cur_dir .. "/Music.mp3") then
	  sndMusic = Sound.open(cur_dir .. "/Music.mp3")
	elseif System.doesFileExist(cur_dir .. "/Music.ogg") then
	      sndMusic = Sound.open(cur_dir .. "/Music.ogg")
	else
	    return	 -- if no music exists, just closes this function.
	end
	if musicLoop == 1 then
	    Sound.play(sndMusic, true)
	else
	    Sound.play(sndMusic, false)
	end
    end
end
play_music()

function SetThemeColor()
    if themeColor == 1 then
        themeCol = red
    elseif themeColor == 2 then
        themeCol = yellow
    elseif themeColor == 3 then
        themeCol = green
    elseif themeColor == 4 then
        themeCol = lightgrey
    elseif themeColor == 5 then
        themeCol = black
    elseif themeColor == 7 then
        themeCol = orange
    elseif themeColor == 6 then
        themeCol = purple
    elseif themeColor == 8 then
        themeCol = darkpurple
    else
        themeCol = blue -- default blue
    end
end
SetThemeColor()

--@@-- Speed related settings	 --@@ MOVED!
--@@local cpu_speed = 444
--@@System.setBusSpeed(222)
--@@System.setGpuSpeed(222)
--@@System.setGpuXbarSpeed(166)
--@@System.setCpuSpeed(cpu_speed)
--@@
--@@function OneShotPrint(my_func)
--@@	local loadingCacheImg = Graphics.loadImage("app0:/DATA/oneshot_cache_write.png")
--@@	-- Draw loading screen for caching process
--@@	Graphics.termBlend()  -- End main loop blending if still running
--@@	Graphics.initBlend()
--@@	Screen.clear(black)
--@@	Graphics.drawImage(0, 0, loadingCacheImg) --@@in the future, replace "loadingCache" image with a textless version of bg.png and write the text using "old" font from data folder.
--@@	Graphics.drawImage(587, 496, imgCacheIcon)
--@@	Graphics.termBlend()
--@@	Screen.flip()
--@@	Graphics.freeImage(loadingCacheImg)
--@@end

local lang_lines = {}
local lang_default = "PS VITA\nHOMEBREWS\nPSP\nPS1\nALL\nSETTINGS\nLaunch\nDetails\nCategory\nView\nClose\nVersion\nAbout\nStartup Category\nReflection Effect\nSounds\nTheme Color\nCustom Background\nDownload Covers\nReload Covers Database\nLanguage\nON\nOFF\nRed\nYellow\nGreen\nGrey\nBlack\nPurple\nOrange\nBlue\nSelect"
		  .. "Nintendo 64\nSuper Nintendo\nNintendo Entertainment System\nGame Boy Advance\nGame Boy Color\nGame Boy\nSega Genesis/Mega Drive\nSega Master System\nSega Game Gear\nMAME\nAmiga\nTurboGrafx-16\nPC Engine\nHomebrews Category\nStartup scan\nRefresh cache\nCUSTOM\nCover style\nScan\nPlease wait...\nMenu\nDark Purple"
		  .. "Done. Please 'Refresh cache' via the start menu\nCover * found!\nCache has been updated.\nwriting to cache... please don't suspend/power off"
function ChangeLanguage()
    lang_lines = {}
    local lang = "EN.ini"
     -- 0 EN, 1 DE, 2 FR, 3 IT, 4 SP, 5 RU, 6 SW, 7 PT, 8 PL, 9 JA
    if setLanguage == 1 then
	lang = "DE.ini"
    elseif setLanguage == 2 then
	lang = "FR.ini"
    elseif setLanguage == 3 then
	lang = "IT.ini"
    elseif setLanguage == 4 then
	lang = "SP.ini"
    elseif setLanguage == 5 then
	lang = "RU.ini"
    elseif setLanguage == 6 then
	lang = "SW.ini"
    elseif setLanguage == 7 then
	lang = "PT.ini"
    elseif setLanguage == 8 then
	lang = "PL.ini"
    elseif setLanguage == 9 then
	lang = "JA.ini"
--@@    elseif setLanguage == 10 then	 --@@ Removed Chinese temporarily while I figure out why it's not showing up right.
--@@	lang = "CN.ini"
		
    else
        lang = "EN.ini"
    end
    
    if System.doesFileExist("app0:/translations/" .. lang) then
        langfile = "app0:/translations/" .. lang
    else
        --create default EN.ini if language is missing
	handle = System.openFile("ux0:/data/HexFlow/EN.ini", FCREATE)
        System.writeFile(handle, "" .. lang_default, string.len(lang_default))
        System.closeFile(handle)
	langfile = "ux0:/data/HexFlow/EN.ini"
        setLanguage=0
    end

    for line in io.lines(langfile) do
        lang_lines[#lang_lines+1] = line
    end

    if arcadeMerge == 1 then
	fba_text = "Arcade"
    else
	fba_text = "fba_table"
    end

--Set footer button spacing.   btnMargin: 44    btnImgWidth: 20    8px img-text buffer.
    label1ImgX = 900-Font.getTextWidth(fnt20, lang_lines[7])			 --X
    label1X = label1ImgX+btnImgWidth+8						 --Launch
    label2ImgX = label1ImgX-(Font.getTextWidth(fnt20, lang_lines[8])+btnMargin)	 --Tri
    label2X = label2ImgX+btnImgWidth+8						 --Details
    label3ImgX = label2ImgX-(Font.getTextWidth(fnt20, lang_lines[9])+btnMargin)	 --Box
    label3X = label3ImgX+btnImgWidth+8						 --Category
    label4ImgX = label3ImgX-(Font.getTextWidth(fnt20, lang_lines[10])+btnMargin) --O
    label4X = label4ImgX+btnImgWidth+8						 --View

    label1AltImgX = 900-Font.getTextWidth(fnt20, lang_lines[11])			--O
    label1AltX = label1AltImgX+btnImgWidth+8						--Close
    label2AltImgX = label1AltImgX-(Font.getTextWidth(fnt20, lang_lines[32])+btnMargin)	--X
    label2AltX = label2AltImgX+btnImgWidth+8						--Select
    
    toggle1X = nil
end
ChangeLanguage()

function PrintCentered(font, x, y, text, color, size)
    text = text:gsub("\n","")
    local width = Font.getTextWidth(font,text)
    Font.print(font, x - width / 2, y, text, color)
end

function TableConcat(t1, t2)
    for i = 1, #t2 do
        t1[#t1 + 1] = t2[i]
    end
    return t1
end

function FreeMemory()
    if (System.doesFileExist(cur_dir .. "/Music.mp3")
     or System.doesFileExist(cur_dir .. "/Music.ogg"))
     and setSounds == 1 then
        Sound.close(sndMusic)
    end
    Graphics.freeImage(imgCoverTmp)
    Graphics.freeImage(btnX)
    Graphics.freeImage(btnT)
    Graphics.freeImage(btnS)
    Graphics.freeImage(btnO)
    Graphics.freeImage(imgWifi)
    Graphics.freeImage(imgBattery)
    Graphics.freeImage(imgBack)
    Graphics.freeImage(imgBox)
    if SwitchviewAssetsAreLoaded == true then
	SwitchviewAssetsAreLoaded = false
	Graphics.freeImage(imgCart)
	--@@Graphics.freeImage(imgAvatar)	 --@@ new but unused
	--@@Graphics.freeImage(imgCont)		 --@@ new but unused
	--@@Graphics.freeImage(img4Square)	 --@@ new but unused
	Graphics.freeImage(imgFloor2)		 --@@ NEW!
	Graphics.freeImage(btnMenu1)
	Graphics.freeImage(btnMenu2)
	Graphics.freeImage(btnMenu3)
	Graphics.freeImage(btnMenu4)
	Graphics.freeImage(btnMenu5)
	Graphics.freeImage(btnMenu6)
	Graphics.freeImage(btnMenuSel)
    end
end


function toboolean(str)
    local bool = false
    if str == "true" then
        bool = true
    end
    return bool
end

function WriteAppList()
    local file_over = System.openFile(cur_dir .. "/applist.dat", FCREATE)
    System.closeFile(file_over)

    file = io.open(cur_dir .. "/applist.dat", "w")
    for k, v in pairs(files_table) do
--@@local sanitized_apptitle = string.gsub(v.apptitle, "\n", " ")
	file:write(v.name .. "," .. sanitize(v.apptitle) .. "\n")	 --@@ NEW! Function sanitize() is now used instead, saving a local.
    end
    file:close()
end


-- If app in the custom sort doesn't exist, then it won't be found in files_table, 
-- therefore it will be omitted as desired. If an installed app is not present in 
-- the custom sort, then it won't be displayed, working as a "hide" function.
function ReadCustomSort()
    sortTimer = Timer.new()
    local rem_table = {}
    for k, v in pairs(files_table) do
        table.insert(rem_table, v) --@@I'm sure there's a better way to do this.
    end
    if System.doesFileExist(cur_dir .. "/customsort.dat") then
	for line in io.lines(cur_dir .. "/customsort.dat") do
	    if not (line == "" or line == " " or line == "\n") then
	        local app = stringSplit(line, ",")
	        for k, v in pairs(rem_table) do
		    if v.name == app[1] then
		        table.insert(custom_table, v)
			-- By removing it from the original table, 
			-- duplicates in customsort.dat will be ignored.
			table.remove(rem_table, k)
		    end
		end
	    end
	end
    end
    rem_table = {}
    sortTime = Timer.getTime(sortTimer)
    Timer.destroy(sortTimer)
end


function xCatLookup(CatNum)	 -- CatNum = Showcat (for example). Used very often.
    if CatNum == 1 then		 return games_table
    elseif CatNum == 2 then	 return homebrews_table
    elseif CatNum == 3 then	 return psp_table
    elseif CatNum == 4 then	 return psx_table
    elseif CatNum == 5 then	 return custom_table
    else			 return files_table
    end
end

function xTextLookup(CatTextNum)	 --@@ Used to be "xCatTextLookup"
    if CatTextNum == 1 then	 return lang_lines[1] --PS VITA
    elseif CatTextNum == 2 then	 return lang_lines[2] --HOMEBREWS
    elseif CatTextNum == 3 then	 return lang_lines[3] --PSP
    elseif CatTextNum == 4 then	 return lang_lines[4] --PSX
    elseif CatTextNum == 5 then	 return lang_lines[49] --CUSTOM
    else			 return lang_lines[5] --ALL
    end
end

function appt_hotfix(apptype)
    if apptype == 2 then	 return 3
    elseif apptype == 3 then	 return 4
    elseif apptype == 0
    or apptype == 4 then	 return 2
    else			 return apptype		 --@@ vita & retro apptypes.
    end
end

function CoverDirectoryLookup(getCovers)  -- For categoric cover downloads
    if getCovers == 2 then
	return covers_psp
    elseif getCovers == 3 then
	return covers_psx
    else		 -- vita & homebrew (0, 1, and 4)
	return covers_psv
    end
end

--@@ NEW! Resets table entry specifications (app_type and icon_path) based on override.dat
function Respec_Entry(file, pspemu_translate_tmp) --@@, ovrrd_str)
    custom_path, custom_path_id, custom_path_psx = nil, nil, nil
    if file.directory and ovrrd_str then	 --@@ the directory check is only here so the app functions exactly like HEXflow launcher v0.5, it's probably not necessary at all.
	--0 default, 1 vita, 2 psp, 3 psx, 4 homebrew
	if string.match(ovrrd_str, file.name .. "=1") then
	    file.app_type=1
	elseif string.match(ovrrd_str, file.name .. "=2") then
	    file.app_type=2
	elseif string.match(ovrrd_str, file.name .. "=3") then
	    file.app_type=3
	elseif string.match(ovrrd_str, file.name .. "=4") then
	    file.app_type=0
	end
    end

    table.insert(xCatLookup(appt_hotfix(file.app_type)), file)

    custom_path =    CoverDirectoryLookup(file.app_type) .. app_short_title .. ".png"
    custom_path_id = CoverDirectoryLookup(file.app_type) .. file.name .. ".png"

    if custom_path and System.doesFileExist(custom_path) then
	file.icon_path = custom_path --custom cover by app name
    elseif custom_path_id and System.doesFileExist(custom_path_id) then
	file.icon_path = custom_path_id --custom cover by app id
    else
	if System.doesFileExist("ur0:/appmeta/" .. file.name .. "/icon0.png") then
	    file.icon_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"  --app icon
	else
	    file.icon_path = "app0:/DATA/noimg.png" --blank grey
	end
    end
    return file.app_type, file.icon_path
end

function onlcovtable(getCovers)  -- For categoric cover downloads
    if getCovers == 1 then
	return onlineCovers
    elseif getCovers == 2 then
	return onlineCoversPSP
    elseif getCovers == 3 then
	return onlineCoversPSX
    else
	return onlineCovers
    end
end





-- Structure of TSV:
-- {
-- directory:bool, 
-- size:number, 
-- icon:Graphics.FileHandler(int?), 
-- icon_path:string, 
-- apptitle:string, 
-- name:string, 
-- app_type:number (0 homebrew, 1 psvita, 2 psp, 3 psx)
-- }
function CacheTitleTable()
    OneShotPrint() --Basic Loading Screen
    local file_over = System.openFile(cur_dir .. "/apptitlecache.dat", FCREATE)

    --@@ NEW! Clear apptitlecache.dat data. Might be necessary if you delete 2 apps and add 1?
    io.open(cur_dir .. "/apptitlecache.dat","w"):close()

    System.closeFile(file_over)

    file = io.open(cur_dir .. "/apptitlecache.dat", "w")

    for _, v in pairs(files_table) do
	local entry_data = {v.directory, v.size, "-2121791736", v.icon_path, v.apptitle, v.name, v.app_type}
	for key, val in ipairs(entry_data) do
	    file:write(sanitize(val) .. "\t")	
	end
	file:seek("cur", -1)
	file:write("\n")
    end
    file:close()
end

function p_plus(plus_num)			 --@@ NEW! This has been moved here now.
    if setSounds == 1 then
	Sound.play(click, NO_LOOP)
    end
    if bottomMenu == true then
	menuSel = menuSel + 1
	if menuSel > 6 then
	    menuSel = 1
	end
    else
	p = p + plus_num
	if p <= curTotal then
	    GetNameSelected()
	end
	if showView == 5 then
	    if p > master_index+2 then		 --@@ Simplified p>=m+3 into p>m+2
		master_index = p - 3
	    end
	else
	    if p >= master_index then
		master_index = p
	    end
	end
    end
end

function p_minus(minus_num)			 --@@ NEW! This has been moved here now.
    if setSounds == 1 then
	Sound.play(click, NO_LOOP)
    end
    if bottomMenu == true then
	menuSel = menuSel - 1
	if menuSel < 1 then
	    menuSel = 6
	end
    else
	p = p - minus_num
	if p > 0 then
	    GetNameSelected()
	end
--@@	if (showView == 5) then			 -- (1/6) REMOVED - NOT NECESSARY.
--@@	    if (p <= master_index-1) then	 -- (2/6)
--@@	        master_index = p		 -- (3/6)
--@@	    end					 -- (4/6)
--@@	else					 -- (5/6)
	    if (p <= master_index) then
		master_index = p
	    end
--@@	end					 -- (6/6)
    end
end

-- Loads cache if it exists, or generates a new one if it doesn't. @@ Consolidated RestoreTitleTable() into this function.
function LoadAppTitleTables()
    local applistReadTimer = Timer.new()				  --@@ Moved here now.

    files_table = {}
    games_table = {}
    homebrews_table = {}
    psp_table = {}
    psx_table = {}
        recently_played_table = {}
    search_results_table = {}
    favorites_table = {}
    custom_table = {}

    local real_app_list = System.listDirectory(System.currentDirectory()) --@@ Moved here now for cleaner code below.

    local newAppsMsg = ""						  --@@ Moved here now for cleaner code below.

    local cover_dir_psv = switch_generator(covers_psv)
    local cover_dir_psp = switch_generator(covers_psp)
    local cover_dir_psx = switch_generator(covers_psx)

    if cur_quick_dir["apptitlecache.dat"] then				  -- Faster than System.doesFileExist(...)
    --@@local real_app_list = {}
	local quick_app_list = {}
	local cover_path = ""
	local cover_list = {}
	local custom_path = ""
	local custom_path_id = ""
    --@@local newAppsMsg = ""						  --@@ MOVED!

    --@@real_app_list = System.listDirectory(System.currentDirectory())	  --@@ MOVED!
	for k, v in ipairs(real_app_list) do
	    quick_app_list[v.name] = k
	end
	for line in io.lines(cur_dir .. "/apptitlecache.dat") do
	    if not (line == "" or line == " " or line == "\n") then
                -- {directory,size,icon,icon_path,apptitle,name,app_type}
                local app = stringSplit(line, "\t")
                file = {}
                file.directory = toboolean(app[1])
                file.size = tonumber(app[2])
                -- file.icon = tonumber(app[3])
                file.icon = imgCoverTmp
                --file.icon_path = tostring(app[4])			  -- Uses instant cover finder now instead.
                file.apptitle = tostring(app[5])
                file.name = tostring(app[6])
                file.app_type = tonumber(app[7])

		file.launch_type = 0					  --@@ NEW!

		-- START INSTANT COVER FINDER
		cover_path = CoverDirectoryLookup(file.app_type)
		if cover_path == covers_psv then
		    cover_list = cover_dir_psv
		elseif cover_path == covers_psp then
		    cover_list = cover_dir_psp
		elseif cover_path == covers_psx then
		    cover_list = cover_dir_psx
		else
		    error("impossible apptype (" .. file.app_type .. ") on apptitlecache.dat entry " .. file.name .. ":" .. file.apptitle)
		end
		custom_path = file.apptitle .. ".png"			  -- needs sanitization?
		if cover_list[custom_path] then
		    file.icon_path = cover_path .. custom_path
		    goto cover_found
		end
		custom_path_id = file.name .. ".png"
		if cover_list[custom_path_id] then
		    file.icon_path = cover_path .. custom_path_id
		    goto cover_found
		end
		file.icon_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"
		::cover_found::
		-- END INSTANT COVER FINDER

		if quick_app_list[file.name] then
		    if real_app_list[(quick_app_list[file.name])].name == nil then
			-- do nothing - entry is a duplicate
		    elseif file.app_type == 1 then
			table.insert(files_table, file)
			table.insert(games_table, file) 
		    elseif file.app_type == 2 then
			table.insert(files_table, file)
			table.insert(psp_table, file) 
		    elseif file.app_type == 3 then
			table.insert(files_table, file)
			table.insert(psx_table, file)
		    else
			table.insert(files_table, file)
			table.insert(homebrews_table, file)
		    end
		    real_app_list[(quick_app_list[file.name])].name = nil
		else
		    newAppsMsg = newAppsMsg .. "-" .. file.name .. "\n"
		end
	    end		
	end
    end						 --@@ NEW!

    total_apps = #real_app_list
    for i=0, total_apps do
	k = total_apps - i			 -- reversefor k, v in ipairs(real_app_list) do
	local v = real_app_list[k]
	if v and (not v.name or not v.directory) then
	    table.remove(real_app_list, k)
	end
    end
    if #real_app_list > 0 then
	local file_over = System.openFile(cur_dir .. "/overrides.dat", FREAD)
	local filesize = System.sizeFile(file_over)
	ovrrd_str = System.readFile(file_over, filesize)
	System.closeFile(file_over)

	--@@ psx.lua taken from Retroflow 3.4 and completely repurposed
	local file_over = System.openFile("app0:addons/psx.lua", FREAD)
	local filesize = System.sizeFile(file_over)
	psxdb = System.readFile(file_over, filesize)
	System.closeFile(file_over)

	for _, file in pairs(real_app_list) do
	    newAppsMsg = newAppsMsg .. "+" .. file.name .. "\n"
	    local custom_path, custom_path_id, app_type = nil, nil, nil
	    info = System.extractSfo(working_dir .. "/" .. file.name .. "/sce_sys/param.sfo")
	    app_short_title = sanitize(info.short_title)						 --@@ NEW! Stronger sanitizing + Now using Rinnegatamante's short title bugfix.
	    file.launch_type = 0
	    if string.match(file.name, "PCS") and not string.match(file.name, "PCSI") then
		-- PSVita Games
		file.app_type = 1
	    elseif System.doesFileExist(working_dir .. "/" .. file.name .. "/data/boot.bin") and not System.doesFileExist("ux0:pspemu/PSP/GAME/" .. file.name .. "/EBOOT.PBP") then
		-- PSP Games
		pspemu_translate_tmp = readBin(working_dir .. "/" .. file.name .. "/data/boot.bin", false)	 --@@ example: "SLUS00453"
		if pspemu_translate_tmp and pspemu_translate_tmp ~= "-" and string.match(psxdb, pspemu_translate_tmp) then
		    -- PSX
		    file.app_type = 3
		else
		    -- PSP
		    file.app_type = 2
		end
	    elseif System.doesFileExist(working_dir .. "/" .. file.name .. "/data/boot.bin") and System.doesFileExist("ux0:pspemu/PSP/GAME/" .. file.name .. "/EBOOT.PBP") then
		-- PSX Games
		file.app_type = 3
	    else
		-- Homebrews.
		file.app_type=0
	    end
	    -- Respec applies overrides, adds item to table, and sets icon_path. Also used for instant inline overrides.
	    file.app_type, file.icon_path = Respec_Entry(file, pspemu_translate_tmp)

	    --add blank icon to all
	    file.icon = imgCoverTmp
        
	    file.apptitle = app_short_title
	    table.insert(files_table, file)
	end
    end
    table.sort(games_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(homebrews_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(psp_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(psx_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    --@@ MOVED SLIGHTLY LOWER! table.sort(files_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)

    if newAppsMsg ~= "" then
	table.sort(files_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
	CacheTitleTable()
	WriteAppList()

	local file_over = System.openFile(cur_dir .. "/debugfile.dat", FCREATE)
	System.closeFile(file_over)

	file = io.open(cur_dir .. "/debugfile.dat", "w")
	file:write(newAppsMsg)
	file:close()

	System.setMessage(newAppsMsg, false, BUTTON_OK)
    end

    applistReadTime = Timer.getTime(applistReadTimer)		 --@@ Moved here now.
    Timer.destroy(applistReadTimer)				 --@@ Moved here now.
    local retroReadTimer = Timer.new()				 --@@ NEW!
    if setRetroFlow==1 then					 --@@ NEW!
    function xCatLookup(CatNum)	 -- CatNum = Showcat. (or sometimes "GetCovers"). Used very often.
    if CatNum == 1 then      return games_table
    elseif CatNum == 2 then  return homebrews_table
    elseif CatNum == 3 then  return psp_table
    elseif CatNum == 4 then  return psx_table
    elseif CatNum == 5 then  return n64_table
    elseif CatNum == 6 then  return snes_table
    elseif CatNum == 7 then  return nes_table
    elseif CatNum == 8 then  return nds_table		 --@@ NEW!
    elseif CatNum == 9 then  return gba_table
    elseif CatNum == 10 then     return gbc_table
    elseif CatNum == 11 then     return gb_table
    elseif CatNum == 12 then     return dreamcast_table
    elseif CatNum == 13 then     return sega_cd_table
    elseif CatNum == 14 then     return s32x_table
    elseif CatNum == 15 then     return md_table
    elseif CatNum == 16 then     return sms_table
    elseif CatNum == 17 then     return gg_table
    elseif CatNum == 18 then     return tg16_table
    elseif CatNum == 19 then     return tgcd_table
    elseif CatNum == 20 then     return pce_table
    elseif CatNum == 21 then     return pcecd_table
    elseif CatNum == 22 then     return amiga_table
    elseif CatNum == 23 then     return c64_table
    elseif CatNum == 24 then     return wswan_col_table
    elseif CatNum == 25 then     return wswan_table
    elseif CatNum == 26 then     return pico8_table	 --@@ NEW!
    elseif CatNum == 27 then     return msx2_table
    elseif CatNum == 28 then     return msx1_table
    elseif CatNum == 29 then     return zxs_table
    elseif CatNum == 30 then     return atari_7800_table
    elseif CatNum == 31 then     return atari_5200_table
    elseif CatNum == 32 then     return atari_2600_table
    elseif CatNum == 33 then     return atari_lynx_table
    elseif CatNum == 34 then     return colecovision_table
    elseif CatNum == 35 then     return vectrex_table
    elseif CatNum == 36 then     return fba_table
    elseif CatNum == 37 then     return mame_2003_plus_table
    elseif CatNum == 38 then     return mame_2000_table
    elseif CatNum == 39 then     return neogeo_table
    elseif CatNum == 40 then     return ngpc_table
    elseif CatNum == 41 then     return search_results_table
    elseif CatNum == 42 then	 return custom_table
    else             return files_table			 --@@ Also known as table #0
    end
end

function xTextLookup(CatTextNum)
    if CatTextNum == 1 then	  return lang_lines[1] --PS VITA
    elseif CatTextNum == 2 then	  return lang_lines[2] --HOMEBREWS
    elseif CatTextNum == 3 then	  return lang_lines[3] --PSP
    elseif CatTextNum == 4 then	  return lang_lines[4] --PSX
    elseif CatTextNum == 5 then	  return lang_lines[33] --Nintendo 64
    elseif CatTextNum == 6 then	  return lang_lines[34] --Super Nintendo
    elseif CatTextNum == 7 then	  return lang_lines[35] --Nintendo Entertainment System
    elseif CatTextNum == 8 then   return "nds_table"		 --@@ NEW!
    elseif CatTextNum == 9 then	  return lang_lines[36] --Game Boy Advance
    elseif CatTextNum == 10 then  return lang_lines[37] --Game Boy Color
    elseif CatTextNum == 11 then  return lang_lines[38] --Game Boy
    elseif CatTextNum == 12 then  return "dreamcast_table"
    elseif CatTextNum == 13 then  return "sega_cd_table"
    elseif CatTextNum == 14 then  return "s32x_table"
    elseif CatTextNum == 15 then  return lang_lines[39] --Sega Genesis/Mega Drive
    elseif CatTextNum == 16 then  return lang_lines[40] --Sega Master System
    elseif CatTextNum == 17 then  return lang_lines[41] --Sega Game Gear
    elseif CatTextNum == 18 then  return lang_lines[44] --TurboGrafx-16
    elseif CatTextNum == 19 then  return "tgcd_table"
    elseif CatTextNum == 20 then  return lang_lines[44] --PC Engine
    elseif CatTextNum == 21 then  return "pcecd_table"
    elseif CatTextNum == 22 then  return lang_lines[43] --Amiga
    elseif CatTextNum == 23 then  return "c64_table"
    elseif CatTextNum == 24 then  return "wswan_col_table"
    elseif CatTextNum == 25 then  return "wswan_table"
    elseif CatTextNum == 26 then  return "pico8_table"		 --@@ NEW!
    elseif CatTextNum == 27 then  return "msx2_table"
    elseif CatTextNum == 28 then  return "msx1_table"
    elseif CatTextNum == 29 then  return "zxs_table"
    elseif CatTextNum == 30 then  return "atari_7800_table"
    elseif CatTextNum == 31 then  return "atari_5200_table"
    elseif CatTextNum == 32 then  return "atari_2600_table"
    elseif CatTextNum == 33 then  return "atari_lynx_table"
    elseif CatTextNum == 34 then  return "colecovision_table"
    elseif CatTextNum == 35 then  return "vectrex_table"
    elseif CatTextNum == 36 then  return fba_text		 --@@ NEW! Set in ChangeLanguage()
    elseif CatTextNum == 37 then  return "mame_2003_plus_table"
    elseif CatTextNum == 38 then  return "mame_2000_table"
    elseif CatTextNum == 39 then  return "neogeo_table"
    elseif CatTextNum == 40 then  return "ngpc_table"
    elseif CatTextNum == 41 then  return "search_results_table"
    elseif CatTextNum == 42 then  return lang_lines[49] --CUSTOM
    else			  return lang_lines[5] --ALL
    end
end
	load_RetroFlow()					 --@@ NEW!
elseif RetroflowAssetsAreLoaded == false then
    function xCatLookup(CatNum)	 -- CatNum = Showcat (for example). Used very often.
	if CatNum == 1 then		 return games_table
	elseif CatNum == 2 then	 return homebrews_table
	elseif CatNum == 3 then	 return psp_table
	elseif CatNum == 4 then	 return psx_table
	elseif CatNum == 5 then	 return custom_table
	else			 return files_table
	end
    end

    function xTextLookup(CatTextNum)	 --@@ Used to be "xCatTextLookup"
	if CatTextNum == 1 then	 return lang_lines[1] --PS VITA
	elseif CatTextNum == 2 then	 return lang_lines[2] --HOMEBREWS
	elseif CatTextNum == 3 then	 return lang_lines[3] --PSP
	elseif CatTextNum == 4 then	 return lang_lines[4] --PSX
	elseif CatTextNum == 5 then	 return lang_lines[49] --CUSTOM
	else			 return lang_lines[5] --ALL
	end
    end
    end								 --@@ NEW!
    retroReadTime = applistReadTime .. " + " .. Timer.getTime(retroReadTimer) .. " (Retro)"	 --@@ NEW!
    Timer.destroy(retroReadTimer)				 --@@ NEW!

    table.sort(files_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    ovrrd_str = ""
    ReadCustomSort()


    if startCategory == 6 and cur_quick_dir["lastplayedgame.dat"] then	 --@@ NEW! LAST PLAYED GAME
	showCat = 0

	local lastPlayedGameFile = assert(io.open(cur_dir .. "/lastplayedgame.dat", "r"), "Failed to open lastplayedgame.dat")
	local lastPlayedGameCat = tonumber(lastPlayedGameFile:read("*line"))
	local lastPlayedGameID = lastPlayedGameFile:read("*line")
	lastPlayedGameFile:close()

	for i=1,#xCatLookup(lastPlayedGameCat),1 do
	    if xCatLookup(lastPlayedGameCat)[i].name==lastPlayedGameID then
		showCat = lastPlayedGameCat
		p_plus(i - 1)
		break
            end
        end
    end
end

--@@ Sects: [1]=directory, [2]=size, [3]=icon, [4]=icon_path, [5]=apptitle, [6]=name, [7]=app_type
function UpdateCacheSect(app_id, working_sect, new_path)
    if cur_quick_dir["apptitlecache.dat"] then	 --@@ NEW! Faster than System.doesFileExist(cur_dir .. "/apptitlecache.dat")
	local inf = assert(io.open(cur_dir .. "/apptitlecache.dat", "r"), "Failed to open apptitlecache.dat")
	local lines = ""
	while(true) do
	    local line = inf:read("*line")
	    if not line then break end
	    if string.find(line, app_id, 1) then
	        local app = stringSplit(line, "\t")
		app[working_sect] = new_path
		new_line = table.concat(app,"\t")
		lines = lines .. new_line .. "\n"
	    else
	        lines = lines .. line .. "\n"
	    end
	end
	inf:close()
	file = io.open(cur_dir .. "/apptitlecache.dat", "w")
	file:write(lines)
	file:close()
    end
end

function loadImage(img_path)
    imgTmp = Graphics.loadImage(img_path)
end

function getAppSize(dir)
    local size = 0
    local function get_size(dir)
        local d = System.listDirectory(dir) or {}
        for _, v in ipairs(d) do
            if v.directory then
                get_size(dir .. "/" .. v.name)
            else
                size = size + v.size
            end
        end
    end
    get_size(dir)
    return size
end

function GetNameSelected()
    if #xCatLookup(showCat) > 0 then	 --if the currently-shown category isn't empty
	app_short_title = xCatLookup(showCat)[p].apptitle
    else
	app_short_title = "-"
    end
end

function GetInfoSelected()
    appdir = ""
    app_title = "-"
    icon_path = "app0:/DATA/noimg.png"
    pic_path = "app0:/DATA/noimg.png"
    apptype = 0
    app_titleid = "000000000"
    app_version = "00.00"
    psx_serial = "-"

    if #xCatLookup(showCat) > 0 then --if the currently-shown category isn't empty then:
	apptype = xCatLookup(showCat)[p].app_type
	ricon_path = xCatLookup(showCat)[p].icon_path	 --@@ NEW! May seem confusing, but this is unrelated to the standalone variable "icon_path".
        if xCatLookup(showCat)[p].launch_type == 0 then
	    if System.doesFileExist(working_dir .. "/" .. xCatLookup(showCat)[p].name .. "/sce_sys/param.sfo") then
		appdir=working_dir .. "/" .. xCatLookup(showCat)[p].name	 --example: "ux0:app/SLUS00453"
        	info = System.extractSfo(appdir .. "/sce_sys/param.sfo")
        	icon_path = "ur0:/appmeta/" .. xCatLookup(showCat)[p].name .. "/icon0.png"
        	--@@pic_path = "ur0:/appmeta/" .. xCatLookup(showCat)[p].name .. "/pic0.png"
		app_title = xCatLookup(showCat)[p].apptitle	 --@@ NEW!
		app_short_title = tostring(info.short_title)		 --@@ NEW!
		advanced_title = sanitize(app_short_title)
		if sanitize(app_title) ~= advanced_title then
		    advanced_title = "(renamed) " .. advanced_title
		end
		app_titleid = tostring(info.titleid)
		app_version = tostring(info.version)
		if apptype==2 then
		    pic_path = "ux0:data/RetroFlow/BACKGROUNDS/Sony - PlayStation Portable/" .. xCatLookup(showCat)[p].name .. ".png"
		    psx_serial = readBin(appdir .. "/data/boot.bin", true)
		elseif apptype==3 then
		    pic_path = "ux0:data/RetroFlow/BACKGROUNDS/Sony - PlayStation/" .. xCatLookup(showCat)[p].name .. ".png"
		    psx_serial = readBin(appdir .. "/data/boot.bin", true)
		else
		    pic_path = "ux0:data/RetroFlow/BACKGROUNDS/Sony - PlayStation Vita/" .. xCatLookup(showCat)[p].name .. ".png"
		end
		if not System.doesFileExist(pic_path) then
		    pic_path = "ur0:/appmeta/" .. xCatLookup(showCat)[p].name .. "/pic0.png"
		end
	    end
	else
	    if xCatLookup(showCat)[p].directory then
		appdir=working_dir .. "/" .. xCatLookup(showCat)[p].name	 --@@example: "ux0:pspemu/PSP/GAME/"SLUS00453"
	    end
	    icon_path = xSIconLookup(apptype)
	    if apptype == 0 or apptype == 4 then
		pic_path = "ux0:data/RetroFlow/BACKGROUNDS/Sony - PlayStation Vita/"
	    elseif apptype == 2 then
		pic_path = "ux0:data/RetroFlow/BACKGROUNDS/Sony - PlayStation Portable/"
	    elseif apptype == 3 then
		pic_path = "ux0:data/RetroFlow/BACKGROUNDS/Sony - PlayStation/"
	    elseif apptype == 26 then
		pic_path = "ux0:data/RetroFlow/BACKGROUNDS/Lexaloffle Games - Pico-8/"
	    else
		pic_path = xRomDirLookup(apptype):gsub("/ROMS/", "/BACKGROUNDS/")
	    end
	    pic_path = pic_path .. (xCatLookup(showCat)[p].name:match("(.+)%..+$") or xCatLookup(showCat)[p].name) .. ".png"
	    --@@ "(xCatLookup(showCat)[p].name:m... or xCatLookup(showCat)[p].name)" cuts off everything after the last "." like this:   "Donkey-Kong.n64" --> "Donkey-Kong"
	    app_title = xCatLookup(showCat)[p].apptitle
	    app_short_title = app_title
	    advanced_title = "file: " .. sanitize(xCatLookup(showCat)[p].name)
	    if (xCatLookup(showCat)[p].launch_type == 26 and xCatLookup(showCat)[p].name:sub(1, -8) ~= sanitize(app_short_title))
	    or (xCatLookup(showCat)[p].launch_type ~= 26 and (xCatLookup(showCat)[p].name:match("(.+)%..+$") or xCatLookup(showCat)[p].name) ~= sanitize(app_short_title)) then
		advanced_title = "(renamed) " .. advanced_title
	    end
	--@@app_titleid = xCatLookup(showCat)[p].name
	    if app_title:match("%((.+)%)") then		 --@@ input: "Wario Land (USA) (NTSC).gba" ---> output: "(USA) (NTSC)" @@ input: "Wario Land.gba" ---> output: nothing (FAILS THE "IF" STATEMENT)
		app_version = app_title:match("%((.+)%)"):gsub("%) %(", ', ')	 --@@ the gsub takes out midsection parenthesis like this: input: "(USA) (NTSC)" ---> output: (USA, NTSC)
	    end
        end
    end
end

function close_triangle_preview()
    GetNameSelected()
    oldpad = pad			 -- prevents launching next game accidentally when overriding.
    showMenu = 0
    prvRotY = 0
    spin_allowance = 0
    if setBackground > 0.5 then
	Render.useTexture(modBackground, imgCustomBack)
    end
    inPreview = false			 --@@ NEW! Probably a good idea to do this so 3D cover rotation won't glitch up if there's ever an issue with the new drawcover() code.
end

function check_for_out_of_bounds()
    curTotal = #xCatLookup(showCat)
    if curTotal == 0 then
        p = 0
        master_index = p
    end
    if p < 1 then
        p = curTotal
	if showView == 5 then
	    if curTotal > 3 then
		master_index = p - 3
	    else
		master_index = 1
	    end
        elseif curTotal > 0 then
            master_index = p	 -- 0
        end
        startCovers = false
        GetNameSelected()
    elseif p > curTotal then
        p = 1
        master_index = p
        startCovers = false
        GetNameSelected()
    end
end

--@@local rolling_overrides = true		 --@@ rolling_overrides can no longer be disabled.
function OverrideCategory()
    local running = false
    status = System.getMessageState()
    if status ~= RUNNING then
	System.setMessage("Please don't use overrides in this pre-release. They were causing a GPU failure. I'll fix it ASAP.", false, BUTTON_OK)
    end
    if true == true then
	return
    end


    --[1]=VITA, [2]=PSP, [3]=PS1, [4]=HOMEBREWS. (0 is default but it does nothing right now)
    if tmpappcat>0 and System.doesFileExist(cur_dir .. "/overrides.dat") then
	local inf = assert(io.open(cur_dir .. "/overrides.dat", "rw"), "Failed to open overrides.dat")
	local lines = ""
	while(true) do
	    local line = inf:read("*line")
	    if not line then break end
	    if not string.find(line, app_titleid .. "", 1) then
		lines = lines .. line .. "\n"
	    end
	end
	lines = lines .. app_titleid .. "=" .. tmpappcat .. "\n"
	inf:close()
	file = io.open(cur_dir .. "/overrides.dat", "w")
	file:write(lines)
	file:close()

--@@	if rolling_overrides then
	    -- Respec applies overrides, adds item to table, and set icon_path. Also used during the "listDirectory" app scan.
	    xCatLookup(showCat)[p].app_type, xCatLookup(showCat)[p].icon_path = Respec_Entry(xCatLookup(showCat)[p], nil, lines)
	    -- force icon change
	    xCatLookup(showCat)[p].ricon = Graphics.loadImage(xCatLookup(showCat)[p].icon_path)

	    UpdateCacheSect(app_titleid, 7, tmpappcat)
--@@	    UpdateCacheSect(app_titleid, 4, xCatLookup(showCat)[p].icon_path)

	    -- Tidy up: remove game from old table, sort target table.
	    for k, v in pairs(xCatLookup(appt_hotfix(apptype))) do
		if (v.name ~= nil) and (v.name == app_titleid) then
		    table.remove(xCatLookup(appt_hotfix(apptype)), k)
		    break
		end
	    end
	    table.sort(xCatLookup(appt_hotfix(tmpappcat)), function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
	    
--@@	else
--@@	    System.setMessage(lang_lines[55], false, BUTTON_OK)--"Done. Please 'refresh cache' via the start menu."
--@@	end
    end
end

function DownloadCovers()
    local txt = "Downloading covers..."
    local old_txt = txt
    local percent = 0
    local old_percent = 0
    local cvrfound = 0
    
    local app_idx = 1
    local running = false
    status = System.getMessageState()
    
    if Network.isWifiEnabled() then
        if #xCatLookup(getCovers) > 0 then
	    if status ~= RUNNING then
		if scanComplete == false then
		    System.setMessage("Downloading covers...", true)
		    System.setMessageProgMsg(txt)

		    while app_idx <= #xCatLookup(getCovers) do
			if System.getAsyncState() ~= 0 then
			    --@@ new but unused: a low-effort attempt to add 3 new categories of cover download: "All except homebrew", "Vita covers for Homebrew", and "Custom".
			    --@@ might try again once I figure out the annoying RetroFlow GPU crash.
			    --@@if xCatLookup(getCovers)[app_idx].app_type == 1
			    --@@or xCatLookup(getCovers)[app_idx].app_type == 2
			    --@@or xCatLookup(getCovers)[app_idx].app_type == 3
			    --@@or getCovers == 2 then
				Network.downloadFileAsync(onlcovtable(getCovers) .. xCatLookup(getCovers)[app_idx].name .. ".png", "ux0:/data/HexFlow/" .. xCatLookup(getCovers)[app_idx].name .. ".png")
				running = true
			    --@@else
			    --@@app_idx = app_idx + 1
			    --@@end
			end
			if System.getAsyncState() == 1 then
			    Graphics.initBlend()
			    Graphics.termBlend()
			    Screen.flip()
			    running = false
			end
			if running == false then
			    if System.doesFileExist("ux0:/data/HexFlow/" .. xCatLookup(getCovers)[app_idx].name .. ".png") then
				tmpfile = System.openFile("ux0:/data/HexFlow/" .. xCatLookup(getCovers)[app_idx].name .. ".png", FREAD)
				size = System.sizeFile(tmpfile)
				if size < 1024 then
				    System.deleteFile("ux0:/data/HexFlow/" .. xCatLookup(getCovers)[app_idx].name .. ".png")
				else
				    System.rename("ux0:/data/HexFlow/" .. xCatLookup(getCovers)[app_idx].name .. ".png", CoverDirectoryLookup(getCovers) .. xCatLookup(getCovers)[app_idx].name .. ".png")
				    cvrfound = cvrfound + 1
				end
				System.closeFile(tmpfile)

				percent = (app_idx / #xCatLookup(getCovers)) * 100
				txt = "Downloading " .. xTextLookup(getCovers) .. " covers...\nCover " .. xCatLookup(getCovers)[app_idx].name .. "\nFound " .. cvrfound .. " of " .. #xCatLookup(getCovers)

				Graphics.initBlend()
				Graphics.termBlend()
				Screen.flip()
				app_idx = app_idx + 1
			    end
			end

			if txt ~= old_txt then
			    System.setMessageProgMsg(txt)
			    old_txt = txt
			end
			if percent ~= old_percent then
			    System.setMessageProgress(percent)
			    old_percent = percent
			end
		    end
		    if app_idx >= #xCatLookup(getCovers) then
			System.closeMessage()
			scanComplete = true
		    end
		else
		    FreeIcons()
		    FreeMemory()
		    Network.term()
		    dofile("app0:index.lua")
		end
	    end
	end

    else
	if status ~= RUNNING then
	    System.setMessage("Internet Connection Required", false, BUTTON_OK)
	end
		
    end
--@@if System.doesFileExist(cur_dir .. "/apptitlecache.dat") then
--@@    System.deleteFile(cur_dir .. "/apptitlecache.dat")
--@@end
    FreeIcons()
    FreeMemory()
    Network.term()
    dofile("app0:index.lua")
--@@    menuY = 0
--@@    if status ~= RUNNING then
--@@        System.setMessage("Done. Please 'refresh cache' via the start menu.", false, BUTTON_OK)
--@@    end
    gettingCovers = false
end

local function DrawCover(x, y, text, icon, sel, apptype, reflections)	 --@@ NEW! You can now disable reflections. Allows cleaner triangle menu code.
    rot = 0
    extraz = 0
    extrax = 0
    extray = 0
    zoom = 0
    camX = 0
    Graphics.setImageFilters(icon, FILTER_LINEAR, FILTER_LINEAR)
    if inPreview==true then	 --@@ NEW!
	extraz = 0-prevZ	 --@@ NEW!
	rot = prevRot+prvRotY	 --@@ NEW!
    elseif showView == 1 then
        -- flat zoom out view
        space = 1.6
        zoom = 0
        if x > 0.5 then
            extraz = 6
            extrax = 1
	    --@@table.insert(tap_zones, {(x*96)+491, 213, 95, sel}) @@ new but unused
        elseif x < -0.5 then
            extraz = 6
            extrax = -1
	    --@@table.insert(tap_zones, {(x*96)+369, 213, 95, sel}) @@ new but unused
        end
    elseif showView == 2 then
        -- zoomin view
        space = 1.6
        zoom = -1
        extray = -0.6
        if x > 0.5 then
            rot = -1
            extraz = 0
            extrax = 1
        elseif x < -0.5 then
            rot = 1
            extraz = 0
            extrax = -1
        end
    elseif showView == 3 then
        -- left side view
        space = 1.5
        zoom = -0.6
        extray = -0.3
        camX = 1
        if x > 0.5 then
            rot = -0.5
            extraz = 2 + (x / 2)
            extrax = 0.6
        elseif x < -0.5 then
            rot = 0.5
            extraz = 2
            extrax = -10
        end
    elseif showView == 4 then
        -- scroll around
        space = 1
        zoom = 0
        if x > 0.5 then
            extraz = 2 + (x / 1.5)
            extrax = 1
        elseif x < -0.5 then
            extraz = 2 - (x / 1.5)
            extrax = -1
        end
    elseif showView ~= 5 then	 -- NOTE: ~=
        -- default view
        space = 1
        zoom = 0
        if x > 0.5 then
            rot = -1
            extraz = 3
            extrax = 1
        elseif x < -0.5 then
            rot = 1
            extraz = 3
            extrax = -1
        end
    end
    
    Render.setCamera(camX, 0, 0, 0.0, 0.0, 0.0)
    
    if hideBoxes <= 0 then
	if showView == 5 then				 -- SwitchView UI v0.1.2 integration!!!
	    x = x * 200 + 85				 --@@ NEW! View 5 and 6 don't use extraX/Y so the code can be cleaned up by just hard-coding X and Y
	    y = 152					 --@@ NEW!
	    table.insert(tap_zones, {x, y, 192, sel})	 --@@ NEW!
	    if sel==p and not bottomMenu then		 --@@ new sel style.
		--@@Graphics.fillRect(x*200+85-6, x*200+85+198,152-6,152+198,lightblue)
		Graphics.fillRect(x-6, x+198, y-6, y+198,lightblue)	 --@@ NEW!
	    end
	    icon_height = Graphics.getImageHeight(icon)	 --@@ NEW! Replaces View5IconHeightBaseTmp
	    icon_width = Graphics.getImageWidth(icon)	 --@@ NEW!
	    if apptype==1 and View5VitaCropTop==1 and icon_height~=128 then
		vita_header_size = math.ceil(icon_height*31/320)	 -- calculate vita cover's "blue top" proportion (29/320 will work but 31/320 looks better) and use this calculation to dynamicly crop it. @@ Replaces "View5IconHeightModTmp"
		--@@Graphics.drawImageExtended(x*200+85+96, 152+96, icon, 0, View5IconHeightModTmp, Graphics.getImageWidth(icon), View5IconHeightBaseTmp-View5IconHeightModTmp, 0, 192 / Graphics.getImageWidth(icon), 192 / (View5IconHeightBaseTmp-View5IconHeightModTmp))
		Graphics.drawImageExtended(x+96, y+96, icon, 0, vita_header_size, icon_width, icon_height - vita_header_size, 0, 192 / icon_width, 192 / (icon_height-vita_header_size))	 --@@ NEW!
	    else
		--@@Graphics.drawScaleImage(x*200+85, 152, icon, 192 / Graphics.getImageWidth(icon), 192 / View5IconHeightBaseTmp)
		Graphics.drawScaleImage(x, 152, icon, 192 / icon_width, 192 / icon_height) --@@ NEW!
	    end
        elseif apptype==1 then
            -- PSVita Boxes
            if reflections == 1 then
                Render.useTexture(modCover, icon)
                Render.drawModel(modCover, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
                Render.drawModel(modBox, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            else
                Render.useTexture(modCoverNoref, icon)
                Render.drawModel(modCoverNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
                Render.drawModel(modBoxNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            end
        elseif apptype==2 then
            -- PSP Boxes
            if reflections == 1 then
                Render.useTexture(modCoverPSP, icon)
                Render.drawModel(modCoverPSP, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
                Render.drawModel(modBoxPSP, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            else
                Render.useTexture(modCoverPSPNoref, icon)
                Render.drawModel(modCoverPSPNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
                Render.drawModel(modBoxPSPNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            end
        elseif apptype==3 then
            -- PSX Boxes
            if reflections == 1 then
                Render.useTexture(modCoverPSX, icon)
                Render.drawModel(modCoverPSX, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
                Render.drawModel(modBoxPSX, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            else
                Render.useTexture(modCoverPSXNoref, icon)
                Render.drawModel(modCoverPSXNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
                Render.drawModel(modBoxPSXNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            end
	elseif setRetroFlow == 0 then
            -- Homebrew Icon
            if reflections == 1 then
                Render.useTexture(modCoverHbr, icon)
                Render.drawModel(modCoverHbr, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            else
                Render.useTexture(modCoverHbrNoref, icon)
                Render.drawModel(modCoverHbrNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            end
        elseif apptype==5 or apptype==6 then
            if reflections == 1 then
                Render.useTexture(modCoverN64, icon)
                Render.drawModel(modCoverN64, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            else
                Render.useTexture(modCoverN64Noref, icon)
                Render.drawModel(modCoverN64Noref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            end
        elseif apptype==7 or apptype==13 or apptype==18 or apptype==19 or apptype==20 or apptype==21 or apptype==22 or apptype==24 or apptype==25 or apptype==36 or apptype==37 or apptype==38 or apptype==39 or apptype==40 then
            if reflections == 1 then
                Render.useTexture(modCoverNES, icon)
                Render.drawModel(modCoverNES, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            else
                Render.useTexture(modCoverNESNoref, icon)
                Render.drawModel(modCoverNESNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            end
        elseif apptype==8 or apptype==9 or apptype==10 or apptype==11 or apptype==12 then
	    --@@ NEW! Nintendo DS (apptype 8)
            if reflections == 1 then
                Render.useTexture(modCoverGB, icon)
                Render.drawModel(modCoverGB, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            else
                Render.useTexture(modCoverGBNoref, icon)
                Render.drawModel(modCoverGBNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            end
        elseif apptype==14 or apptype==15 or apptype==16 or apptype==17 then
            if reflections == 1 then
                Render.useTexture(modCoverMD, icon)
                Render.drawModel(modCoverMD, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            else
                Render.useTexture(modCoverMDNoref, icon)
                Render.drawModel(modCoverMDNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            end
        elseif apptype==23 or apptype==27 or apptype==28 or apptype==29 then
            if reflections == 1 then
                Render.useTexture(modCoverTAPE, icon)
                Render.drawModel(modCoverTAPE, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            else
                Render.useTexture(modCoverTAPENoref, icon)
                Render.drawModel(modCoverTAPENoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            end
        elseif apptype==30 or apptype==31 or apptype==32 or apptype==34 or apptype==35 then
            if reflections == 1 then
                Render.useTexture(modCoverATARI, icon)
                Render.drawModel(modCoverATARI, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            else
                Render.useTexture(modCoverATARINoref, icon)
                Render.drawModel(modCoverATARINoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            end
        elseif apptype==26 or apptype==33 then
	    --@@ NEW! Pico8 (apptype 26)
            if reflections == 1 then
                Render.useTexture(modCoverLYNX, icon)
                Render.drawModel(modCoverLYNX, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            else
                Render.useTexture(modCoverLYNXNoref, icon)
                Render.drawModel(modCoverLYNXNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            end
        else
            -- Homebrew Icon
            if reflections == 1 then
                Render.useTexture(modCoverHbr, icon)
                Render.drawModel(modCoverHbr, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            else
                Render.useTexture(modCoverHbrNoref, icon)
                Render.drawModel(modCoverHbrNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            end
        end
--@@else
--@@    hideBoxes = hideBoxes - 0.1
    end
end

local FileLoad = {}

function FreeIcons()
    FileLoad = {}			 --@@ NEW!
    Threads.clear()			 --@@ NEW!
    for k, v in pairs(files_table) do	 --@@ Due to a quirk in LuaJIT, clearing the "All" table clears every table.
        --@@FileLoad[v] = nil
        --@@Threads.remove(v)
        if v.ricon then
            Graphics.freeImage(v.ricon)
            v.ricon = nil
        end
    end
--@@    for k, v in pairs(games_table) do
--@@        FileLoad[v] = nil
--@@        Threads.remove(v)
--@@        if v.ricon then
--@@            Graphics.freeImage(v.ricon)
--@@            v.ricon = nil
--@@        end
--@@    end
--@@    for k, v in pairs(psp_table) do
--@@        FileLoad[v] = nil
--@@        Threads.remove(v)
--@@        if v.ricon then
--@@            Graphics.freeImage(v.ricon)
--@@            v.ricon = nil
--@@        end
--@@    end
--@@    for k, v in pairs(psx_table) do
--@@        FileLoad[v] = nil
--@@        Threads.remove(v)
--@@        if v.ricon then
--@@            Graphics.freeImage(v.ricon)
--@@            v.ricon = nil
--@@        end
--@@    end
--@@    for k, v in pairs(homebrews_table) do
--@@        FileLoad[v] = nil
--@@        Threads.remove(v)
--@@        if v.ricon then
--@@            Graphics.freeImage(v.ricon)
--@@            v.ricon = nil
--@@        end
--@@    end
--@@        for k, v in pairs(custom_table) do
--@@        FileLoad[v] = nil
--@@        Threads.remove(v)
--@@        if v.ricon then
--@@            Graphics.freeImage(v.ricon)
--@@            v.ricon = nil
--@@        end
--@@    end
end

function DownloadSingleCover()
    cvrfound = 0
    app_idx = p
    running = false
    status = System.getMessageState()

    local coverspath = ""
    local onlineCoverspath = ""

    if Network.isWifiEnabled() then
	local app_titleid_psx = nil
	if psx_serial and psx_serial ~= "-" then
	    app_titleid_psx = psx_serial
	end
	coverspath = CoverDirectoryLookup(apptype)
	onlineCoverspath = onlcovtable(apptype)
	-- covers_psv:		 ux0:/data/HexFlow/COVERS/PSVITA/
	-- onlineCovers:	 https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/PSVita/
	-- covers_psp:		 ux0:/data/HexFlow/COVERS/PSP/
	-- onlineCoversPSP:	 https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/PSP/
	-- covers_psx:		 ux0:/data/HexFlow/COVERS/PSX/
	-- onlineCoversPSX:	 https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/PS1/

	Network.downloadFile(onlineCoverspath .. (app_titleid_psx or app_titleid) .. ".png", "ux0:/data/HexFlow/" .. app_titleid .. ".png")
	--@@local new_path = coverspath .. (app_titleid_psx or app_titleid) .. ".png"
	local new_path = coverspath .. app_titleid .. ".png"	 --@@ NEW! Removal of covers-by-PSX ID is needed for rolling cache.

	if System.doesFileExist("ux0:/data/HexFlow/" .. app_titleid .. ".png") then
	    tmpfile = System.openFile("ux0:/data/HexFlow/" .. app_titleid .. ".png", FREAD)
	    size = System.sizeFile(tmpfile)
	    if size < 1024 then
		System.deleteFile("ux0:/data/HexFlow/" .. app_titleid .. ".png")
	    else
		System.rename("ux0:/data/HexFlow/" .. app_titleid .. ".png", new_path)
		cvrfound = 1
	    end
	    System.closeFile(tmpfile)
	end

	if cvrfound==1 then
	    xCatLookup(showCat)[app_idx].icon_path = new_path

	    Threads.addTask(xCatLookup(showCat)[app_idx], {
	    Type = "ImageLoad",
	    Path = xCatLookup(showCat)[app_idx].icon_path,
	    Table = xCatLookup(showCat)[app_idx],
	    Index = "ricon"
	    })

	--@@UpdateCacheSect(app_titleid, 4, new_path)
	    if status ~= RUNNING then
		System.setMessage(lang_lines[56]:gsub("*", (app_titleid_psx or app_titleid)) .. "\n" .. lang_lines[57], false, BUTTON_OK) --Cover XXXXXXXXX found!\nCache has been updated.

	    end
	elseif status ~= RUNNING then
	    System.setMessage("Cover not found", false, BUTTON_OK)
	end

    elseif status ~= RUNNING then
	System.setMessage("Internet Connection Required", false, BUTTON_OK)
    end

    gettingCovers = false
end

--@@function RestoreAppTitle()	 --@@ Moved/Integrated into the new triangle menu renamer option
--@@    local running = false
--@@    status = System.getMessageState()
--@@    if status ~= RUNNING then
--@@        if xCatLookup(showCat)[p].apptitle ~= sanitized_title then
--@@            xCatLookup(showCat)[p].apptitle = sanitized_title
--@@            UpdateCacheSect(app_titleid, 5, sanitized_title)
--@@            System.setMessage(lang_lines[57], false, BUTTON_OK) --Cache has been updated.
--@@        else
--@@            System.setMessage("Can't restore, app hasn't been renamed. To do so, please edit ux0:data/HexFlow/apptitlecache.dat\nNote: 'refresh cache' & 'refresh icons' will reset this file.", false, BUTTON_OK)
--@@        end
--@@    end
--@@end

--@@function p_plus(plus_num)	 --@@ MOVED!
--@@    if setSounds == 1 then
--@@	Sound.play(click, NO_LOOP)
--@@    end
--@@    if bottomMenu == true then
--@@	menuSel = menuSel + 1
--@@	if (menuSel>6) then
--@@	    menuSel=1
--@@	end
--@@    else
--@@	p = p + plus_num
--@@	if p <= curTotal then
--@@	    GetNameSelected()
--@@	end
--@@	if (showView == 5) then
--@@	    if (p >= master_index+3) then
--@@		master_index = p - 3
--@@	    end
--@@	else
--@@	    if (p >= master_index) then
--@@		master_index = p
--@@	    end
--@@	end
--@@    end
--@@end

--@@function p_minus(minus_num)	 --@@ MOVED!
--@@    if setSounds == 1 then
--@@	Sound.play(click, NO_LOOP)
--@@    end
--@@    if bottomMenu == true then
--@@	menuSel = menuSel - 1
--@@	if (menuSel<1) then
--@@	    menuSel=6
--@@	end
--@@    else
--@@	p = p - minus_num
--@@	if p > 0 then
--@@	    GetNameSelected()
--@@	end
--@@	if (showView == 5) then
--@@	    if (p <= master_index-1) then
--@@		master_index = p
--@@	    end
--@@	else
--@@	    if (p <= master_index) then
--@@		master_index = p
--@@	    end
--@@	end
--@@    end
--@@end

--@@ NEW! For simpler code in secret feature "superskip"
function first_letter_of_apptitle(target_position)
    local letr = string.sub(xCatLookup(showCat)[target_position].apptitle, 1, 1):lower()
    if letr and (letr >= "a") then
	return letr
    else
	return "1"
    end
end

function Category_Minus()
    FreeIcons()		 --@@ moved here (up slightly) now.
    hideBoxes = 0.5
    p = 1
    master_index = p
    startCovers = false	
	    while true do		 --loop in case hideEmptyCats is enabled.
		if showCat ~= 0 then
		    if showCat==3 and showHomebrews==0 then
			showCat = 1
		    else
			showCat = showCat -1
		    end
		elseif System.doesFileExist(cur_dir .. "/customsort.dat") == true then
		    if setRetroFlow == 1 then
			showCat = 42
		    else
			showCat = 5
		    end
		elseif setRetroFlow == 1 then
		    showCat = 40
		else
		    showCat = 4
		end
		if #xCatLookup(showCat) > 0 or hideEmptyCats == 0 or showCat == 0 then
		    break
		end
	    end
	    GetNameSelected()
	    --@@FreeIcons()		 --@@ MOVED
end

function Category_Plus()
    FreeIcons()		 --@@ moved here (up slightly) now.
    hideBoxes = 0.5
    p = 1
    master_index = p
    startCovers = false
    while true do			 --loop in case hideEmptyCats is enabled.
	showCat = showCat + 1
	if (showCat > 42) or (setRetroFlow == 0 and showCat > 4) then
	    showCat = 0
	    GetNameSelected()
	    break
	elseif showCat==2 and showHomebrews==0 then
	    showCat = 3
	elseif (showCat == 41) or (setRetroFlow == 0 and showCat > 4) then
	    if System.doesFileExist(cur_dir .. "/customsort.dat") then
		showCat = 42
	    else
		showCat = 0
		GetNameSelected()
		break
	    end
	end

	if #xCatLookup(showCat) > 0 or hideEmptyCats == 0 then
	    break
	end
    end
    GetNameSelected()
    --@@FreeIcons()		 --@@ MOVED
end

function execute_switch_bottom_menu()
    if menuSel==1 then
	System.executeUri("wbapp0:")	   --1 News (Internet Browser)
    elseif menuSel==2 then
	System.executeUri("psns:")	   --2 Store
    elseif menuSel==3 then
	System.executeUri("photo:")	   --3 Album
    elseif menuSel==4 then			
	System.executeUri("scecomboplay:") --4 Controls (PS3 Cross-Controller). Note: to launch moonlight it's FreeMemory() + System.launchApp(XYZZ00002) + System.exit()
    elseif menuSel==5 then
	System.executeUri("settings_dlg:") --5 System Settings
    elseif menuSel==6 then
	FreeMemory()			   --6 Exit
	System.exit()
    end
end

-- Loads App list if cache exists, or generates a new one if it doesn't
--@@local applistReadTimer = Timer.new()		 --@@ (1/3) MOVED!
LoadAppTitleTables()
--@@applistReadTime = Timer.getTime(applistReadTimer)	 --@@ (2/3)
--@@Timer.destroy(applistReadTimer)			 --@@ (3/3)

--functionTime = Timer.getTime(functionTimer)
functionTime = Timer.getTime(oneLoopTimer)
--Timer.destroy(functionTimer)

-- Main loop
while true do
    
    -- Threads update
    Threads.update()
    
    if hasTyped == false then	 --@@ NEW!
	-- controller input
	pad = Controls.read()
	mx, my = Controls.readLeftAnalog()

	-- touch input
	x1, y1 = Controls.readTouch()
    end				 --@@ NEW!

    --@@ NEW! You can now tap apps/ribbon buttons in SwitchView!
    if showView == 5 then
	tap_zones = {
	    {240, 378, 78, -1},		 --@@ News
	    {322, 378, 78, -2},		 --@@ Store
	    {404, 378, 78, -3},		 --@@ Album
	    {486, 378, 78, -4},		 --@@ Controls
	    {568, 378, 78, -5},		 --@@ System Settings
	    {650, 378, 78, -6}		 --@@ Exit
	}
    else
	tap_zones = {}
    end
    
    -- Initializing rendering
    Graphics.initBlend()
    Screen.clear(black)
    
    if delayButton > 0 then
        delayButton = delayButton - 0.1
    else
        delayButton = 0
    end

    if hideBoxes > 0 then		 --@@ NEW!
	hideBoxes = hideBoxes - 0.1	 --@@ NEW!
    else				 --@@ NEW!
	hideBoxes = 0			 --@@ NEW!
    end					 --@@ NEW!

    if touchdown > 0 then		 --@@ NEW!
	touchdown = touchdown - 0.01	 --@@ NEW!
    else				 --@@ NEW!
	touchdown = 0			 --@@ NEW!
    end					 --@@ NEW!
    
    -- Graphics
    if setBackground > 0.5 then
        Render.drawModel(modBackground, 0, 0, -5, 0, 0, 0)-- Draw Background as model
    else
        Render.drawModel(modDefaultBackground, 0, 0, -5, 0, 0, 0)-- Draw Background as model
    end
    Graphics.debugPrint(10,70, "prerelease 2.0", white)
    
    Graphics.fillRect(0, 960, 496, 544, themeCol)-- footer bottom
    
    if showMenu == 0 then
        -- MAIN VIEW
        -- Header
        h, m, s = System.getTime()
        Font.print(fnt20, 726, 34, string.format("%02d:%02d", h, m), white)-- Draw time
        life = System.getBatteryPercentage()
        Font.print(fnt20, 830, 34, life .. "%", white)-- Draw battery
        Graphics.drawImage(888, 41, imgBattery)
        Graphics.fillRect(891, 891 + (life / 5.2), 45, 53, white)

        -- Footer buttons and icons. positions set in ChangeLanguage()
	Graphics.drawImage(label1ImgX, 510, btnX)
	Font.print(fnt20, label1X, 508, lang_lines[7], white)--Launch
	Graphics.drawImage(label2ImgX, 510, btnT)
	Font.print(fnt20, label2X, 508, lang_lines[8], white)--Details
	if dCategoryButton == 1 then
	    Graphics.drawImage(label3ImgX, 510, btnD)
	else
	    Graphics.drawImage(label3ImgX, 510, btnS)
	end
	Font.print(fnt20, label3X, 508, lang_lines[9], white)--Category
	if lockView == 0 then
	    Graphics.drawImage(label4ImgX, 510, btnO)
	    Font.print(fnt20, label4X, 508, lang_lines[10], white)--View
	end
	if showView == 2 then
	    floorY = -0.6
	    Font.print(fnt22, 24, 508, app_short_title, white)
	elseif showView == 3 then
	    floorY = -0.3
            Graphics.fillRect(0, 960, 424, 496, black)-- black footer bottom
            PrintCentered(fnt25, 480, 430, app_short_title, white, 25)-- Draw title
	elseif showView == 5 then --@@and setSwitch == 1 then
	    floorY = 100
	    if setReflections==1 then 				   --@@ NEW!
		Graphics.drawScaleImage(0, 298, imgFloor2, 960, 1) --@@ NEW!
	    end							   --@@ NEW!
	    --Graphics.drawLine(21, 940, 489, 489, white)
	    Graphics.drawLine(21, 940, 496, 496, white)
	    Graphics.drawImage(27, 108, imgCart)
	    --@@Graphics.drawImage(51, 502, imgCont)		   --@@ new but unused. Doesn't look right in the thin-style footer bottom.
	    Font.print(fnt23_5, 60, 106, app_short_title:gsub("\n",""), lightblue)	 -- Draw title in SwitchView UI style.
	    Graphics.drawImage(240, 378, btnMenu1)		   -- News
	    Graphics.drawImage(322, 378, btnMenu2)		   -- Store
	    Graphics.drawImage(404, 378, btnMenu3)		   -- Album
	    Graphics.drawImage(486, 378, btnMenu4)		   -- Controls
	    Graphics.drawImage(568, 378, btnMenu5)		   -- System Settings
	    Graphics.drawImage(650, 378, btnMenu6)		   -- Exit
	    if bottomMenu then
		Graphics.drawImage(menuSel*82-82+240-2, 378-2, btnMenuSel)
		PrintCentered(fnt23_5, menuSel*82-82+240+39, 452, lang_lines[menuSel+78], lightblue, 22) -- News/Store/Album/Controls/System Settings/Exit ... This is a really cheap way to put lang lines; Might need upgraded later.
	    end
        else
	    floorY = 0
            Graphics.fillRect(0, 960, 424, 496, black)-- black footer bottom
            PrintCentered(fnt25, 480, 430, app_short_title, white, 25)-- Draw title
        end

	Font.print(fnt22, 32, 34, xTextLookup(showCat), white)--PS VITA/HOMEBREWS/PSP/PSX/CUSTOM/ALL
        if Network.isWifiEnabled() then
            Graphics.drawImage(800, 38, imgWifi)-- wifi icon
        end
        
        -- Draw Covers
        base_x = 0
        
        --GAMES
	-- If the cover 7 tiles away has been loaded, increase render distance.
	if xCatLookup(showCat)[p+7] and xCatLookup(showCat)[p+7].ricon then
	    render_distance = 16
	else
	    render_distance = 8
	end
        for l, file in pairs(xCatLookup(showCat)) do
            if l >= master_index then
                base_x = base_x + space
            end
	    if l > p-render_distance and l < p+render_distance+2 then
                if FileLoad[file] == nil then --add a new check here
                    FileLoad[file] = true
                    Threads.addTask(file, {
                        Type = "ImageLoad",
                        Path = file.icon_path,
                        Table = file,
                        Index = "ricon"
                    })
                end

		--@@DrawCover((targetX + l * space) - (#xCatLookup(showCat) * space + space), -0.6, file.name, file.ricon or file.icon, l, file.app_type)--draw visible covers only
		DrawCover(space*(l-curTotal-1)+targetX, -0.6, file.name, file.ricon or file.icon, l, file.app_type, setReflections)--draw visible covers only

            else
                if FileLoad[file] == true then
                    FileLoad[file] = nil
                    Threads.remove(file)
                end
                if file.ricon then
                    Graphics.freeImage(file.ricon)
                    file.ricon = nil
                end
            end
        end
        if showView ~= 2 and not bottomMenu then
            PrintCentered(fnt20, 480, 462, p .. " of " .. #xCatLookup(showCat), white, 20)-- Draw total items
        end
        
        
        -- Smooth move items horizontally. Stops calculating when within 0.0001 of base_x
        if (targetX < (base_x - 0.0001)) or (targetX > (base_x + 0.0001)) then
            targetX = targetX - ((targetX - base_x) * 0.1)
        else
            targetX = base_x
        end
        
        -- Instantly move to selection
        if startCovers == false then
            targetX = base_x
            startCovers = true
            GetNameSelected()
        end
        
--@@ Saved some "if" statements because floorY is now set in the "Draw title" section.
	if setReflections==1 and showView~=5 then
--@@	if setReflections==1 and not (showView == 5 and setSwitch == 1) then
--@@	    floorY = 0
--@@	    if showView == 2 then
--@@		floorY = -0.6
--@@	    elseif showView == 3 then
--@@		floorY = -0.3
--@@	    end
            --Draw half transparent floor for reflection effect
            Render.drawModel(modFloor, 0, -0.6+floorY, 0, 0, 0, 0)
        end
        
        prevX = 0
        prevZ = 0
        prevRot = 0
        inPreview = false
    elseif showMenu == 1 then
        
        -- PREVIEW
        -- Footer buttons and icons. positions set in ChangeLanguage()
        Graphics.drawImage(label1AltImgX, 510, btnO)
        Font.print(fnt20, label1AltX, 508, lang_lines[11], white)--Close
        Graphics.drawImage(label2AltImgX, 510, btnX)
        Font.print(fnt20, label2AltX, 508, lang_lines[32], white)--Select
        
        Graphics.fillRect(24, 470, 24, 470, darkalpha)
        Render.setCamera(0, 0, 0, 0.0, 0.0, 0.0)
        if inPreview == false then
            if not pcall(loadImage, icon_path) then
                iconTmp = imgCoverTmp
            else
                iconTmp = Graphics.loadImage(icon_path)
            end
            -- set pic0 as background
            if System.doesFileExist(pic_path) and setBackground > 0.5 then
                Graphics.freeImage(backTmp)
                backTmp = Graphics.loadImage(pic_path)
                Graphics.setImageFilters(backTmp, FILTER_LINEAR, FILTER_LINEAR)
                Render.useTexture(modBackground, backTmp)
            else
                Render.useTexture(modBackground, imgCustomBack)
            end
			
			app_size = getAppSize(appdir)/1024/1024
			menuY=0
			tmpappcat=0
            inPreview = true
        end
        
        -- animate cover zoom in
        if prevX < 1.4 then
            prevX = prevX + 0.1
        end
        if prevZ < 1 then
            prevZ = prevZ + 0.06
        end
        if prevRot > -0.6 then
            prevRot = prevRot - 0.04
        end
        
        Graphics.drawImage(50, 50, iconTmp)-- icon
	--Graphics.drawScaleImage(50, 50, iconTmp, 128 / Graphics.getImageWidth(iconTmp), 128 / Graphics.getImageHeight(iconTmp)) --icon, stretched to frame (unused)
        
        --@@txtname = string.sub(app_title, 1, 32) .. "\n" .. string.sub(app_title, 33)
	txtname = string.sub(xCatLookup(showCat)[p].apptitle, 1, 32) .. "\n" .. string.sub(xCatLookup(showCat)[p].apptitle, 33)
        
        -- Set cover image
--@@	if xCatLookup(showCat)[p].ricon ~= nil then
--@@	    Render.useTexture(modCoverNoref, xCatLookup(showCat)[p].ricon)
--@@	    Render.useTexture(modCoverHbrNoref, xCatLookup(showCat)[p].ricon)
--@@	    Render.useTexture(modCoverPSPNoref, xCatLookup(showCat)[p].ricon)
--@@	    Render.useTexture(modCoverPSXNoref, xCatLookup(showCat)[p].ricon)
--@@	else
--@@	    Render.useTexture(modCoverNoref, xCatLookup(showCat)[p].icon)
--@@	    Render.useTexture(modCoverHbrNoref, xCatLookup(showCat)[p].icon)
--@@	    Render.useTexture(modCoverPSPNoref, xCatLookup(showCat)[p].icon)
--@@	    Render.useTexture(modCoverPSXNoref, xCatLookup(showCat)[p].icon)
--@@	end
		
        local tmpapptype=""
		local tmpcatText=""
        -- Draw box
        if apptype==1 then
--@@	    Render.drawModel(modCoverNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
--@@	    Render.drawModel(modBoxNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
	    tmpapptype = "PS Vita Game"
        elseif apptype==2 then
--@@	    Render.drawModel(modCoverPSPNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
--@@	    Render.drawModel(modBoxPSPNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
	    tmpapptype = "PSP Game"
        elseif apptype==3 then
--@@	    Render.drawModel(modCoverPSXNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
--@@	    Render.drawModel(modBoxPSXNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
	    tmpapptype = "PS1 Game"
        else
--@@	    Render.drawModel(modCoverHbrNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
			tmpapptype = "Homebrew"
        end

	--Draw box
	local file = xCatLookup(showCat)[p]	--@@ NEW! So much easier to do it like this (this line of code and the one below it)
	DrawCover(prevX, -1.0, file.name, file.ricon or imgCoverTmp, p, file.app_type, 0)
    
        Font.print(fnt22, 50, 190, txtname, white)-- app name
	if psx_serial and psx_serial ~= "-" then
	    Font.print(fnt22, 50, 240, tmpapptype .. "\nApp ID: " .. app_titleid .. " (" .. psx_serial .. ")\nVersion: " .. app_version .. "\nSize: " .. string.format("%02d", app_size) .. "Mb", white)-- Draw info (PS1)
	else
	    Font.print(fnt22, 50, 240, tmpapptype .. "\nApp ID: " .. app_titleid .. "\nVersion: " .. app_version .. "\nSize: " .. string.format("%02d", app_size) .. "Mb", white)-- Draw info (not PS1)
	end
		
		if tmpappcat==1 then
			tmpcatText = "PS Vita"
		elseif tmpappcat==2 then
			tmpcatText = "PSP"
		elseif tmpappcat==3 then
			tmpcatText = "PS1"
		elseif tmpappcat==4 then
			tmpcatText = "Homebrew"
		else
			tmpcatText = "Default"
		end

		menuItems = 2
		if xCatLookup(showCat)[p].launch_type == 0 then
		    Graphics.fillRect(24, 470, 350 + (menuY * 40), 390 + (menuY * 40), themeCol)-- selection
		    Font.print(fnt22, 50, 352, "Download Cover", white)
		    Font.print(fnt22, 50, 352+40, "Override Category: < " .. tmpcatText .. " >", lightgrey)
		    Font.print(fnt22, 50, 352+80, "Rename", white)

		status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS) and not Controls.check(oldpad, SCE_CTRL_CROSS)) then
                if menuY == 0 then
		    if gettingCovers == false then
                        gettingCovers = true
                        DownloadSingleCover()
                    end
		elseif menuY == 1 then
		    if spin_allowance < 0.1 then
			if (showCat == 0 or showCat == 5) then --@@ and rolling_overrides then
			    spin_allowance = 3
			else
			    OverrideCategory()
			--@@if rolling_overrides then
				check_for_out_of_bounds()
				close_triangle_preview()
			--@@end
			end
		    end
		elseif menuY == 2 then	 --@@ NEW! Renamer option!!!!
		    --@@RestoreAppTitle()
		    local running = false
		    status = Keyboard.getState()
		    if status ~= RUNNING then
			if hasTyped == false then
			    Keyboard.start("Rename. Leave blank to reset title.", sanitize(xCatLookup(showCat)[p].apptitle), 512, TYPE_LATIN, MODE_TEXT)
			    hasTyped = true
			else
			    result_text = sanitize(Keyboard.getInput())
			    Keyboard.clear()
			    hasTyped = false
			    status = System.getMessageState()
			    if ("\"" .. result_text .. "\"") ~= string.format("%q", result_text) then
				--@@ %q format makes the string LUA compatible by 1: adding quotes to the end and 2: sanitizing any LUA-special characters...
				--@@ ...so if the string with added quotes DOESN'T equal the %q format output, it's not gonna go well with cache.
				System.setMessage("invalid title", false, BUTTON_OK)
			    else
			    --@@if string.format("%q", result_text):len() == 0 then
				if result_text:len() == 0 then
				    result_text = sanitize(app_short_title)
				end
				xCatLookup(showCat)[p].apptitle = result_text

				if xCatLookup(showCat)[p].app_type == 1 then
				    table.sort(games_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
				elseif xCatLookup(showCat)[p].app_type == 2 then
				    table.sort(psp_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
				elseif xCatLookup(showCat)[p].app_type == 3 then
				    table.sort(psx_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
				else
				    table.sort(homebrews_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
				end
				table.sort(files_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
				ReadCustomSort()
				targetX = targetX - 0.5

				UpdateCacheSect(app_titleid, 5, result_text)
				GetNameSelected()
				close_triangle_preview()
			    end
			end
                    end
		end
	    elseif (Controls.check(pad, SCE_CTRL_UP)) and not (Controls.check(oldpad, SCE_CTRL_UP)) then
                if menuY > 0 then
                    menuY = menuY - 1
					else
					menuY=menuItems
                end
            elseif (Controls.check(pad, SCE_CTRL_DOWN)) and not (Controls.check(oldpad, SCE_CTRL_DOWN)) then
                if menuY < menuItems then
                    menuY = menuY + 1
					else
					menuY=0
                end
            elseif (Controls.check(pad, SCE_CTRL_LEFT)) and not (Controls.check(oldpad, SCE_CTRL_LEFT)) then
				if menuY==1 then
					if tmpappcat > 0 then
						tmpappcat = tmpappcat - 1
					else
						tmpappcat=4
					end
				end
            elseif (Controls.check(pad, SCE_CTRL_RIGHT)) and not (Controls.check(oldpad, SCE_CTRL_RIGHT)) then
				if menuY==1 then
					if tmpappcat < 4 then
						tmpappcat = tmpappcat + 1
					else
						tmpappcat=0
					end
				end
			end
		end
	end	
    elseif showMenu == 2 then
	--@@if btDIsLoaded ~= true then
	--@@    btnD = Graphics.loadImage("app0:/DATA/d.png")
	--@@    btDIsLoaded = true
	--@@end

	-- Set Setting Menu Tab Spacing. This bit of code is so ugly sorry >.<
	if not toggle1X then
	    if (Font.getTextWidth(fnt22, lang_lines[91] .. ": ")) > 260 then
		toggle1X = (Font.getTextWidth(fnt22, lang_lines[91] .. ": ")) - 260 --Background #9 & View #5
	    elseif (Font.getTextWidth(fnt22, lang_lines[95] .. ": ")) > 260 then
		toggle1X = (Font.getTextWidth(fnt22, lang_lines[95] .. ": ")) - 260 --Pro Triangle Menu
	    else
		toggle1X = 0
	    end
	    if (Font.getTextWidth(fnt22, lang_lines[99] .. ": ")) > 275 then
		toggle2X = (Font.getTextWidth(fnt22, lang_lines[99] .. ": ")) - 275 --Hide Empty Categories
	    else
		toggle2X = 0
	    end
	end
        -- SETTINGS
        -- Footer buttons and icons. label X's are set in function ChangeLanguage()
        Graphics.drawImage(label1AltImgX, 510, btnO)
        Font.print(fnt20, label1AltX, 508, lang_lines[11], white)--Close
        Graphics.drawImage(label2AltImgX, 510, btnX)
        Font.print(fnt20, label2AltX, 508, lang_lines[32], white)--Select
        Graphics.fillRect(60, 900, 24, 488, darkalpha)
        Font.print(fnt22, 84, 34, lang_lines[6], white)--SETTINGS
	if menuY < 5 then
	    Graphics.fillRect(60, 900, 77 + (menuY * 34), 112 + (menuY * 34), themeCol)-- selection
--@@	elseif menuY == 11 then
--@@	    Graphics.fillRect(60 + (280 * menuX), 60 + 280 + (280 * menuX), 77 + (menuY * 34), 112 + (menuY * 34), themeCol)-- selection
	elseif menuX == 0 then
	    Graphics.fillRect(60, 460, 77 + (menuY * 34), 112 + (menuY * 34), themeCol)-- selection
	else
	    Graphics.fillRect(460, 900, 77 + (menuY * 34), 112 + (menuY * 34), themeCol)-- selection
	end
        Graphics.drawLine(60, 900, 70, 70, white)
        Graphics.drawLine(60, 900, 248, 248, white)
        Graphics.drawLine(60, 900, 452, 452, white)
        
        menuItems = 11
        
        Font.print(fnt22, 84, 79, lang_lines[14] .. ": ", white)--Startup Category
        if startCategory == 0 then
            Font.print(fnt22, 84 + 260, 79, lang_lines[5], white)--ALL
        elseif startCategory == 1 then
            Font.print(fnt22, 84 + 260, 79, lang_lines[1], white)--PS VITA
        elseif startCategory == 2 then
            Font.print(fnt22, 84 + 260, 79, lang_lines[2], white)--HOMEBREWS
        elseif startCategory == 3 then
            Font.print(fnt22, 84 + 260, 79, lang_lines[3], white)--PSP
        elseif startCategory == 4 then
            Font.print(fnt22, 84 + 260, 79, lang_lines[4], white)--PSX
        elseif startCategory == 5 then
            Font.print(fnt22, 84 + 260, 79, lang_lines[49], white)--CUSTOM
	elseif startCategory == 6 then				  --@@ NEW!
            Font.print(fnt22, 84 + 260, 79, lang_lines[109], white)--@@ NEW! Return to last played game & category
        end
        
        Font.print(fnt22, 84, 79 + 34,  lang_lines[17] .. ": ", white)--Theme Color
        if themeColor == 1 then
            Font.print(fnt22, 84 + 260, 79 + 34, lang_lines[24], white)--Red
        elseif themeColor == 2 then
            Font.print(fnt22, 84 + 260, 79 + 34, lang_lines[25], white)--Yellow
        elseif themeColor == 3 then
            Font.print(fnt22, 84 + 260, 79 + 34, lang_lines[26], white)--Green
        elseif themeColor == 4 then
            Font.print(fnt22, 84 + 260, 79 + 34, lang_lines[27], white)--Grey
        elseif themeColor == 5 then
            Font.print(fnt22, 84 + 260, 79 + 34, lang_lines[28], white)--Black
        elseif themeColor == 7 then
            Font.print(fnt22, 84 + 260, 79 + 34, lang_lines[30], white)--Orange
        elseif themeColor == 6 then
            Font.print(fnt22, 84 + 260, 79 + 34, lang_lines[29], white)--Purple
        elseif themeColor == 8 then
            Font.print(fnt22, 84 + 260, 79 + 34, lang_lines[54], white)--Dark Purple
        else
            Font.print(fnt22, 84 + 260, 79 + 34, lang_lines[31], white)--Blue
        end

	if scanComplete == false then
	    Font.print(fnt22, 84, 79 + 68, lang_lines[19] .. ":", white)--Download Covers
	    Font.print(fnt22, 84 + 260, 79 + 68, "<  " .. xTextLookup(getCovers) .. "  >", white) --PS VITA/HOMEBREWS/PSP/PSX/CUSTOM/ALL
	else
	    Font.print(fnt22, 84, 79 + 170,  lang_lines[20], white)--Reload Covers Database
	end
        
        Font.print(fnt22, 84, 79 + 102,  lang_lines[18] .. ": ", white)
	if getBGround == 1 then
	    if cur_quick_dir["background.jpg"] or cur_quick_dir["background.png"] then		 --@@ NEW! Faster than System.doesFileExist("ux0:/data/HexFlow/background.jpg") or System.doesFileExist("ux0:/data/HexFlow/Background.png")
		BGroundText = lang_lines[49] --CUSTOM
	    else
		BGroundText = lang_lines[22] --ON
	    end
	elseif getBGround == 2 then
	    BGroundText = lang_lines[65] --Citylights
	elseif getBGround == 3 then
	    BGroundText = lang_lines[66] --Aurora
	elseif getBGround == 4 then
	    BGroundText = lang_lines[76] --Crystal		 --@@ Used to be Wood 1
	elseif getBGround == 5 then
	    BGroundText = lang_lines[67] --Wood			 --@@ Used to be Wood 2
	elseif getBGround == 6 then
	    BGroundText = lang_lines[69] --Dark
	elseif getBGround == 7 then
	    BGroundText = lang_lines[74] --Playstation Pattern	 --@@ Used to be Marble
	elseif getBGround == 8 then
	    BGroundText = lang_lines[71] --Retro
	elseif getBGround == 9 then
	    BGroundText = lang_lines[72] --SwitchView Basic Black
	--@@elseif getBGround == 10 then
	--@@    BGroundText = lang_lines[73] --SwitchView Basic White
	--@@elseif getBGround == 11 then
	--@@    BGroundText = lang_lines[74] --Playstation Pattern 1
	--@@elseif getBGround == 12 then
	--@@    BGroundText = lang_lines[75] --Playstation Pattern 2
	--@@elseif getBGround == 13 then
	--@@    BGroundText = lang_lines[76] --MVPlayer 1
	else
	    BGroundText = lang_lines[23] --OFF
	end
	if (background_brackets == true) and (BGroundText ~= nil) then
	    BGroundText = "<  " .. BGroundText .. "  >"
	    --if setBackground ~= getBGround then	 -- Puts X icon next to unconfirmed background selection. Uncomment these 3 lines to try it. Unused because I didn't like it.
	    --    Graphics.drawImage(Font.getTextWidth(fnt20, BGroundText) + btnMargin + 84 + 260, 5 + 79 + 102, btnX)
	    --end
	end
        Font.print(fnt22, 84 + 260, 79 + 102, BGroundText, white)

        Font.print(fnt22, 84, 79 + 136, lang_lines[21] .. ": ", white)--Language
        if setLanguage == 1 then
            Font.print(fnt22, 84 + 260, 79 + 136, "German", white)
        elseif setLanguage == 2 then
            Font.print(fnt22, 84 + 260, 79 + 136, "French", white)
        elseif setLanguage == 3 then
            Font.print(fnt22, 84 + 260, 79 + 136, "Italian", white)
        elseif setLanguage == 4 then
            Font.print(fnt22, 84 + 260, 79 + 136, "Spanish", white)
        elseif setLanguage == 5 then
            Font.print(fnt22, 84 + 260, 79 + 136, "Russian", white)
        elseif setLanguage == 6 then
            Font.print(fnt22, 84 + 260, 79 + 136, "Swedish", white)
        elseif setLanguage == 7 then
            Font.print(fnt22, 84 + 260, 79 + 136, "Portugese", white)
        elseif setLanguage == 8 then
            Font.print(fnt22, 84 + 260, 79 + 136, "Polish", white)
        elseif setLanguage == 9 then
            Font.print(fnt22, 84 + 260, 79 + 136, "Japanese", white)
        elseif setLanguage == 10 then
            Font.print(fnt22, 84 + 260, 79 + 136, "Chinese", white)
        else
            Font.print(fnt22, 84 + 260, 79 + 136, "English", white)
        end


	Font.print(fnt22, 84, 79 + 170, lang_lines[16] .. ": ", white)--Music & Sounds
        if setSounds == 1 then
            Font.print(fnt22, 84 + 260 + toggle1X, 79 + 170, lang_lines[22], white)--ON
        else
            Font.print(fnt22, 84 + 260 + toggle1X, 79 + 170, lang_lines[23], white)--OFF
        end
        Font.print(fnt22, 484, 79 + 170, lang_lines[96] .. ": ", white)--RetroFlow
        if setRetroFlow == 1 then
            Font.print(fnt22, 484 + toggle2X + 275, 79 + 170, lang_lines[22], white)--ON
        else
            Font.print(fnt22, 484 + toggle2X + 275, 79 + 170, lang_lines[23], white)--OFF
        end

                Font.print(fnt22, 84, 79 + 204, lang_lines[15] .. ": ", white)--Reflection Effect
        if setReflections == 1 then
            Font.print(fnt22, 84 + 260 + toggle1X, 79 + 204, lang_lines[22], white)--ON
        else
            Font.print(fnt22, 84 + 260 + toggle1X, 79 + 204, lang_lines[23], white)--OFF
        end
        Font.print(fnt22, 484, 79 + 204, lang_lines[99] .. ": ", white)--Hide Empty Categories
	if hideEmptyCats == 1 then
            Font.print(fnt22, 484 + toggle2X + 275, 79 + 204, lang_lines[22], white)--ON
        else
            Font.print(fnt22, 484 + toggle2X + 275, 79 + 204, lang_lines[23], white)--OFF
        end
		
        Font.print(fnt22, 84, 79 + 238, lang_lines[46] .. ": ", white)--Show Homebrews
	if showHomebrews == 1 then
            Font.print(fnt22, 84 + 260 + toggle1X, 79 + 238, lang_lines[22], white)--ON
        else
            Font.print(fnt22, 84 + 260 + toggle1X, 79 + 238, lang_lines[23], white)--OFF
        end
	Graphics.drawImage(484, 79 + 238 + 3, btnD)
        Font.print(fnt22, 484+28, 79 + 238, lang_lines[100] .. ": ", white)--* Category Button
	if dCategoryButton == 1 then
            Font.print(fnt22, 484 + toggle2X + 275, 79 + 238, lang_lines[22], white)--ON
        else
            Font.print(fnt22, 484 + toggle2X + 275, 79 + 238, lang_lines[23], white)--OFF
        end

        Font.print(fnt22, 84, 79 + 272, lang_lines[90] .. ": ", white)--Music: Shuffle
        if musicLoop == 1 then
            Font.print(fnt22, 84 + 260 + toggle1X, 79 + 272, lang_lines[22], white)--ON
        else
            Font.print(fnt22, 84 + 260 + toggle1X, 79 + 272, lang_lines[23], white)--OFF
        end
        Font.print(fnt22, 484, 79 + 272, lang_lines[94] .. ": ", white)--Lock Current View (#*)
        if lockView == 1 then
            Font.print(fnt22, 484 + toggle2X + 275, 79 + 272, lang_lines[22], white)--ON
        else
            Font.print(fnt22, 484 + toggle2X + 275, 79 + 272, lang_lines[23], white)--OFF
        end
        
        Font.print(fnt22, 84, 79 + 306, lang_lines[91] .. ": ", white)--Background #9 & View #5
	if setSwitch == 1 then
	    Font.print(fnt22, 84 + 260 + toggle1X, 79 + 306, lang_lines[22], white)--ON
	    Font.print(fnt22, 84, 79 + 340, lang_lines[107] .. ": ", white)--Crop 'Vita' in View #5
	    if View5VitaCropTop == 1 then
		Font.print(fnt22, 84 + 260 + toggle1X, 79 + 340, lang_lines[22], white)--ON
	    else
		Font.print(fnt22, 84 + 260 + toggle1X, 79 + 340, lang_lines[23], white)--OFF
	    end
	else
	    Font.print(fnt22, 84 + 260 + toggle1X, 79 + 306, lang_lines[23], white)--OFF
	    Font.print(fnt22, 84, 79 + 340, lang_lines[107] .. ": ", lightgrey)--Crop 'Vita' in View #5
	    if View5VitaCropTop == 1 then
		Font.print(fnt22, 84 + 260 + toggle1X, 79 + 340, lang_lines[22], lightgrey)--ON
	    else
		Font.print(fnt22, 84 + 260 + toggle1X, 79 + 340, lang_lines[23], lightgrey)--OFF
	    end
	end

        --@@PrintCentered(fnt22, 60+140, 79 + 374, lang_lines[98], white, 22)--Refresh Icons
        --@@PrintCentered(fnt22, 60+140+280, 79 + 374, lang_lines[48], white, 22)--Refresh Cache
        --@@PrintCentered(fnt22, 60+140+560, 79 + 374, lang_lines[13], white, 22)--About

	--@@ NEW! Removed any references to startup scan or cache. Not needed anymore.
        PrintCentered(fnt22, 270, 79 + 374, lang_lines[95], white, 22)--Decrypt Icons
        PrintCentered(fnt22, 690, 79 + 374, lang_lines[13], white, 22)--More Information
        
        status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS) and not Controls.check(oldpad, SCE_CTRL_CROSS)) then
                if menuY == 0 then
                    if startCategory < 6 then	 --@@ used to be 5
                        startCategory = startCategory + 1
                    else
                        startCategory = 0
                    end
                elseif menuY == 1 then
                    if themeColor == 5 then	 -- cheap reorder hack to maintain HEXFlow Launcher 0.5 compatibility.
                        themeColor = 7
                    elseif themeColor == 7 then
                        themeColor = 6
                    elseif themeColor == 6 then
                        themeColor = 8
                    elseif themeColor < 5 then   -- normally "elseif themeColor < 7 then"
                        themeColor = themeColor + 1
                    else
                        themeColor = 0
                    end
                    SetThemeColor()
                elseif menuY == 2 then
                    if gettingCovers == false then
                        gettingCovers = true
                        DownloadCovers()
                    end
                elseif menuY == 3 then
                    if (setBackground == 0) and (getBGround == 0) then	 -- "OFF" becomes "<ON>"
			setBackground, getBGround = 1, 1
			background_brackets = true
		    else
			if (getBGround == 0) or (setBackground == getBGround) then
			    setBackground, getBGround = 0, 0		 -- "<OFF>" (with <>) and everything else (without <>) becomes "OFF"
			else
			    setBackground = getBGround			 -- "<Name of Background>" becomes "Name of Background"
			end
			background_brackets = false
		    end
		    ApplyBackground(setBackground)
                elseif menuY == 4 then
		    if setLanguage < 9 then
                        setLanguage = setLanguage + 1
                    else
                        setLanguage = 0
                    end
		    ChangeLanguage()

                elseif menuY == 5 then
		    if menuX == 0 then
			if setSounds == 1 then
			    setSounds = 0
			    if Sound.isPlaying(sndMusic) then
				Sound.close(sndMusic)
				sndMusic = click--temp
			    end
			else
			    setSounds = 1
			    play_music()
			end
		    else
			if setRetroFlow == 1 then
			    setRetroFlow = 0
			else
			    setRetroFlow = 1
			end
			LoadAppTitleTables()
			check_for_out_of_bounds()
			GetNameSelected()	 -- refresh selected app's name when toggling Retroflow
		    end
                elseif menuY == 6 then
		    if menuX == 0 then
			if setReflections == 1 then
			    setReflections = 0
			else
			    setReflections = 1
			end
		    else
			if hideEmptyCats == 1 then
			    hideEmptyCats = 0
			else
			    hideEmptyCats = 1
			end
		    end
                elseif menuY == 7 then
		    if menuX == 0 then
			if showHomebrews == 1 then
			    showHomebrews = 0
			else
			    showHomebrews = 1
			end
		    else
			if dCategoryButton == 1 then
			    dCategoryButton = 0
			else
			    dCategoryButton = 1
			end
		    end
                elseif menuY == 8 then
		    if menuX == 0 then
                	if musicLoop == 1 then
                            musicLoop = 0
                	else
                	    musicLoop = 1
			end
			if Sound.isPlaying(sndMusic) then
			    Sound.close(sndMusic)
			    sndMusic = click--temp
			end
			play_music()
		    else
			if lockView == 1 then
			    lockView = 0
			else
			    lockView = 1
			end
		    end
                elseif menuY == 9 then
		    if menuX == 0 then
                	if setSwitch == 1 then
			    bottomMenu = false
			    --menuSel = 0
                            setSwitch = 0
			    if SwitchviewAssetsAreLoaded == true then	 --@@ NEW! free the SwitchView Images if possible.
				SwitchviewAssetsAreLoaded = false
				Graphics.freeImage(imgCart)
				--@@Graphics.freeImage(imgAvatar)	 --@@ new but unused
				--@@Graphics.freeImage(imgCont)		 --@@ new but unused
				--@@Graphics.freeImage(img4Square)	 --@@ new but unused
				Graphics.freeImage(imgFloor2)		 --@@ NEW!
				Graphics.freeImage(btnMenu1)
				Graphics.freeImage(btnMenu2)
				Graphics.freeImage(btnMenu3)
				Graphics.freeImage(btnMenu4)
				Graphics.freeImage(btnMenu5)
				Graphics.freeImage(btnMenu6)
				Graphics.freeImage(btnMenuSel)
			    end
			    if showView == 5 then
				showView = 0
			    end
                	else
                	    setSwitch = 1
			end
		    end
                elseif menuY == 10 then
		    if menuX == 0 then
                	if View5VitaCropTop == 1 then
			    View5VitaCropTop = 0
                	else
                	    View5VitaCropTop = 1
			end
		    end
                elseif menuY == 11 then
		    if menuX == 0 then
			--@@ Decrypt Icons @@ Formerly: "Refresh Icons"
			FreeIcons()
			FreeMemory()
			Network.term()
		--@@	if System.doesFileExist(cur_dir .. "/apptitlecache.dat") then
		--@@	    System.deleteFile(cur_dir .. "/apptitlecache.dat")
		--@@	end
			System.launchEboot("app0:/copyicons.bin")
		--@@elseif menuX == 1 then
		--@@	-- Refresh Cache
		--@@	FreeIcons()
		--@@	FreeMemory()
		--@@	Network.term()
		--@@	if System.doesFileExist(cur_dir .. "/apptitlecache.dat") then
		--@@	    System.deleteFile(cur_dir .. "/apptitlecache.dat")
		--@@	end
		--@@	dofile("app0:index.lua")
		    else
			-- More Information / About
			showMenu = 3
			menuY = 0
			menuX = 0
		    end
                end
                
                
		write_config()	 --Save settings
            elseif (Controls.check(pad, SCE_CTRL_UP)) and not (Controls.check(oldpad, SCE_CTRL_UP)) then
		if menuY == 5 then --@@or (menuY == 11 and menuX ~= 2) then -- When moving to start menu rows with LESS columns, round "menuX" DOWN.
		    menuX = 0
                    menuY = menuY - 1
                elseif menuY > 0 then
                    menuY = menuY - 1
		else
		    menuX = 0
		    menuY = menuItems
                end
            elseif (Controls.check(pad, SCE_CTRL_DOWN)) and not (Controls.check(oldpad, SCE_CTRL_DOWN)) then
--@@		if menuY == 10 and menuX == 2 then	 -- When moving to start menu rows with MORE columns, round "menuX" DOWN.
--@@		    menuX = 1
--@@		    menuY = menuY + 1
--@@		elseif menuY < menuItems then
		if menuY < menuItems then
                    menuY = menuY + 1
		else
		    menuX=0				 -- When going from bottom to top of settings, set menuX to 0.
		    menuY=0
                end
            elseif (Controls.check(pad, SCE_CTRL_LEFT)) and not (Controls.check(oldpad, SCE_CTRL_LEFT)) then
		if menuY==2 then --covers download selection -- [1]=PS VITA, [2]=HOMEBREWS, [3]=PSP, [4]=PSX, [5]=CUSTOM, [default]=ALL
		    if getCovers == 3 then
			--if showHomebrews == 1 then
			--    getCovers = 2
			--else
			    getCovers = 1
			--end
		    elseif getCovers > 1 then
			getCovers = getCovers - 1
		    else
			getCovers=4
		    end
		elseif menuY==3 then --Background selection @@ NEW! Minor code cleanup, removed some "less popular" backgrounds
		-- [1]=Custom, [2]=Citylights, [3]=Aurora, [4]=Wood 1, [5]=Wood 2, [6]=Dark, [7]=Marble, [8]=Retro.
		    if getBGround > 0 then
			getBGround = getBGround - 1
		    elseif setSwitch == 1 then
			getBGround = 9
		    else
			getBGround = 8
		    end
		    background_brackets = true
--@@		elseif menuY == 11 then
--@@		    if menuX > 0 then
--@@			menuX = menuX - 1
--@@		    else
--@@			menuX=2
--@@		    end
		elseif menuY > 4 then
		    if menuX == 0 then
			menuX = 1
		    else
			menuX = 0
		    end
		end
            elseif (Controls.check(pad, SCE_CTRL_RIGHT)) and not (Controls.check(oldpad, SCE_CTRL_RIGHT)) then
		if menuY==2 then --covers download selection -- [1]=PS VITA, [2]=HOMEBREWS, [3]=PSP, [4]=PSX, [5]=CUSTOM, [default]=ALL
		    if getCovers == 1 then
			--if showHomebrews == 1 then
			--    getCovers = 2
			--else
			    getCovers = 3
			--end
		    elseif getCovers < 4 then
			getCovers = getCovers + 1
		    else
			getCovers=1
		    end
		elseif menuY==3 then --Background selection @@ NEW! Minor code cleanup, removed some "less popular" backgrounds
		    -- [1]=Custom, [2]=Citylights, [3]=Aurora, [4]=Wood 1, [5]=Wood 2, [6]=Dark, [7]=Marble, [8]=Retro.
		    if getBGround == 8 and setSwitch == 1 then
			getBGround = 9
		    elseif getBGround < 8 then
			getBGround = getBGround + 1
		    else
			getBGround = 0
		    end
		    background_brackets = true
--@@		elseif menuY == 11 then
--@@		    if menuX > 1 then
--@@			menuX = 0
--@@		    else
--@@			menuX = menuX + 1
--@@		    end
		elseif menuY > 4 then
		    if menuX == 0 then
			menuX = 1
		    else
			menuX = 0
		    end
		end
	    end --End of Control Section
	end
    elseif showMenu == 3 then
        
        -- ABOUT
        -- Footer buttons and icons. label X's are set in ChangeLanguage()
        Graphics.drawImage(label1AltImgX, 510, btnO)
        Font.print(fnt20, label1AltX, 508, lang_lines[11], white)--Close
        
        Graphics.fillRect(30, 930, 24, 496, darkalpha)-- bg
        
        Font.print(fnt20, 54, 42, "HexLauncher Custom - ver." .. appversion .. " by BlackSheepBoy69\nRevamp mod for VitaHEX's HexFlow Launcher 0.5\nSupport the original creator on patreon.com/vitahex", white)-- Draw info
        Font.print(fnt15, 690, 42, "Sort time: ".. sortTime .. " ms.\nRead time: ".. applistReadTime .. " ms.\nFunction Load time: ".. functionTime .. " ms.\nOne Loop time: ".. oneLoopTime .. " ms.", white)
        Graphics.drawLine(30, 930, 124, 124, white)
        Graphics.drawLine(30, 930, 364, 364, white)
        Font.print(fnt20, 54, 132, "Custom Covers\nPlace your custom covers in 'ux0:/data/HexFlow/COVERS/PSVITA' or '/PSP' or '/PS1'\nCover images must be in png format and file name must match the App ID or the App Name"
            .. "\n\nCustom Backgrounds & Music\nIn 'ux0:/data/HexFlow/', place your image - 'background.png' or 'background.jpg'\n(1280x720 max) and song - 'music.ogg' or 'music.mp3' (mp3 not recommended)"
            .. "\n\nCustom Category\nTake the file 'ux0:/data/HexFlow/applist.dat' and rename it to customsort.dat then\nrearrange the titles how you like. It will spawn in a new category ('Custom')"
            .. "\n\nOriginal app by VitaHEX. OG code by Sakis RG. Lua Player Plus by Rinnegatamante."
            .. "\nSpecial Thanks: VitaHEX and everyone who worked on HexFlow Launcher 0.5 which this"
            .. "\nis based on. jimbob4000 and everyone who worked on RetroFlow Launcher 3.4, from whom"
            .. "\na lot of inspiration and a little code was taken. Google Translate, and one or more coders"
            .. "\nwho helped in HexLauncher Custom who wish to remain anonymous", white)-- Draw info
    
    end
    
    -- Terminating rendering phase
    Graphics.termBlend()
    if showMenu == 1 then
        --Left Analog rotate preview box
	if spin_allowance > 0 then
	    if (prvRotY > 1.70) and (prvRotY < 2) then
		prvRotY = -1.3	 --never show the back of the cover lol
		OverrideCategory()
		GetInfoSelected()
	    else
		prvRotY=prvRotY+0.1
		spin_allowance = spin_allowance - 0.1
	    end
	elseif mx < 64 then
	    if prvRotY>-0.5 then
		prvRotY=prvRotY-0.02
	    end
        elseif mx > 180 then
	    if prvRotY<0.6 then
		prvRotY=prvRotY+0.02
	    end
        end
    end
    --Controls Start
    if showMenu == 0 then
        --Navigation Left Analog --@@ NEW! Redesigned for vertical movement/bottom menu access
	tmp_move = 0
	if delayButton < 0.5 then
	    if mx < 64 then
	    --@@bottomMenu = false
		delayButton = 1
		tmp_move = 0 - 1
	    elseif mx > 180 then
	    --@@bottomMenu = false
		delayButton = 1
		tmp_move = tmp_move + 1
	    end
	    if my > 180 and showView == 6 then
		delayButton = 1
		tmp_move = tmp_move + 6
	    elseif my > 250 and showView == 5 and setSwitch == 1 and bottomMenu == false then
		delayButton = 1
		bottomMenu = true
	    elseif my < 64 then
		if showView == 6 then
		    delayButton = 1
		    tmp_move = tmp_move - 6
		elseif bottomMenu == true then
		    delayButton = 1
		    bottomMenu = false
		end
	    end
	    if tmp_move < 0 then
		p_minus(-tmp_move)
	    elseif tmp_move > 0 then
		p_plus(tmp_move)
	    elseif delayButton == 1 then
		Sound.play(click, NO_LOOP)
	    end
	end
        
        -- Navigation Buttons
        if (Controls.check(pad, SCE_CTRL_CROSS) and not Controls.check(oldpad, SCE_CTRL_CROSS)) then
	    if bottomMenu then
		execute_switch_bottom_menu()
	    elseif gettingCovers == false and app_short_title~="-" then
                FreeMemory()
		local file = xCatLookup(showCat)[p]	 --@@ NEW! Just allows cleaner code.
		local launch_mode = file.launch_type	 --@@ 0 real apps, 1 UNUSED (PS Mobile?), 2 PSP/PS1, 3 PS1 Retroarch, 4 UNUSED, 5 N64, 6 SNES, 7 NES...
		local apptype = file.app_type
		local Working_Launch_ID = file.name	 -- Example: VITASHELL. This hotfix seems to 99% stop the "please close HexLauncher Custom" errors.

		if launch_mode == 0 then
		-- for category LAST PLAYED GAME
		    if startCategory == 6 then
			local lastPlayedGameText = showCat .. "\n" .. Working_Launch_ID
			local file_over = System.openFile(cur_dir .. "/lastplayedgame.dat", FCREATE)	--@@ open file or create if it doesn't exist.
			io.open(cur_dir .. "/lastplayedgame.dat","w"):close()				--@@ clear file data incase new data is shorter.
			System.writeFile(file_over, lastPlayedGameText, lastPlayedGameText:len())
			System.closeFile(file_over)
		    end

		    System.launchApp(Working_Launch_ID)
		    System.exit()
		else
		    romfile = xRomDirLookup(launch_mode) .. "/" .. file.name		 --@@ example: "ux0:/data/RetroFlow/ROMS/Nintendo - Game Boy/batman.gb"

		    if apptype and xRomDirLookup(launch_mode) then
			if launch_mode == 3 then	 --@@ PS1
			    launch_retroarch(romfile, "app0:/pcsx_rearmed_libretro.self")
			elseif launch_mode == 5 then	 --@@ N64
			    launch_DaedalusX64(romfile)
			elseif launch_mode == 6 then	 --@@ SNES
			    launch_retroarch(romfile, "app0:/snes9x2005_libretro.self")
			elseif launch_mode == 7 then	 --@@ NES
			    launch_retroarch(romfile, "app0:/quicknes_libretro.self")
			elseif launch_mode == 8 then	 --@@ NDS
			    launch_NooDS(romfile)
			elseif launch_mode == 9 then	 --@@ GBA
			    launch_retroarch(romfile, "app0:/gpsp_libretro.self")
			elseif launch_mode == 10 then	 --@@ GBC
			    launch_retroarch(romfile, "app0:/gambatte_libretro.self")
			elseif launch_mode == 11 then	 --@@ GB
			    launch_retroarch(romfile, "app0:/gambatte_libretro.self")
			elseif launch_mode == 12 then	 --@@ DREAMCAST
			    launch_Flycast(romfile)
			elseif launch_mode == 13 then	 --@@ SEGA_CD
			    launch_retroarch(romfile, "app0:/genesis_plus_gx_libretro.self")
			elseif launch_mode == 14 then	 --@@ S32X
			    launch_retroarch(romfile, "app0:/picodrive_libretro.self")
			elseif launch_mode == 15 then	 --@@ MD
			    launch_retroarch(romfile, "app0:/genesis_plus_gx_libretro.self")
			elseif launch_mode == 16 then	 --@@ SMS
			    launch_retroarch(romfile, "app0:/smsplus_libretro.self")
			elseif launch_mode == 17 then	 --@@ GG
			    launch_retroarch(romfile, "app0:/smsplus_libretro.self")
			elseif launch_mode == 18 then	 --@@ TG16
			    launch_retroarch(romfile, "app0:/mednafen_pce_fast_libretro.self")
			elseif launch_mode == 19 then	 --@@ TGCD
			    launch_retroarch(romfile, "app0:/mednafen_pce_fast_libretro.self")
			elseif launch_mode == 20 then	 --@@ PCE
			    launch_retroarch(romfile, "app0:/mednafen_pce_fast_libretro.self")
			elseif launch_mode == 21 then	 --@@ PCECD
			    launch_retroarch(romfile, "app0:/mednafen_pce_fast_libretro.self")
			elseif launch_mode == 22 then	 --@@ AMIGA
			    launch_retroarch(romfile, "app0:/puae_libretro.self")
			elseif launch_mode == 23 then	 --@@ C64
			    launch_retroarch(romfile, "app0:/vice_x64_libretro.self")
			elseif launch_mode == 24 then	 --@@ WSCAN_COL
			    launch_retroarch(romfile, "app0:/mednafen_wswan_libretro.self")
			elseif launch_mode == 25 then	 --@@ WSWAN
			    launch_retroarch(romfile, "app0:/mednafen_wswan_libretro.self")
			elseif launch_mode == 26 then	 --@@ PICO8
			    launch_Fake08(romfile)
			elseif launch_mode == 27 then	 --@@ MSX2
			    launch_retroarch(romfile, "app0:/fmsx_libretro.self")
			elseif launch_mode == 28 then	 --@@ MSX1
			    launch_retroarch(romfile, "app0:/fmsx_libretro.self")
			elseif launch_mode == 29 then	 --@@ ZXS
			    launch_retroarch(romfile, "app0:/fuse_libretro.self")	 --@@ NOTE: FUSE NOT FMSX
			elseif launch_mode == 30 then	 --@@ ATARI_7800
			    launch_retroarch(romfile, "app0:/prosystem_libretro.self")
			elseif launch_mode == 31 then	 --@@ ATARI_5200
			    launch_retroarch(romfile, "app0:/atari800_libretro.self")
			elseif launch_mode == 32 then	 --@@ ATARI_2600
			    launch_retroarch(romfile, "app0:/stella2014_libretro.self")
			elseif launch_mode == 33 then	 --@@ ATARI_LYNX
			    launch_retroarch(romfile, "app0:/handy_libretro.self")
			elseif launch_mode == 34 then	 --@@ COLECOVISION
			    launch_retroarch(romfile, "app0:/bluemsx_libretro.self")
			elseif launch_mode == 35 then	 --@@ VECTREX
			    launch_retroarch(romfile, "app0:/vecx_libretro.self")
			elseif launch_mode == 36 then	 --@@ FBA
			    launch_retroarch(romfile, "app0:/fbalpha2012_libretro.self")
			elseif launch_mode == 37 then	 --@@ MAME_2003_PLUS
			    launch_retroarch(romfile, "app0:/mame2003_plus_libretro.self")
			elseif launch_mode == 38 then	 --@@ MAME_2000
			    launch_retroarch(romfile, "app0:/mame2000_libretro.self")
			elseif launch_mode == 39 then	 --@@ NEOGEO
			    launch_retroarch(romfile, "app0:/fbalpha2012_neogeo_libretro.self")
			elseif launch_mode == 40 then	 --@@ NGPC
			    launch_retroarch(romfile, "app0:/mednafen_ngp_libretro.self")
			end
		    else
			status = System.getMessageState()
			if status ~= RUNNING then
			    System.setMessage("Entry either has no .app_type or invalid .app_type\nTry refreshing cache?", false, BUTTON_OK)
			end
		    end
		end
            end
        elseif (Controls.check(pad, SCE_CTRL_TRIANGLE) and not Controls.check(oldpad, SCE_CTRL_TRIANGLE)) then
            if showMenu == 0 and app_short_title~="-" then
		prvRotY = 0
		GetInfoSelected()	 -- Full info scan is only here now.
                showMenu = 1
            end
        elseif (Controls.check(pad, SCE_CTRL_START) and not Controls.check(oldpad, SCE_CTRL_START)) then
            if showMenu == 0 then
		getBGround = setBackground
		background_brackets = true
                showMenu = 2
            end
	elseif (dCategoryButton == 0 and Controls.check(pad, SCE_CTRL_SQUARE) and not Controls.check(oldpad, SCE_CTRL_SQUARE))
	or     (dCategoryButton == 1 and Controls.check(pad, SCE_CTRL_DOWN) and not Controls.check(oldpad, SCE_CTRL_DOWN)) then
	    Category_Plus()
	elseif (dCategoryButton == 1 and Controls.check(pad, SCE_CTRL_UP) and not Controls.check(oldpad, SCE_CTRL_UP)) then
	    Category_Minus()
        elseif (Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldpad, SCE_CTRL_CIRCLE))
	and (lockView == 0) then
            -- VIEW
	    if showView == 4 and setSwitch == 0 then
		showView = 0
	    elseif showView < 5 then
                showView = showView + 1
		if showView == 5 then
		    if (curTotal > 4) and (p > curTotal - 3) then	 --@@ NEW!
			master_index = curTotal - 3			 --@@ NEW!
		    end							 --@@ NEW!
		    if SwitchviewAssetsAreLoaded ~= true then
			load_SwitchView()				 --@@ NEW!
		    end
		end
            else
		master_index = p	 -- Makes it not act weird when leaving switch view.
		bottomMenu = false	 -- Exit the switch view bottom menu...
		menuSel = 1		 -- ... and reset your position in it.
                showView = 0
            end
            menuY = 0
            startCovers = false
	    write_config()	 --Save settings
        elseif (Controls.check(pad, SCE_CTRL_LEFT)) and not (Controls.check(oldpad, SCE_CTRL_LEFT)) then
	    p_minus(1)
        elseif (Controls.check(pad, SCE_CTRL_RIGHT)) and not (Controls.check(oldpad, SCE_CTRL_RIGHT)) then
	    p_plus(1)

        elseif (Controls.check(pad, SCE_CTRL_LTRIGGER)) and not (Controls.check(oldpad, SCE_CTRL_LTRIGGER)) then
	    bottomMenu = false
	    if (Controls.check(pad, SCE_CTRL_SELECT)) and p~=0 and p~=1 then --@@and superSkip == 1 then @@ Hold select + press L to move left by alphabet.
		for i=0, #xCatLookup(showCat) do	 -- the loop.
		    local v = #xCatLookup(showCat) - i	 -- go from the back.
		    if v == 1 then			 -- If you ran out of stuff to check...
			p_minus(p - 1)			 -- ... then move to position 1...
			break				 -- ... and exit the loop.
		    elseif (p > v)
		    and (first_letter_of_apptitle(v) < first_letter_of_apptitle(p))	    --@@ if target's letter is EARLIER in the alphabet...
		    and (first_letter_of_apptitle(v) ~= first_letter_of_apptitle(v-1)) then --@@ ... and target is the FIRST of a kind of that letter...
			p_minus(p - v)							    --@@ ... then jump to target.
			break
		    end
		end
	    else
		p_minus(5)
	    end
        elseif (Controls.check(pad, SCE_CTRL_RTRIGGER)) and not (Controls.check(oldpad, SCE_CTRL_RTRIGGER)) then
	    bottomMenu = false
	    if (Controls.check(pad, SCE_CTRL_SELECT)) and p ~= #xCatLookup(showCat) then --@@ and superSkip == 1 then	 -- Hold select + press R to move right by alphabet.
		for i=1, #xCatLookup(showCat) do	 --the loop.
		    if i == #xCatLookup(showCat) then	 -- If you ran out of stuff to check...
			p_plus(i - p)			 -- ... then move to position max...
			break				 -- ... and exit the loop.
		    elseif (p < i)
		    and (first_letter_of_apptitle(i) > first_letter_of_apptitle(p)) then
			p_plus(i - p)			 -- Jump to a target with LATER-in-alphabet letter.
			break
		    end
		end
	    else
		p_plus(5)
	    end
	elseif (Controls.check(pad,SCE_CTRL_UP)) and not (Controls.check(oldpad,SCE_CTRL_UP))
	 and showView == 5 and bottomMenu == true then
	    bottomMenu = false
	    if setSounds == 1 then
		Sound.play(click, NO_LOOP)
	    end
	elseif (Controls.check(pad,SCE_CTRL_DOWN)) and not (Controls.check(oldpad,SCE_CTRL_DOWN))
	 and showView == 5 and bottomMenu == false then
	    bottomMenu = true
	    if setSounds == 1 then
		Sound.play(click, NO_LOOP)
	    end
        end
        
        -- Touch Input
        if x1 ~= nil then
            if xstart == nil then
		touchdown = 1 			 --@@ restored from v0.9
                xstart = x1

		--@@ NEW! You can now tap apps/ribbon buttons in SwitchView.
		for k, v in pairs(tap_zones) do
		    if (x1 > v[1]) and (x1 < v[1] + v[3]) and (y1 > v[2]) and (y1 < v[2] + v[3]) then
			tap_target = v[4]	 --@@ The above line will only make sense if you look at a tap zone's data.
			break
		    end
		end
            end
            if showView == 1 then
		-- flat zoom out view - pan camera 1/487 p per pixel moved.
	        targetX = targetX + ((x1 - xstart) / 487)
	    elseif (showView == 2) or (showView == 3) then
		-- zoomin view & left side view - pan camera 1/1000 p per pixel moved.
	        targetX = targetX + ((x1 - xstart) / 1000)
	    elseif showView == 5 then
		-- SwitchView - pan camera 1/1840 p per pixel moved with gentle bump back at ends.
		if targetX + ((x1 - (xstart)) / 1840) > curTotal + 0.2 then
		    targetX = curTotal + 0.2								 -- 0.2 above max border. Kept in bounds by master_index.
		elseif curTotal <= 3 and targetX + ((x1 - xstart) / 1840) < curTotal - 0.2 then
		    targetX = curTotal - 0.2								 -- 0.2 below minimum border.
		elseif curTotal > 3 and targetX + ((x1 - xstart) / 1840) < 3.8 then
		    targetX = 3.8									 -- 0.2 below special fixed minimum border.
		else
		    targetX = targetX + ((x1 - xstart) / 1840)
		end
	    else
		-- all other views - pan camera 1/700 p per pixel moved.
	        targetX = targetX + ((x1 - xstart) / 700)
	    end
	    if x1 > xstart + 60 then
		if master_index > 1 then
		    master_index = master_index - 1
		end
                xstart = x1				 --refresh tracking start point
                p = p - 1
                if p > 0 then
                    GetNameSelected()
                end
		bottomMenu = false
		touchdown = 0				 --@@ NEW!
	    elseif x1 < xstart - 60 then
                xstart = x1				 --refresh tracking start point
                p = p + 1
		if showView ~= 5 or master_index < curTotal - 3 then
		    master_index = master_index + 1
		end
                if p <= curTotal then
                    GetNameSelected()
                end
		bottomMenu = false
		touchdown = 0				 --@@ NEW!
            end
	elseif xstart ~= nil then
	    --@@ NEW! You can now tap apps/ribbon buttons in SwitchView.
	    --@@ Check if where you released the tap is the same as where you started... then move there.
	    if touchdown~=0 then --and tap_target~=0 then
		for k, v in pairs(tap_zones) do
		    if  (x1_old > v[1]) and (x1_old < v[1] + v[3]) and (y1_old > v[2]) and (y1_old < v[2] + v[3]) and (tap_target == v[4]) then
			bottomMenu = false
			if tap_target < 0 then
			    bottomMenu = true
			    if setSounds ~= 0 then
				Sound.play(click, NO_LOOP)
			    end
			    menuSel = -tap_target
			elseif tap_target > p then
			    p_plus(tap_target - p)
			elseif tap_target < p then
			    p_minus(p - tap_target)
			end
			break
		    end
		end
	    end
	    touchdown = 0			  --@@ restored from v0.9
	    if showView == 5 and master_index > curTotal - 3 then
		if curTotal > 3 then
		    master_index = curTotal - 3
		else
		    master_index = 1
		end
	    end	
	    xstart = nil
        end
    -- End Touch
    elseif showMenu > 0 then
        if (Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldpad, SCE_CTRL_CIRCLE))
	 and not hasTyped then --@@ NEW! Only read controls while keyboard is not displayed
            status = System.getMessageState()
            if status ~= RUNNING then
		if spin_allowance > 0 then
		    OverrideCategory()
		    spin_allowance = 0
		end
                close_triangle_preview()
            end
        end
    end
    -- End Controls    
    check_for_out_of_bounds()
    
    -- Refreshing screen and oldpad
    Screen.waitVblankStart()
    Screen.flip()
    if hasTyped == false then			  --@@ NEW! only read controls/touch while keyboard is not displayed
	oldpad = pad
	x1_old = x1 or nil			  --@@ NEW! Store old touch data in order for tapping to work.
	y1_old = y1 or nil			  --@@ NEW!
    end						  --@@ NEW!
    
    if oneLoopTimer then			  -- if the timer is running then...
        oneLoopTime = Timer.getTime(oneLoopTimer) -- save the time
        Timer.destroy(oneLoopTimer)		  -- not sure if this is necessary
	oneLoopTimer = nil			  -- clear timer value
    end 
end
