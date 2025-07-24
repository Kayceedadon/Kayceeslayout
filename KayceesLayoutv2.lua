--[[
  Kaycees Layout V2 - Full FPS & FastFlag GUI for Football Fusion 2
  Runs ONLY in Practice Mode.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Replace these with your actual Practice Mode Place IDs
local PracticePlaceIDs = {
  123456789, -- example ID 1
  987654321, -- example ID 2
}

local function isPracticeMode()
  for _, id in ipairs(PracticePlaceIDs) do
    if game.PlaceId == id then
      return true
    end
  end
  return false
end

if not isPracticeMode() then
  return -- stop script silently outside Practice Mode
end

-- Global config table
local config = getgenv().KayceesConfig or {}
getgenv().KayceesConfig = configlocal function safeSetFFlag(flag, value)
  if typeof(setfflag) == "function" then
    pcall(function() setfflag(flag, value) end)
  end
end

local function clampFPS(fps)
  if fps < 30 then return 30 end
  if fps > 120 then return 120 end
  return fps
end

local themes = {
  Default = {
    Background = Color3.fromRGB(240, 240, 240),
    Button = Color3.fromRGB(255, 0, 0),
    TextColor = Color3.fromRGB(0, 0, 0),
  },
  Dark = {
    Background = Color3.fromRGB(45, 45, 45),
    Button = Color3.fromRGB(139, 0, 0),
    TextColor = Color3.fromRGB(255, 255, 255),
  },
  Classic = {
    Background = Color3.fromRGB(224, 224, 224),
    Button = Color3.fromRGB(211, 47, 47),
    TextColor = Color3.fromRGB(0, 0, 0),
  },
  Stealth = {
    Background = Color3.fromRGB(30, 30, 30),
    Button = Color3.fromRGB(102, 102, 102),
    TextColor = Color3.fromRGB(180, 180, 180),
  },
}

local fonts = {
  "Gotham", "Arial", "SourceSans", "SourceSansBold", "SourceSansItalic",
  "Highway", "HighwayBold", "HighwayItalic", "Arcade", "ArcadeBold",
}

local currentFPS = 60
local applyingFPS = false
local currentTheme = "Default"
local currentFontIndex = 1
local greySkyState = false
local boostModeState = false
local warningDismissed = false

local TweenService = game:GetService("TweenService")

local function newUICorner(parent, radius)
  local c = Instance.new("UICorner")
  c.CornerRadius = radius or UDim.new(0, 8)
  c.Parent = parent
  return c
endlocal ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KayceesLayoutV2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 40, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.Text = "K"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 28
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.BackgroundColor3 = themes.Default.Button
toggleButton.AutoButtonColor = false
toggleButton.Active = true
toggleButton.Draggable = true
toggleButton.Parent = ScreenGui
newUICorner(toggleButton)

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 340, 0, 420)
mainFrame.Position = UDim2.new(0, 60, 0, 10)
mainFrame.BackgroundColor3 = themes.Default.Background
mainFrame.Visible = false
mainFrame.Parent = ScreenGui
newUICorner(mainFrame)

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -20)
scrollFrame.Position = UDim2.new(0, 10, 0, 10)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 6
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = mainFramelocal y = 0
local function addLabel(text, color, fontBold, size)
  local label = Instance.new("TextLabel")
  label.Size = UDim2.new(1, 0, 0, size or 24)
  label.Position = UDim2.new(0, 0, 0, y)
  label.BackgroundTransparency = 1
  label.TextColor3 = color or themes.Default.TextColor
  label.Font = fontBold and Enum.Font.GothamBold or Enum.Font.Gotham
  label.TextSize = size and (size - 6) or 16
  label.TextXAlignment = Enum.TextXAlignment.Left
  label.Text = text
  label.Parent = scrollFrame
  y = y + label.Size.Y.Offset + 8
  return label
end

local function addButton(text, callback)
  local btn = Instance.new("TextButton")
  btn.Size = UDim2.new(1, 0, 0, 30)
  btn.Position = UDim2.new(0, 0, 0, y)
  btn.BackgroundColor3 = themes.Default.Button
  btn.TextColor3 = themes.Default.TextColor
  btn.Font = Enum.Font.GothamBold
  btn.TextSize = 16
  btn.Text = text
  btn.AutoButtonColor = true
  btn.Parent = scrollFrame
  newUICorner(btn, UDim.new(0,6))
  btn.MouseButton1Click:Connect(callback)
  y = y + 38
  return btn
end

local function addToggle(text, initial, callback)
  local toggled = initial or false
  local btn = Instance.new("TextButton")
  btn.Size = UDim2.new(1, 0, 0, 30)
  btn.Position = UDim2.new(0, 0, 0, y)
  btn.BackgroundColor3 = toggled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
  btn.TextColor3 = Color3.new(1,1,1)
  btn.Font = Enum.Font.GothamBold
  btn.TextSize = 16
  btn.Text = text .. ": " .. (toggled and "ON" or "OFF")
  btn.Parent = scrollFrame
  btn.AutoButtonColor = true
  newUICorner(btn, UDim.new(0,6))
  btn.MouseButton1Click:Connect(function()
    toggled = not toggled
    btn.BackgroundColor3 = toggled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    btn.Text = text .. ": " .. (toggled and "ON" or "OFF")
    callback(toggled)
    saveConfig()
  end)
  y = y + 38
  return btn
end

local fpsLabel = addLabel("FPS: 60", themes.Default.TextColor, true, 24)
local fpsInput = Instance.new("TextBox")
fpsInput.Size = UDim2.new(1, 0, 0, 30)
fpsInput.Position = UDim2.new(0, 0, 0, y)
fpsInput.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
fpsInput.TextColor3 = themes.Default.TextColor
fpsInput.Font = Enum.Font.Gotham
fpsInput.TextSize = 16
fpsInput.ClearTextOnFocus = false
fpsInput.PlaceholderText = "Enter FPS (30-120)"
fpsInput.Text = tostring(currentFPS)
fpsInput.Parent = scrollFrame
newUICorner(fpsInput)
y = y + 38

local function applyFPS()
  applyingFPS = true
  spawn(function()
    while applyingFPS do
      safeSetFFlag("DFIntTaskSchedulerTargetFps", tostring(currentFPS))
      RunService.Heartbeat:Wait()
    end
  end)
end

local function setFPS(val)
  currentFPS = clampFPS(tonumber(val) or 60)
  fpsLabel.Text = "FPS: " .. currentFPS
  fpsInput.Text = tostring(currentFPS)
  applyFPS()
  saveConfig()
end

fpsInput.FocusLost:Connect(function(enter)
  if enter then setFPS(fpsInput.Text) end
end)

setFPS(currentFPS)local function toggleGreySky(state)
  greySkyState = state
  if state then
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 0
    Lighting.FogStart = 0
    Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
    Lighting.ClockTime = 12
    Lighting.Brightness = 0.2
    Lighting.Sky = nil
    safeSetFFlag("FFlagDebugForceFutureIsBrightPhase3", "True")
  else
    Lighting.GlobalShadows = true
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
    Lighting.ClockTime = 14
    Lighting.Brightness = 2
    if not Lighting:FindFirstChildOfClass("Sky") then
      local sky = Instance.new("Sky")
      sky.Parent = Lighting
    end
    safeSetFFlag("FFlagDebugForceFutureIsBrightPhase3", "False")
  end
  saveConfig()
end

local greySkyToggle = addToggle("Grey Sky", greySkyState, toggleGreySky)

local function toggleBoost(state)
  boostModeState = state
  if state then
    for _, obj in pairs(workspace:GetDescendants()) do
      if obj:IsA("Decal") or obj:IsA("Texture") then
        obj.Transparency = 1
      end
    end
  else
    for _, obj in pairs(workspace:GetDescendants()) do
      if obj:IsA("Decal") or obj:IsA("Texture") then
        obj.Transparency = 0
      end
    end
  end
  saveConfig()
end

local boostToggle = addToggle("Boost Mode", boostModeState, toggleBoost)ilocal themeLabel = addLabel("Theme Selector", themes.Default.TextColor, true)
local themeDropdown = Instance.new("TextButton")
themeDropdown.Size = UDim2.new(1, 0, 0, 30)
themeDropdown.Position = UDim2.new(0, 0, 0, y)
themeDropdown.BackgroundColor3 = themes.Default.Button
themeDropdown.TextColor3 = themes.Default.TextColor
themeDropdown.Font = Enum.Font.GothamBold
themeDropdown.TextSize = 16
themeDropdown.Text = currentTheme
themeDropdown.Parent = scrollFrame
newUICorner(themeDropdown)
y = y + 38

local themeDropdownFrame = Instance.new("Frame")
themeDropdownFrame.Size = UDim2.new(1, 0, 0, 0)
themeDropdownFrame.Position = UDim2.new(0, 0, 0, y)
themeDropdownFrame.BackgroundColor3 = themes.Default.Background
themeDropdownFrame.ClipsDescendants = true
themeDropdownFrame.Parent = scrollFrame
newUICorner(themeDropdownFrame)
themeDropdownFrame.Visible = false

local function closeThemeDropdown()
  themeDropdownFrame.Visible = false
  themeDropdownFrame.Size = UDim2.new(1, 0, 0, 0)
end
local function openThemeDropdown()
  themeDropdownFrame.Visible = true
  local height = #themes * 30
  themeDropdownFrame:TweenSize(UDim2.new(1, 0, 0, height), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true)
end

themeDropdown.MouseButton1Click:Connect(function()
  if themeDropdownFrame.Visible then
    closeThemeDropdown()
  else
    openThemeDropdown()
  end
end)

local themeButtons = {}
do
  local i = 0
  for name, _ in pairs(themes) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, 30 * i)
    btn.BackgroundColor3 = themes.Default.Button
    btn.TextColor3 = themes.Default.TextColor
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Text = name
    btn.Parent = themeDropdownFrame
    newUICorner(btn)
    btn.MouseButton1Click:Connect(function()
      currentTheme = name
      themeDropdown.Text = name
      applyTheme(name)
      closeThemeDropdown()
      saveConfig()
    end)
    i = i + 1
    themeButtons[#themeButtons+1] = btn
  end
end
y = y + 40

local function applyTheme(name)
  local t = themes[name]
  if not t then return end
  mainFrame.BackgroundColor3 = t.Background
  themeDropdown.BackgroundColor3 = t.Button
  themeDropdown.TextColor3 = t.TextColor
  toggleButton.BackgroundColor3 = t.Button
  toggleButton.TextColor3 = t.TextColor
  fpsLabel.TextColor3 = t.TextColor
  greySkyToggle.TextColor3 = t.TextColor
  boostToggle.TextColor3 = t.TextColor
  fpsInput.TextColor3 = t.TextColor
  fpsInput.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
  for _, btn in ipairs(themeButtons) do
    btn.BackgroundColor3 = t.Button
    btn.TextColor3 = t.TextColor
  end
end

applyTheme(currentTheme)

-- Font selector dropdown + manual input
local fontLabel = addLabel("Font Selector", themes.Default.TextColor, true)
local fontDropdown = Instance.new("TextButton")
fontDropdown.Size = UDim2.new(1, 0, 0, 30)
fontDropdown.Position = UDim2.new(0, 0, 0, y)
fontDropdown.BackgroundColor3 = themes.Default.Button
fontDropdown.TextColor3 = themes.Default.TextColor
fontDropdown.Font = Enum.Font.GothamBold
fontDropdown.TextSize = 16
fontDropdown.Text = fonts[currentFontIndex]
fontDropdown.Parent = scrollFrame
newUICorner(fontDropdown)
y = y + 38

local fontDropdownFrame = Instance.new("Frame")
fontDropdownFrame.Size = UDim2.new(1, 0, 0, 0)
fontDropdownFrame.Position = UDim2.new(0, 0, 0, y)
fontDropdownFrame.BackgroundColor3 = themes.Default.Background
fontDropdownFrame.ClipsDescendants = true
fontDropdownFrame.Parent = scrollFrame
newUICorner(fontDropdownFrame)
fontDropdownFrame.Visible = false

local function closeFontDropdown()
  fontDropdownFrame.Visible = false
  fontDropdownFrame.Size = UDim2.new(1, 0, 0, 0)
end
local function openFontDropdown()
  fontDropdownFrame.Visible = true
  local height = #fonts * 30
  fontDropdownFrame:TweenSize(UDim2.new(1, 0, 0, height), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true)
end

fontDropdown.MouseButton1Click:Connect(function()
  if fontDropdownFrame.Visible then
    closeFontDropdown()
  else
    openFontDropdown()
  end
end)

local fontButtons = {}
do
  local i = 0
  for _, name in ipairs(fonts) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, 30 * i)
    btn.BackgroundColor3 = themes.Default.Button
    btn.TextColor3 = themes.Default.TextColor
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Text = name
    btn.Parent = fontDropdownFrame
    newUICorner(btn)
    btn.MouseButton1Click:Connect(function()
      currentFontIndex = i + 1
      fontDropdown.Text = name
      applyFont(name)
      closeFontDropdown()
      saveConfig()
    end)
    i = i + 1
    fontButtons[#fontButtons+1] = btn
  end
end
y = y + 40

local function applyFont(name)
  local fontEnum = Enum.Font[name] or Enum.Font.Gotham
  fpsLabel.Font = fontEnum
  fpsInput.Font = fontEnum
  greySkyToggle.Font = fontEnum
  boostToggle.Font = fontEnum
  themeDropdown.Font = fontEnum
  fontDropdown.Font = fontEnum
  for _, btn in ipairs(themeButtons) do
    btn.Font = fontEnum
  end
  for _, btn in ipairs(fontButtons) do
    btn.Font = fontEnum
  end
end

applyFont(fonts[currentFontIndex])local ffLabel = addLabel("FastFlag JSON Editor", themes.Default.TextColor, true)
local ffTextBox = Instance.new("TextBox")
ffTextBox.Size = UDim2.new(1, 0, 0, 100)
ffTextBox.Position = UDim2.new(0, 0, 0, y)
ffTextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ffTextBox.TextColor3 = themes.Default.TextColor
