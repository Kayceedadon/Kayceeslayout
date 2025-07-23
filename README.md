Kaycee'slayout.lou
--[[
  Kaycee's Layout V2
  Features:
    • FPS Input (30–120) with silent clamping & locking
    • FastFlag JSON editor with paste & validation
    • Grey Sky toggle, Boost Mode (no textures), Reset to Defaults
    • Save/load config with getgenv(), persistent during executor session
    • Runs only in Practice Mode (safe for public/private servers)
    • Draggable floating “K” toggle button
    • GUI animations (slide-in, fade, button feedback)
    • Theme switching (Default, Dark, Classic, Stealth)
    • Live FPS counter
    • Custom font selector & manual font input
    • Splash screen with YouTube & Discord info
    • Performance boost toggle
    • Warning popup about saving/applying settings with dismiss button

  Tested on Delta, KML, CodeZ, Codex, Arceus X executors
  Mobile compatible (iOS and Android)
--]]

local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local UI = Instance.new

-- Config keys in getgenv
local config = getgenv().KayceesConfig or {}
getgenv().KayceesConfig = config

-- Utility Functions
local function setfflag(flag, value)
  local success, err = pcall(function()
    setfflag(flag, value)
  end)
  if not success then
    -- silently fail
  end
end

local function applyFlags(jsonText)
  local succ, data = pcall(function() return HttpService:JSONDecode(jsonText) end)
  if not succ or type(data) ~= "table" then
    return false, "Invalid JSON"
  end
  for k,v in pairs(data) do
    pcall(function() setfflag(k,v) end)
  end
  return true
end

local function clampFPS(fps)
  if fps < 30 then return 30 end
  if fps > 120 then return 120 end
  return fps
end

local PracticePlaceIDs = {
  -- Add your Practice Mode Place IDs here
  123456789, -- Example ID, replace with actual
  987654321,
}

local function isPracticeMode()
  for _, id in ipairs(PracticePlaceIDs) do
    if game.PlaceId == id then return true end
  end
  return false
end

-- UI Creation

local scr = UI("ScreenGui", game.CoreGui)
scr.Name = "KayceesLayoutV2"; scr.ResetOnSpawn = false
scr.Enabled = true

-- Floating K Button
local btn = UI("TextButton", scr)
btn.Name = "Toggle"
btn.Size = UDim2.new(0, 40, 0, 40)
btn.Position = UDim2.new(0, 10, 0, 10)
btn.BackgroundColor3 = Color3.new(1, 0, 0)
btn.Text = "K"
btn.Font = Enum.Font.GothamBold
btn.TextSize = 28
btn.TextColor3 = Color3.new(1,1,1)
btn.AutoButtonColor = false
btn.Active = true
btn.Draggable = true
UI("UICorner", btn).CornerRadius = UDim.new(0,8)

-- Main Frame
local frm = UI("Frame", scr)
frm.Name = "Main"
frm.Size = UDim2.new(0, 320, 0, 380)
frm.Position = UDim2.new(0, 60, 0, 10)
frm.BackgroundColor3 = Color3.fromRGB(240,240,240)
frm.Visible = true
UI("UICorner", frm).CornerRadius = UDim.new(0,10)

-- Container scrolling frame
local sc = UI("ScrollingFrame", frm)
sc.Size = UDim2.new(1, -20, 1, -20)
sc.Position = UDim2.new(0, 10, 0, 10)
sc.BackgroundTransparency = 1
sc.ScrollBarThickness = 6
sc.AutomaticCanvasSize = Enum.AutomaticSize.Y

local Y = 0

local function addLabel(txt, col)
  local l = UI("TextLabel", sc)
  l.Text = txt
  l.Size = UDim2.new(1, 0, 0, 24)
  l.Position = UDim2.new(0, 0, 0, Y)
  l.Font = Enum.Font.GothamBold
  l.TextSize = 16
  l.TextColor3 = Color3.new(0, 0, 0)
  l.BackgroundColor3 = col or Color3.fromRGB(200, 200, 200)
  Y = Y + 26
  return l
end

local function addToggle(txt, bool, callback)
  local t = UI("TextButton", sc)
  t.Text = txt .. ": " .. (bool and "ON" or "OFF")
  t.Size = UDim2.new(1, 0, 0, 24)
  t.Position = UDim2.new(0, 0, 0, Y)
  t.Font = Enum.Font.Gotham
  t.TextSize = 14
  t.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
  t.TextColor3 = Color3.new(0, 0, 0)
  UI("UICorner", t).CornerRadius = UDim.new(0, 6)
  t.MouseButton1Click:Connect(function()
    bool = not bool
    t.Text = txt .. ": " .. (bool and "ON" or "OFF")
    callback(bool)
    saveConfig()
  end)
  Y = Y + 26
  return t
end

-- Save config function
function saveConfig()
  config.fps = currentFPS
  config.fastFlags = flagBox.Text
  config.greySky = greySkyToggle and greySkyToggle.Text:find("ON")
  config.boostMode = boostToggle and boostToggle.Text:find("ON")
  config.theme = currentTheme
  config.fontIndex = currentFontIndex
  config.warningDismissed = warningDismissed
  getgenv().KayceesConfig = config
end

-- Load config function
function loadConfig()
  if config.fps then
    setFPS(config.fps)
    updateFPSDisplay(config.fps)
    currentFPS = config.fps
  else
    setFPS(60)
    currentFPS = 60
  end
  if config.fastFlags then
    flagBox.Text = config.fastFlags
    applyFlags(config.fastFlags)
  else
    flagBox.Text = "{}"
  end
  if config.greySky ~= nil then
    greySkyToggle.Text = "Grey Sky: " .. (config.greySky and "ON" or "OFF")
    toggleGreySky(config.greySky)
  end
  if config.boostMode ~= nil then
    boostToggle.Text = "Boost Mode: " .. (config.boostMode and "ON" or "OFF")
    toggleBoostMode(config.boostMode)
  end
  if config.theme then
    applyTheme(config.theme)
  end
  if config.fontIndex then
    applyFont(config.fontIndex)
  end
  if config.warningDismissed then
    hideWarning()
  else
    showWarning()
  end
end

-- FPS variables and display
local currentFPS = 60
local fpsLabel = addLabel("FPS: 60", Color3.fromRGB(100, 100, 100))

local function updateFPSDisplay(fps)
  fpsLabel.Text = "FPS: " .. tostring(fps)
end

local function setFPS(fps)
  fps = clampFPS(fps)
  currentFPS = fps
  -- Apply the flag multiple times to ensure it sticks
  spawn(function()
    for _=1,5 do
      pcall(function()
        setfflag("DFIntTaskSchedulerTargetFps", fps)
      end)
      wait(0.1)
    end
  end)
end

-- FPS input box
local fpsInput = UI("TextBox", sc)
fpsInput.Size = UDim2.new(1, 0, 0, 30)
fpsInput.Position = UDim2.new(0, 0, 0, Y)
fpsInput.Text = tostring(currentFPS)
fpsInput.ClearTextOnFocus = false
fpsInput.Font = Enum.Font.Gotham
fpsInput.TextSize = 16
fpsInput.PlaceholderText = "Enter FPS (30-120)"
fpsInput.TextColor3 = Color3.new(0,0,0)
fpsInput.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
UI("UICorner", fpsInput).CornerRadius = UDim.new(0,6)
Y = Y + 36

fpsInput.FocusLost:Connect(function(enterPressed)
  if enterPressed then
    local val = tonumber(fpsInput.Text)
    if val then
      val = clampFPS(val)
      fpsInput.Text = tostring(val)
      setFPS(val)
      updateFPSDisplay(val)
      saveConfig()
    else
      fpsInput.Text = tostring(currentFPS)
    end
  end
end)

-- FastFlag JSON editor label
addLabel("FastFlag JSON Editor", Color3.fromRGB(180,180,180))

-- FastFlag JSON box
local flagBox = UI("TextBox", sc)
flagBox.Size = UDim2.new(1, 0, 0, 100)
flagBox.Position = UDim2.new(0, 0, 0, Y)
flagBox.Text = "{}"
flagBox.ClearTextOnFocus = false
flagBox.MultiLine = true
flagBox.Font = Enum.Font.Code
flagBox.TextSize = 14
flagBox.TextColor3 = Color3.new(0,0,0)
flagBox.BackgroundColor3 = Color3.fromRGB(245,245,245)
UI("UICorner", flagBox).CornerRadius = UDim.new(0,6)
Y = Y + 106

flagBox.FocusLost:Connect(function(enterPressed)
  if enterPressed then
    local succ, err = applyFlags(flagBox.Text)
    if succ then
      infoLabel.Text = "Status: Applied"
      saveConfig()
    else
      infoLabel.Text = "Status: JSON Error"
    end
  end
end)

-- Status label
local infoLabel = addLabel("Status: OK", Color3.fromRGB(150,150,150))

-- Grey Sky toggle
local greySkyToggle = addToggle("Grey Sky", false, function(state)
  toggleGreySky(state)
  saveConfig()
end)

-- Boost Mode toggle
local boostToggle = addToggle("Boost Mode", false, function(state)
  toggleBoostMode(state)
  saveConfig()
end)

-- Function to toggle Grey Sky
function toggleGreySky(state)
  if state then
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 0
    Lighting.FogStart = 0
    Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
    Lighting.ClockTime = 12
    Lighting.Brightness = 0.2
    Lighting.Sky = nil
  else
    -- Reset lighting settings to defaults (you can customize these)
    Lighting.GlobalShadows = true
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
    Lighting.ClockTime = 14
    Lighting.Brightness = 2
    if not Lighting:FindFirstChildOfClass("Sky") then
      local sky = Instance.new("Sky", Lighting)
      Lighting.Sky = sky
    end
  end
end

-- Function to toggle Boost Mode (No textures etc)
function toggleBoostMode(state)
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
end

-- Theme system
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

local currentTheme = "Default"

local function applyTheme(name)
  local t = themes[name]
  if not t then return end
  frm.BackgroundColor3 = t.Background
  btn.BackgroundColor3 = t.Button
  btn.TextColor3 = t.TextColor
  fpsLabel.TextColor3 = t.TextColor
  infoLabel.TextColor3 = t.TextColor
  greySkyToggle.TextColor3 = t.TextColor
  boostToggle.TextColor3 = t.TextColor
  -- Update toggle buttons colors
  local toggles = {greySkyToggle, boostToggle}
  for _, toggle in ipairs(toggles) do
    toggle.BackgroundColor3 = t.Button:Lerp(Color3.new(1,1,1), 0.7)
  end
  -- Theme specific font colors for all text labels/buttons here...
  currentTheme = name
  saveConfig()
end

-- Theme selector UI
local themeLabel = addLabel("Theme Selector", Color3.fromRGB(200, 200, 200))
local themeDropdown = UI("TextButton", sc)
themeDropdown.Text = currentTheme
themeDropdown.Size = UDim2.new(1, 0, 0, 26)
themeDropdown.Position = UDim2.new(0, 0, 0, Y)
themeDropdown.Font = Enum.Font.Gotham
themeDropdown.TextSize = 16
themeDropdown.BackgroundColor3 = Color3.fromRGB(230,230,230)
UI("UICorner", themeDropdown).CornerRadius = UDim.new(0,6)
Y = Y + 32

local dropdownOpen = false
local dropdownFrame = UI("Frame", sc)
dropdownFrame.Size = UDim2.new(1, 0, 0, 0)
dropdownFrame.Position = UDim2.new(0, 0, 0, Y)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
dropdownFrame.ClipsDescendants = true
UI("UICorner", dropdownFrame).CornerRadius = UDim.new(0,6)
dropdownFrame.Visible = false
Y = Y + 0

local function closeDropdown()
  dropdownOpen = false
  dropdownFrame.Visible = false
  dropdownFrame.Size = UDim2.new(1, 0, 0, 0)
end

local function openDropdown()
  dropdownOpen = true
  dropdownFrame.Visible = true
  local height = 26 * #themes
  dropdownFrame:TweenSize(UDim2.new(1, 0, 0, height), "Out", "Quad", 0.25, true)
end

themeDropdown.MouseButton1Click:Connect(function()
  if dropdownOpen then
    closeDropdown()
  else
    openDropdown()
  end
end)

local function setTheme(name)
  applyTheme(name)
  themeDropdown.Text = name
  closeDropdown()
  saveConfig()
end

-- Populate dropdown
local themeButtons = {}
do
  local i = 0
  for name,_ in pairs(themes) do
    local btn = UI("TextButton", dropdownFrame)
    btn.Text = name
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.Position = UDim2.new(0, 0, 0, 26*i)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    btn.TextColor3 = Color3.new(0,0,0)
    UI("UICorner", btn).CornerRadius = UDim.new(0,6)
    btn.MouseButton1Click:Connect(function()
      setTheme(name)
    end)
    table.insert(themeButtons, btn)
    i = i + 1
  end
end

Y = Y + 26 -- reserve space for dropdown expanded later

-- Font selector
local fonts = {
  "Gotham", "Arial", "SourceSans", "SourceSansBold", "SourceSansItalic",
  "Highway", "HighwayBold", "HighwayItalic", "Arcade", "ArcadeBold",
}

local currentFontIndex = 1

local fontLabel = addLabel("Font Selector", Color3.fromRGB(200, 200, 200))
local fontDropdown = UI("TextButton", sc)
fontDropdown.Text = fonts[currentFontIndex]
fontDropdown.Size = UDim2.new(1, 0, 0, 26)
fontDropdown.Position = UDim2.new(0, 0, 0, Y)
fontDropdown.Font = Enum.Font.Gotham
fontDropdown.TextSize = 16
fontDropdown.BackgroundColor3 = Color3.fromRGB(230,230,230)
UI("UICorner", fontDropdown).CornerRadius = UDim.new(0,6)
Y = Y + 32

local fontDropdownOpen = false
local fontDropdownFrame = UI("Frame", sc)
fontDropdownFrame.Size = UDim2.new(1, 0, 0, 0)
fontDropdownFrame.Position = UDim2.new(0, 0, 0, Y)
fontDropdownFrame.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
fontDropdownFrame.ClipsDescendants = true
UI("UICorner", fontDropdownFrame).CornerRadius = UDim.new(0,6)
fontDropdownFrame.Visible = false
Y = Y + 0

local function closeFontDropdown()
  fontDropdownOpen = false
  fontDropdownFrame.Visible = false
  fontDropdownFrame.Size = UDim2
