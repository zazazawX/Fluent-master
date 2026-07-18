local httpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end

local KeySystem = {} do
	KeySystem.Library = nil
	
	function KeySystem:SetLibrary(library)
		self.Library = library
	end

	local Presets = {
		PandaAuth = function(Key, Config)
			local Service = Config.Service or ""
			local Url = "https://api-gateway.pandadevelopment.net/v1/sdk/verify?key=" .. tostring(Key) .. "&service=" .. tostring(Service)
			local success, result = pcall(function()
				return game:HttpGet(Url)
			end)
			if success and result then
				local successJson, decoded = pcall(function()
					return game:GetService("HttpService"):JSONDecode(result)
				end)
				if successJson and decoded then
					return decoded.success == true or decoded.valid == true
				end
			end
			return false
		end,
		
		Luaguard = function(Key, Config)
			local Project = Config.Project or ""
			local Url = "https://api.luaguard.org/v1/check?key=" .. tostring(Key) .. "&project=" .. tostring(Project)
			local success, result = pcall(function()
				return game:HttpGet(Url)
			end)
			if success and result then
				local successJson, decoded = pcall(function()
					return game:GetService("HttpService"):JSONDecode(result)
				end)
				if successJson and decoded then
					return decoded.success == true or decoded.valid == true or decoded.status == "success"
				end
			end
			return false
		end,
		
		Keyguard = function(Key, Config)
			local Project = Config.Project or ""
			local Url = "https://api.keyguard.xyz/v1/assets/verify?key=" .. tostring(Key) .. "&project=" .. tostring(Project)
			local success, result = pcall(function()
				return game:HttpGet(Url)
			end)
			if success and result then
				local successJson, decoded = pcall(function()
					return game:GetService("HttpService"):JSONDecode(result)
				end)
				if successJson and decoded then
					return decoded.success == true or decoded.valid == true
				end
			end
			return false
		end,
		
		Custom = function(Key, Config)
			local Url = Config.Url or ""
			if Url == "" then return false end
			local FinalUrl = Url:gsub("{key}", tostring(Key))
			if FinalUrl == Url then
				if FinalUrl:find("%?") then
					FinalUrl = FinalUrl .. "&key=" .. tostring(Key)
				else
					FinalUrl = FinalUrl .. "?key=" .. tostring(Key)
				end
			end
			local success, result = pcall(function()
				return game:HttpGet(FinalUrl)
			end)
			if success and result then
				if Config.CheckFunction then
					local successCheck, res = pcall(Config.CheckFunction, result)
					return successCheck and res == true
				else
					local successJson, decoded = pcall(function()
						return game:GetService("HttpService"):JSONDecode(result)
					end)
					if successJson and decoded then
						return decoded.success == true or decoded.valid == true or decoded.status == "success"
					end
					return result:lower():find("true") ~= nil or result:lower():find("success") ~= nil
				end
			end
			return false
		end
	}

	function KeySystem:CreateKeySystem(Config)
		assert(self.Library, "KeySystem - Must set library first (KeySystem:SetLibrary(Fluent))")
		local Library = self.Library
		local Creator = Library.Creator
		local Acrylic = Library.Acrylic
		local New = Creator.New
		
		assert(Config.OnVerified, "KeySystem - Missing OnVerified callback")

		local UseAcrylic = Config.Acrylic ~= false
		if UseAcrylic then
			Library.UseAcrylic = true
			Acrylic.init()
		end

		local SaveKey = Config.SaveKey
		local SavePath = Config.SavePath or "fluent-key.txt"
		local SavedKey = ""

		if SaveKey then
			local readfile = readfile or (io and io.read)
			local isfile = isfile or function(path)
				local success, _ = pcall(readfile, path)
				return success
			end
			if isfile(SavePath) then
				local successRead, content = pcall(readfile, SavePath)
				if successRead and content then
					SavedKey = content:gsub("%s+", "")
				end
			end
		end

		local KeySystemGui = New("ScreenGui", {
			Name = "CoreXKeySystem",
			IgnoreGuiInset = false,
			ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
			SafeAreaCompatibility = Enum.SafeAreaCompatibility.None,
			ClipToDeviceSafeArea = true,
			Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui"),
		})
		ProtectGui(KeySystemGui)

		local KeySystemFrame = New("Frame", {
			Size = UDim2.fromOffset(340, 200),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Parent = KeySystemGui,
		})

		local KeySystemPaint = Acrylic.AcrylicPaint()
		if KeySystemPaint.AddParent then
			KeySystemPaint.AddParent(KeySystemFrame)
		end

		New("UICorner", {
			CornerRadius = UDim.new(0, 8),
			Parent = KeySystemPaint.Frame,
		})

		local UIStroke = New("UIStroke", {
			Color = Color3.fromRGB(80, 80, 80),
			Transparency = 0.5,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = KeySystemPaint.Frame,
		})

		local Title = New("TextLabel", {
			Size = UDim2.new(1, -24, 0, 24),
			Position = UDim2.fromOffset(12, 16),
			Text = Config.Title or "Key System",
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextSize = 18,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			Parent = KeySystemPaint.Frame,
		})

		local SubTitle = New("TextLabel", {
			Size = UDim2.new(1, -24, 0, 18),
			Position = UDim2.fromOffset(12, 38),
			Text = Config.SubTitle or "Verification Required",
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
			TextSize = 12,
			TextColor3 = Color3.fromRGB(180, 180, 180),
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			Parent = KeySystemPaint.Frame,
		})

		local TextboxFrame = New("Frame", {
			Size = UDim2.new(1, -24, 0, 36),
			Position = UDim2.fromOffset(12, 75),
			BackgroundColor3 = Color3.fromRGB(35, 35, 35),
			BackgroundTransparency = 0.3,
			Parent = KeySystemPaint.Frame,
		}, {
			New("UICorner", { CornerRadius = UDim.new(0, 6) }),
			New("UIStroke", {
				Color = Color3.fromRGB(60, 60, 60),
				Transparency = 0.5,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			})
		})

		local Input = New("TextBox", {
			Size = UDim2.new(1, -20, 1, 0),
			Position = UDim2.fromOffset(10, 0),
			BackgroundTransparency = 1,
			Text = "",
			PlaceholderText = "Enter key here...",
			PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextSize = 13,
			ClearTextOnFocus = false,
			TextXAlignment = Enum.TextXAlignment.Left,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
			Parent = TextboxFrame,
		})

		local GetKeyButton, DiscordButton, VerifyButton
		
		if Config.Discord then
			GetKeyButton = New("TextButton", {
				Size = UDim2.new(0, 100, 0, 36),
				Position = UDim2.new(0, 12, 1, -48),
				BackgroundColor3 = Color3.fromRGB(45, 45, 45),
				BackgroundTransparency = 0.3,
				Text = "Get Key",
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
				TextColor3 = Color3.fromRGB(230, 230, 230),
				TextSize = 13,
				Parent = KeySystemPaint.Frame,
			}, {
				New("UICorner", { CornerRadius = UDim.new(0, 6) }),
				New("UIStroke", {
					Color = Color3.fromRGB(70, 70, 70),
					Transparency = 0.6,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				})
			})

			DiscordButton = New("TextButton", {
				Size = UDim2.new(0, 100, 0, 36),
				Position = UDim2.new(0, 120, 1, -48),
				BackgroundColor3 = Color3.fromRGB(45, 45, 45),
				BackgroundTransparency = 0.3,
				Text = "Discord",
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
				TextColor3 = Color3.fromRGB(230, 230, 230),
				TextSize = 13,
				Parent = KeySystemPaint.Frame,
			}, {
				New("UICorner", { CornerRadius = UDim.new(0, 6) }),
				New("UIStroke", {
					Color = Color3.fromRGB(70, 70, 70),
					Transparency = 0.6,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				})
			})

			VerifyButton = New("TextButton", {
				Size = UDim2.new(0, 100, 0, 36),
				Position = UDim2.new(0, 228, 1, -48),
				BackgroundColor3 = Creator.GetThemeProperty("Accent") or Color3.fromRGB(96, 205, 255),
				BackgroundTransparency = 0,
				Text = "Verify Key",
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
				TextColor3 = Color3.fromRGB(0, 0, 0),
				TextSize = 13,
				Parent = KeySystemPaint.Frame,
			}, {
				New("UICorner", { CornerRadius = UDim.new(0, 6) })
			})
		else
			GetKeyButton = New("TextButton", {
				Size = UDim2.new(0.5, -16, 0, 36),
				Position = UDim2.new(0, 12, 1, -48),
				BackgroundColor3 = Color3.fromRGB(45, 45, 45),
				BackgroundTransparency = 0.3,
				Text = "Get Key",
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
				TextColor3 = Color3.fromRGB(230, 230, 230),
				TextSize = 13,
				Parent = KeySystemPaint.Frame,
			}, {
				New("UICorner", { CornerRadius = UDim.new(0, 6) }),
				New("UIStroke", {
					Color = Color3.fromRGB(70, 70, 70),
					Transparency = 0.6,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				})
			})

			VerifyButton = New("TextButton", {
				Size = UDim2.new(0.5, -16, 0, 36),
				Position = UDim2.new(0.5, 4, 1, -48),
				BackgroundColor3 = Creator.GetThemeProperty("Accent") or Color3.fromRGB(96, 205, 255),
				BackgroundTransparency = 0,
				Text = "Verify Key",
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
				TextColor3 = Color3.fromRGB(0, 0, 0),
				TextSize = 13,
				Parent = KeySystemPaint.Frame,
			}, {
				New("UICorner", { CornerRadius = UDim.new(0, 6) })
			})
		end

		local TweenService = game:GetService("TweenService")
		
		GetKeyButton.MouseEnter:Connect(function()
			TweenService:Create(GetKeyButton, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(55, 55, 55) }):Play()
		end)
		GetKeyButton.MouseLeave:Connect(function()
			TweenService:Create(GetKeyButton, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(45, 45, 45) }):Play()
		end)

		if DiscordButton then
			DiscordButton.MouseEnter:Connect(function()
				TweenService:Create(DiscordButton, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(55, 55, 55) }):Play()
			end)
			DiscordButton.MouseLeave:Connect(function()
				TweenService:Create(DiscordButton, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(45, 45, 45) }):Play()
			end)
			DiscordButton.Activated:Connect(function()
				if setclipboard then
					setclipboard(Config.Discord)
					Library:Notify({
						Title = "Discord Link",
						Content = "Discord invite link copied to clipboard!",
						Type = "Success",
						Duration = 3
					})
				else
					Library:Notify({
						Title = "Discord Link",
						Content = "Your executor does not support setclipboard.",
						Type = "Error",
						Duration = 3
					})
				end
			end)
		end

		VerifyButton.MouseEnter:Connect(function()
			TweenService:Create(VerifyButton, TweenInfo.new(0.15), { BackgroundTransparency = 0.15 }):Play()
		end)
		VerifyButton.MouseLeave:Connect(function()
			TweenService:Create(VerifyButton, TweenInfo.new(0.15), { BackgroundTransparency = 0 }):Play()
		end)

		local Attempts = 0
		local MaxAttempts = Config.MaxAttempts or 5
		local LockoutDuration = Config.LockoutDuration or 60
		local IsLocked = false
		local IsVerifying = false

		local function SetInputEnabled(Enabled)
			Input.TextEditable = Enabled
		end

		local function StartLockout()
			IsLocked = true
			SetInputEnabled(false)
			local TimeLeft = LockoutDuration
			task.spawn(function()
				while TimeLeft > 0 do
					VerifyButton.Text = "Locked (" .. tostring(TimeLeft) .. "s)"
					VerifyButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
					VerifyButton.TextColor3 = Color3.fromRGB(150, 150, 150)
					task.wait(1)
					TimeLeft = TimeLeft - 1
				end
				IsLocked = false
				Attempts = 0
				SetInputEnabled(true)
				VerifyButton.Text = "Verify Key"
				VerifyButton.BackgroundColor3 = Creator.GetThemeProperty("Accent") or Color3.fromRGB(96, 205, 255)
				VerifyButton.TextColor3 = Color3.fromRGB(0, 0, 0)
			end)
		end

		local function VerifyKey(Key)
			if Key == "" or Key == nil then return false end
			
			if Config.Preset and Presets[Config.Preset] then
				return Presets[Config.Preset](Key, Config.PresetConfig or {})
			elseif Config.Callback then
				local success, res = pcall(Config.Callback, Key)
				return success and res == true
			elseif Config.Key and Key == Config.Key then
				return true
			elseif Config.Keys then
				for _, k in ipairs(Config.Keys) do
					if Key == tostring(k) then
						return true
					end
				end
			end
			return false
		end

		local function Verify(KeyOverride)
			if IsLocked or IsVerifying then return end
			
			local Entered = KeyOverride or Input.Text
			if Entered == "" then
				Library:Notify({
					Title = "Key System",
					Content = "Please enter a key first.",
					Type = "Warning",
					Duration = 3
				})
				return
			end

			IsVerifying = true
			SetInputEnabled(false)
			VerifyButton.Text = "Verifying..."
			VerifyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			VerifyButton.TextColor3 = Color3.fromRGB(150, 150, 150)

			task.spawn(function()
				local Correct = VerifyKey(Entered)
				
				if Correct then
					if SaveKey then
						local writefile = writefile or (io and io.write)
						if writefile then
							pcall(writefile, SavePath, Entered)
						end
					end

					Library:Notify({
						Title = "Key System",
						Content = "Access granted! Loading UI...",
						Type = "Success",
						Duration = 3
					})

					local FadeTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					TweenService:Create(Title, FadeTweenInfo, { TextTransparency = 1 }):Play()
					TweenService:Create(SubTitle, FadeTweenInfo, { TextTransparency = 1 }):Play()
					TweenService:Create(TextboxFrame, FadeTweenInfo, { BackgroundTransparency = 1 }):Play()
					TweenService:Create(Input, FadeTweenInfo, { TextTransparency = 1 }):Play()
					TweenService:Create(GetKeyButton, FadeTweenInfo, { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
					if DiscordButton then
						TweenService:Create(DiscordButton, FadeTweenInfo, { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
					end
					TweenService:Create(VerifyButton, FadeTweenInfo, { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
					TweenService:Create(UIStroke, FadeTweenInfo, { Transparency = 1 }):Play()

					local FrameScale = New("UIScale", { Scale = 1, Parent = KeySystemPaint.Frame })
					TweenService:Create(FrameScale, FadeTweenInfo, { Scale = 1.05 }):Play()

					task.wait(0.3)
					KeySystemGui:Destroy()
					
					task.spawn(Config.OnVerified)
				else
					IsVerifying = false
					SetInputEnabled(true)
					VerifyButton.Text = "Verify Key"
					VerifyButton.BackgroundColor3 = Creator.GetThemeProperty("Accent") or Color3.fromRGB(96, 205, 255)
					VerifyButton.TextColor3 = Color3.fromRGB(0, 0, 0)

					local Stroke = TextboxFrame:FindFirstChildOfClass("UIStroke")
					if Stroke then
						Stroke.Color = Color3.fromRGB(245, 115, 115)
						task.spawn(function()
							task.wait(1.5)
							if Stroke.Parent then
								Stroke.Color = Color3.fromRGB(60, 60, 60)
							end
						end)
					end

					local OriginalPos = KeySystemFrame.Position
					task.spawn(function()
						for i = 1, 6 do
							local OffsetX = (i % 2 == 0) and 8 or -8
							KeySystemFrame.Position = OriginalPos + UDim2.fromOffset(OffsetX, 0)
							task.wait(0.04)
						end
						KeySystemFrame.Position = OriginalPos
					end)

					Attempts = Attempts + 1
					if Config.BruteForceProtection ~= false and Attempts >= MaxAttempts then
						StartLockout()
						Library:Notify({
							Title = "Key System",
							Content = "Too many wrong attempts! Locked for " .. tostring(LockoutDuration) .. "s.",
							Type = "Error",
							Duration = 5
						})
					else
						Library:Notify({
							Title = "Key System",
							Content = "Invalid key. Attempts: " .. tostring(Attempts) .. "/" .. tostring(MaxAttempts),
							Type = "Error",
							Duration = 3
						})
					end
				end
		end)
	end

	VerifyButton.Activated:Connect(function()
		Verify()
	end)
	
	GetKeyButton.Activated:Connect(function()
		if Config.GetKeyLink then
			if setclipboard then
				setclipboard(Config.GetKeyLink)
				Library:Notify({
					Title = "Key System",
					Content = "Key link copied to clipboard!",
					Type = "Success",
					Duration = 3
				})
			else
				Library:Notify({
					Title = "Key System",
					Content = "Your executor does not support setclipboard.",
					Type = "Error",
					Duration = 3
				})
			end
		else
			Library:Notify({
				Title = "Key System",
				Content = "No key link provided.",
				Type = "Warning",
				Duration = 3
			})
		end
	end)

	Input.FocusLost:Connect(function(EnterPressed)
		if EnterPressed then
			Verify()
		end
	end)

	if SavedKey ~= "" then
		Input.Text = SavedKey
		Verify(SavedKey)
	end
end
end

return KeySystem
