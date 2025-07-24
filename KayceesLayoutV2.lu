--[[ 
    Kaycees Layout V2 - FPS & Flag Utility GUI for Football Fusion 2
    Made for Mobile Exploiting (Delta, KML, Codex)
    Theme: Red, White, Green
    Features: Auto FPS lock, Flag Editor, Save Settings, Grey Sky, UI polish, Warning in non-practice
--]]

if not getgenv then return end
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")

local SettingsKey = "Kaycee_Layout_V2_Saved"
local function Save(data)
    if writefile then
        writefile(SettingsKey .. ".json", HttpService:JSONEncode(data))
    end
end

local function Load()
    if isfile and isfile(SettingsKey .. ".json") then
        return HttpService:JSONDecode(readfile(SettingsKey .. ".json"))
    end
    return {}
end

local saved = Load()
local function isPublicOrPrivate()
    return game.PrivateServerId ~= "" or game.VIPServerId ~= ""
end

-- UI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "KayceesLayout"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
pcall(function()
    gui.Parent = game:GetService("CoreGui")
end)

local theme = {
    red = Color3.fromRGB(255, 0, 0),
    white = Color3.fromRGB(255, 255, 255),
    green = Color3.fromRGB(0, 255, 0),
    background = Color3.fromRGB(30, 30, 30)
}

local function warnFrame(msg)
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0.6, 0, 0.15, 0)
    frame.Position = UDim2.new(0.2, 0, 0.4, 0)
    frame.BackgroundColor3 = theme.red
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = msg
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.TextColor3 = theme.white
    label.BackgroundTransparency = 1

    wait(6)
    frame:Destroy()
end

if isPublicOrPrivate() then
    warnFrame("⚠️ Do not execute in Public or Private servers. Practice Mode only recommended.")
end-- FPS & FastFlag Settings Handler
local function applyFPS(value)
	if not isPractice then return end
	setfpscap(value)
	if getgenv then getgenv().kayceefps = value end
end

local function applyFlags(json)
	if not isPractice then return end
	for flag, val in pairs(json) do
		if typeof(val) == "boolean" then
			setfflag(flag, val and "true" or "false")
		else
			setfflag(flag, tostring(val))
		end
	end
	if getgenv then getgenv().kayceeflags = json end
end

-- Save Settings
local function saveConfig()
	local config = {
		fps = getgenv().kayceefps,
		flags = getgenv().kayceeflags
	}
	writefile("kayceeconfig.json", game:GetService("HttpService"):JSONEncode(config))
end

-- Load Settings
local function loadConfig()
	if isfile("kayceeconfig.json") then
		local config = game:GetService("HttpService"):JSONDecode(readfile("kayceeconfig.json"))
		if config.fps then applyFPS(config.fps) end
		if config.flags then applyFlags(config.flags) end
	end
end

-- JSON Flag Editor Handler
local function parseAndApplyFlags(jsonText)
	local success, result = pcall(function()
		return game:GetService("HttpService"):JSONDecode(jsonText)
	end)
	if success then
		applyFlags(result)
	else
		warn("Invalid JSON")
	end
end

-- Warning Screen
local function showWarning()
	local screen = Instance.new("ScreenGui", game:GetService("CoreGui"))
	screen.Name = "KayceeWarning"

	local frame = Instance.new("Frame", screen)
	frame.Size = UDim2.new(0.8, 0, 0.3, 0)
	frame.Position = UDim2.new(0.1, 0, 0.35, 0)
	frame.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
	frame.BorderSizePixel = 0
	frame.BackgroundTransparency = 0.1

	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.new(1, 0, 0.7, 0)
	label.Position = UDim2.new(0, 0, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = "⚠️ Do not execute this in public or private servers There is highrisk of ban— Only safe in sandbox/practice modes. Your saved FPS and flags will still apply, but the UI is disabled outside of practice."
	label.Font = Enum.Font.GothamBold
	label.TextWrapped = true
	label.TextScaled = true
	label.TextColor3 = Color3.new(1, 1, 1)

	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(0.3, 0, 0.2, 0)
	btn.Position = UDim2.new(0.35, 0, 0.75, 0)
	btn.Text = "OK, I Understand"
	btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextColor3 = Color3.fromRGB(0, 0, 0)
	btn.Font = Enum.Font.Gotham
	btn.TextScaled = true
	btn.MouseButton1Click:Connect(function()
		screen:Destroy()
	end)
end-- Theme Setup
local themeColor = Color3.fromRGB(255, 75, 75) -- Red
local accentColor = Color3.fromRGB(0, 255, 0)   -- Green
local bgColor = Color3.fromRGB(30, 30, 30)

-- Main GUI
local KayceeGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
KayceeGui.Name = "KayceesLayoutV2"
KayceeGui.ResetOnSpawn = false

-- Draggable Frame
local MainFrame = Instance.new("Frame", KayceeGui)
MainFrame.Size = UDim2.new(0.8, 0, 0.6, 0)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = bgColor
MainFrame.Active = true
MainFrame.Draggable = true

-- Title
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0.1, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Kaycee's Layout V2"
Title.Font = Enum.Font.GothamBlack
Title.TextScaled = true
Title.TextColor3 = themeColor

-- FPS Dropdown
local FPSLabel = Instance.new("TextLabel", MainFrame)
FPSLabel.Size = UDim2.new(0.4, 0, 0.1, 0)
FPSLabel.Position = UDim2.new(0.05, 0, 0.15, 0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "FPS Cap:"
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.TextScaled = true
FPSLabel.TextColor3 = Color3.new(1, 1, 1)

local fpsBox = Instance.new("TextBox", MainFrame)
fpsBox.Size = UDim2.new(0.4, 0, 0.1, 0)
fpsBox.Position = UDim2.new(0.55, 0, 0.15, 0)
fpsBox.Text = tostring(getgenv().kayceefps or 60)
fpsBox.TextScaled = true
fpsBox.Font = Enum.Font.Gotham
fpsBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
fpsBox.TextColor3 = Color3.new(1, 1, 1)
fpsBox.FocusLost:Connect(function()
	local n = tonumber(fpsBox.Text)
	if n then
		applyFPS(n)
		saveConfig()
	end
end)

-- Flag Editor
local FlagLabel = Instance.new("TextLabel", MainFrame)
FlagLabel.Size = UDim2.new(1, -20, 0.1, 0)
FlagLabel.Position = UDim2.new(0.05, 0, 0.3, 0)
FlagLabel.BackgroundTransparency = 1
FlagLabel.Text = "Paste FastFlag JSON Below:"
FlagLabel.Font = Enum.Font.GothamBold
FlagLabel.TextScaled = true
FlagLabel.TextColor3 = Color3.new(1, 1, 1)

local flagBox = Instance.new("TextBox", MainFrame)
flagBox.Size = UDim2.new(0.9, 0, 0.25, 0)
flagBox.Position = UDim2.new(0.05, 0, 0.4, 0)
flagBox.MultiLine = true
flagBox.Text = ""
flagBox.TextScaled = false
flagBox.ClearTextOnFocus = false
flagBox.Font = Enum.Font.Code
flagBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
flagBox.TextColor3 = Color3.new(1, 1, 1)

local applyBtn = Instance.new("TextButton", MainFrame)
applyBtn.Size = UDim2.new(0.4, 0, 0.08, 0)
applyBtn.Position = UDim2.new(0.3, 0, 0.7, 0)
applyBtn.Text = "Apply Flags"
applyBtn.TextScaled = true
applyBtn.BackgroundColor3 = accentColor
applyBtn.TextColor3 = Color3.new(0, 0, 0)
applyBtn.Font = Enum.Font.GothamBold
applyBtn.MouseButton1Click:Connect(function()
	parseAndApplyFlags(flagBox.Text)
	saveConfig()
end)-- Toggle Button to show/hide main GUI
local toggleBtn = Instance.new("TextButton", KayceeGui)
toggleBtn.Size = UDim2.new(0, 40, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "K"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 28
toggleBtn.TextColor3 = themeColor
toggleBtn.BackgroundColor3 = bgColor
toggleBtn.AutoButtonColor = false
toggleBtn.Active = true
toggleBtn.Draggable = true
toggleBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = not MainFrame.Visible
end)

-- Live FPS counter
local fpsCounter = Instance.new("TextLabel", KayceeGui)
fpsCounter.Size = UDim2.new(0, 80, 0, 20)
fpsCounter.Position = UDim2.new(1, -90, 0, 10)
fpsCounter.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
fpsCounter.TextColor3 = Color3.new(1,1,1)
fpsCounter.Font = Enum.Font.GothamBold
fpsCounter.TextSize = 16
fpsCounter.Text = "FPS: 0"
fpsCounter.TextXAlignment = Enum.TextXAlignment.Right
fpsCounter.Visible = true
newUICorner(fpsCounter)

local lastTick = tick()
local frameCount = 0
RunService.RenderStepped:Connect(function()
	frameCount += 1
	if tick() - lastTick >= 1 then
		fpsCounter.Text = "FPS: "..frameCount
		frameCount = 0
		lastTick = tick()
	end
end)

-- Splash screen
local splash = Instance.new("Frame", KayceeGui)
splash.Size = UDim2.new(1,0,1,0)
splash.BackgroundColor3 = bgColor

local splashText = Instance.new("TextLabel", splash)
splashText.Size = UDim2.new(1, 0, 0, 100)
splashText.Position = UDim2.new(0, 0, 0.4, 0)
splashText.BackgroundTransparency = 1
splashText.TextColor3 = themeColor
splashText.Font = Enum.Font.GothamBold
splashText.TextSize = 32
splashText.Text = "Thenewkaycee on YouTube\nJoin our Discord!"
splashText.TextWrapped = true
splashText.TextYAlignment = Enum.TextYAlignment.Top

delay(4, function()
	splash:Destroy()
end)

-- Warning popup
local warningFrame = Instance.new("Frame", KayceeGui)
warningFrame.Size = UDim2.new(0, 300, 0, 120)
warningFrame.Position = UDim2.new(0.5, -150, 0.5, -60)
warningFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
warningFrame.Visible = true
newUICorner(warningFrame)

local warningLabel = Instance.new("TextLabel", warningFrame)
warningLabel.Size = UDim2.new(1, -20, 1, -50)
warningLabel.Position = UDim2.new(0, 10, 0, 10)
warningLabel.BackgroundTransparency = 1
warningLabel.TextColor3 = Color3.new(1,1,1)
warningLabel.Font = Enum.Font.GothamBold
warningLabel.TextSize = 16
warningLabel.TextWrapped = true
warningLabel.TextYAlignment = Enum.TextYAlignment.Top
warningLabel.Text = "Warning:\nDo NOT execute in public or private servers!\nOnly use in Practice."

local warningBtn = Instance.new("TextButton", warningFrame)
warningBtn.Size = UDim2.new(1, -20, 0, 40)
warningBtn.Position = UDim2.new(0, 10, 1, -45)
warningBtn.BackgroundColor3 = themeColor
warningBtn.TextColor3 = Color3.new(1,1,1)
warningBtn.Font = Enum.Font.GothamBold
warningBtn.TextSize = 18
warningBtn.Text = "Dismiss"
warningBtn.MouseButton1Click:Connect(function()
	warningFrame.Visible = false
	config.WarningDismissed = true
	saveConfig()
end)

-- Load saved config and auto-apply
loadConfig()

-- Make GUI visible only after splash fades
MainFrame.Visible = false
toggleBtn.Visible = true

-- If user already dismissed warning, hide it
if config.WarningDismissed then
	warningFrame.Visible = false
end
