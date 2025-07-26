--[[
  KayceeLayoutV2 by TheNewkaycee
  ✅ Mobile + PC compatible
  ✅ Features: Splash, Tabs, FastFlags, Engine Settings, FPS, Save Config, Old Oof, Drag UI
]]

print("[KayceeLayoutV2] Starting loader...")

if not writefile then
	warn("[KayceeLayoutV2] writefile/readfile not supported by your executor.")
	return
end

print("[KayceeLayoutV2] writefile supported.")

-- Services
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local http = game:GetService("HttpService")
local players = game:GetService("Players")
local lighting = game:GetService("Lighting")
local terrain = workspace:FindFirstChildOfClass("Terrain")

-- Paths
local configPath = "KayceeLayoutV2/Config.json"
local flagPath = "KayceeLayoutV2/Flags.json"

-- Ensure folder
if not isfolder("KayceeLayoutV2") then
	makefolder("KayceeLayoutV2")
end

-- JSON helpers
local function readJSON(path)
	local ok, res = pcall(function() return http:JSONDecode(readfile(path)) end)
	return ok and res or {}
end
local function saveJSON(path, tbl)
	pcall(function() writefile(path, http:JSONEncode(tbl)) end)
end

local config = readJSON(configPath)
local savedFlags = readJSON(flagPath)

-- FPS label
-- (already styled above this code remains unchanged)
-- ... [Your existing FPS display code continues here]

-- GUI setup and splash code
-- ... [Your existing splash, toggle button, tabs creation, Mods tab code continues here]

-- Engine Settings Tab:
do
	local engine = tabFrames["Engine Settings"]
	local padding, h = 10, 24
	local y = padding

	local function saveConfigValue(key, value)
		config[key] = value
		saveJSON(configPath, config)
	end

	local function createLabel(parent, text, posY)
		local lbl = Instance.new("TextLabel", parent)
		lbl.Size = UDim2.new(0, 200, 0, h)
		lbl.Position = UDim2.new(0, padding, 0, posY)
		lbl.BackgroundTransparency = 1
		lbl.TextColor3 = Color3.fromRGB(0,170,255)
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 14
		lbl.Text = text
		lbl.TextXAlignment = Enum.TextXAlignment.Left
	end

	local function newToggle(key, labelText, posY, desc)
		createLabel(engine, labelText, posY)
		local btn = Instance.new("TextButton", engine)
		btn.Size = UDim2.new(0, 80, 0, h)
		btn.Position = UDim2.new(0, 220, 0, posY)
		btn.BackgroundColor3 = Color3.fromRGB(10,10,10)
		btn.BorderColor3 = Color3.fromRGB(0,170,255)
		btn.TextColor3 = Color3.fromRGB(0,170,255)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 14

		local state = config[key] == true
		btn.Text = state and "On" or "Off"

		btn.MouseButton1Click:Connect(function()
			state = not state
			btn.Text = state and "On" or "Off"
			saveConfigValue(key, state)
			-- apply effect
			if key=="oldOof" then
				if state then
					players.LocalPlayer.CharacterAdded:Connect(function(c)
						c:WaitForChild("Humanoid").Died:Connect(function()
							local s=Instance.new("Sound", workspace)
							s.SoundId="rbxassetid://131070686"
							s:Play()
							game.Debris:AddItem(s,3)
						end)
					end)
				end
			elseif key=="displayFPS" then
				fpsLabel.Visible = state
			elseif key=="disableShadows" then
				if players.LocalPlayer.Character and players.LocalPlayer.Character:FindFirstChild("Head") then
					players.LocalPlayer.Character.HumanoidRootPart.CastShadow = not state
				end
			elseif key=="disablePost" then
				for _,i in ipairs(lighting:GetDescendants()) do
					if i:IsA("PostEffect") then i.Enabled = not state end
				end
			elseif key=="disableTerrainTex" and terrain then
				terrain:SetMaterials(state and 1 or 0) -- simplified
			end
		end)

		-- initial apply:
		if state then btn.MouseButton1Click:Fire() end

		return h + padding
	end

	local function newTextbox(key, labelText, posY, placeholder)
		createLabel(engine, labelText, posY)
		local tb = Instance.new("TextBox", engine)
		tb.Size = UDim2.new(0, 80, 0, h)
		tb.Position = UDim2.new(0, 220, 0, posY)
		tb.BackgroundColor3 = Color3.fromRGB(10,10,10)
		tb.BorderColor3 = Color3.fromRGB(0,170,255)
		tb.TextColor3 = Color3.fromRGB(0,170,255)
		tb.Font = Enum.Font.GothamBold
		tb.TextSize = 14
		tb.PlaceholderText = placeholder or ""
		tb.Text = tostring(config[key] or "")

		tb.FocusLost:Connect(function(enterPressed)
			local num = tonumber(tb.Text)
			if num then
				saveConfigValue(key, num)
				if key=="fpsLimit" then
					if num>0 then
						if setfpscap then setfpscap(num) end
					else
						if setfpscap then setfpscap(999) end
					end
				end
			else
				tb.Text = tostring(config[key] or "")
			end
		end)
		-- initial apply
		if config[key] then tb.FocusLost(true) end

		return h + padding
	end

	local function newDropdown(key, labelText, posY, opts)
		createLabel(engine, labelText, posY)
		for i,opt in ipairs(opts) do
			local btn = Instance.new("TextButton", engine)
			btn.Size = UDim2.new(0, 80, 0, h)
			btn.Position = UDim2.new(0, 220 + (i-1)*85, 0, posY)
			btn.BackgroundColor3 = Color3.fromRGB(10,10,10)
			btn.BorderColor3 = Color3.fromRGB(0,170,255)
			btn.TextColor3 = Color3.fromRGB(0,170,255)
			btn.Font = Enum.Font.GothamBold
			btn.TextSize = 14
			btn.Text = opt

			btn.MouseButton1Click:Connect(function()
				saveConfigValue(key, opt)
				for _,b in ipairs(engine:GetChildren()) do
					if b:IsA("TextButton") and b.Position.Y.Offset==posY and b.Text~=opt then
						b.BackgroundColor3 = Color3.fromRGB(10,10,10)
						b.TextColor3 = Color3.fromRGB(0,170,255)
					end
				end
				btn.BackgroundColor3 = Color3.fromRGB(0,170,255)
				btn.TextColor3 = Color3.fromRGB(0,0,0)

				if key=="aaQuality" then
					game:GetService("RunService"):Set3dRenderingEnabled(true)
					settings().Rendering.QualityLevel = opts.indexOf(opt) * 2
				elseif key=="lightingTech" then
					lighting.Technology = opt
				elseif key=="textureQuality" then
					if terrain then terrain:SetMaterials(#opts - #opts + 1) end
				end
			end)

			-- apply stored selection
			if config[key]==opt then
				btn.BackgroundColor3 = Color3.fromRGB(0,170,255)
				btn.TextColor3 = Color3.fromRGB(0,0,0)
			end
		end

		return h + padding
	end

	local delta = 0
	delta += newToggle("oldOof", "Use old death sound", y)
	y += delta

	delta = newDropdown("aaQuality", "Anti-aliasing quality (MSAA)", y, {"Off","Low","Medium","High"})
	y += delta

	delta = newToggle("disableShadows", "Disable player shadows", y)
	y += delta

	delta = newToggle("disablePost", "Disable post‑processing effects", y)
	y += delta

	delta = newToggle("disableTerrainTex", "Disable terrain textures", y)
	y += delta

	delta = newTextbox("fpsLimit", "Framerate limit", y, "0 = unlock")
	y += delta

	delta = newToggle("displayFPS", "Display FPS", y)
	y += delta

	delta = newDropdown("lightingTech", "Preferred lighting technology", y, {"Compatibility","ShadowMap","Voxel","Future"})
	y += delta

	delta = newDropdown("textureQuality", "Texture quality", y, {"Low","Medium","High"})
	y += delta
end

-- Toggle menu
toggleButton.MouseButton1Click:Connect(function()
	menu.Visible = not menu.Visible
end)

-- Save Config tab (rest of script remains unchanged)
