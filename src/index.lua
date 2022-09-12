-- HexFlow Launcher Custom version 0.9,
-- based in HexFlow Launcher by VitaHEX version 0.5. Inspired from Retroflow.
-- https://www.patreon.com/vitahex
-- Want to make your own version? Right-click the vpk and select "Open with... Winrar" and replace the index.lua inside with your own.

--@@Startup speed timers. View results in the start menu's "about" section.
local oneLoopTimer = Timer.new()
local oneLoopTime = 0
local bOneLoop = false --Blocks oneloop timer after the first frame is rendered.
--local functionTimer = Timer.new()
local functionTime = 0
local sortTimer = 0
local sortTime = 0
local applistReadTimer = 0
local applistReadTime = 0

dofile("app0:addons/threads.lua")
local working_dir = "ux0:/app"
local appversion = "0.9"
function System.currentDirectory(dir) --@@ Upgrade this function to work with pspemu/rom folders before v1.0 release.
    if dir == nil then
        return working_dir --"ux0:/app"
    else
        working_dir = dir
    end
end


Network.init()
local onlineCovers = "https://raw.githubusercontent.com/andiweli/hexflow-covers/main/Covers/PSVita/"
local onlineCoversPSP = "https://raw.githubusercontent.com/andiweli/hexflow-covers/main/Covers/PSP/"
local onlineCoversPSX = "https://raw.githubusercontent.com/andiweli/hexflow-covers/main/Covers/PS1/"

Sound.init()
local click = Sound.open("app0:/DATA/click2.ogg") --@@ now "ogg" instead of "wav"
local sndMusic = click--temp
local imgCoverTmp = Graphics.loadImage("app0:/DATA/noimg.png")
local backTmp = Graphics.loadImage("app0:/DATA/noimg.png")
local btnX = Graphics.loadImage("app0:/DATA/x.png")
local btnT = Graphics.loadImage("app0:/DATA/t.png")
local btnS = Graphics.loadImage("app0:/DATA/s.png")
local btnO = Graphics.loadImage("app0:/DATA/o.png")
local imgWifi = Graphics.loadImage("app0:/DATA/wifi.png")
local imgBattery = Graphics.loadImage("app0:/DATA/bat.png")
local imgCacheIcon = Graphics.loadImage("app0:/DATA/cache_icon_25x25.png") --@@ NEW
local imgBack = Graphics.loadImage("app0:/DATA/back_01.jpg")
local imgFloor = Graphics.loadImage("app0:/DATA/floor.png")
Graphics.setImageFilters(imgFloor, FILTER_LINEAR, FILTER_LINEAR)

--@@ Footer button margins
local btnMargin = 44 --@@ Retroflow v3.4.2 uses 64. HEXFlow Launcher v0.5 uses ~46
local btnImgWidth = 20
--@@local btnImgWidth = Graphics.getImageWidth("app0:/DATA/x.png") --@@20

--@@ Footer button X coordinates. Calculated in changeLanguage() (except new alt 3). Alts are for start menu.
local label1AltImgX = 0
local label2AltImgX = 0
local label3AltImgX = 0
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

local working_text = ""
local byte_errorlevel = ""

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

if not System.doesFileExist(cur_dir .. "/overrides.dat") then
    local file_over = System.openFile(cur_dir .. "/overrides.dat", FCREATE)
    System.writeFile(file_over, " ", 1)
    System.closeFile(file_over)
end

-- load oneshot images (loading screens)
local loadingCache = Graphics.loadImage("app0:/DATA/oneshot_cache_write.png")

-- load textures
local imgBox = Graphics.loadImage("app0:/DATA/vita_cover.png")
local imgBoxPSP = Graphics.loadImage("app0:/DATA/psp_cover.png")
local imgBoxPSX = Graphics.loadImage("app0:/DATA/psx_cover.png")

-- Load models
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

local modBackground = Render.loadObject("app0:/DATA/planebg.obj", imgBack)
local modDefaultBackground = Render.loadObject("app0:/DATA/planebg.obj", imgBack)
local modFloor = Render.loadObject("app0:/DATA/planefloor.obj", imgFloor)

local img_path = ""

local fnt = Font.load("app0:/DATA/font.ttf")
local fnt15 = Font.load("app0:/DATA/font.ttf")
local fnt20 = Font.load("app0:/DATA/font.ttf")
local fnt22 = Font.load("app0:/DATA/font.ttf")
local fnt25 = Font.load("app0:/DATA/font.ttf")
local fnt35 = Font.load("app0:/DATA/font.ttf")

Font.setPixelSizes(fnt15, 15)
Font.setPixelSizes(fnt20, 20)
Font.setPixelSizes(fnt22, 22)
Font.setPixelSizes(fnt25, 25)
Font.setPixelSizes(fnt35, 35)


local menuX = 0
local menuY = 0
local showMenu = 0
local showCat = 1 -- Category: 0 = all, 1 = games, 2 = homebrews, 3 = psp, 4 = psx, 5 = custom
local showView = 0

local info = System.extractSfo("app0:/sce_sys/param.sfo")
local app_version = info.version
local app_title = info.title
local app_category = info.category
local app_titleid = info.titleid
local app_titleid_backup = 0	 --@@NEW. Cheap workaround to get psx_serial to work. Should be removed later...
local app_size = 0
local psx_serial = "-"		 --@@NEW

local master_index = 1
local p = 1
local oldpad = 0
local delayTouch = 8.0
local delayButton = 8.0
local hideBoxes = 1.0
local prvRotY = 0

local gettingCovers = false
local scanComplete = false

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
local orange = Color.new(220, 120, 0)
local purple = Color.new(151, 0, 185)
local darkpurple = Color.new(77, 4, 160) --@@ New! Also, purples are now after orange.
local bg = Color.new(153, 217, 234)
local themeCol = Color.new(2, 72, 158)

local targetX = 0
local xstart = 0
local ystart = 0
local space = 1
local touchdown = 0
local startCovers = false
local inPreview = false
local apptype = 0
local appdir = ""
local getCovers = 1 --1 PSV, 2 Homebrews, 3 PSP, 4 PS1
local getBGround = 1 --1 Custom, 2 Citylights, 3 Aurora, 4 "Wood 1", 5 "Wood 2", 6 Dark, 7 Marble
local BGroundText = "-"
local tmpappcat = 0
local verif_ref = 0
local v_info = 0

local prevX = 0
local prevZ = 0
local prevRot = 0

--@@local total_all = 0
local total_games = 0
--@@local total_homebrews = 0
local total_pspemu = 0
local total_roms = 0
local working_entry_count = 0
local curTotal = 1

-- Settings
local startCategory = 1
local setReflections = 1
local setSounds = 1
local themeColor = 0 -- 0 blue, 1 red, 2 yellow, 3 green, 4 grey, 5 black, 7 orange, 6 purple, 8 darkpurple. (reorder hack)
local menuItems = 3
local setBackground = 1
local setLanguage = 0
local showHomebrews = 0

function stringSplit(inputstr, sep) --@@used for verify_cache() & ReadCustomSort()
    if sep == nil then
	sep = "%s" --all "space"-type characters
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
	table.insert(t, str)
    end
    return t
end


-- PS1 binary translator
--@@ a better solution might be found in Adrenaline Bubble Manager's "str2int" function (untested), shown in the following 5 lines:
--@@-- Convert 4 bytes (32 bit) string to number int...
--@@function str2int(str)
--@@	local b1, b2, b3, b4 = string.byte(str, 1, 4)
--@@	return (b4 << 24) + (b3 << 16) + (b2 << 8) + b1
--@@end

--@@ local byte_convert_table was made from trial and error off these contents of a PS1 megaman 8 Adrenaline Bubble Manager boot.bin file:
--@@ variable b#     65, 66, 67, 68, 69  70  71  72  73  74  75  76  77  78  79  80  81  82  83  84  85  86  87  88  89  90  91  92  93 ...
--@@ string.byte val 117 120 48  58  112 115 112 101 109 117 47  112 115 112 47  103 97  109 101 47  115 108 117 115 48  48  52  53  51 ...
--@@ actual          u   x   0   :   p   s   p   e   m   u   /   p   s   p   /   g   a   m   e   /   s   l   u   s   0   0   4   5   3   /eboot.pbp

local byte_convert_table = {
--[47] = "/",
[48] = "0",
[49] = "1",
[50] = "2",
[51] = "3",
[52] = "4",
[53] = "5",
[54] = "6",
[55] = "7",
[56] = "8",
[57] = "9",
--[58] = ":",
[97] = "a",
[98] = "b",
[99] = "c",
[100] = "d",
[101] = "e",
[102] = "f",
[103] = "g",
[104] = "h",
[105] = "i",
[106] = "j",
[107] = "k",
[108] = "l",
[109] = "m",
[110] = "n",
[111] = "o",
[112] = "p",
[113] = "q",
[114] = "r",
[115] = "s",
[116] = "t",
[117] = "u",
[118] = "v",
[119] = "w",
[120] = "x",
[121] = "y",
[122] = "z"}


function bytesToStr(bytes_table)
    working_text = ""
    byte_errorlevel = ""
    if #bytes_table > 0 then
	for index=1, #bytes_table do
	    if bytes_table[index] ~= nil then
		if byte_convert_table[bytes_table[index]] ~= nil then
		    working_text = working_text .. byte_convert_table[bytes_table[index]]
		else
		    -- working_text = working_text .. "?"
		    byte_errorlevel = "error" --@@character not on case sensitive convert list
		end
	    else
		byte_errorlevel = "error" --@@unexpected end to bytes list.
	    end
	end
    else
	byte_errorlevel = "error" --@@totally empty bytes table
    end
    if (byte_errorlevel ~= "error") and (working_text ~= nil) and (working_text ~= "") then
	return working_text
    else
	return nil --@@not sure if necessary.
    end
end
	    
function readBin(filename)
    if System.doesFileExist(filename) and string.match(filename, ".bin") then
	local path_game = ""
	local b76,b77,b85,b86,b87,b88,b89,b90,b91,b92,b93,b94 = nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
	local inp = assert(io.open(filename, "rb"), "Failed to open boot.bin") --@@ I feel assert should be used to prevent rest of this function if fail.
	local data = inp:read("*all")
	inp:close()

	--@@I'm ~99.9% sure there's a better way to do this (the below line) @@ I'm also 69% sure if you read a blanked binary (from a psp bubble created manually, back before adrenaline bubble manager), the app will crash on startup, untested.
	b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16,b17,b18,b19,b20,b21,b22,b23,b24,b25,b26,b27,b28,b29,b30,b31,b32,b33,b34,b35,b36,b37,b38,b39,b40,b41,b42,b43,b44,b45,b46,b47,b48,b49,b50,b51,b52,b53,b54,b55,b56,b57,b58,b59,b60,b61,b62,b63,b64,b65,b66,b67,b68,b69,b70,b71,b72,b73,b74,b75,b76,b77,b78,b79,b80,b81,b82,b83,b84,b85,b86,b87,b88,b89,b90,b91,b92,b93,b94,b95,b96,b97,b98,b99,b100 = string.byte(data,1,100)

	--@@ untested code marked with "--#"
	--@@ find "0" (char 48) in "ux0:", "uma0:", "ur0:", "imc0:", or "xmc0:" (binary slot 67/68 for ux0/uma0 respectively)
	if not (b67 ~= 48) then						 --@@ux0
	    --#if not (b76 ~= 112) then					 --@@ux0:pspemu/p   [sp/game/] @@ ps1 & eboots.
		b85,b86,b87,b88,b89,b90,b91,b92,b93 = string.byte(data,85,93)
		path_game = bytesToStr({b85,b86,b87,b88,b89,b90,b91,b92,b93})
	    --#elseif not (b76 ~= 105) then				 --@@ux0:pspemu/i   [so/] @@ psp.
	    --#--@@blah blah scan psp iso param blah blah
	    --#end
	elseif not (b68 ~= 48) then					 --@@uma0
	    --#if not (b77 ~= 112) then					 --@@uma0:pspemu/p  [sp/game/] @@ ps1 & eboots.
		b86,b87,b88,b89,b90,b91,b92,b93,b94 = string.byte(data,86,94)
		path_game = bytesToStr({b86,b87,b88,b89,b90,b91,b92,b93,b94,})
	    --#elseif not (b77 ~= 105) then				 --@@uma0:pspemu/i  [so/] @@ psp.
	    --#--@@blah blah scan psp iso param blah blah
	    --#end
	end
	if path_game ~= nil then
	    return path_game
	    --@@   slus00453
	else
	    return nil --@@not sure if necessary.
	end
    end
end

if System.doesFileExist(cur_dir .. "/config.dat") then
    local file_config = System.openFile(cur_dir .. "/config.dat", FREAD)
    local filesize = System.sizeFile(file_config)
    local str = System.readFile(file_config, filesize)
    System.closeFile(file_config)
    
    local getCategory = tonumber(string.sub(str, 1, 1)); if getCategory ~= nil then startCategory = getCategory end
    local getReflections = tonumber(string.sub(str, 2, 2)); if getReflections ~= nil then setReflections = getReflections end
    local getSounds = tonumber(string.sub(str, 3, 3)); if getSounds ~= nil then setSounds = getSounds end
    local getthemeColor = tonumber(string.sub(str, 4, 4)); if getthemeColor ~= nil then themeColor = getthemeColor end
    local getBackground = tonumber(string.sub(str, 5, 5)); if getBackground ~= nil then setBackground = getBackground end
    local getLanguage = tonumber(string.sub(str, 6, 6)); if getLanguage ~= nil then setLanguage = getLanguage end
    if not (string.sub(str, 6, 6) ~= "C") then setLanguage = 10 end --@@ Cheap workaround to add a 10th language. (1/2)
    local getView = tonumber(string.sub(str, 7, 7)); if getView ~= nil then showView = getView end
    local getHomebrews = tonumber(string.sub(str, 8, 8)); if getHomebrews ~= nil then showHomebrews = getHomebrews end
else
    local file_config = System.openFile(cur_dir .. "/config.dat", FCREATE)
    if setLanguage == 10 then --@@ Cheap workaround to add a 10th language. (2/2)
	System.writeFile(file_config, startCategory .. setReflections .. setSounds .. themeColor .. setBackground .. "C" .. showView .. showHomebrews, 8)
    else
	System.writeFile(file_config, startCategory .. setReflections .. setSounds .. themeColor .. setBackground .. setLanguage .. showView .. showHomebrews, 8)
    end
    System.closeFile(file_config)
end
showCat = startCategory

-- Custom Background
local imgCustomBack = imgBack
if (setBackground > 1.5) and (setBackground < 8.5) then
    if System.doesFileExist("app0:/DATA/back_0" .. setBackground .. ".png") then
	imgCustomBack = Graphics.loadImage("app0:/DATA/back_0" .. setBackground .. ".png")
	Graphics.setImageFilters(imgCustomBack, FILTER_LINEAR, FILTER_LINEAR)
	Render.useTexture(modBackground, imgCustomBack)
    end
else
    if System.doesFileExist("ux0:/data/HexFlow/Background.png") then
	imgCustomBack = Graphics.loadImage("ux0:/data/HexFlow/Background.png")
	Graphics.setImageFilters(imgCustomBack, FILTER_LINEAR, FILTER_LINEAR)
	Render.useTexture(modBackground, imgCustomBack)
    elseif System.doesFileExist("ux0:/data/HexFlow/Background.jpg") then
	imgCustomBack = Graphics.loadImage("ux0:/data/HexFlow/Background.jpg")
	Graphics.setImageFilters(imgCustomBack, FILTER_LINEAR, FILTER_LINEAR)
	Render.useTexture(modBackground, imgCustomBack)
    end
end

-- Custom Music
if System.doesFileExist(cur_dir .. "/Music.mp3") then
    sndMusic = Sound.open(cur_dir .. "/Music.mp3")
    if setSounds == 1 then
        Sound.play(sndMusic, LOOP)
    end
end

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

-- Speed related settings
local cpu_speed = 444
System.setBusSpeed(222)
System.setGpuSpeed(222)
System.setGpuXbarSpeed(166)
System.setCpuSpeed(cpu_speed)

function OneShotPrint(my_func)
	-- Draw loading screen for caching process
	Graphics.termBlend()  -- End main loop blending if still running
	Graphics.initBlend()
	Screen.clear(black)
	Graphics.drawImage(0, 0, loadingCache) --@@in the future, replace "loadingCache" image with a textless version of bg.png and write the text using "old" font from data folder.
	Graphics.drawImage(587, 496, imgCacheIcon)
	Graphics.termBlend()
	Screen.flip()
end

local lang_lines = {}
local lang_default = "PS VITA\nHOMEBREWS\nPSP\nPS1\nALL\nSETTINGS\nLaunch\nDetails\nCategory\nView\nClose\nVersion\nAbout\nStartup Category\nReflection Effect\nSounds\nTheme Color\nCustom Background\nDownload Covers\nReload Covers Database\nLanguage\nON\nOFF\nRed\nYellow\nGreen\nGrey\nBlack\nPurple\nOrange\nBlue\nSelect"
function ChangeLanguage()
    lang_lines = {}
    local lang = "EN.ini"
     -- 0 EN, 1 DE, 2 FR, 3 IT, 4 SP, 5 RU, 6 SW, 7 PT, 8 PL, 9 JA, 10CN
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
    elseif setLanguage == 10 then
	lang = "CN.ini"
		
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

--@@Good luck understanding this, future self. @@ btnMargin: 44 @@ btnImgWidth: 20 @@ 8px img-text buffer.

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
    
    BGroundText = "" --Re-texts and re-brackets "Custom Background" option.
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
    if System.doesFileExist(cur_dir .. "/Music.mp3") then
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
    Graphics.freeImage(loadingCache)
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
		local sanitized_apptitle = string.gsub(v.apptitle, "\n", " ")
--@@		file:write(v.name .. "\t" .. sanitized_apptitle .. "\n") --@@bugfix for games with commas in the app title not displaying their full name, but it makes applist ugly.
		file:write(v.name .. "," .. sanitized_apptitle .. "\n")
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
--@@	        local app = stringSplit(line, "\t") --@@bugfix for games with commas in the app title not displaying their full name, but it makes applist ugly.
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


function xCatLookup(CatNum)	 --@@CatNum = Showcat. (or sometimes "GetCovers"). Used very often.
    if CatNum == 1 then
        return games_table
    elseif CatNum == 2 then
        return homebrews_table
    elseif CatNum == 3 then
        return psp_table
    elseif CatNum == 4 then
        return psx_table
    elseif CatNum == 5 then
        return custom_table
    else
        return files_table
    end
end

function xCatTextLookup(CatTextNum)	 --@@CatTextNum = Getcovers. Used in several places.
    if CatTextNum == 1 then
        return "PS VITA"
    elseif CatTextNum == 2 then
        return "HOMEBREWS"
    elseif CatTextNum == 3 then
        return "PSP"
    elseif CatTextNum == 4 then
        return "PSX"
    elseif CatTextNum == 5 then
        return "CUSTOM"
    else
        return "ALL"
    end
end
--    if CatTextNum == 1 then
--        return lang_lines[1] --PS VITA
--    elseif CatTextNum == 2 then
--        return lang_lines[2] --HOMEBREWS
--    elseif CatTextNum == 3 then
--        return lang_lines[3] --PSP
--    elseif CatTextNum == 4 then
--        return lang_lines[4] --PSX
--    elseif CatTextNum == 5 then
--        return lang_lines[49] --CUSTOM
--    else
--        return lang_lines[5] --ALL
--    end

function coversptable(getCovers) --@@For categorical cover download (1/2)
    if getCovers == 1 then
	return covers_psv
    elseif getCovers == 2 then
	return covers_psp
    elseif getCovers == 3 then
	return covers_psx
    else
	return covers_psv
    end
end

function onlcovtable(getCovers)  --@@For categorical cover download (2/2)
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


-- the Table consists of 1 entry per file/game, and that entry is a struct
-- that contains the following values: {directory,size,icon,icon_path,apptitle,name,app_type}
function listDirectory(dir)
    dir = System.listDirectory(dir)
    folders_table = {}
    files_table = {}
    games_table = {} --@@tables should've been localized beforehand for speed.
    psp_table = {}
    psx_table = {}
    custom_table = {}
    homebrews_table = {}
    pspemu_translation_table = {} --@@only used for ps1 right now.
    -- app_type = 0 -- 0 homebrew, 1 psvita, 2 psp, 3 psx
	
    local file_over = System.openFile(cur_dir .. "/overrides.dat", FREAD)
    local filesize = System.sizeFile(file_over)
    local str = System.readFile(file_over, filesize)
    System.closeFile(file_over)
    
    --@@ psx.lua taken from Retroflow 3.4 and completely repurposed
    local file_over = System.openFile("app0:addons/psx.lua", FREAD)
    local filesize = System.sizeFile(file_over)
    local psxdb = System.readFile(file_over, filesize)
    System.closeFile(file_over)

    for i, file in pairs(dir) do
	local custom_path, custom_path_id, app_type, pspemu_translate_tmp = nil, nil, nil, nil
        if file.directory == true then
	    --@@ START FOLDER-TYPE GAMES SCAN
            -- get app name to match with custom cover file name
            if System.doesFileExist(working_dir .. "/" .. file.name .. "/sce_sys/param.sfo") then
                info = System.extractSfo(working_dir .. "/" .. file.name .. "/sce_sys/param.sfo")
                app_title = info.title
            end

            if string.match(file.name, "PCS") and not string.match(file.name, "PCSI") then
                -- Scan PSVita Games
                table.insert(folders_table, file)
                --table.insert(games_table, file)
		file.app_type=1
            elseif System.doesFileExist(working_dir .. "/" .. file.name .. "/data/boot.bin") and not System.doesFileExist("ux0:pspemu/PSP/GAME/" .. file.name .. "/EBOOT.PBP") then
                -- Scan PSP Games (and improperly ID'd PS1 games) @@ Dear future self, good luck understanding the following line.
		pspemu_translate_tmp = readBin(working_dir .. "/" .. file.name .. "/data/boot.bin")
		if (pspemu_translate_tmp ~= nil) and (string.match(psxdb, pspemu_translate_tmp:upper())) then
		    pspemu_translation_table[file.name] = pspemu_translate_tmp:upper() --@@ For filtering Adrenaline launcher entries. Very cool. (not implemented yet at time of writing).
		    -- PSX
		    table.insert(folders_table, file)
		    --table.insert(psx_table, file)
		    file.app_type=3
		else
		    -- PSP
		    table.insert(folders_table, file)
		    --table.insert(psp_table, file)
		    file.app_type=2
		end
            elseif System.doesFileExist(working_dir .. "/" .. file.name .. "/data/boot.bin") and System.doesFileExist("ux0:pspemu/PSP/GAME/" .. file.name .. "/EBOOT.PBP") then
                -- Scan PSX Games
                table.insert(folders_table, file)
                --table.insert(psx_table, file)
		file.app_type=3
            else
                -- Scan Homebrews.
                table.insert(folders_table, file)
                --table.insert(homebrews_table, file)
		file.app_type=0
            end
	    if System.doesFileExist(cur_dir .. "/overrides.dat") then
	        --0 default, 1 vita, 2 psp, 3 psx, 4 homebrew
		if string.match(str, file.name .. "=1") then
		    file.app_type=1
		elseif string.match(str, file.name .. "=2") then
		    file.app_type=2
		elseif string.match(str, file.name .. "=3") then
		    file.app_type=3
		elseif string.match(str, file.name .. "=4") then
		    file.app_type=0
	        end
	    end
	    --@@ END FOLDER-TYPE GAMES SCAN
	--else
	    --@@ START ROM GAMES SCAN
	    --blah blah indentification blah blah system overrides blah blah
	    --@@ END ROM GAMES SCAN
        end
	if file.app_type == 1 then
	    table.insert(games_table, file)
	    custom_path = covers_psv .. app_title .. ".png"
	    custom_path_id = covers_psv .. file.name .. ".png"
	elseif file.app_type == 2 then
	    table.insert(psp_table, file)
	    custom_path = covers_psp .. app_title .. ".png"
	    custom_path_id = covers_psp .. file.name .. ".png"
	elseif file.app_type == 3 then
	    table.insert(psx_table, file)
	    custom_path = covers_psx .. app_title .. ".png"
	    custom_path_id = covers_psx .. file.name .. ".png"
	else
	    table.insert(homebrews_table, file)
	    custom_path = covers_psv .. app_title .. ".png"
	    custom_path_id = covers_psv .. file.name .. ".png"
	end
        
        if custom_path and System.doesFileExist(custom_path) then
            img_path = custom_path --custom cover by app name
        elseif custom_path_id and System.doesFileExist(custom_path_id) then
            img_path = custom_path_id --custom cover by app id
        elseif custom_path_id and (pspemu_translation_table[file.name] ~= nil) then
	    custom_path_id = custom_path_id:gsub(file.name .. ".png", pspemu_translation_table[file.name] .. ".png")
	    if System.doesFileExist(custom_path_id) then
                img_path = custom_path_id
	    else
	        if System.doesFileExist("ur0:/appmeta/" .. file.name .. "/icon0.png") then
	            img_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"  --app icon
	        else
	            img_path = "app0:/DATA/noimg.png" --blank grey
	        end
	    end
        else
            if System.doesFileExist("ur0:/appmeta/" .. file.name .. "/icon0.png") then
                img_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"  --app icon
            else
                img_path = "app0:/DATA/noimg.png" --blank grey
            end
        end
        
        table.insert(files_table, 4, file.app_type)
		
		
        --add blank icon to all
        file.icon = imgCoverTmp
        file.icon_path = img_path
		
        table.insert(files_table, 4, file.icon)
        
        file.apptitle = app_title
        table.insert(files_table, 4, file.apptitle)
        
    end
    table.sort(files_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(folders_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    
    table.sort(games_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(homebrews_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(psp_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    table.sort(psx_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
    
    return_table = TableConcat(folders_table, files_table)
    
--@@    total_all = #files_table
--@@    total_games = #games_table
--@@    total_homebrews = #homebrews_table
    
    return return_table
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
	System.closeFile(file_over)

	file = io.open(cur_dir .. "/apptitlecache.dat", "w")

	for k, v in pairs(files_table) do
        for key, val in pairs(v) do --@@this will be bad if new keys are added (ex: file.serial_number)
            local sanitized_value
            if type(val) == "string" then
                sanitized_value = string.gsub(val, "\n", " ") --@@sanitization will have to be better (ex: replacing "/" with "%20") here if Emu-launch is added.
            else
                sanitized_value = val
            end
            file:write(tostring(sanitized_value) .. "\t")
            -- file:write(key .. string.char(0x1F) .. tostring(val) .. "\t")
        end
        file:seek("cur", -1)
        file:write("\n")
	end

	file:close()
end

function RestoreTitleTable()

    files_table = {}
    games_table = {}
    psp_table = {}
    psx_table = {}
    homebrews_table = {}
    custom_table = {}

	if System.doesFileExist(cur_dir .. "/apptitlecache.dat") then
		for line in io.lines(cur_dir .. "/apptitlecache.dat") do
			if not (line == "" or line == " " or line == "\n") then
                -- {directory,size,icon,icon_path,apptitle,name,app_type}
                local app = stringSplit(line, "\t")
                file = {}
                file.directory = toboolean(app[1])
                file.size = tonumber(app[2])
                -- file.icon = tonumber(app[3])
                file.icon = imgCoverTmp
                file.icon_path = tostring(app[4])
                file.apptitle = tostring(app[5])
                file.name = tostring(app[6])
                file.app_type = tonumber(app[7])
                
                table.insert(files_table, file)
                
                if file.app_type == 0 then --@@not sure if necessary
                    table.insert(homebrews_table, file)
                elseif file.app_type == 1 then
                    table.insert(games_table, file) 
                elseif file.app_type == 2 then
                    table.insert(psp_table, file) 
                elseif file.app_type == 3 then
                    table.insert(psx_table, file) 
                else
                    table.insert(homebrews_table, file)
                end
			end		
		end
        
	end
end

-- Loads App list if cache exists, or generates a new one if it doesn't
function LoadAppTitleTables()
    if System.doesFileExist(cur_dir .. "/apptitlecache.dat") then
        RestoreTitleTable()
    else
        files_table = listDirectory(System.currentDirectory())
        CacheTitleTable()
        WriteAppList()
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

function GetInfoSelected()
    if #xCatLookup(showCat) > 0 then --if the currently-shown category isn't empty
        if System.doesFileExist(working_dir .. "/" .. xCatLookup(showCat)[p].name .. "/sce_sys/param.sfo") then
            info = System.extractSfo(working_dir .. "/" .. xCatLookup(showCat)[p].name .. "/sce_sys/param.sfo")
            icon_path = "ur0:/appmeta/" .. xCatLookup(showCat)[p].name .. "/icon0.png"
            pic_path = "ur0:/appmeta/" .. xCatLookup(showCat)[p].name .. "/pic0.png"
	    app_title = tostring(info.title)
	    apptype = xCatLookup(showCat)[p].app_type
        end
    else
        app_title = "-"
    end
--@@    elseif showCat == 2 then
--@@        if #homebrews_table > 0 then
--@@Above 2 lines kept here so Beyond Compare software will properly compare the above to HexFlow Launcher 0.5 or RetroFlow 1.0

    --@@The below 2 lines may cause a crash if Emu-launch is added.
    app_titleid = tostring(info.titleid)
    app_version = tostring(info.version)
end

function GetHeavyInfoSelected()
    if #xCatLookup(showCat) > 0 then --if the currently-shown category isn't empty then:
        if System.doesFileExist(working_dir .. "/" .. xCatLookup(showCat)[p].name .. "/sce_sys/param.sfo") then
            info = System.extractSfo(working_dir .. "/" .. xCatLookup(showCat)[p].name .. "/sce_sys/param.sfo")
            icon_path = "ur0:/appmeta/" .. xCatLookup(showCat)[p].name .. "/icon0.png"
            pic_path = "ur0:/appmeta/" .. xCatLookup(showCat)[p].name .. "/pic0.png"
	    app_title = tostring(info.title)
	    apptype = xCatLookup(showCat)[p].app_type
	    appdir=working_dir .. "/" .. xCatLookup(showCat)[p].name
        end
    else
        app_title = "-"
    end
--@@    elseif showCat == 2 then
--@@        if #homebrews_table > 0 then
--@@Above 2 lines kept here so Beyond Compare software will properly compare the above to HexFlow Launcher 0.5 or RetroFlow 1.0

    --@@The below 2 lines may cause a crash if Emu-launch is added.
    app_titleid = tostring(info.titleid)
    app_version = tostring(info.version)
    if not (apptype ~= 3)										 --@@ NEW! @@ finds easiest disqualifiers first for speed (1/5, invalid apptype and/or not PS1)
    and #xCatLookup(showCat) > 0									 --@@ NEW! @@ finds easiest disqualifiers first for speed (2/5, empty category. Maybe this should be first?
    and xCatLookup(showCat)[p].name ~= nil								 --@@ NEW! @@ finds easiest disqualifiers first for speed (3/5, I'm not sure if this check is necessary.
    and System.doesFileExist(working_dir .. "/" .. xCatLookup(showCat)[p].name .. "/data/boot.bin")	 --@@ NEW! @@ finds easiest disqualifiers first for speed (4/5, not Adrenaline Bubble)
    and not System.doesFileExist("ux0:pspemu/PSP/GAME/" .. xCatLookup(showCat)[p].name .. "/EBOOT.PBP")	 --@@ NEW! @@ finds easiest disqualifiers first for speed (5/5, has proper ID)
    and readBin(working_dir .. "/" .. xCatLookup(showCat)[p].name .. "/data/boot.bin") ~= nil then	 --@@ NEW! @@ Since it's an improperly ID'd PS1 "Adrenaline Bubble Manager"-made bubble, scan the PS1 launch binary.
	psx_serial = readBin(working_dir .. "/" .. xCatLookup(showCat)[p].name .. "/data/boot.bin"):upper()
    else
	psx_serial = "-"
    end
end

local rolling_overrides = false --@@I got this working before, now it causes crash. Not sure why. Try at your own risk.
function OverrideCategory()
	--@@[1]=VITA, [2]=PSP, [3]=PS1, [4]=HOMEBREWS. (0 is default but it does nothing right now)
	if System.doesFileExist(cur_dir .. "/overrides.dat") then
		local inf = assert(io.open(cur_dir .. "/overrides.dat", "rw"), "Failed to open overrides.dat")
		local lines = ""
		while(true) do
			local line = inf:read("*line")
			if not line then break end
			
			if not string.find(line, app_titleid .. "", 1) then
				lines = lines .. line .. "\n"
			end
		end
		if tmpappcat>0 then
			lines = lines .. app_titleid .. "=" .. tmpappcat .. "\n"
			if (rolling_overrides ~= nil) and (rolling_overrides == true) then
			    if (tmpappcat == 1) or (tmpappcat == 2) or (tmpappcat == 3) then
				UpdateCacheSect(app_titleid, 7, tmpappcat)
			    elseif tmpappcat == 4 then
				UpdateCacheSect(app_titleid, 7, "0")
			    end
			end
		end
		inf:close()
		file = io.open(cur_dir .. "/overrides.dat", "w")
		file:write(lines)
		file:close()
		
		if (rolling_overrides ~= nil) and (rolling_overrides == true) then
		    --Reload
		    FreeIcons()
		    FreeMemory()
		    Network.term()
		    dofile("app0:index.lua")
		else
		    System.setMessage(lang_lines[55], false, BUTTON_OK)--"Done. Please 'refresh cache' via the start menu."
		end
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
			    Network.downloadFileAsync(onlcovtable(getCovers) .. xCatLookup(getCovers)[app_idx].name .. ".png", "ux0:/data/HexFlow/" .. xCatLookup(getCovers)[app_idx].name .. ".png")
			    running = true
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
				    System.rename("ux0:/data/HexFlow/" .. xCatLookup(getCovers)[app_idx].name .. ".png", coversptable(getCovers) .. xCatLookup(getCovers)[app_idx].name .. ".png")
				    cvrfound = cvrfound + 1
				end
				System.closeFile(tmpfile)

				percent = (app_idx / #xCatLookup(getCovers)) * 100
				txt = "Downloading " .. xCatTextLookup(getCovers) .. " covers...\nCover " .. xCatLookup(getCovers)[app_idx].name .. "\nFound " .. cvrfound .. " of " .. #xCatLookup(getCovers)

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
    if System.doesFileExist(cur_dir .. "/apptitlecache.dat") then
        System.deleteFile(cur_dir .. "/apptitlecache.dat")
    end
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

local function DrawCover(x, y, text, icon, sel, apptype)
    rot = 0
    extraz = 0
    extrax = 0
    extray = 0
    zoom = 0
    camX = 0
    Graphics.setImageFilters(icon, FILTER_LINEAR, FILTER_LINEAR)
    if showView == 1 then
        -- flat zoom out view
        space = 1.6
        zoom = 0
        if x > 0.5 then
            extraz = 6
            extrax = 1
        elseif x < -0.5 then
            extraz = 6
            extrax = -1
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
    else
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
        if apptype==1 then
            -- PSVita Boxes
            if setReflections == 1 then
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
            if setReflections == 1 then
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
            if setReflections == 1 then
                Render.useTexture(modCoverPSX, icon)
                Render.drawModel(modCoverPSX, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
                Render.drawModel(modBoxPSX, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            else
                Render.useTexture(modCoverPSXNoref, icon)
                Render.drawModel(modCoverPSXNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
                Render.drawModel(modBoxPSXNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            end
        else
            -- Homebrew Icon
            if setReflections == 1 then
                Render.useTexture(modCoverHbr, icon)
                Render.drawModel(modCoverHbr, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            else
                Render.useTexture(modCoverHbrNoref, icon)
                Render.drawModel(modCoverHbrNoref, x + extrax, y + extray, -5 - extraz - zoom, 0, math.deg(rot), 0)
            end
        end
    else
        hideBoxes = hideBoxes - 0.1
    end
end

local FileLoad = {}

function FreeIcons()
    for k, v in pairs(files_table) do
        FileLoad[v] = nil
        Threads.remove(v)
        if v.ricon then
            Graphics.freeImage(v.ricon)
            v.ricon = nil
        end
    end
    for k, v in pairs(games_table) do
        FileLoad[v] = nil
        Threads.remove(v)
        if v.ricon then
            Graphics.freeImage(v.ricon)
            v.ricon = nil
        end
    end
    for k, v in pairs(psp_table) do
        FileLoad[v] = nil
        Threads.remove(v)
        if v.ricon then
            Graphics.freeImage(v.ricon)
            v.ricon = nil
        end
    end
    for k, v in pairs(psx_table) do
        FileLoad[v] = nil
        Threads.remove(v)
        if v.ricon then
            Graphics.freeImage(v.ricon)
            v.ricon = nil
        end
    end
    for k, v in pairs(homebrews_table) do
        FileLoad[v] = nil
        Threads.remove(v)
        if v.ricon then
            Graphics.freeImage(v.ricon)
            v.ricon = nil
        end
    end
        for k, v in pairs(custom_table) do
        FileLoad[v] = nil
        Threads.remove(v)
        if v.ricon then
            Graphics.freeImage(v.ricon)
            v.ricon = nil
        end
    end
end



function UpdateCacheSect(app_id, working_sect, new_path) --@@ This function is like magic. I have no idea how it works but it works so good.
    if System.doesFileExist(cur_dir .. "/apptitlecache.dat") then
--	for line in io.lines(cur_dir .. "/apptitlecache.dat") do
--	    if not (line == "" or line == " " or line == "\n") then
--		{directory,size,icon,icon_path,apptitle,name,app_type}
--		local app = stringSplit(line, "\t")
--		if string.find(app_id)
--		    file.name = tostring(app[6])
--		    file.app_type = tonumber(app[7])
--		end
--	    end
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



function DownloadSingleCover()
    cvrfound = 0
    app_idx = p
    running = false
	status = System.getMessageState()
	
	local coverspath = ""
	local onlineCoverspath = ""

	
	if Network.isWifiEnabled() then
		app_titleid_backup = 0
		if (apptype == 3) and (psx_serial ~= nil) and (psx_serial ~= "-") then
			app_titleid_backup = app_titleid
			app_titleid = psx_serial	 --@@Low quality code (1/4)... please make it more like COBOL by having a separate routine instead of this workaround.
		end
		if apptype == 1 then
			coverspath = covers_psv			 -- ux0:/data/HexFlow/COVERS/PSVITA/
			onlineCoverspath = onlineCovers		 -- https://raw.githubusercontent.com/andiweli/hexflow-covers/main/Covers/PSVita/
		elseif apptype == 2 then
			coverspath = covers_psp			 -- ux0:/data/HexFlow/COVERS/PSP/
			onlineCoverspath = onlineCoversPSP	 -- https://raw.githubusercontent.com/andiweli/hexflow-covers/main/Covers/PSP/
		elseif apptype == 3 then
			coverspath = covers_psx			 -- ux0:/data/HexFlow/COVERS/PSX/
			onlineCoverspath = onlineCoversPSX	 -- https://raw.githubusercontent.com/andiweli/hexflow-covers/main/Covers/PS1/
		else
			coverspath = covers_psv
			onlineCoverspath = onlineCovers
		end
	
		Network.downloadFile(onlineCoverspath .. app_titleid .. ".png", "ux0:/data/HexFlow/" .. app_titleid .. ".png")
		
		if System.doesFileExist("ux0:/data/HexFlow/" .. app_titleid .. ".png") then
			tmpfile = System.openFile("ux0:/data/HexFlow/" .. app_titleid .. ".png", FREAD)
			size = System.sizeFile(tmpfile)
			if size < 1024 then
				System.deleteFile("ux0:/data/HexFlow/" .. app_titleid .. ".png")
			else
				System.rename("ux0:/data/HexFlow/" .. app_titleid .. ".png", coverspath .. app_titleid .. ".png")
				cvrfound = 1
			end
			System.closeFile(tmpfile)
		end
		
		if cvrfound==1 then
		    xCatLookup(showCat)[app_idx].icon_path=coverspath .. app_titleid .. ".png"
		    if FileLoad[xCatLookup(showCat)[app_idx]] == true then
			FileLoad[xCatLookup(showCat)[app_idx]] = nil
			Threads.remove(xCatLookup(showCat)[app_idx])
		    end
		    if xCatLookup(showCat)[app_idx].ricon then
			xCatLookup(showCat)[app_idx].ricon = nil
				--"homebrews_table"
--@@The above line is kept here so Beyond Compare software will properly compare the preceeding lines to HexFlow Launcher 0.5's.
		    end
			
		    -- Update cache if it exists --@@NEW
		    local new_path = coverspath .. app_titleid .. ".png" --@@NEW
		    UpdateCacheSect(app_titleid, 4, new_path) --@@NEW
			
		    if status ~= RUNNING then
			local new_path = coverspath .. app_titleid .. ".png"		  --@@NEW @@ update cover in cache (1/3)
			if (app_titleid_backup ~= nil) and (app_titleid_backup ~= 0) then --@@NEW
			    app_titleid = app_titleid_backup				  --@@NEW @@ Low quality code (2/4)... please make it more like COBOL by having a separate routine instead of this workaround. (1/2)
			end								  --@@NEW
			-- Update cache if it exists					  --@@NEW @@ update cover in cache (2/3)
			UpdateCacheSect(app_titleid, 4, new_path)			  --@@NEW @@ update cover in cache (3/3)
			if (apptype == 3) and (psx_serial ~= nil) and (psx_serial ~= "-") then --@@ Low quality code (3/4)... revert this part back how was in HEXFlow launcher 0.5
			    System.setMessage("Cover " .. psx_serial .. " found!\nCache has been updated.", false, BUTTON_OK)
			else
			    System.setMessage("Cover " .. app_titleid .. " found!\nCache has been updated.", false, BUTTON_OK)
			end
		    end
		else
		    if (app_titleid_backup ~= nil) and (app_titleid_backup ~= 0) then	 --@@NEW
			app_titleid = app_titleid_backup				 --@@NEW @@ Low quality code (4/4)... please make it more like COBOL by having a separate routine instead of this workaround. (1/2)
		    end	
		    if status ~= RUNNING then
			System.setMessage("Cover not found", false, BUTTON_OK)
		    end
		end
		
	else
		if status ~= RUNNING then
			System.setMessage("Internet Connection Required", false, BUTTON_OK)
		end
	end
	
	gettingCovers = false
end

-- Loads App list if cache exists, or generates a new one if it doesn't
local applistReadTimer = Timer.new()
LoadAppTitleTables()
applistReadTime = Timer.getTime(applistReadTimer)
Timer.destroy(applistReadTimer)

--functionTime = Timer.getTime(functionTimer)
functionTime = Timer.getTime(oneLoopTimer)
--Timer.destroy(functionTimer)

ReadCustomSort()

-- Main loop
while true do
    
    -- Threads update
    Threads.update()
    
    -- Reading input
    pad = Controls.read()
    
    mx, my = Controls.readLeftAnalog()
    
    -- touch input
    x1, y1 = Controls.readTouch()
    
    -- Initializing rendering
    Graphics.initBlend()
    Screen.clear(black)
    
    if delayButton > 0 then
        delayButton = delayButton - 0.1
    else
        delayButton = 0
    end
    
    -- Graphics
    if setBackground > 0.5 then
        Render.drawModel(modBackground, 0, 0, -5, 0, 0, 0)-- Draw Background as model
    else
        Render.drawModel(modDefaultBackground, 0, 0, -5, 0, 0, 0)-- Draw Background as model
    end
    
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
        -- Footer buttons and icons @@ positions set in ChangeLanguage()
	Graphics.drawImage(label1ImgX, 510, btnX)
	Font.print(fnt20, label1X, 508, lang_lines[7], white)--Launch
	Graphics.drawImage(label2ImgX, 510, btnT)
	Font.print(fnt20, label2X, 508, lang_lines[8], white)--Details
	Graphics.drawImage(label3ImgX, 510, btnS)
	Font.print(fnt20, label3X, 508, lang_lines[9], white)--Category
	Graphics.drawImage(label4ImgX, 510, btnO)
	Font.print(fnt20, label4X, 508, lang_lines[10], white)--View

	Font.print(fnt22, 32, 34, xCatTextLookup(showCat), white)--PS VITA/HOMEBREWS/PSP/PSX/CUSTOM/ALL
        if Network.isWifiEnabled() then
            Graphics.drawImage(800, 38, imgWifi)-- wifi icon
        end
        
        if showView ~= 2 then
            Graphics.fillRect(0, 960, 424, 496, black)-- black footer bottom
            PrintCentered(fnt25, 480, 430, app_title, white, 25)-- Draw title
        else
            Font.print(fnt22, 24, 508, app_title, white)
        end
        
        -- Draw Covers
        base_x = 0
        
        --GAMES
        for l, file in pairs(xCatLookup(showCat)) do
            if (l >= master_index) then
                base_x = base_x + space
            end
            if l > p-8 and base_x < 10 then
                if FileLoad[file] == nil then --add a new check here
                    FileLoad[file] = true
                    Threads.addTask(file, {
                        Type = "ImageLoad",
                        Path = file.icon_path,
                        Table = file,
                        Index = "ricon"
                    })
                end
                if file.ricon ~= nil then
                    DrawCover((targetX + l * space) - (#xCatLookup(showCat) * space + space), -0.6, file.name, file.ricon, base_x, file.app_type)--draw visible covers only
                else
                    DrawCover((targetX + l * space) - (#xCatLookup(showCat) * space + space), -0.6, file.name, file.icon, base_x, file.app_type)--draw visible covers only
                end
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
        if showView ~= 2 then
            PrintCentered(fnt20, 480, 462, p .. " of " .. #xCatLookup(showCat), white, 20)-- Draw total items
        end
            --HOMEBREWS --@@This is kept here so Beyond Compare software will properly compare the above to HexFlow Launcher 0.5
        
        
        -- Smooth move items horizontally
        if targetX ~= base_x then
            targetX = targetX - ((targetX - base_x) * 0.1)
        end
        
        -- Instantly move to selection
        if startCovers == false then
            targetX = base_x
            startCovers = true
            GetInfoSelected()
        end
        
        if setReflections==1 then
            floorY = 0
            if showView == 2 then
                floorY = -0.6
            elseif showView == 3 then
                floorY = -0.3
            end
            --Draw half transparent floor for reflection effect
            Render.drawModel(modFloor, 0, -0.6+floorY, 0, 0, 0, 0)
        end
        
        prevX = 0
        prevZ = 0
        prevRot = 0
        inPreview = false
    elseif showMenu == 1 then
        
        -- PREVIEW
        -- Footer buttons and icons @@ positions set in ChangeLanguage()
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
	--@@Graphics.drawScaleImage(50, 50, iconTmp, 128 / Graphics.getImageWidth(iconTmp), 128 / Graphics.getImageHeight(iconTmp)) --icon for triangle preview
	--@@ Line above works well, but is unneccesary until Roms & Emu-launch are added.
        
        txtname = string.sub(app_title, 1, 32) .. "\n" .. string.sub(app_title, 33)
        
        -- Set cover image
        if xCatLookup(showCat)[p].ricon ~= nil then
            Render.useTexture(modCoverNoref, xCatLookup(showCat)[p].ricon)
            Render.useTexture(modCoverHbrNoref, xCatLookup(showCat)[p].ricon)
            Render.useTexture(modCoverPSPNoref, xCatLookup(showCat)[p].ricon)
            Render.useTexture(modCoverPSXNoref, xCatLookup(showCat)[p].ricon)
        else
            Render.useTexture(modCoverNoref, xCatLookup(showCat)[p].icon)
            Render.useTexture(modCoverHbrNoref, xCatLookup(showCat)[p].icon)
            Render.useTexture(modCoverPSPNoref, xCatLookup(showCat)[p].icon)
            Render.useTexture(modCoverPSXNoref, xCatLookup(showCat)[p].icon)
        end      
            --Graphics.setImageFilters(homebrews_table[p].icon, FILTER_LINEAR, FILTER_LINEAR)
            --Graphics.setImageFilters(psp_table[p].icon, FILTER_LINEAR, FILTER_LINEAR)
 --@@The above 2 lines are kept here so Beyond Compare software will properly compare the above to HexFlow Launcher 0.5
		
        local tmpapptype=""
		local tmpcatText=""
        -- Draw box
        if apptype==1 then
            Render.drawModel(modCoverNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            Render.drawModel(modBoxNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
			tmpapptype = "PS Vita Game"
        elseif apptype==2 then
            Render.drawModel(modCoverPSPNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            Render.drawModel(modBoxPSPNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
			tmpapptype = "PSP Game"
        elseif apptype==3 then
            Render.drawModel(modCoverPSXNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
            Render.drawModel(modBoxPSXNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
			tmpapptype = "PS1 Game"
        else
            Render.drawModel(modCoverHbrNoref, prevX, -1.0, -5 + prevZ, 0, math.deg(prevRot+prvRotY), 0)
			tmpapptype = "Homebrew"
        end
    
        Font.print(fnt22, 50, 190, txtname, white)-- app name
	if (psx_serial ~= nil) and (psx_serial ~= "-") then
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

		menuItems = 1
		if menuY==1 then
			Graphics.fillRect(24, 470, 350 + (menuY * 40), 430 + (menuY * 40), themeCol)-- selection two lines
		else
			Graphics.fillRect(24, 470, 350 + (menuY * 40), 390 + (menuY * 40), themeCol)-- selection
		end
		Font.print(fnt22, 50, 352, "Download Cover", white)
		Font.print(fnt22, 50, 352+40, "Override Category: < " .. tmpcatText .. " >\n(Press X to apply Category)", white)
		

		status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS) and not Controls.check(oldpad, SCE_CTRL_CROSS)) then
                if menuY == 0 then
					if gettingCovers == false then
                        gettingCovers = true
                        DownloadSingleCover()
                    end
				elseif menuY == 1 then
					OverrideCategory()
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
		
    elseif showMenu == 2 then
        
        -- SETTINGS
        -- Footer buttons and icons @@ label X's are set in function ChangeLanguage()
        Graphics.drawImage(label1AltImgX, 510, btnO)
        Font.print(fnt20, label1AltX, 508, lang_lines[11], white)--Close
        Graphics.drawImage(label2AltImgX, 510, btnX)
        Font.print(fnt20, label2AltX, 508, lang_lines[32], white)--Select
        Graphics.fillRect(60, 900, 24, 488, darkalpha)
        Font.print(fnt22, 84, 37, lang_lines[6], white)--SETTINGS
        Graphics.drawLine(60, 900, 74, 74, white)
        Graphics.fillRect(60, 900, 86 + (menuY * 40), 126 + (menuY * 40), themeCol)-- selection
        
        menuItems = 9
        
        Font.print(fnt22, 84, 90, lang_lines[14] .. ": ", white)--Startup Category
        if startCategory == 0 then
            Font.print(fnt22, 84 + 260, 90, lang_lines[5], white)--ALL
        elseif startCategory == 1 then
            Font.print(fnt22, 84 + 260, 90, lang_lines[1], white)--PS VITA
        elseif startCategory == 2 then
            Font.print(fnt22, 84 + 260, 90, lang_lines[2], white)--HOMEBREWS
        elseif startCategory == 3 then
            Font.print(fnt22, 84 + 260, 90, lang_lines[3], white)--PSP
        elseif startCategory == 4 then
            Font.print(fnt22, 84 + 260, 90, lang_lines[4], white)--PSX
        elseif startCategory == 5 then
            Font.print(fnt22, 84 + 260, 90, lang_lines[49], white)--CUSTOM
        end
        
        Font.print(fnt22, 84, 90 + 40, lang_lines[15] .. ": ", white)
        if setReflections == 1 then
            Font.print(fnt22, 84 + 260, 90 + 40, lang_lines[22], white)--ON
        else
            Font.print(fnt22, 84 + 260, 90 + 40, lang_lines[23], white)--OFF
        end
        
        Font.print(fnt22, 84, 90 + 80, lang_lines[16] .. ": ", white)--SOUNDS
        if setSounds == 1 then
            Font.print(fnt22, 84 + 260, 90 + 80, lang_lines[22], white)--ON
        else
            Font.print(fnt22, 84 + 260, 90 + 80, lang_lines[23], white)--OFF
        end
        
        Font.print(fnt22, 84, 90 + 120,  lang_lines[17] .. ": ", white)
        if themeColor == 1 then
            Font.print(fnt22, 84 + 260, 90 + 120, lang_lines[24], white)--Red
        elseif themeColor == 2 then
            Font.print(fnt22, 84 + 260, 90 + 120, lang_lines[25], white)--Yellow
        elseif themeColor == 3 then
            Font.print(fnt22, 84 + 260, 90 + 120, lang_lines[26], white)--Green
        elseif themeColor == 4 then
            Font.print(fnt22, 84 + 260, 90 + 120, lang_lines[27], white)--Grey
        elseif themeColor == 5 then
            Font.print(fnt22, 84 + 260, 90 + 120, lang_lines[28], white)--Black
        elseif themeColor == 7 then
            Font.print(fnt22, 84 + 260, 90 + 120, lang_lines[30], white)--Orange --@@reorder hack
        elseif themeColor == 6 then
            Font.print(fnt22, 84 + 260, 90 + 120, lang_lines[29], white)--Purple
        elseif themeColor == 8 then
            Font.print(fnt22, 84 + 260, 90 + 120, lang_lines[54], white)--Dark Purple
        else
            Font.print(fnt22, 84 + 260, 90 + 120, lang_lines[31], white)--Blue
        end
        
        Font.print(fnt22, 84, 90 + 160,  lang_lines[18] .. ": ", white)
        if (label3AltImgX == nil) or (label3AltImgX == 0) then --@@image alt 3 is at X900 when not in use.
	    if getBGround == 1 then
		if System.doesFileExist("ux0:/data/HexFlow/Background.jpg") or System.doesFileExist("ux0:/data/HexFlow/Background.png") then
		    BGroundText = "<  " .. lang_lines[49] .. "  >" --<  CUSTOM  >
		else
		    BGroundText = "<  " .. lang_lines[22] .. "  >" --<  ON  >
		end
	    elseif getBGround == 2 then
		BGroundText = "<  Citylights  >"
	    elseif getBGround == 3 then
		BGroundText = "<  Aurora  >"
	    elseif getBGround == 4 then
		BGroundText = "<  Wood 1  >"
	    elseif getBGround == 5 then
		BGroundText = "<  Wood 2  >"
	    elseif getBGround == 6 then
		BGroundText = "<  Dark  >"
	    elseif getBGround == 7 then
		BGroundText = "<  Marble  >"
	    elseif getBGround == 8 then
		BGroundText = "<  Retro  >"
	    else
		BGroundText = "<  " .. lang_lines[23] .. "  >" --<  OFF  >
	    end
	    label3AltImgX = 84 + 260 + Font.getTextWidth(fnt22, BGroundText) + 20
	end
	if (BGroundText == nil) or (BGroundText == "") then
	    if setBackground == 1 then
		if System.doesFileExist("ux0:/data/HexFlow/Background.jpg") or System.doesFileExist("ux0:/data/HexFlow/Background.png") then
		    BGroundText = lang_lines[49] --CUSTOM
		else
		    BGroundText = lang_lines[22] --ON
		end
	    elseif setBackground == 2 then
		BGroundText = "Citylights"
	    elseif setBackground == 3 then
		BGroundText = "Aurora"
	    elseif setBackground == 4 then
		BGroundText = "Wood 1"
	    elseif setBackground == 5 then
		BGroundText = "Wood 2"
	    elseif setBackground == 6 then
		BGroundText = "Dark"
	    elseif setBackground == 7 then
		BGroundText = "Marble"
	    elseif setBackground == 8 then
		BGroundText = "Retro"
	    else
		BGroundText = lang_lines[23] --OFF
	    end
	    label3AltImgX = 900
	end
        Font.print(fnt22, 84 + 260, 90 + 160, BGroundText, white)
	--Graphics.drawImage(label3ImgX, 90 + 160, btnX)
	
        
		if scanComplete == false then
		    if setLanguage == 2 then --French Language Fix
		        Font.print(fnt22, 84, 90 + 200, lang_lines[19] .. ":   <  " .. xCatTextLookup(getCovers) .. "  >", white)--Download Covers < PS VITA/HOMEBREWS/PSP/PSX/CUSTOM/ALL >
		    else
			Font.print(fnt22, 84, 90 + 200, lang_lines[19] .. ":", white)--Download Covers
			Font.print(fnt22, 84 + 260, 90 + 200, "<  " .. xCatTextLookup(getCovers) .. "  >", white) --PS VITA/HOMEBREWS/PSP/PSX/CUSTOM/ALL
		    end
		else
			Font.print(fnt22, 84, 90 + 200,  lang_lines[20], white)--Reload Covers Database
		end
		
        Font.print(fnt22, 84, 90 + 240, lang_lines[21] .. ": ", white)--Language
        if setLanguage == 1 then
            Font.print(fnt22, 84 + 260, 90 + 240, "German", white)
        elseif setLanguage == 2 then
            Font.print(fnt22, 84 + 260, 90 + 240, "French", white)
        elseif setLanguage == 3 then
            Font.print(fnt22, 84 + 260, 90 + 240, "Italian", white)
        elseif setLanguage == 4 then
            Font.print(fnt22, 84 + 260, 90 + 240, "Spanish", white)
        elseif setLanguage == 5 then
            Font.print(fnt22, 84 + 260, 90 + 240, "Russian", white)
        elseif setLanguage == 6 then
            Font.print(fnt22, 84 + 260, 90 + 240, "Swedish", white)
        elseif setLanguage == 7 then
            Font.print(fnt22, 84 + 260, 90 + 240, "Portugese", white)
        elseif setLanguage == 8 then
            Font.print(fnt22, 84 + 260, 90 + 240, "Polish", white)
        elseif setLanguage == 9 then
            Font.print(fnt22, 84 + 260, 90 + 240, "Japanese", white)
        elseif setLanguage == 10 then
            Font.print(fnt22, 84 + 260, 90 + 240, "Chinese", white)
        else
            Font.print(fnt22, 84 + 260, 90 + 240, "English", white)
        end
		
        Font.print(fnt22, 84, 90 + 280, lang_lines[46] .. ": ", white)--Show Homebrews
		if showHomebrews == 1 then
            Font.print(fnt22, 84 + 260, 90 + 280, lang_lines[22], white)--ON
        else
            Font.print(fnt22, 84 + 260, 90 + 280, lang_lines[23], white)--OFF
        end
		
        Font.print(fnt22, 84, 90 + 320, lang_lines[48], white)--Refresh Cache
--@@        if ????????????? == 1 then --while loading, say "please wait..."
--@@            Font.print(fnt22, 84 + 260, 90 + 320, lang_lines[52], white) --Please wait...
--@@        end
        
        Font.print(fnt22, 84, 90 + 360, lang_lines[13], white)--About
        
        status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS) and not Controls.check(oldpad, SCE_CTRL_CROSS)) then
                if menuY == 0 then
                    if startCategory < 5 then
                        startCategory = startCategory + 1
                    else
                        startCategory = 0
                    end
                elseif menuY == 1 then
                    if setReflections == 1 then
                        setReflections = 0
                    else
                        setReflections = 1
                    end
                elseif menuY == 2 then
                    if setSounds == 1 then
                        setSounds = 0
						if System.doesFileExist(cur_dir .. "/Music.mp3") then
							if Sound.isPlaying(sndMusic) then
								Sound.pause(sndMusic)
							end
						end
                    else
                        setSounds = 1
						if System.doesFileExist(cur_dir .. "/Music.mp3") then
							if not Sound.isPlaying(sndMusic) then
								Sound.play(sndMusic, LOOP)
							end
						end
                    end
                elseif menuY == 3 then
                    if themeColor == 5 then	 --@@ new 1/6. reorder hack so I can have purple after orange but keep HEXFlow Launcher 0.5 compatibility. Maybe I'll find a better solution later.
                        themeColor = 7		 --@@ new 2/6
                    elseif themeColor == 7 then	 --@@ new 3/6
                        themeColor = 6		 --@@ new 4/6
                    elseif themeColor == 6 then  --@@ new 5/6
                        themeColor = 8		 --@@ new 6/6
                    elseif themeColor < 5 then   --@@ normally "elseif themeColor < 7 then"
                        themeColor = themeColor + 1
                    else
                        themeColor = 0
                    end
                    SetThemeColor()
                elseif menuY == 4 then
                    if setBackground == getBGround then
			if getBGround > 0 then --elseif setBackground > 0.5 then --@@click "<OFF>" turns it to "OFF", also click something that's ON turns it OFF.
			    setBackground, getBGround = 0, 0
			    BGroundText = ""	 --remove brackets 1/2
			    label3AltImgX = 961	 --remove brackets 2/2
			else	 --@@ if you click OFF, turn it to ON ("< CUSTOM >")
			    setBackground, getBGround = 1, 1
			    label3AltImgX = 0 --add brackets
			    imgCustomBack = imgBack
			    if System.doesFileExist("ux0:/data/HexFlow/Background.png") then
				imgCustomBack = Graphics.loadImage("ux0:/data/HexFlow/Background.png")
				Graphics.setImageFilters(imgCustomBack, FILTER_LINEAR, FILTER_LINEAR)
				Render.useTexture(modBackground, imgCustomBack)
			    elseif System.doesFileExist("ux0:/data/HexFlow/Background.jpg") then
				imgCustomBack = Graphics.loadImage("ux0:/data/HexFlow/Background.jpg")
				Graphics.setImageFilters(imgCustomBack, FILTER_LINEAR, FILTER_LINEAR)
				Render.useTexture(modBackground, imgCustomBack)
			    else
				Render.useTexture(modBackground, imgBack)
			    end
			end
		    elseif getBGround == 0 then
			setBackground, getBGround = 0, 0
			BGroundText = ""	 --remove brackets 1/2
			label3AltImgX = 961	 --remove brackets 2/2
		    else --elseif getBGround > 0.5 then
                        setBackground = getBGround
			BGroundText = ""	 --remove brackets 1/2
			label3AltImgX = 961	 --remove brackets 2/2
			imgCustomBack = imgBack
			if (setBackground > 1.5) and (setBackground < 8.5) then
			    if System.doesFileExist("app0:/DATA/back_0" .. setBackground .. ".png") then
				imgCustomBack = Graphics.loadImage("app0:/DATA/back_0" .. setBackground .. ".png")
				Graphics.setImageFilters(imgCustomBack, FILTER_LINEAR, FILTER_LINEAR)
				Render.useTexture(modBackground, imgCustomBack)
			    end
			else
			    if System.doesFileExist("ux0:/data/HexFlow/Background.png") then
				imgCustomBack = Graphics.loadImage("ux0:/data/HexFlow/Background.png")
				Graphics.setImageFilters(imgCustomBack, FILTER_LINEAR, FILTER_LINEAR)
				Render.useTexture(modBackground, imgCustomBack)
			    elseif System.doesFileExist("ux0:/data/HexFlow/Background.jpg") then
				imgCustomBack = Graphics.loadImage("ux0:/data/HexFlow/Background.jpg")
				Graphics.setImageFilters(imgCustomBack, FILTER_LINEAR, FILTER_LINEAR)
				Render.useTexture(modBackground, imgCustomBack)
			    else
				Render.useTexture(modBackground, imgBack)
			    end
			end
                    end
                elseif menuY == 5 then
                    if gettingCovers == false then
                        gettingCovers = true
                        DownloadCovers()
                    end
                elseif menuY == 6 then
                    if setLanguage < 10 then
                        setLanguage = setLanguage + 1
                    else
                        setLanguage = 0
                    end
					ChangeLanguage()
                elseif menuY == 7 then
                    if showHomebrews == 1 then
                        showHomebrews = 0
                    else
                        showHomebrews = 1
                    end
                elseif menuY == 8 then
                    if System.doesFileExist(cur_dir .. "/apptitlecache.dat") then
                        System.deleteFile(cur_dir .. "/apptitlecache.dat")
                    end
                    FreeIcons()
                    FreeMemory()
                    Network.term()
                    dofile("app0:index.lua")
                elseif menuY == 9 then
                    showMenu = 3
                    menuY = 0
                end
                
                
                --Save settings
                local file_config = System.openFile(cur_dir .. "/config.dat", FCREATE)
		if setLanguage == 10 then --@@ Cheap workaround to add a 10th language. A clean solution has been worked out, coming in next update, but it won't be back compatible with HexFlow Launcher v0.5.
		    System.writeFile(file_config, startCategory .. setReflections .. setSounds .. themeColor .. setBackground .. "C" .. showView .. showHomebrews, 8)
		else
		    System.writeFile(file_config, startCategory .. setReflections .. setSounds .. themeColor .. setBackground .. setLanguage .. showView .. showHomebrews, 8)
		end
                System.closeFile(file_config)
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
		if menuY==4 then --Background selection --@@ [1]=Custom, [2]=Citylights, [3]=Aurora, [4]=Wood 1, [5]=Wood 2, [6]=Dark, [7]=Marble, [8]=Retro.
		    if getBGround > 0 then
			getBGround = getBGround - 1
		    else
			getBGround = 8
		    end
		    label3AltImgX = 0
		elseif menuY==5 then --covers download selection --@@ [1]=PS VITA, [2]=HOMEBREWS, [3]=PSP, [4]=PSX, [5]=CUSTOM, [default]=ALL
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
		end
            elseif (Controls.check(pad, SCE_CTRL_RIGHT)) and not (Controls.check(oldpad, SCE_CTRL_RIGHT)) then
		if menuY==4 then --Background selection --@@ [1]=Custom, [2]=Citylights, [3]=Aurora, [4]=Wood 1, [5]=Wood 2, [6]=Dark, [7]=Marble, [8]=Retro.
		    if getBGround < 8 then
			getBGround = getBGround + 1
		    else
			getBGround = 0
		    end
		    label3AltImgX = 0
		elseif menuY==5 then --covers download selection --@@ [1]=PS VITA, [2]=HOMEBREWS, [3]=PSP, [4]=PSX, [5]=CUSTOM, [default]=ALL
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
		end
	    end --End of Control Section
	end
    elseif showMenu == 3 then
        
        -- ABOUT
        -- Footer buttons and icons @@ label X's are set in ChangeLanguage()
        Graphics.drawImage(label1AltImgX, 510, btnO)
        Font.print(fnt20, label1AltX, 508, lang_lines[11], white)--Close
        
        Graphics.fillRect(30, 930, 24, 496, darkalpha)-- bg
        
        Font.print(fnt20, 54, 42, "HexLauncher Custom - ver." .. appversion .. " by BlackSheepBoy69\nRevamp mod for VitaHEX's HexFlow Launcher 0.5\nSupport the original creator on patreon.com/vitahex", white)-- Draw info
        Font.print(fnt15, 690, 42, "Sort time: ".. sortTime .. " ms.\nRead time: ".. applistReadTime .. " ms.\nFunction Load time: ".. functionTime .. " ms.\nOne Loop time: ".. oneLoopTime .. " ms.", white)
        Graphics.drawLine(30, 930, 124, 124, white)
        Graphics.drawLine(30, 930, 364, 364, white)
        Font.print(fnt20, 54, 132, "Custom Covers\nPlace your custom covers in 'ux0:/data/HexFlow/COVERS/PSVITA' or '/PSP' or '/PS1'\nCover images must be in png format and file name must match the App ID or the App Name"
            .. "\n\nCustom Background\nPlace your custom background image in 'ux0:/data/HexFlow/'\nBackground image must be named 'Background.jpg' or 'Background.png' (1280 x 720 max)"
            .. "\n\nCustom Category\nTake the file 'ux0:/data/HexFlow/applist.dat' and rename it to customsort.dat then\nrearrange the titles how you like. It will spawn in a new category ('Custom')"
            .. "\n\nOriginal app by VitaHEX. OG code by Sakis RG. Lua Player Plus by Rinnegatamante."
            .. "\nSpecial Thanks: VitaHEX and everyone who worked on HexFlow Launcher 0.5 which this"
            .. "\nis based on. jimbob4000 and everyone who worked on RetroFlow Launcher 3.0, from whom"
            .. "\na lot of inspiration and a little code was taken. Google Translate, and one or more coders"
            .. "\nwho helped in HexLauncher Custom who wish to remain anonymous", white)-- Draw info
    
    end
    
    -- Terminating rendering phase
    Graphics.termBlend()
    if showMenu == 1 then
        --Left Analog rotate preview box
        if mx < 64 then
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
        --Navigation Left Analog
        if mx < 64 then
            if delayButton < 0.5 then
                delayButton = 1
                if setSounds == 1 then
                    Sound.play(click, NO_LOOP)
                end
                p = p - 1
                
                if p > 0 then
                    GetInfoSelected()
                end
                
                if (p <= master_index) then
                    master_index = p
                end
            end
        elseif mx > 180 then
            if delayButton < 0.5 then
                delayButton = 1
                if setSounds == 1 then
                    Sound.play(click, NO_LOOP)
                end
                p = p + 1
                
                if p <= curTotal then
                    GetInfoSelected()
                end
                
                if (p >= master_index) then
                    master_index = p
                end
            end
        end
        
        -- Navigation Buttons
        if (Controls.check(pad, SCE_CTRL_CROSS) and not Controls.check(oldpad, SCE_CTRL_CROSS)) then
            if gettingCovers == false and app_title~="-" then
                FreeMemory()
		local Working_Launch_ID = xCatLookup(showCat)[p].name --@@ Example: VITASHELL
                System.launchApp(Working_Launch_ID)
                System.exit()
            end
        elseif (Controls.check(pad, SCE_CTRL_TRIANGLE) and not Controls.check(oldpad, SCE_CTRL_TRIANGLE)) then
            if showMenu == 0 and app_title~="-" then
				prvRotY = 0
		GetHeavyInfoSelected()
                showMenu = 1
            end
        elseif (Controls.check(pad, SCE_CTRL_START) and not Controls.check(oldpad, SCE_CTRL_START)) then
            if showMenu == 0 then
		getBGround = setBackground
		label3AltImgX = 0
                showMenu = 2
            end
	elseif (Controls.check(pad, SCE_CTRL_SELECT) and not Controls.check(oldpad, SCE_CTRL_SELECT)) then
	    System.setMessage(Font.getTextWidth(fnt22, BGroundText), false, BUTTON_OK)
        elseif (Controls.check(pad, SCE_CTRL_SQUARE) and not Controls.check(oldpad, SCE_CTRL_SQUARE)) then
            -- CATEGORY
            if showCat < 5 then
	        if showCat==1 and showHomebrews==0 then
		    showCat = 3
		elseif showCat == 4 and System.doesFileExist(cur_dir .. "/customsort.dat") == false then
		    showCat = 0
		else
		    showCat = showCat + 1
		end
            else
                showCat = 0
            end
            hideBoxes = 8
            p = 1
            master_index = p
            startCovers = false
            GetInfoSelected()
            FreeIcons()
        elseif (Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldpad, SCE_CTRL_CIRCLE)) then
            -- VIEW
            if showView < 4 then
                showView = showView + 1
            else
                showView = 0
            end
            menuY = 0
            startCovers = false
			local file_config = System.openFile(cur_dir .. "/config.dat", FCREATE)
            System.writeFile(file_config, startCategory .. setReflections .. setSounds .. themeColor .. setBackground .. setLanguage .. showView .. showHomebrews, 8)
            System.closeFile(file_config)
        elseif (Controls.check(pad, SCE_CTRL_LEFT)) and not (Controls.check(oldpad, SCE_CTRL_LEFT)) then
            if setSounds == 1 then
                Sound.play(click, NO_LOOP)
            end
            p = p - 1
            
            if p > 0 then
                GetInfoSelected()
            end
            
            if (p <= master_index) then
                master_index = p
            end
        elseif (Controls.check(pad, SCE_CTRL_RIGHT)) and not (Controls.check(oldpad, SCE_CTRL_RIGHT)) then
            if setSounds == 1 then
                Sound.play(click, NO_LOOP)
            end
            p = p + 1
            
            if p <= curTotal then
                GetInfoSelected()
            end
            
            if (p >= master_index) then
                master_index = p
            end
        elseif (Controls.check(pad, SCE_CTRL_LTRIGGER)) and not (Controls.check(oldpad, SCE_CTRL_LTRIGGER)) then
            if setSounds == 1 then
                Sound.play(click, NO_LOOP)
            end
            p = p - 5
            
            if p > 0 then
                GetInfoSelected()
            end
            
            if (p <= master_index) then
                master_index = p
            end
        elseif (Controls.check(pad, SCE_CTRL_RTRIGGER)) and not (Controls.check(oldpad, SCE_CTRL_RTRIGGER)) then
            if setSounds == 1 then
                Sound.play(click, NO_LOOP)
            end
            p = p + 5
            
            if p <= curTotal then
                GetInfoSelected()
            end
            
            if (p >= master_index) then
                master_index = p
            end
        
        end
        
        -- Touch Input
        if x1 ~= nil then
            if xstart == nil then
		--@@Start tracking touch upon touchdown:
                xstart = x1
            end
            if showView == 1 then
		-- flat zoom out view - pan camera 1/487 p per pixel moved.
	        targetX = targetX + ((x1 - xstart) / 487)
	    elseif (showView == 2) or (showView == 3) then
		-- zoomin view & left side view - pan camera 1/1000 p per pixel moved.
	        targetX = targetX + ((x1 - xstart) / 1000)
	    else
		-- all other views - pan camera 1/700 p per pixel moved.
	        targetX = targetX + ((x1 - xstart) / 700)
	    end
            if x1 > xstart + 60 then
                xstart = x1
                p = p - 1
                if p > 0 then
                    GetInfoSelected()
                end
                if (p <= master_index) then
                    master_index = p
                end
            elseif x1 < xstart - 60 then
                xstart = x1
                p = p + 1
                if p <= curTotal then
                    GetInfoSelected()
                end
                if (p >= master_index) then
                    master_index = p
                end

            end
	elseif xstart ~= nil then
	    -- clear touch data upon touch off (important), NOT clear touch data based on a timer like HEXFlow 0.5
	    xstart = nil
        end
    -- End Touch
    elseif showMenu > 0 then
        if (Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldpad, SCE_CTRL_CIRCLE)) then
            status = System.getMessageState()
            if status ~= RUNNING then
                showMenu = 0
                prvRotY = 0
                if setBackground > 0.5 then
                    Render.useTexture(modBackground, imgCustomBack)
                end
            end
        end
    end
    -- End Controls
    curTotal = #xCatLookup(showCat) --@@number of entries in the category shown.
    if curTotal == 0 then
        p = 0 --@@Lock into position 0 in empty categories.
        master_index = p
    end
    
    -- Check for out of bounds in menu
    if p < 1 then
        p = curTotal
        if p >= 1 then
            master_index = p -- 0
        end
        startCovers = false
        GetInfoSelected()
    elseif p > curTotal then
        p = 1
        master_index = p
        startCovers = false
        GetInfoSelected()
    end
    
    -- Refreshing screen and oldpad
    Screen.waitVblankStart()
    Screen.flip()
    oldpad = pad
    
    if bOneLoop == false then
        bOneLoop = true
        oneLoopTime = Timer.getTime(oneLoopTimer)
        Timer.destroy(oneLoopTimer)
    end 
end
