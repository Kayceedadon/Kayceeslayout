--[[
    Kaycees Layout - FPS GUI for Football Fusion 2
    Designed for mobile (Delta, KML, CodeZ)
    Features: Scrollable GUI, FPS Lock, Grey Sky, FastFlag Editor
    Theme: Red / White / Green
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "KayceesLayout"
ScreenGui.ResetOnSpawn = false

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 40, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0.5, -20)
toggleButton.Text = "+"
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Parent = ScreenGui
toggleButton.Active = true
toggleButton.Draggable = true

local mainFrame = Instance.new("ScrollingFrame")
mainFrame.Size = UDim2.new(0, 280, 0, 300)
mainFrame.Position = UDim2.new(0, 60, 0.5, -150)
mainFrame.CanvasSize = UDim2.new(0, 0, 1.5, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = ScreenGui

-- Theme Color Palette
local red = Color3.fromRGB(255, 0, 0)
local green = Color3.fromRGB(0, 255, 0)
local white = Color3.fromRGB(255, 255, 255)

-- UI Helper
local function createLabel(text, y)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 30)
    label.Position = UDim2.new(0, 10, 0, y)
    label.BackgroundTransparency = 1
    label.TextColor3 = white
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.Parent = mainFrame
    return label
end

local function createButton(text, y, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = white
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = mainFrame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function createTextBox(y)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -20, 0, 60)
    box.Position = UDim2.new(0, 10, 0, y)
    box.Text = "Paste your FastFlags or JSON here"
    box.ClearTextOnFocus = false
    box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    box.TextColor3 = white
    box.TextWrapped = true
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.TextYAlignment = Enum.TextYAlignment.Top
    box.Font = Enum.Font.Code
    box.TextSize = 14
    box.Parent = mainFrame
    return box
end

-- Sections
local y = 10
createLabel("🔰 Kaycees Layout", y).TextColor3 = green; y += 35

-- Introduction
createLabel("📌 Introduction", y).TextColor3 = red; y += 25

createLabel("Welcome! This is a mobile FPS GUI", y); y += 30

-- Engine Settings
createLabel("⚙️ Engine Settings", y).TextColor3 = red; y += 25

-- FPS Slider + Set
local fpsVal = 60
local fpsLabel = createLabel("FPS: 60", y); y += 25

local fpsBox = Instance.new("TextBox")
fpsBox.Size = UDim2.new(1, -20, 0, 30)
fpsBox.Position = UDim2.new(0, 10, 0, y)
fpsBox.Text = "60"
fpsBox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
fpsBox.TextColor3 = white
fpsBox.Font = Enum.Font.Gotham
fpsBox.TextSize = 14
fpsBox.Parent = mainFrame
y += 35

local function setFPS(val)
    fpsVal = tonumber(val) or 60
    if setfflag then
        pcall(function()
            setfflag("DFIntTaskSchedulerTargetFps", tostring(fpsVal))
        end)
    end
    fpsLabel.Text = "FPS: " .. fpsVal
end

fpsBox.FocusLost:Connect(function()
    setFPS(fpsBox.Text)
end)

-- Grey Sky Toggle
createButton("Enable Grey Sky", y, green, function()
    if setfflag then
        pcall(function()
            setfflag("FFlagDebugForceFutureIsBrightPhase3", "True")
        end)
    end
end)
y += 35

-- Show FPS Live
local fpsCounter = createLabel("FPS: 0", y); y += 30
local last = tick()
local count = 0

RunService.RenderStepped:Connect(function()
    count += 1
    if tick() - last >= 1 then
        fpsCounter.Text = "FPS: " .. count
        last = tick()
        count = 0
    end
end)

-- FastFlag JSN Section
createLabel("🚩 FastFlag Editor", y).TextColor3 = red; y += 25

local jsnBox = createTextBox(y); y += 70

createButton("Apply FastFlags", y, red, function()
    local lines = string.split(jsnBox.Text, "\n")
    for _, line in ipairs(lines) do
        local flag, val = string.match(line, "\"(.-)\":%s*\"(.-)\"")
        if flag and val and setfflag then
            pcall(function()
                setfflag(flag, val)
            end)
        end
    end
end)
y += 35

-- Toggle visibility
toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)
