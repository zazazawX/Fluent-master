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

	local function ReadPath(Value, Path)
		for Part in tostring(Path or "success"):gmatch("[^%.]+") do
			if type(Value) ~= "table" then return nil end
			Value = Value[Part]
		end
		return Value
	end

	local function VerifyAPI(Key, API)
		local RawUrl = tostring(API.Url or API.URL or "")
		local Url = RawUrl:gsub("{key}", tostring(Key))
		if Url == "" then return false end
		local Method = string.upper(API.Method or "GET")
		if Method == "GET" and Url == RawUrl and API.AppendKey ~= false then
			Url = Url .. (Url:find("?", 1, true) and "&" or "?") .. tostring(API.KeyParam or "key") .. "=" .. tostring(Key)
		end
		local Response
		local Request = API.Request or request or http_request or (syn and syn.request)
		if Request then
			local Body = API.Body
			if type(Body) == "table" then
				local Copy = {}
				for Name, Value in pairs(Body) do Copy[Name] = Value end
				Copy[API.KeyField or "key"] = Key
				Body = Copy
				Body = httpService:JSONEncode(Body)
			end
			local Result = Request({ Url = Url, Method = Method, Headers = API.Headers or {}, Body = Body })
			Response = Result and (Result.Body or Result.body)
		elseif Method == "GET" then
			Response = game:HttpGet(Url)
		else
			return false
		end
		if API.CheckFunction then return API.CheckFunction(Response, Key) == true end
		local Success, Decoded = pcall(function() return httpService:JSONDecode(Response) end)
		if not Success then
			return tostring(Response):lower():find("true", 1, true) ~= nil
		end
		local Result = ReadPath(Decoded, API.SuccessField or "success")
		if API.SuccessValues then
			for _, Value in ipairs(API.SuccessValues) do
				if Result == Value then return true end
			end
			return false
		end
		return Result == true or Result == "true" or Result == "success" or Result == "valid"
	end

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
		local Overlay = New("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = Config.OverlayTransparency or 0.35,
			BorderSizePixel = 0,
			Parent = KeySystemGui,
		})

		local KeySystemFrame = New("Frame", {
			Size = UDim2.new(0.9, 0, 0, 390),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Parent = Overlay,
		})
		New("UISizeConstraint", {
			MinSize = Vector2.new(300, 360),
			MaxSize = Vector2.new(420, 390),
			Parent = KeySystemFrame,
		})
		New("ImageLabel", {
			Size = UDim2.new(1, 70, 1, 70),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = "rbxassetid://8992230677",
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			ImageTransparency = 0.45,
			BackgroundTransparency = 1,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(99, 99, 99, 99),
			Parent = KeySystemFrame,
		})

		local KeySystemPaint = Acrylic.AcrylicPaint()
		KeySystemPaint.Frame.Parent = KeySystemFrame
		KeySystemPaint.Frame.BackgroundTransparency = 0.08
		local PaintBackground = KeySystemPaint.Frame:FindFirstChild("Background")
		if PaintBackground then PaintBackground.BackgroundTransparency = 0.08 end
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

		local LockIcon = New("TextLabel", {
			Size = UDim2.fromOffset(44, 44),
			Position = UDim2.new(0.5, -22, 0, 22),
			Text = "🔐",
			TextSize = 28,
			BackgroundTransparency = 1,
			Parent = KeySystemPaint.Frame,
		})
		local Title = New("TextLabel", {
			Size = UDim2.new(1, -56, 0, 26),
			Position = UDim2.fromOffset(28, 70),
			Text = Config.Title or "Key System",
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextSize = 18,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextXAlignment = Enum.TextXAlignment.Center,
			BackgroundTransparency = 1,
			Parent = KeySystemPaint.Frame,
		})

		local SubTitle = New("TextLabel", {
			Size = UDim2.new(1, -56, 0, 18),
			Position = UDim2.fromOffset(28, 99),
			Text = Config.SubTitle or "Verification Required",
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
			TextSize = 12,
			TextColor3 = Color3.fromRGB(180, 180, 180),
			TextXAlignment = Enum.TextXAlignment.Center,
			BackgroundTransparency = 1,
			Parent = KeySystemPaint.Frame,
		})

		local TextboxFrame = New("Frame", {
			Size = UDim2.new(1, -48, 0, 46),
			Position = UDim2.fromOffset(24, 132),
			BackgroundColor3 = Color3.fromRGB(35, 35, 35),
			BackgroundTransparency = 0.05,
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
			Size = UDim2.new(1, -54, 1, 0),
			Position = UDim2.fromOffset(10, 0),
			BackgroundTransparency = 1,
			Text = "",
			PlaceholderText = "Enter key here...",
			PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
			TextColor3 = Color3.fromRGB(240, 240, 240),
			TextTransparency = 1,
			TextSize = 13,
			ClearTextOnFocus = false,
			TextXAlignment = Enum.TextXAlignment.Left,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
			Parent = TextboxFrame,
		})
		local MaskLabel = New("TextLabel", { Size = UDim2.new(1, -54, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1, Text = "", TextColor3 = Color3.fromRGB(240, 240, 240), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"), Parent = TextboxFrame })
		local RevealButton = New("TextButton", { Size = UDim2.fromOffset(42, 42), Position = UDim2.new(1, -44, 0, 2), BackgroundTransparency = 1, Text = "SHOW", TextSize = 9, TextColor3 = Color3.fromRGB(170, 170, 170), Parent = TextboxFrame })
		local StatusLabel = New("TextLabel", { Size = UDim2.new(1, -48, 0, 20), Position = UDim2.fromOffset(24, 184), BackgroundTransparency = 1, Text = "", TextSize = 12, TextColor3 = Color3.fromRGB(180, 180, 180), TextXAlignment = Enum.TextXAlignment.Left, Parent = KeySystemPaint.Frame })
		local VerifyButton = New("TextButton", { Size = UDim2.new(1, -48, 0, 44), Position = UDim2.fromOffset(24, 216), BackgroundColor3 = Creator.GetThemeProperty("Accent") or Color3.fromRGB(96, 205, 255), Text = "Verify Key", TextColor3 = Color3.fromRGB(0, 0, 0), TextSize = 14, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal), Parent = KeySystemPaint.Frame }, { New("UICorner", { CornerRadius = UDim.new(0, 7) }) })
		local Spinner = New("TextLabel", { Size = UDim2.fromOffset(24, 24), Position = UDim2.new(0.5, -70, 0, 226), BackgroundTransparency = 1, Text = "◌", TextSize = 20, TextColor3 = Color3.fromRGB(0, 0, 0), Visible = false, Parent = KeySystemPaint.Frame })
		local GetKeyButton = New("TextButton", { Size = UDim2.new(1, -48, 0, 24), Position = UDim2.fromOffset(24, 273), BackgroundTransparency = 1, Text = "Don't have a key? Get Key", TextSize = 12, TextColor3 = Color3.fromRGB(96, 205, 255), Parent = KeySystemPaint.Frame })
		local DiscordButton = Config.Discord and New("TextButton", { Size = UDim2.new(1, -48, 0, 22), Position = UDim2.fromOffset(24, 299), BackgroundTransparency = 1, Text = "Join Discord", TextSize = 12, TextColor3 = Color3.fromRGB(170, 170, 170), Parent = KeySystemPaint.Frame }) or nil
		local CloseButton = New("TextButton", { Size = UDim2.fromOffset(32, 32), Position = UDim2.new(1, -42, 0, 10), BackgroundTransparency = 1, Text = "×", TextSize = 25, TextColor3 = Color3.fromRGB(190, 190, 190), Parent = KeySystemPaint.Frame })
		local ReopenButton = New("TextButton", { Size = UDim2.fromOffset(48, 48), Position = UDim2.new(1, -64, 1, -64), BackgroundColor3 = Color3.fromRGB(28, 30, 35), Text = "🔐", TextSize = 20, Visible = false, Parent = KeySystemGui }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }), New("UIStroke", { Color = Color3.fromRGB(80, 80, 80), Transparency = 0.35 }) })

		local TweenService = game:GetService("TweenService")
		local KeyVisible = false
		local SpinnerTween = TweenService:Create(Spinner, TweenInfo.new(0.7, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), { Rotation = 360 })
		local function UpdateMaskedText()
			MaskLabel.Text = KeyVisible and "" or string.rep("•", #Input.Text)
		end
		Input:GetPropertyChangedSignal("Text"):Connect(UpdateMaskedText)
		RevealButton.Activated:Connect(function()
			KeyVisible = not KeyVisible
			Input.TextTransparency = KeyVisible and 0 or 1
			RevealButton.Text = KeyVisible and "HIDE" or "SHOW"
			UpdateMaskedText()
		end)
		CloseButton.Activated:Connect(function()
			Overlay.Visible = false
			ReopenButton.Visible = true
		end)
		ReopenButton.Activated:Connect(function()
			Overlay.Visible = true
			ReopenButton.Visible = false
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
			VerifyButton.Active = Enabled
		end

		local function StartLockout()
			IsLocked = true
			SetInputEnabled(false)
			local TimeLeft = LockoutDuration
			task.spawn(function()
				while TimeLeft > 0 do
					StatusLabel.Text = "Too many attempts. Try again in " .. tostring(TimeLeft) .. "s"
					StatusLabel.TextColor3 = Color3.fromRGB(245, 115, 115)
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
				StatusLabel.Text = ""
			end)
		end

		local function VerifyKey(Key)
			if Key == "" or Key == nil then return false end

			if Config.Providers then
				for _, Provider in ipairs(Config.Providers) do
					local Success, Valid = pcall(function()
						if Provider.Callback then return Provider.Callback(Key) end
						if Provider.Preset and Presets[Provider.Preset] then
							return Presets[Provider.Preset](Key, Provider.PresetConfig or Provider.Config or {})
						end
						return VerifyAPI(Key, Provider.API or Provider)
					end)
					if Success and Valid == true then return true end
				end
				return false
			elseif Config.API then
				local Success, Valid = pcall(VerifyAPI, Key, Config.API)
				return Success and Valid == true
			elseif Config.Preset and Presets[Config.Preset] then
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
				StatusLabel.Text = "Please enter a key first."
				StatusLabel.TextColor3 = Color3.fromRGB(245, 190, 90)
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
			StatusLabel.Text = "Checking your key..."
			StatusLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
			Spinner.Visible = true
			SpinnerTween:Play()
			VerifyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			VerifyButton.TextColor3 = Color3.fromRGB(150, 150, 150)

			task.spawn(function()
				local Correct = VerifyKey(Entered)
				
				if Correct then
					SpinnerTween:Cancel()
					Spinner.Visible = false
					StatusLabel.Text = "Key verified successfully."
					StatusLabel.TextColor3 = Color3.fromRGB(110, 220, 150)
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
					SpinnerTween:Cancel()
					Spinner.Visible = false
					IsVerifying = false
					SetInputEnabled(true)
					VerifyButton.Text = "Verify Key"
					VerifyButton.BackgroundColor3 = Creator.GetThemeProperty("Accent") or Color3.fromRGB(96, 205, 255)
					VerifyButton.TextColor3 = Color3.fromRGB(0, 0, 0)
					StatusLabel.Text = "Invalid key. Please try again."
					StatusLabel.TextColor3 = Color3.fromRGB(245, 115, 115)

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
