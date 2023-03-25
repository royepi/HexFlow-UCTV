-- HexFlow Launcher Custom version 1.0.1
-- based on VitaHEX's HexFlow Launcher v0.5 + SwitchView UI v0.1.2, and jimbob4000's Retroflow v3.6.1
-- https://www.patreon.com/vitahex
-- Want to make your own version? Right-click the vpk and select "Open with... Winrar" and edit the index.lua inside.

local oneLoopTimer = Timer.new()	 --Startup speed timer, view result in menu>about

dofile("app0:addons/threads.lua")
local working_dir = "ux0:/app"
local appversion = "1.0.1"
function System.currentDirectory(dir)
    if dir == nil then
        return working_dir --"ux0:/app"
    else
        working_dir = dir
    end
end

Network.init()	 --@@ NEW! Now using the Retroflow cover archive: more homebrew covers and it's just more complete in general.
local onlineCovers = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/PSVita/"
local onlineCoversPSP = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/PSP/"
local onlineCoversPSX = "https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/PS1/"

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
local imgCacheIcon = Graphics.loadImage("app0:/DATA/cache_icon_25x25.png")
local imgBack = Graphics.loadImage("app0:/DATA/back_01.jpg")
local imgFloor = Graphics.loadImage("app0:/DATA/floor.png")
Graphics.setImageFilters(imgFloor, FILTER_LINEAR, FILTER_LINEAR)

local SwitchviewAssetsAreLoaded = false				 --@@ NEW!

-- Footer button margins
local btnMargin = 44	 --Retroflow: 64. HEXFlow: ~46
local btnImgWidth = 20
--local btnImgWidth = Graphics.getImageWidth("app0:/DATA/x.png") --20

--@@ Footer button X coordinates. Calculated in changeLanguage() (except new alt 3). Alts are for start menu.
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
local toggle1X = nil	 --@@ NEW!
local toggle2X = nil	 --@@ NEW!

local working_text = ""
local byte_errorlevel = ""
local spin_allowance = 0	  --@@ NEW
local bottomMenu = false	  --@@ NEW!
local menuSel = 1		  --@@ NEW!
local render_distance = 8	  --@@ NEW!

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

--local fnt = Font.load("app0:/DATA/font.ttf")
local fnt15 = Font.load("app0:/DATA/font.ttf")
local fnt20 = Font.load("app0:/DATA/font.ttf")
local fnt22 = Font.load("app0:/DATA/font.ttf")
local fnt25 = Font.load("app0:/DATA/font.ttf")
--local fnt35 = Font.load("app0:/DATA/font.ttf")

Font.setPixelSizes(fnt15, 15)
Font.setPixelSizes(fnt20, 20)
Font.setPixelSizes(fnt22, 22)
Font.setPixelSizes(fnt25, 25)
--Font.setPixelSizes(fnt35, 35)


local menuX = 0
local menuY = 0
local showMenu = 0
local showCat = 1 -- Category: 0 = all, 1 = games, 2 = homebrews, 3 = psp, 4 = psx, 5 = custom
local showView = 0

local info = System.extractSfo("app0:/sce_sys/param.sfo")
local app_version = info.version
local app_title = info.title
sanitized_title = app_title --@@string.gsub(app_title, "\n", " ")	 --@@ NEW!
local app_category = info.category
local app_titleid = info.titleid
local app_titleid_psx = 0	 --@@NEW. Workaround for PSX single cover download.
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
local purple = Color.new(151, 0, 185)
local orange = Color.new(220, 120, 0)
local darkpurple = Color.new(77, 4, 160)
local lightblue = Color.new(67,178,255)      --@@ NEW! "blue" from SwitchView UI v0.1.2
local greyalpha = Color.new(45, 45, 45, 180) --@@ NEW! "grey" theme becomes greyalpha in view #5.
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
local background_brackets = true
local verif_ref = 0
local v_info = 0

local prevX = 0
local prevZ = 0
local prevRot = 0

--@@local total_all = 0
--@@local total_games = 0
--@@local total_homebrews = 0
--@@local total_pspemu = 0
--@@local total_roms = 0
local working_entry_count = 0
local curTotal = 1

-- Settings
local startCategory = 1
local setReflections = 1
local setSounds = 1
local musicLoop = 1		 --@@ NEW
local themeColor = 0 -- 0 blue, 1 red, 2 yellow, 3 green, 4 grey, 5 black, 7 orange, 6 purple, 8 darkpurple. (reorder hack) 
local menuItems = 3 
local setBackground = 1 
local setLanguage = 0 
local showHomebrews = 0 
local setSwitch = 0		 --@@ NEW 
local proTriangleMenu = 0	 --@@ NEW but unused
local setRetroFlow = 0		 --@@ NEW 
local hideEmptyCats = 0		 --@@ NEW 
local dCategoryButton = 0	 --@@ NEW 
local smoothView = 0		 --@@ NEW 
local superSkip = 1		 --@@ NEW but lacking start menu entry
local View5VitaCropTop = 1	 --@@ NEW
local lockView = 0		 --@@ NEW

function write_config()	 --@@ NEW! This function called 1: when config.dat doesn't exist, 2: when current view mode or any start menu setting is changed
    local file_config = System.openFile(cur_dir .. "/config.dat", FCREATE)
    writeLanguage, writeBackground = nil, nil
    if setLanguage == 10 then writeLanguage = "C" end
    if setBackground == 10 then writeBackground = "W"
    elseif setBackground == 11 then writeBackground = "P"
    elseif setBackground == 12 then writeBackground = "Q"
    elseif setBackground == 13 then writeBackground = "M" end
    System.writeFile(file_config, startCategory .. setReflections .. setSounds .. themeColor .. (writeBackground or setBackground) .. (writeLanguage or setLanguage) .. showView .. showHomebrews .. musicLoop .. setSwitch .. hideEmptyCats .. dCategoryButton .. View5VitaCropTop .. setRetroFlow .. lockView .. proTriangleMenu, 16)
    System.closeFile(file_config)
end

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
--location:	     65, 66, 67, 68, 69  70  71  72  73  74  75  76  77  78  79  80  81  82  83  84  85  86  87  88  89  90  91  92  93 ...
--string.byte val:  117 120 48  58  112 115 112 101 109 117 47  112 115 112 47  103 97  109 101 47  115 108 117 115 48  48  52  53  51 ...
--string.char val:  u   x   0   :   p   s   p   e   m   u   /   p   s   p   /   g   a   m   e   /   s   l   u   s   0   0   4   5   3   /eboot.pbp
--
function readBin(filename)
    local path_game = nil
    if System.doesFileExist(filename) and string.match(filename, ".bin") then
	local inp = assert(io.open(filename, "rb"), "Failed to open boot.bin") --@@ I feel assert should be used to prevent rest of this function if fail.
	local data = inp:read(94)	 --@@ used to be: inp:read("*all"). Revert if psp scan is added.
	inp:close()

	-- If you read a blanked binary (from a psp bubble created manually, back before adrenaline bubble manager), the app may crash on startup? Untested.
	-- untested code marked with "--#"

	if string.sub(data, 67, 67) == "0" then		    --ux0
	    --#if string.sub(data, 76, 76) == "p" then	    --ux0:pspemu/p   [sp/game/] (ps1 & eboots)
		path_game = string.sub(data, 85, 93)	    --@@ example: "slus00453"
	    --#elseif string.sub(data, 76, 76) == "i" then  --ux0:pspemu/i   [so/] (normal psp iso files)
	    --#--@@blah blah scan psp iso param blah blah
	    --#end
	elseif string.sub(data, 68, 68) == "0" then	    --uma0  (memory card #2)
	    --#if string.sub(data, 77, 77) == "p" then	    --uma0:pspemu/p  [sp/game/]
		path_game = string.sub(data, 86, 94)	    --@@ example: "slus00453"
	    --#elseif string.sub(data, 77, 77) == "i" then  --uma0:pspemu/i  [so/]
	    --#--@@blah blah scan psp iso param blah blah
	    --#end
	end
    end
    if path_game and not path_game:match("%W") then	    --@@ NEW! if path_game isn't nil, and it does NOT contain any NON-alphanumeric characters then...
	return path_game:upper()			    -- Example: SLUS00453
    else						    --@@ NEW!
	return "-"					    --@@ NEW! "-" debug character allows cleaner code in function OverrideCategory()
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
    if not (string.sub(str, 5, 5) ~= "P") then setBackground = 11 end --@@ Cheap workaround to add a 11th background. (1/2)
    if not (string.sub(str, 5, 5) ~= "Q") then setBackground = 12 end --@@ Cheap workaround to add a 12th background. (1/2)
    if not (string.sub(str, 5, 5) ~= "M") then setBackground = 12 end --@@ Cheap workaround to add a 12th background. (1/2)
    local getLanguage = tonumber(string.sub(str, 6, 6)); if getLanguage ~= nil then setLanguage = getLanguage end
    if not (string.sub(str, 6, 6) ~= "C") then setLanguage = 10 end --@@ Cheap workaround to add a 10th language. (1/2)
    local getView = tonumber(string.sub(str, 7, 7)); if getView ~= nil then showView = getView end
    local getHomebrews = tonumber(string.sub(str, 8, 8)); if getHomebrews ~= nil then showHomebrews = getHomebrews end
    local getMusicLoop = tonumber(string.sub(str, 9, 9)); if getMusicLoop ~= nil then musicLoop = getMusicLoop end	    --@@ NEW!
    local getSwitch = tonumber(string.sub(str, 10, 10)); if getSwitch ~= nil then setSwitch = getSwitch end		    --@@ NEW!
    local getHempCats = tonumber(string.sub(str, 11, 11)); if getHempCats ~= nil then hideEmptyCats = getHempCats end	    --@@ NEW! @@ get hemp cats lol
    local getCButton = tonumber(string.sub(str, 12, 12)); if getCButton ~= nil then dCategoryButton = getCButton end	    --@@ NEW!
    local getV5CropTop = tonumber(string.sub(str, 13, 13)); if getV5CropTop ~= nil then View5VitaCropTop = getV5CropTop end --@@ NEW!
    local getRetroFlow = tonumber(string.sub(str, 14, 14)); if getRetroFlow ~= nil then setRetroFlow = getRetroFlow end	    --@@ NEW!
    local getLockView = tonumber(string.sub(str, 15, 15)); if getLockView ~= nil then lockView = getLockView end	    --@@ NEW!
    local getTriMenu = tonumber(string.sub(str, 16, 16)); if getTriMenu ~= nil then proTriangleMenu = getTriMenu end	    --@@ NEW!
else
    write_config()
end
if showView == 5 then
    fnt23_5 = Font.load("app0:/DATA/font.ttf")
    Font.setPixelSizes(fnt23_5, 23.5)
    imgCart = Graphics.loadImage("app0:/DATA/cart.png")
    --@@imgAvatar = Graphics.loadImage("app0:/AVATARS/AV01.png")
    btnMenu1 = Graphics.loadImage("app0:/DATA/btm1.png")
    btnMenu2 = Graphics.loadImage("app0:/DATA/btm2.png")
    btnMenu3 = Graphics.loadImage("app0:/DATA/btm3.png")
    btnMenu4 = Graphics.loadImage("app0:/DATA/btm4.png")
    btnMenu5 = Graphics.loadImage("app0:/DATA/btm5.png")
    btnMenu6 = Graphics.loadImage("app0:/DATA/btm6.png")
    btnMenuSel = Graphics.loadImage("app0:/DATA/selct.png")
    SwitchviewAssetsAreLoaded = true
end
if dCategoryButton == 1 then			  --@@ NEW!
    btnD = Graphics.loadImage("app0:/DATA/d.png") --@@ NEW! This stupid image takes so long to load, f*ck knows why.
    btDIsLoaded = true				  --@@ NEW!
end						  --@@ NEW!
    
showCat = startCategory

-- Custom Backgrounds
function ApplyBackground()
    imgCustomBack = imgBack
    if (setBackground >= 10) and (setBackground < 99) and (System.doesFileExist("app0:/DATA/back_" .. setBackground .. ".png")) then
	imgCustomBack = Graphics.loadImage("app0:/DATA/back_" .. setBackground .. ".png") --@@ default BG's "back_10.png" through "back_12.png"
    elseif (setBackground > 1.5) and (setBackground < 10) and (System.doesFileExist("app0:/DATA/back_0" .. setBackground .. ".png")) then
	imgCustomBack = Graphics.loadImage("app0:/DATA/back_0" .. setBackground .. ".png") --@@ default BG's "back_02.png" through "back_08.png"
    elseif System.doesFileExist("ux0:/data/HexFlow/Background.png") then
	imgCustomBack = Graphics.loadImage("ux0:/data/HexFlow/Background.png")		   --@@ BG custom png
    elseif System.doesFileExist("ux0:/data/HexFlow/Background.jpg") then
	imgCustomBack = Graphics.loadImage("ux0:/data/HexFlow/Background.jpg")		   --@@ BG custom jpg
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
	    return	 --@@ closes the play_music function before it causes a crash due to no music file existing.
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

-- Speed related settings
local cpu_speed = 444
System.setBusSpeed(222)
System.setGpuSpeed(222)
System.setGpuXbarSpeed(166)
System.setCpuSpeed(cpu_speed)

function OneShotPrint(my_func)
	local loadingCacheImg = Graphics.loadImage("app0:/DATA/oneshot_cache_write.png")
	-- Draw loading screen for caching process
	Graphics.termBlend()  -- End main loop blending if still running
	Graphics.initBlend()
	Screen.clear(black)
	Graphics.drawImage(0, 0, loadingCacheImg) --@@in the future, replace "loadingCache" image with a textless version of bg.png and write the text using "old" font from data folder.
	Graphics.drawImage(587, 496, imgCacheIcon)
	Graphics.termBlend()
	Screen.flip()
	Graphics.freeImage(loadingCacheImg)
end

local lang_lines = {}
local lang_default = "PS VITA\nHOMEBREWS\nPSP\nPS1\nALL\nSETTINGS\nLaunch\nDetails\nCategory\nView\nClose\nVersion\nAbout\nStartup Category\nReflection Effect\nSounds\nTheme Color\nCustom Background\nDownload Covers\nReload Covers Database\nLanguage\nON\nOFF\nRed\nYellow\nGreen\nGrey\nBlack\nPurple\nOrange\nBlue\nSelect"
		  .. "Nintendo 64\nSuper Nintendo\nNintendo Entertainment System\nGame Boy Advance\nGame Boy Color\nGame Boy\nSega Genesis/Mega Drive\nSega Master System\nSega Game Gear\nMAME\nAmiga\nTurboGrafx-16\nPC Engine\nHomebrews Category\nStartup scan\nRefresh cache\nCUSTOM\nCover style\nScan\nPlease wait...\nMenu\nDark Purple"
		  .. "Done. Please 'Refresh cache' via the start menu\nCover * found!\nCache has been updated.\nwriting to cache... please don't suspend/power off"
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
    
    toggle1X = nil	 --@@ NEW!
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
	Graphics.freeImage(imgCart)
	--@@Graphics.freeImage(imgAvatar)
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

function appt_hotfix(apptype)
    if apptype == 2 then
	return 3
    elseif apptype == 3 then
	return 4
    elseif apptype == 0 or apptype == 4 then
	return 2
    else		 --@@ vita
	return apptype
    end
end

function coversptable(getCovers) --@@For categorical cover download (1/2)
    if getCovers == 2 then
	return covers_psp
    elseif getCovers == 3 then
	return covers_psx
    else		 --@@ vita & homebrew (0, 1, and 4)
	return covers_psv
    end
end

--@@ NEW! Resets table entry specifications (app_type and icon_path) based on override.dat
function Respec_Entry(file, pspemu_translate_tmp, ovrrd_str)
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

    custom_path =    coversptable(file.app_type) .. app_title .. ".png"
    custom_path_id = coversptable(file.app_type) .. file.name .. ".png"
    if file.app_type == 3 then
	--@@table.insert(psx_table, file) @@ Can't believe this line got left in the v1.0 release accidentally.
	if not pspemu_translate_tmp then
	    pspemu_translate_tmp = readBin(working_dir .. "/" .. file.name .. "/data/boot.bin")	 --@@ example: "SLUS00453"
	end
	if pspemu_translate_tmp ~= "-" then
	    custom_path_psx = covers_psx .. pspemu_translate_tmp .. ".png"
	end
    end

    if custom_path and System.doesFileExist(custom_path) then
	file.icon_path = custom_path --custom cover by app name
    elseif custom_path_id and System.doesFileExist(custom_path_id) then
	file.icon_path = custom_path_id --custom cover by app id
    elseif custom_path_psx and System.doesFileExist(custom_path_psx) then
	file.icon_path = custom_path_psx --custom cover by special ps1 ID read from binary.
    else
	if System.doesFileExist("ur0:/appmeta/" .. file.name .. "/icon0.png") then
	    file.icon_path = "ur0:/appmeta/" .. file.name .. "/icon0.png"  --app icon
	else
	    file.icon_path = "app0:/DATA/noimg.png" --blank grey
	end
    end
    return file.app_type, file.icon_path
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
    --@@ pspemu_translation_table = {} @@ UNUSED. For filtering Adrenaline LAUNCHER vs Adrenaline MANAGER entries.
    -- app_type = 0 -- 0 homebrew, 1 psvita, 2 psp, 3 psx
	
    local file_over = System.openFile(cur_dir .. "/overrides.dat", FREAD)
    local filesize = System.sizeFile(file_over)
    local ovrrd_str = System.readFile(file_over, filesize)
    System.closeFile(file_over)
    
    --@@ psx.lua taken from Retroflow 3.4 and completely repurposed
    local file_over = System.openFile("app0:addons/psx.lua", FREAD)
    local filesize = System.sizeFile(file_over)
    local psxdb = System.readFile(file_over, filesize)
    System.closeFile(file_over)

    for i, file in pairs(dir) do
	local custom_path, custom_path_id, custom_path_psx, app_type, pspemu_translate_tmp = nil, nil, nil, nil, nil
        if file.directory == true then
	    -- START FOLDER-TYPE GAMES SCAN
            -- get app name to match with custom cover file name
            if System.doesFileExist(working_dir .. "/" .. file.name .. "/sce_sys/param.sfo") then
                info = System.extractSfo(working_dir .. "/" .. file.name .. "/sce_sys/param.sfo")
                app_title = info.title
            end

            if string.match(file.name, "PCS") and not string.match(file.name, "PCSI") then
                -- Scan PSVita Games
		file.app_type=1
            elseif System.doesFileExist(working_dir .. "/" .. file.name .. "/data/boot.bin") and not System.doesFileExist("ux0:pspemu/PSP/GAME/" .. file.name .. "/EBOOT.PBP") then
                -- Scan PSP Games (and improperly ID'd PS1 games)
		pspemu_translate_tmp = readBin(working_dir .. "/" .. file.name .. "/data/boot.bin")	 --@@ example: "SLUS00453"
		if pspemu_translate_tmp and pspemu_translate_tmp ~= "-" and string.match(psxdb, pspemu_translate_tmp) then
		    --@@pspemu_translation_table[file.name] = pspemu_translate_tmp			 --@@ UNUSED. For filtering Adrenaline LAUNCHER vs Adrenaline MANAGER entries.
		    -- PSX
		    file.app_type=3
		else
		    -- PSP
		    file.app_type=2
		end
            elseif System.doesFileExist(working_dir .. "/" .. file.name .. "/data/boot.bin") and System.doesFileExist("ux0:pspemu/PSP/GAME/" .. file.name .. "/EBOOT.PBP") then
                -- Scan PSX Games
		file.app_type=3
            else
                -- Scan Homebrews.
		file.app_type=0
            end
	    table.insert(folders_table, file)
--@@	    -- END FOLDER-TYPE GAMES SCAN
--@@	else
--@@	    -- START ROM GAMES SCAN
--@@	    --blah blah indentification blah blah system overrides blah blah
--@@	    --@@ Please note: the retroflow implementation in HexLauncher Custom V1.0 bugtester edition uses cache import and doesn't actually have rom-scan ability (yet?)
--@@	    --blah blah insert to files_table
--@@	    -- END ROM GAMES SCAN
        end

	-- Respec applies overrides, adds item to table, and sets icon_path. Also used for instant inline overrides.
	file.app_type, file.icon_path = Respec_Entry(file, pspemu_translate_tmp, ovrrd_str)
		
		
        --add blank icon to all
        file.icon = imgCoverTmp
        
        file.apptitle = app_title
        
    end
    --#return_table = TableConcat(folders_table, files_table)
    --#table.sort(return_table, function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)

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
                
                --@@if file.app_type == 0 then
                --@@    table.insert(homebrews_table, file)
                if file.app_type == 1 then
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
    ReadCustomSort()
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

function GetNameSelected() --@@NEW! This gives a massive performance boost VS reading whole app info.
    if #xCatLookup(showCat) > 0 then	 --if the currently-shown category isn't empty
	app_title = xCatLookup(showCat)[p].apptitle
    else
	app_title = "-"
    end
end

function GetInfoSelected()
    if #xCatLookup(showCat) > 0 then --if the currently-shown category isn't empty then:
        if System.doesFileExist(working_dir .. "/" .. xCatLookup(showCat)[p].name .. "/sce_sys/param.sfo") then
	    appdir=working_dir .. "/" .. xCatLookup(showCat)[p].name	 --@@example: "ux0:app/SLUS00453"
            info = System.extractSfo(appdir .. "/sce_sys/param.sfo")
            icon_path = "ur0:/appmeta/" .. xCatLookup(showCat)[p].name .. "/icon0.png"
            pic_path = "ur0:/appmeta/" .. xCatLookup(showCat)[p].name .. "/pic0.png"
	    app_title = tostring(info.title)
	    sanitized_title = string.gsub(app_title, "\n", " ")	 --@@ NEW!
	    apptype = xCatLookup(showCat)[p].app_type
        end
    else
        app_title = "-"
    end
    app_titleid = tostring(info.titleid)	 --@@ (1/2) May cause a crash if Emu-launch is added.
    app_version = tostring(info.version)	 --@@ (2/2)
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

function close_triangle_preview()
    GetNameSelected()
    oldpad = pad	 --@@ NEW! prevents it from launching next game accidentally.
    showMenu = 0
    prvRotY = 0
    spin_allowance = 0	 --@@ NEW!
    if setBackground > 0.5 then
	Render.useTexture(modBackground, imgCustomBack)
    end
end

function check_for_out_of_bounds()
    curTotal = #xCatLookup(showCat) --@@number of entries in the category shown.
    if curTotal == 0 then
        p = 0 --@@Lock into position 0 in empty categories.
        master_index = p
    end
    if p < 1 then
        p = curTotal
	if showView == 5 then		 --@@ NEW!
	    if curTotal > 3 then	 --@@ NEW!
		master_index = p - 3	 --@@ NEW!
	    else			 --@@ NEW!
		master_index = 1	 --@@ NEW! In SwitchView, don't move the camera in categories with less than 3 entries.
	    end				 --@@ NEW!
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

local rolling_overrides = true
function OverrideCategory()
    --@@[1]=VITA, [2]=PSP, [3]=PS1, [4]=HOMEBREWS. (0 is default but it does nothing right now)
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
	--@@inf:write(lines)				 --@@ (1/4) Didn't work quite right in v1.0.0, so now in v1.0.1 it has been restored to be like the very old versions.
	inf:close()
	file = io.open(cur_dir .. "/overrides.dat", "w") --@@ (2/4)
	file:write(lines)				 --@@ (3/4)
	file:close()					 --@@ (4/4)

	if rolling_overrides then
	    -- Respec applies overrides, adds item to table, and set icon_path. @@ Also used during the "listDirectory" app scan.
	    xCatLookup(showCat)[p].app_type, xCatLookup(showCat)[p].icon_path = Respec_Entry(xCatLookup(showCat)[p], nil, lines)
	    -- force icon change
	    xCatLookup(showCat)[p].ricon = Graphics.loadImage(xCatLookup(showCat)[p].icon_path)

	    UpdateCacheSect(app_titleid, 7, tmpappcat)
	    UpdateCacheSect(app_titleid, 4, xCatLookup(showCat)[p].icon_path)

	    -- Tidy up: remove game from old table, sort target table.
	    for k, v in pairs(xCatLookup(appt_hotfix(apptype))) do
		if (v.name ~= nil) and (v.name == app_titleid) then
		    table.remove(xCatLookup(appt_hotfix(apptype)), k)
		    break
		end
	    end
	    table.sort(xCatLookup(appt_hotfix(tmpappcat)), function(a, b) return (a.apptitle:lower() < b.apptitle:lower()) end)
	    
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
    elseif showView ~= 5 then	 --@@ NOTE: ~=
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
	if showView == 5 then	 --@@ NEW! SwitchView UI v0.1.2 integration!!!
	    if sel and not bottomMenu then
		Graphics.fillRect(x*200+85-6, x*200+85+198,152-6,152+198,lightblue)
	    end
	    View5IconHeightBaseTmp = Graphics.getImageHeight(icon)
	    if (apptype==1) and (View5VitaCropTop == 1) and (View5IconHeightBaseTmp ~= 128) then
		View5IconHeightModTmp = math.ceil(Graphics.getImageHeight(icon)*31/320)	 --@@ <--- this is how big the blue top of the vita cover is - 29/320 will work but 31/320 looks better. @@ dear future self... good luck figuring out the below line.
		Graphics.drawImageExtended(x*200+85+96, 152+96, icon, 0, View5IconHeightModTmp, Graphics.getImageWidth(icon), View5IconHeightBaseTmp-View5IconHeightModTmp, 0, 192 / Graphics.getImageWidth(icon), 192 / (View5IconHeightBaseTmp-View5IconHeightModTmp))
	    else
		Graphics.drawScaleImage(x*200+85, 152, icon, 192 / Graphics.getImageWidth(icon), 192 / View5IconHeightBaseTmp) --@@ NEW!
	    end
        elseif apptype==1 then
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

function DownloadSingleCover()
    cvrfound = 0
    app_idx = p
    running = false
    status = System.getMessageState()

    local coverspath = ""
    local onlineCoverspath = ""

    if Network.isWifiEnabled() then
	local app_titleid_psx = nil
	if (apptype == 3) and (psx_serial ~= nil) and (psx_serial ~= "-") then
	    app_titleid_psx = psx_serial
	end
	coverspath = coversptable(apptype)
	onlineCoverspath = onlcovtable(apptype)
	--@@ covers_psv:	 ux0:/data/HexFlow/COVERS/PSVITA/
	--@@ onlineCovers:	 https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/PSVita/
	--@@ covers_psp:	 ux0:/data/HexFlow/COVERS/PSP/
	--@@ onlineCoversPSP:	 https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/PSP/
	--@@ covers_psx:	 ux0:/data/HexFlow/COVERS/PSX/
	--@@ onlineCoversPSX:	 https://raw.githubusercontent.com/jimbob4000/hexflow-covers/main/Covers/PS1/

	Network.downloadFile(onlineCoverspath .. (app_titleid_psx or app_titleid) .. ".png", "ux0:/data/HexFlow/" .. app_titleid .. ".png")
	local new_path = coverspath .. (app_titleid_psx or app_titleid) .. ".png"

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
			
	    -- Update cache if it exists
	    UpdateCacheSect(app_titleid, 4, new_path)
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

function RestoreAppTitle()	 --@@ NEW!
    local running = false
    status = System.getMessageState()
    if status ~= RUNNING then
	if xCatLookup(showCat)[p].apptitle ~= sanitized_title then
	    xCatLookup(showCat)[p].apptitle = sanitized_title
	    UpdateCacheSect(app_titleid, 5, sanitized_title)
	    System.setMessage(lang_lines[57], false, BUTTON_OK) --Cache has been updated.
	else
	    System.setMessage("Can't restore, app hasn't been renamed. To do so, please edit ux0:data/HexFlow/apptitlecache.dat\nNote: 'refresh cache' & 'refresh icons' will reset this file.", false, BUTTON_OK)
	end
    end
end

function p_plus(plus_num)
    if setSounds == 1 then
	Sound.play(click, NO_LOOP)
    end
    if bottomMenu == true then			 --@@ NEW!
	menuSel = menuSel + 1			 --@@ NEW!
	if (menuSel>6) then			 --@@ NEW!
	    menuSel=1				 --@@ NEW!
	end					 --@@ NEW!
    else					 --@@ NEW!
	p = p + plus_num
	if p <= curTotal then
	    GetNameSelected()
	end
	if (showView == 5) then			 --@@ NEW!
	    if (p >= master_index+3) then	 --@@ NEW!
		master_index = p - 3		 --@@ NEW!
	    end					 --@@ NEW!
	else					 --@@ NEW!
	    if (p >= master_index) then
		master_index = p
	    end
	end
    end						 --@@ NEW!
end

function p_minus(minus_num)
    if setSounds == 1 then
	Sound.play(click, NO_LOOP)
    end
    if bottomMenu == true then		 --@@ NEW!
	menuSel = menuSel - 1		 --@@ NEW!
	if (menuSel<1) then		 --@@ NEW!
	    menuSel=6			 --@@ NEW!
	end				 --@@ NEW!
    else				 --@@ NEW!
	p = p - minus_num
	if p > 0 then
	    GetNameSelected()
	end
	if (showView == 5) then		  --@@ NEW!
	    if (p <= master_index-1) then --@@ NEW! Remove the "-1" for it to act just like SwitchView UI v0.1.2
		master_index = p	  --@@ NEW! Add "-1" to the end for it to act just like SwitchView UI v0.1.2
	    end				  --@@ NEW!
	else				  --@@ NEW!
	    if (p <= master_index) then
		master_index = p
	    end
	end
    end					 --@@ NEW!
end

function Category_Minus()
	    while true do		 --@@loop in case hideEmptyCats is enabled.
		if showCat ~= 0 then
		    if showCat==3 and showHomebrews==0 then
			showCat = 1
		    else
			showCat = showCat -1
		    end
		elseif System.doesFileExist(cur_dir .. "/customsort.dat") == true then
		    --@@showCat = 40 	 --@@skip #41, "search result category"
		    showCat = 5
		else
		    --@@showCat = 39
		    showCat = 4
		end
		if #xCatLookup(showCat) > 0 or hideEmptyCats == 0 or showCat == 0 then
		    break
		end
	    end
	    hideBoxes = 8
	    p = 1
	    master_index = p
	    startCovers = false
	    GetNameSelected()
	    FreeIcons()
end

function Category_Plus()
	    while true do		 --@@loop in case hideEmptyCats is enabled.
		--@@if showCat < 40 then	 --@@skip #41, "search result category"
		if showCat < 5 then
		    if showCat==1 and showHomebrews==0 then
			showCat = 3
		    elseif (setRetroFlow == 0 and showCat > 3.5)
		    --@@or     (setRetroFlow == 1 and showCat == 39) then
		    then
			if System.doesFileExist(cur_dir .. "/customsort.dat") == true then
			    --@@showCat = 40
			    showCat = 5
			else
			    showCat = 0
			end
		    else
			showCat = showCat + 1
		    end
		else
		    showCat = 0
		end
		if #xCatLookup(showCat) > 0 or hideEmptyCats == 0 or showCat == 0 then
		    break
		end
	    end
            hideBoxes = 8
            p = 1
            master_index = p
            startCovers = false
            GetNameSelected()
            FreeIcons()
end

 --@@ NEW! @@ credit to VitaHex's SwitchView UI v0.1.2
function execute_switch_bottom_menu()
    if menuSel==1 then
	System.executeUri("wbapp0:")	   --@@1: News (Internet Browser)
    elseif menuSel==2 then
	System.executeUri("psns:")	   --@@2: Store
    elseif menuSel==3 then
	System.executeUri("photo:")	   --@@3: Album
    elseif menuSel==4 then			
	System.executeUri("scecomboplay:") --@@4: Controls (PS3 Cross-Controller). Note: to launch moonlight it's FreeMemory() + System.launchApp(XYZZ00002) + System.exit()
    elseif menuSel==5 then
	System.executeUri("settings_dlg:") --@@5: System Settings
    elseif menuSel==6 then
	FreeMemory()			   --@@6: Exit
	System.exit()
    end
end

-- Loads App list if cache exists, or generates a new one if it doesn't
local applistReadTimer = Timer.new()
LoadAppTitleTables()
applistReadTime = Timer.getTime(applistReadTimer)
Timer.destroy(applistReadTimer)

--functionTime = Timer.getTime(functionTimer)
functionTime = Timer.getTime(oneLoopTimer)
--Timer.destroy(functionTimer)

if startCategory==6 then -- LAST PLAYED GAME 
    showCat = 0

    if System.doesFileExist(cur_dir .. "/lastplayedgame.dat") then
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
	if showView == 5 and setSwitch == 1 then
	    --Graphics.drawLine(21, 940, 489, 489, white)	 --@@ NEW!
	    Graphics.drawLine(21, 940, 496, 496, white)		 --@@ NEW!
	    Graphics.drawImage(27, 108, imgCart)		 --@@ NEW!
	    Font.print(fnt23_5, 60, 106, app_title:gsub("\n",""), lightblue)	 --@@ NEW! Draw title in SwitchView UI style.
	    Graphics.drawImage(240, 378, btnMenu1)		 --@@ NEW! News
	    Graphics.drawImage(322, 378, btnMenu2)		 --@@ NEW! Store
	    Graphics.drawImage(404, 378, btnMenu3)		 --@@ NEW! Album
	    Graphics.drawImage(486, 378, btnMenu4)		 --@@ NEW! Controls
	    Graphics.drawImage(568, 378, btnMenu5)		 --@@ NEW! System Settings
	    Graphics.drawImage(650, 378, btnMenu6)		 --@@ NEW! Exit
	    if bottomMenu then
		Graphics.drawImage(menuSel*82-82+240-2, 378-2, btnMenuSel)
		PrintCentered(fnt23_5, menuSel*82-82+240+39, 452, lang_lines[menuSel+78], lightblue, 22) --@@ News/Store/Album/Controls/System Settings/Exit. @@ Note: old font style + font size 27 was used for this in SwitchView UI v0.1.2
		--@@ This is a really cheap way to put lang lines. I'll fix it later maybe (probably not honestly)
	    end
        elseif showView ~= 2 then
            Graphics.fillRect(0, 960, 424, 496, black)-- black footer bottom
            PrintCentered(fnt25, 480, 430, app_title, white, 25)-- Draw title
	else
            Font.print(fnt22, 24, 508, app_title, white)
        end

	Font.print(fnt22, 32, 34, xCatTextLookup(showCat), white)--PS VITA/HOMEBREWS/PSP/PSX/CUSTOM/ALL
        if Network.isWifiEnabled() then
            Graphics.drawImage(800, 38, imgWifi)-- wifi icon
        end
        
        -- Draw Covers
        base_x = 0
        
        --GAMES
	--@@ NEW! If the cover 7 tiles away has been loaded, increase render distance.
	if xCatLookup(showCat)[p+7] and xCatLookup(showCat)[p+7].ricon then
	    render_distance = 16
	else
	    render_distance = 8
	end
        for l, file in pairs(xCatLookup(showCat)) do
            if (l >= master_index) then
                base_x = base_x + space
            end
	    --@@ if l > p-8 and base_x < 10 then
	    if l > p-render_distance and l < p+render_distance+2 then	 --@@ NEW!
                if FileLoad[file] == nil then --add a new check here
                    FileLoad[file] = true
                    Threads.addTask(file, {
                        Type = "ImageLoad",
                        Path = file.icon_path,
                        Table = file,
                        Index = "ricon"
                    })
                end
                --@@if file.ricon ~= nil then
                --@@    DrawCover((targetX + l * space) - (#xCatLookup(showCat) * space + space), -0.6, file.name, file.ricon, base_x, file.app_type)--draw visible covers only
                --@@else
                --@@    DrawCover((targetX + l * space) - (#xCatLookup(showCat) * space + space), -0.6, file.name, file.icon, base_x, file.app_type)--draw visible covers only
                --@@end

		--draw visible covers only @@ Now using "or" to order a protected call on ricon. @@ Now uses l==p (which returns as true or false) to say where selector goes.
		DrawCover((targetX + l * space) - (#xCatLookup(showCat) * space + space), -0.6, file.name, file.ricon or file.icon, l==p, file.app_type)

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
            --HOMEBREWS --@@This is kept here so Beyond Compare software will properly compare the above to HexFlow Launcher 0.5
        
        
        -- Smooth move items horizontally
        if (targetX < (base_x - 0.0001)) or (targetX > (base_x + 0.0001)) then	 --@@ NEW! Stops drift (represented by targetX) when within 0.0001 of base_x
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
        
        if setReflections==1 and not (showView == 5 and setSwitch == 1) then
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

		menuItems = 2
		Graphics.fillRect(24, 470, 350 + (menuY * 40), 390 + (menuY * 40), themeCol)-- selection
		Font.print(fnt22, 50, 352, "Download Cover", white)
		--@@Font.print(fnt22, 50, 352+40, "Override Category: < " .. tmpcatText .. " >\n(Press X to apply Category)", white)
		Font.print(fnt22, 50, 352+40, "Override Category: < " .. tmpcatText .. " >", white)
		if xCatLookup(showCat)[p].apptitle ~= sanitized_title then		  --@@ NEW!
		    Font.print(fnt22, 50, 352+80, "Restore app title", white)	  --@@ NEW!
		else								  --@@ NEW!
		    Font.print(fnt22, 50, 352+80, "Restore app title", lightgrey) --@@ NEW!
		end								  --@@ NEW!

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
			if rolling_overrides and (showCat == 0 or showCat == 5) then
			    spin_allowance = 3
			else
			    OverrideCategory()
			    if rolling_overrides then
				check_for_out_of_bounds()
				close_triangle_preview()
			    end
			end
		    end
		elseif menuY == 2 then	 --@@ NEW!
		    RestoreAppTitle()	 --@@ NEW!
		end			 --@@ NEW!
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
	if btDIsLoaded ~= true then			  --@@ NEW!
	    btnD = Graphics.loadImage("app0:/DATA/d.png") --@@ NEW! This stupid image takes so long to load, f*ck knows why.
	    btDIsLoaded = true				  --@@ NEW!
	end						  --@@ NEW!
	--@@ Set Setting Menu Tab Spacing. @@ This bit of code is so ugly sorry >.<
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
        -- Footer buttons and icons @@ label X's are set in function ChangeLanguage()
        Graphics.drawImage(label1AltImgX, 510, btnO)
        Font.print(fnt20, label1AltX, 508, lang_lines[11], white)--Close
        Graphics.drawImage(label2AltImgX, 510, btnX)
        Font.print(fnt20, label2AltX, 508, lang_lines[32], white)--Select
        Graphics.fillRect(60, 900, 24, 488, darkalpha)
        Font.print(fnt22, 84, 34, lang_lines[6], white)--SETTINGS
	if menuY < 5 then
	    Graphics.fillRect(60, 900, 77 + (menuY * 34), 112 + (menuY * 34), themeCol)-- selection
	elseif menuY == 11 then
	    Graphics.fillRect(60 + (280 * menuX), 60 + 280 + (280 * menuX), 77 + (menuY * 34), 112 + (menuY * 34), themeCol)-- selection
	elseif menuX == 0 then		--@@and (5 < menuY < 11) then
	    Graphics.fillRect(60, 460, 77 + (menuY * 34), 112 + (menuY * 34), themeCol)-- selection
	else				--@@elseif (5 < menuY < 11) then
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
        elseif startCategory == 6 then
            Font.print(fnt22, 84 + 260, 79, lang_lines[109], white)--LAST PLAYED GAME
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
            Font.print(fnt22, 84 + 260, 79 + 34, lang_lines[30], white)--Orange --@@reorder hack
        elseif themeColor == 6 then
            Font.print(fnt22, 84 + 260, 79 + 34, lang_lines[29], white)--Purple
        elseif themeColor == 8 then
            Font.print(fnt22, 84 + 260, 79 + 34, lang_lines[54], white)--Dark Purple
        else
            Font.print(fnt22, 84 + 260, 79 + 34, lang_lines[31], white)--Blue
        end

	if scanComplete == false then
--@@	    if setLanguage == 2 then --French Language Fix @@ No longer necessary due to better French Translations.
--@@		Font.print(fnt22, 84, 79 + 68, lang_lines[19] .. ":   <  " .. xCatTextLookup(getCovers) .. "  >", white)--Download Covers < PS VITA/HOMEBREWS/PSP/PSX/CUSTOM/ALL >
--@@	    else
		Font.print(fnt22, 84, 79 + 68, lang_lines[19] .. ":", white)--Download Covers
		Font.print(fnt22, 84 + 260, 79 + 68, "<  " .. xCatTextLookup(getCovers) .. "  >", white) --PS VITA/HOMEBREWS/PSP/PSX/CUSTOM/ALL
--@@	    end
	else
	    Font.print(fnt22, 84, 79 + 170,  lang_lines[20], white)--Reload Covers Database
	end
        
        Font.print(fnt22, 84, 79 + 102,  lang_lines[18] .. ": ", white)
	if getBGround == 1 then
	    if System.doesFileExist("ux0:/data/HexFlow/Background.jpg") or System.doesFileExist("ux0:/data/HexFlow/Background.png") then
		BGroundText = lang_lines[49] --CUSTOM
	    else
		BGroundText = lang_lines[22] --ON
	    end
	elseif getBGround == 2 then
	    BGroundText = lang_lines[65] --Citylights
	elseif getBGround == 3 then
	    BGroundText = lang_lines[66] --Aurora
	elseif getBGround == 4 then
	    BGroundText = lang_lines[67] --Wood 1
	elseif getBGround == 5 then
	    BGroundText = lang_lines[68] --Wood 2
	elseif getBGround == 6 then
	    BGroundText = lang_lines[69] --Dark
	elseif getBGround == 7 then
	    BGroundText = lang_lines[70] --Marble
	elseif getBGround == 8 then
	    BGroundText = lang_lines[71] --Retro
	elseif getBGround == 9 then
	    BGroundText = lang_lines[72] --SwitchView Basic Black
	elseif getBGround == 10 then
	    BGroundText = lang_lines[73] --SwitchView Basic White
	elseif getBGround == 11 then
	    BGroundText = lang_lines[74] --Playstation Pattern 1
	elseif getBGround == 12 then
	    BGroundText = lang_lines[75] --Playstation Pattern 2
	elseif getBGround == 13 then
	    BGroundText = lang_lines[76] --MVPlayer 1
	else
	    BGroundText = lang_lines[23] --OFF
	end
	if (background_brackets == true) and (BGroundText ~= nil) then
	    BGroundText = "<  " .. BGroundText .. "  >"
	    --@@if (setBackground ~= getBGround) and (XNextToBG ~= false) then	 --@@ Puts X icon next to unconfirmed background selection @@ Uncomment these 3 lines to try it. I didn't like it personally.
	    --@@    Graphics.drawImage(Font.getTextWidth(fnt20, BGroundText) + btnMargin + 84 + 260, 5 + 79 + 102, btnX)
	    --@@end
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


        Font.print(fnt22, 84, 79 + 170, lang_lines[16] .. ": ", white)--SOUNDS
        if setSounds == 1 then
            Font.print(fnt22, 84 + 260 + toggle1X, 79 + 170, lang_lines[22], white)--ON
        else
            Font.print(fnt22, 84 + 260 + toggle1X, 79 + 170, lang_lines[23], white)--OFF
        end
        Font.print(fnt22, 484, 79 + 170, lang_lines[96] .. ": ", lightgrey)--RetroFlow
        if setRetroFlow == 1 then
            Font.print(fnt22, 484 + toggle2X + 275, 79 + 170, lang_lines[22], lightgrey)--ON
        else
            Font.print(fnt22, 484 + toggle2X + 275, 79 + 170, lang_lines[23], lightgrey)--OFF
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

        PrintCentered(fnt22, 60+140, 79 + 374, lang_lines[98], white, 22)--Refresh Icons
        PrintCentered(fnt22, 60+140+280, 79 + 374, lang_lines[48], white, 22)--Refresh Cache
        PrintCentered(fnt22, 60+140+560, 79 + 374, lang_lines[13], white, 22)--About
        
        status = System.getMessageState()
        if status ~= RUNNING then
            
            if (Controls.check(pad, SCE_CTRL_CROSS) and not Controls.check(oldpad, SCE_CTRL_CROSS)) then
                if menuY == 0 then
                    if startCategory < 6 then
                        startCategory = startCategory + 1
                    else
                        startCategory = 0
                    end
                elseif menuY == 1 then
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
                elseif menuY == 2 then
                    if gettingCovers == false then
                        gettingCovers = true
                        DownloadCovers()
                    end
                elseif menuY == 3 then
                    if (setBackground == 0) and (getBGround == 0) then	 --@@ "OFF" becomes "<ON>"
			setBackground, getBGround = 1, 1
			background_brackets = true
		    else
			if (getBGround == 0) or (setBackground == getBGround) then
			    setBackground, getBGround = 0, 0	 --@@ "<OFF>" (with <>) and everything else (without <>) becomes "OFF"
			else
			    setBackground = getBGround		 --@@ "<Name of Background>" becomes "Name of Background"
			end
			background_brackets = false
		    end
		    ApplyBackground(setBackground)
                elseif menuY == 4 then
		    if setLanguage < 10 then
                        setLanguage = setLanguage + 1
                    else
                        setLanguage = 0
                    end
		    ChangeLanguage()

                elseif menuY == 5 then
		    if menuX == 0 then
			if setSounds == 1 then
			    setSounds = 0
			--@@if System.doesFileExist(cur_dir .. "/Music.mp3")
				if Sound.isPlaying(sndMusic) then
				    --@@Sound.pause(sndMusic)
				    Sound.close(sndMusic)	   --@@ NEW!
				    sndMusic = click--temp	   --@@ NEW!
				end
			--@@end
			else
			    setSounds = 1
			    play_music()
			end
		    else
			local running = false
			status = System.getMessageState()
			if status ~= RUNNING then
			    System.setMessage("Retroflow integration, rolling cache, and the triangle-menu-integrated L_con/PSVShell overclock profile editor have all been fully coded but are completely stripped from the public release until bugtesting is finished so they don't mess up anyone's Vita. This option is just here as a placeholder because it's the perfect spot I.M.O.", false, BUTTON_OK)
			end
			--@@if setRetroFlow == 1 then
			--@@    setRetroFlow = 0
			--@@else
			--@@    setRetroFlow = 1
			--@@end
			--@@LoadAppTitleTables()
			--@@GetNameSelected()	 --@@ refreshs selected app's name when toggling Retroflow
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
			    --@@Sound.pause(sndMusic)
			    Sound.close(sndMusic)	   --@@ NEW!
			    sndMusic = click--temp	   --@@ NEW!
			end
			play_music()	 --@@ only does anything if setsound equals 1.
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
			--@@ Refresh Icons
			FreeIcons()
			FreeMemory()
			Network.term()
			if System.doesFileExist(cur_dir .. "/apptitlecache.dat") then
			    System.deleteFile(cur_dir .. "/apptitlecache.dat")
			end
			System.launchEboot("app0:/copyicons.bin")
		    elseif menuX == 1 then
			--@@ Refresh Cache
			FreeIcons()
			FreeMemory()
			Network.term()
			if System.doesFileExist(cur_dir .. "/apptitlecache.dat") then
			    System.deleteFile(cur_dir .. "/apptitlecache.dat")
			end
			dofile("app0:index.lua")
		    else
			--@@ About
			showMenu = 3
			menuY = 0
			menuX = 0
		    end
                end
                
                
		write_config()	 --Save settings
            elseif (Controls.check(pad, SCE_CTRL_UP)) and not (Controls.check(oldpad, SCE_CTRL_UP)) then
		if menuY == 5 or (menuY == 11 and menuX ~= 2) then --@@ NEW! When moving to start menu rows with LESS columns, round "menuX" DOWN.
		    menuX = 0
                    menuY = menuY - 1
                elseif menuY > 0 then
                    menuY = menuY - 1
		else
		    menuX = 0
		    menuY = menuItems
                end
            elseif (Controls.check(pad, SCE_CTRL_DOWN)) and not (Controls.check(oldpad, SCE_CTRL_DOWN)) then
		if menuY == 10 and menuX == 2 then	 --@@NEW! When moving to start menu rows with MORE columns, round "menuX" DOWN.
		    menuX = 1
		    menuY = menuY + 1
                elseif menuY < menuItems then
                    menuY = menuY + 1
		else
		    menuX=0				 --@@NEW! When going from bottom to top of settings, set menuX to 0.
		    menuY=0
                end
            elseif (Controls.check(pad, SCE_CTRL_LEFT)) and not (Controls.check(oldpad, SCE_CTRL_LEFT)) then
		if menuY==2 then --covers download selection --@@ [1]=PS VITA, [2]=HOMEBREWS, [3]=PSP, [4]=PSX, [5]=CUSTOM, [default]=ALL
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
		elseif menuY==3 then --Background selection --@@ [1]=Custom, [2]=Citylights, [3]=Aurora, [4]=Wood 1, [5]=Wood 2, [6]=Dark, [7]=Marble, [8]=Retro.
		    if getBGround == 11 then--@@needs to be 10 but SwitchView basic White is not added which 10 is reserved for.
			if setSwitch ~= 0 then
			    getBGround = 9
			else
			    getBGround = 8
			end
		    elseif getBGround > 0 then
			getBGround = getBGround - 1
		    else
			getBGround = 13
		    end
		    background_brackets = true
		elseif menuY == 11 then
		    if menuX > 0 then
			menuX = menuX - 1
		    else
			menuX=2
		    end
		elseif menuY > 4 then
		    if menuX == 0 then
			menuX = 1
		    else
			menuX = 0
		    end
		end
            elseif (Controls.check(pad, SCE_CTRL_RIGHT)) and not (Controls.check(oldpad, SCE_CTRL_RIGHT)) then
		if menuY==2 then --covers download selection --@@ [1]=PS VITA, [2]=HOMEBREWS, [3]=PSP, [4]=PSX, [5]=CUSTOM, [default]=ALL
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
		elseif menuY==3 then --Background selection --@@ [1]=Custom, [2]=Citylights, [3]=Aurora, [4]=Wood 1, [5]=Wood 2, [6]=Dark, [7]=Marble, [8]=Retro.
		    if getBGround == 9 then
			getBGround = 11 --@@needs to be 10 but SwitchView basic White is not added which 10 is reserved for.
		    elseif getBGround == 8 then
			if setSwitch ~= 0 then
			    getBGround = 9
			else
			    getBGround = 11
			end
		    elseif getBGround < 8 or getBGround == 11 or getBGround == 12 then
			getBGround = getBGround + 1
		    else
			getBGround = 0
		    end
		    background_brackets = true
		elseif menuY == 11 then
		    if menuX > 1 then
			menuX = 0
		    else
			menuX = menuX + 1
		    end
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
        -- Footer buttons and icons @@ label X's are set in ChangeLanguage()
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
		prvRotY = -1.3 --@@never show the back of the cover lol
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
        --Navigation Left Analog
	--@@if bottomMenu then
	--@@    put something here later to allow analog in bottomMenu
        --@@elseif mx < 64 then
        if mx < 64 then
            if delayButton < 0.5 then
                delayButton = 1
		bottomMenu = false	 --@@ NEW! delete if analog in bottomMenu is added.
                p_minus(1)		 --@@ NEW!
            end
        elseif mx > 180 then
            if delayButton < 0.5 then
                delayButton = 1
		bottomMenu = false	 --@@ NEW! delete if analog in bottomMenu is added.
                p_plus(1)		 --@@ NEW!
            end
        end
        
        -- Navigation Buttons
        if (Controls.check(pad, SCE_CTRL_CROSS) and not Controls.check(oldpad, SCE_CTRL_CROSS)) then
            if bottomMenu then         --@@NEW! Bottom menu functionality from SwitchView UI v0.1.2
                execute_switch_bottom_menu()
            elseif gettingCovers == false and app_title~="-" then
                FreeMemory()
                local Working_Launch_ID = xCatLookup(showCat)[p].name --@@ Example: VITASHELL @@ This hotfix seems to 99% stop the "please close HexLauncher Custom" errors.

                -- for category LAST PLAYED GAME
                local lastPlayedGameFile = assert(io.open(cur_dir .. "/lastplayedgame.dat", "w"), "Failed to open lastplayedgame.dat")
                lastPlayedGameFile:write(showCat .. "\n")
                lastPlayedGameFile:write(Working_Launch_ID)
                lastPlayedGameFile.close()

                System.launchApp(Working_Launch_ID)
                System.exit()
            end
        elseif (Controls.check(pad, SCE_CTRL_TRIANGLE) and not Controls.check(oldpad, SCE_CTRL_TRIANGLE)) then
            if showMenu == 0 and app_title~="-" then
				prvRotY = 0
		GetInfoSelected()	 --@@ NEW! Full info scan is only here now.
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
    --@@elseif (Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldpad, SCE_CTRL_CIRCLE)) then
        elseif (Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldpad, SCE_CTRL_CIRCLE)) and (lockView == 0) then
            -- VIEW
	    if showView == 4 and setSwitch == 0 then	 --@@ NEW! Skip switch view if the option for it is off.
		showView = 0				 --@@ NEW!
	    elseif showView < 5 then
                showView = showView + 1
		if showView == 5 and SwitchviewAssetsAreLoaded ~= true then
		    fnt23_5 = Font.load("app0:/DATA/font.ttf")
		    Font.setPixelSizes(fnt23_5, 23.5)
		    imgCart = Graphics.loadImage("app0:/DATA/cart.png")
		    --@@imgAvatar = Graphics.loadImage("app0:/AVATARS/AV01.png")
		    btnMenu1 = Graphics.loadImage("app0:/DATA/btm1.png")
		    btnMenu2 = Graphics.loadImage("app0:/DATA/btm2.png")
		    btnMenu3 = Graphics.loadImage("app0:/DATA/btm3.png")
		    btnMenu4 = Graphics.loadImage("app0:/DATA/btm4.png")
		    btnMenu5 = Graphics.loadImage("app0:/DATA/btm5.png")
		    btnMenu6 = Graphics.loadImage("app0:/DATA/btm6.png")
		    btnMenuSel = Graphics.loadImage("app0:/DATA/selct.png")
		    SwitchviewAssetsAreLoaded = true
		end
            else
		master_index = p	 --@@ NEW! (1/3) Makes it not act weird when leaving switch view.
		bottomMenu = false	 --@@ NEW! (2/3) Exit the switch view bottom menu...
		menuSel = 1		 --@@ NEW! (3/3) ... and reset your position in it.
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
	    if superSkip == 1 and (Controls.check(pad, SCE_CTRL_SELECT)) and p~=0 and p~=1 then	 --@@ Hold select + press L to move left by alphabet. Doesn't work at p == 1 (position 1) or p == 0 (the debug position)
		for i=0, #xCatLookup(showCat) do		 --@@the loop.
		    local v = #xCatLookup(showCat) - i		 --@@go from the back.
		    if v == 0 then	 --@@ If you ran out of stuff to check...
			p_minus(p - 1)	 --@@ ... then move to position 1...
			break		 --@@ ... and exit the loop.
		    elseif p > v and string.sub(xCatLookup(showCat)[v].apptitle, 1, 1):lower() < string.sub(xCatLookup(showCat)[p].apptitle, 1, 1):lower() then
			p_minus(p-v)	 --@@ Jump to item with EARLIER-in-alphabet first character.
			break
		    end
		end
	    else
		p_minus(5)
	    end
        elseif (Controls.check(pad, SCE_CTRL_RTRIGGER)) and not (Controls.check(oldpad, SCE_CTRL_RTRIGGER)) then
	    bottomMenu = false
	    if superSkip == 1 and (Controls.check(pad, SCE_CTRL_SELECT)) and p ~= #xCatLookup(showCat) then	 --@@ Hold select + press R to move right by alphabet. Doesn't work at position max
		for i=1, #xCatLookup(showCat) do		 --@@the loop.
		    if i == #xCatLookup(showCat) then	 --@@ If you ran out of stuff to check...
			p_plus(i - p)			 --@@ ... then move to position max...
			break				 --@@ ... and exit the loop.
		    elseif p < i and string.sub(xCatLookup(showCat)[i].apptitle, 1, 1):lower() > string.sub(xCatLookup(showCat)[p].apptitle, 1, 1):lower() then
			p_plus(i-p)	 --@@ Jump to item with LATER-in-alphabet first character.
			break
		    end
		end
	    else
		p_plus(5)
	    end
	elseif (Controls.check(pad,SCE_CTRL_UP)) and not (Controls.check(oldpad,SCE_CTRL_UP)) --@@then
	 and showView == 5 and bottomMenu == true then
	    bottomMenu = false
	    if setSounds == 1 then
		Sound.play(click, NO_LOOP)
	    end
	elseif (Controls.check(pad,SCE_CTRL_DOWN)) and not (Controls.check(oldpad,SCE_CTRL_DOWN)) --@@then
	 and showView == 5 and bottomMenu == false then
	    bottomMenu = true
	    if setSounds == 1 then
		Sound.play(click, NO_LOOP)
	    end
        end
        
        -- Touch Input
        if x1 ~= nil then
            if xstart == nil then
		--Start tracking touch upon touchdown
                xstart = x1
            end
            if showView == 1 then
		-- flat zoom out view - pan camera 1/487 p per pixel moved.
	        targetX = targetX + ((x1 - xstart) / 487)
	    elseif (showView == 2) or (showView == 3) then
		-- zoomin view & left side view - pan camera 1/1000 p per pixel moved.
	        targetX = targetX + ((x1 - xstart) / 1000)
	    elseif showView == 5 then
		-- SwitchView - pan camera 1/1840 p per pixel moved with gentle bump back at ends @@ Not only is this ugly AF, it's undercommented AF... but it works but I have no idea why.
		if targetX + ((x1 - (xstart)) / 1840) > curTotal + 0.2 then
		    targetX = curTotal + 0.2	 --@@ NOTICE: PLUS 0.2
		elseif curTotal <= 3 and targetX + ((x1 - (xstart)) / 1840) < curTotal - 0.2 then
		    targetX = curTotal - 0.2	 --@@ NOTICE: MINUS 0.2
		elseif curTotal > 3 and targetX + ((x1 - (xstart)) / 1840) < 3.8 then
		    targetX = 3.8
		else
		    targetX = targetX + ((x1 - (falsified_xstart or xstart)) / 1840)
		end
	    else
		-- all other views - pan camera 1/700 p per pixel moved.
	        targetX = targetX + ((x1 - xstart) / 700)
	    end
	    if x1 > xstart + 60 then			 --@@ If momentum is added, SwitchView should get 184 touch thresh instead of 60
		if master_index > 1 then		 --@@NEW!
		    master_index = master_index - 1	 --@@NEW! shift master_index instead of binding it to p, allowing better touch scrolling in view-mode #5
		end					 --@@NEW!				 --@@NEW!
                xstart = x1				 --@@refresh tracking start point
                p = p - 1
                if p > 0 then
                    GetNameSelected()
                end
		bottomMenu = false			 --@@NEW
	    elseif x1 < xstart - 60 then
                xstart = x1				 --@@refresh tracking start point
                p = p + 1
		bottomMenu = false			 --@@NEW!				    --@@NEW!
		if showView ~= 5 or master_index < curTotal - 3 then
		    master_index = master_index + 1
		end
                if p <= curTotal then
                    GetNameSelected()
                end
	--# elseif showview == 5 then
	--#     something something momentum = x1 - xstart?
            end
	elseif xstart ~= nil then
	    -- clear touch data upon touch off (important), NOT clear touch data based on a timer like HEXFlow 0.5
	    xstart = nil
	    if showView == 5 and master_index > curTotal - 3 then
		if curTotal > 3 then
		    master_index = curTotal - 3
		else
		    master_index = 1
		end
	    end	
        end
    -- End Touch
    elseif showMenu > 0 then
        if (Controls.check(pad, SCE_CTRL_CIRCLE) and not Controls.check(oldpad, SCE_CTRL_CIRCLE)) then
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
    oldpad = pad
    
    if oneLoopTimer then			  --@@ if the timer is running then...
        oneLoopTime = Timer.getTime(oneLoopTimer) --@@ save the time
        Timer.destroy(oneLoopTimer)		  --@@ not sure if this is necessary
	oneLoopTimer = nil			  --@@ clear timer value
    end 
end
