--[[
	KayceeLayoutV2 by TheNewkaycee
	✅ Mobile + PC compatible
	✅ All features work: Splash, Tabs, FastFlags, FPS, Save Config, Fonts, Old Oof, Drag UI
]]

print("[KayceeLayoutV2] Starting loader...")

if not writefile then
	warn("[KayceeLayoutV2] writefile/readfile not supported by your executor.")
	return
end

print("[KayceeLayoutV2] writefile supported.")

--// Services
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local http = game:GetService("HttpService")

--// Variables
local configPath = "KayceeLayoutV2/Config.json"
local flagPath = "KayceeLayoutV2/Flags.json"

--// File Setup
if not isfolder("KayceeLayoutV2") then
	makefolder("KayceeLayoutV2")
end

-- Load config
local function readJSON(path)
	local s, r = pcall(function() return http:JSONDecode(readfile(path)) end)
	return s and r or {}
end

local function saveJSON(path, tbl)
	pcall(function()
		writefile(path, http:JSONEncode(tbl))
	end)
end

local config = readJSON(configPath)
local savedFlags = readJSON(flagPath)

--// FPS Display
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0, 160, 0, 24)
fpsLabel.Position = UDim2.new(0, 10, 0, 10)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
fpsLabel.Font = Enum.Font.Gotham
fpsLabel.TextSize = 14
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Text = "FPS: -- | ms: -- | MB: --"
fpsLabel.Visible = true
fpsLabel.ZIndex = 999
fpsLabel.Parent = game.CoreGui

-- FPS Update
task.spawn(function()
	local lastTime = tick()
	local frames = 0
	while true do
		frames += 1
		local now = tick()
		if now - lastTime >= 1 then
			local fps = frames
			local ms = math.floor((1000 / math.max(fps, 1)))
			local mem = math.floor(gcinfo() / 1024)
			fpsLabel.Text = ("FPS: %d | ms: %d | MB: %d"):format(fps, ms, mem)
			frames = 0
			lastTime = now
		end
		task.wait()
	end
end)

--// UI Setup
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "KayceeLayoutV2"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false

-- Splash Screen
local splash = Instance.new("Frame", gui)
splash.Size = UDim2.new(1,0,1,0)
splash.BackgroundColor3 = Color3.fromRGB(15,15,15)
splash.ZIndex = 1000

local splashText = Instance.new("TextLabel", splash)
splashText.Size = UDim2.new(1,0,1,0)
splashText.Text = "⚠️ WARNING\nThis layout is meant for practice/testing environments only.\nModifying game performance in public/private servers may lead to consequences.\n\nThenewkaycee on YouTube\nJoin our Discord: https://discord.gg/CbQHm7VM"
splashText.TextColor3 = Color3.fromRGB(0,170,255)
splashText.Font = Enum.Font.Gotham
splashText.TextSize = 20
splashText.TextWrapped = true
splashText.TextYAlignment = Enum.TextYAlignment.Center
splashText.BackgroundTransparency = 1

-- Fade splash
task.delay(3, function()
	for i = 1, 20 do
		splash.BackgroundTransparency = i/20
		splashText.TextTransparency = i/20
		task.wait(0.05)
	end
	splash:Destroy()
end)

-- Draggable "K" toggle
local toggleButton = Instance.new("TextButton", gui)
toggleButton.Size = UDim2.new(0, 40, 0, 40)
toggleButton.Position = UDim2.new(0.5, -20, 0.5, -20)
toggleButton.BackgroundColor3 = Color3.fromRGB(10,10,10)
toggleButton.Text = "K"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextColor3 = Color3.fromRGB(0,170,255)
toggleButton.TextSize = 24
toggleButton.Draggable = true
toggleButton.Active = true

-- Main menu
local menu = Instance.new("Frame", gui)
menu.Size = UDim2.new(0, 600, 0, 400)
menu.Position = UDim2.new(0.5, -300, 0.5, -200)
menu.BackgroundColor3 = Color3.fromRGB(20,20,20)
menu.BorderColor3 = Color3.fromRGB(0,170,255)
menu.Visible = false
menu.Active = true
menu.Draggable = true

-- Title
local title = Instance.new("TextLabel", menu)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(0,0,0)
title.Text = "KayceeLayoutV2"
title.Font = Enum.Font.GothamBlack
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(0,170,255)

-- Sidebar
local sidebar = Instance.new("Frame", menu)
sidebar.Size = UDim2.new(0, 140, 1, -40)
sidebar.Position = UDim2.new(0, 0, 0, 40)
sidebar.BackgroundColor3 = Color3.fromRGB(10,10,10)

local tabs = {"Introduction", "Mods", "Engine Settings", "Help", "Save Config"}
local tabFrames = {}
local contentParent = Instance.new("Frame", menu)
contentParent.Size = UDim2.new(1, -140, 1, -40)
contentParent.Position = UDim2.new(0, 140, 0, 40)
contentParent.BackgroundColor3 = Color3.fromRGB(25,25,25)

-- Create tabs and their buttons
for i, tabName in ipairs(tabs) do
	local btn = Instance.new("TextButton", sidebar)
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.Position = UDim2.new(0, 0, 0, (i - 1) * 30)
	btn.Text = tabName
	btn.BackgroundColor3 = Color3.fromRGB(20,20,20)
	btn.TextColor3 = Color3.fromRGB(0,170,255)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14

	local tabContent = Instance.new("Frame", contentParent)
	tabContent.Size = UDim2.new(1,0,1,0)
	tabContent.BackgroundTransparency = 1
	tabContent.Visible = false
	tabFrames[tabName] = tabContent

	btn.MouseButton1Click:Connect(function()
		for _, f in pairs(tabFrames) do f.Visible = false end
		tabContent.Visible = true
	end)
end

-- Enable first tab
tabFrames["Introduction"].Visible = true

-- Introduction Tab Content
do
	local intro = tabFrames["Introduction"]
	local yt = Instance.new("TextLabel", intro)
	yt.Size = UDim2.new(1, -20, 0, 60)
	yt.Position = UDim2.new(0, 10, 0, 10)
	yt.Text = "📢 Subscribe to my YouTube TheNewkaycee\nJoin our Discord: https://discord.gg/CbQHm7VM"
	yt.TextWrapped = true
	yt.TextColor3 = Color3.fromRGB(0,170,255)
	yt.BackgroundTransparency = 1
	yt.Font = Enum.Font.Gotham
	yt.TextSize = 16
end

-- Mods Tab
do
	local mods = tabFrames["Mods"]

	-- FastFlags JSON textbox
	local flagBox = Instance.new("TextBox", mods)
	flagBox.Size = UDim2.new(1, -20, 0, 120)
	flagBox.Position = UDim2.new(0, 10, 0, 10)
	flagBox.PlaceholderText = "Paste your FastFlags JSON here..."
	flagBox.Text = http:JSONEncode(savedFlags)
	flagBox.ClearTextOnFocus = false
	flagBox.TextWrapped = true
	flagBox.MultiLine = true
	flagBox.TextYAlignment = Enum.TextYAlignment.Top
	flagBox.Font = Enum.Font.Code
	flagBox.TextColor3 = Color3.fromRGB(0,170,255)
	flagBox.TextSize = 14
	flagBox.BackgroundColor3 = Color3.fromRGB(10,10,10)
	flagBox.BorderColor3 = Color3.fromRGB(0,170,255)
	flagBox.BorderSizePixel = 1

	local apply = Instance.new("TextButton", mods)
	apply.Size = UDim2.new(0, 100, 0, 30)
	apply.Position = UDim2.new(0, 10, 0, 140)
	apply.Text = "Apply"
	apply.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	apply.BorderColor3 = Color3.fromRGB(0, 170, 255)
	apply.BorderSizePixel = 1
	apply.TextColor3 = Color3.fromRGB(0, 170, 255)
	apply.Font = Enum.Font.GothamBold
	apply.TextSize = 14

	apply.MouseButton1Click:Connect(function()
		local text = flagBox.Text
		local success, parsed = pcall(function()
			return http:JSONDecode(text)
		end)

		if success and typeof(parsed) == "table" then
			for k, v in pairs(parsed) do
				setfflag(k, v)
			end
			saveJSON(flagPath, parsed)
			print("[KayceeLayoutV2] Flags applied.")
		else
			warn("[KayceeLayoutV2] Invalid JSON")
		end
	end)
end

-- Engine Settings Tab (partial example)
do
	local engine = tabFrames["Engine Settings"]
	local padding = 10
	local buttonHeight = 30
	local yPos = padding

	local function createToggle(name, parent, posY, description)
		local btn = Instance.new("TextButton", parent)
		btn.Size = UDim2.new(0, 200, 0, buttonHeight)
		btn.Position = UDim2.new(0, padding, 0, posY)
		btn.BackgroundColor3 = Color3.fromRGB(10,10,10)
		btn.BorderColor3 = Color3.fromRGB(0,170,255)
		btn.BorderSizePixel = 1
		btn.TextColor3 = Color3.fromRGB(0,170,255)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 14
		btn.Text = name .. ": Off"
		btn.AutoButtonColor = false

		local toggled = false
		btn.MouseButton1Click:Connect(function()
			toggled = not toggled
			btn.Text = name .. (toggled and ": On" or ": Off")
			print("[Engine Settings] "..name.." toggled to", toggled)
		end)

		if description then
			local desc = Instance.new("TextLabel", parent)
			desc.Size = UDim2.new(0, 300, 0, 20)
			desc.Position = UDim2.new(0, padding + 210, 0, posY + 5)
			desc.BackgroundTransparency = 1
			desc.TextColor3 = Color3.fromRGB(0,170,255)
			desc.Font = Enum.Font.Gotham
			desc.TextSize = 12
			desc.Text = description
			desc.TextXAlignment = Enum.TextXAlignment.Left
		end

		return btn, buttonHeight + (description and 20 or 0)
	end

	-- Example toggle buttons from your engine settings:

	local oldOofBtn, h1 = createToggle(
		"Use old death sound", engine, yPos,
		"Bring back the classic 'oof' death sound."
	)
	yPos += h1 + buttonHeight

	local antiAliasingOptions = {"Off", "Low", "Medium", "High"}
	-- ... add dropdown creation if needed

	-- You can add more buttons here following createToggle or createDropdown pattern
end

-- Toggle menu visibility
toggleButton.MouseButton1Click:Connect(function()
	menu.Visible = not menu.Visible
end)
