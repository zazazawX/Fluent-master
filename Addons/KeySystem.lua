local httpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end

local KeySystem = {} do
	KeySystem.Library = nil
	
	function KeySystem:SetLibrary(library)
		self.Library = library
	end

	local PandaAuthV4Clients = {}
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

		PandaAuthV4 = function(Key, Config)
			local ServiceId = Config.ServiceId or Config.serviceId
			if not ServiceId or ServiceId == "" then return false end

			local Client = PandaAuthV4Clients[ServiceId]
			if not Client then
				local FetchSuccess, Source = pcall(function()
					return game:HttpGet(Config.LibraryUrl or "https://secure.pandauth.com/pv4/lib")
				end)
				if not FetchSuccess or not Source then return false end

				local CompileSuccess, Loader = pcall(loadstring, Source)
				if not CompileSuccess or type(Loader) ~= "function" then return false end
				local LoadSuccess, PUSL = pcall(Loader)
				if not LoadSuccess or type(PUSL) ~= "table" or type(PUSL.configure) ~= "function" or type(PUSL.validate) ~= "function" then
					return false
				end

				local ConfigureSuccess = pcall(function()
					PUSL.configure({
						serviceId = ServiceId,
						debug = Config.Debug == true or Config.debug == true,
						kickOnDetect = Config.KickOnDetect == true or Config.kickOnDetect == true,
					})
				end)
				if not ConfigureSuccess then return false end
				Client = PUSL
				PandaAuthV4Clients[ServiceId] = Client
			end

			local ValidateSuccess, Result = pcall(Client.validate, Key)
			if not ValidateSuccess then return false end
			if type(Result) == "boolean" then return Result end
			if type(Result) ~= "table" or Result.success ~= true then return false end
			if Config.Premium == true or Config.RequirePremium == true then
				return Result.isPremium == true
			end
			return true
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
		local SessionStore
		if getgenv then
			local Environment = getgenv()
			Environment.__FluentKeySessions = Environment.__FluentKeySessions or {}
			SessionStore = Environment.__FluentKeySessions
		end

		if SaveKey then
			if SessionStore and SessionStore[SavePath] then
				SavedKey = tostring(SessionStore[SavePath])
			end
			local CanRead = type(readfile) == "function"
			local FileExists = true
			if type(isfile) == "function" then
				local CheckSuccess, Exists = pcall(isfile, SavePath)
				FileExists = CheckSuccess and Exists == true
			end
			if SavedKey == "" and CanRead and FileExists then
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
			BackgroundTransparency = Config.OverlayTransparency or 0.55,
			BorderSizePixel = 0,
			Parent = KeySystemGui,
		})

		local KeySystemFrame = New("Frame", {
			Size = UDim2.new(0.9, 0, 0, 280),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Parent = Overlay,
		})
		New("UISizeConstraint", {
			MinSize = Vector2.new(300, 270),
			MaxSize = Vector2.new(400, 280),
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
		if KeySystemPaint.AddParent then
			KeySystemPaint.AddParent(KeySystemFrame)
		end

		New("UICorner", {
			CornerRadius = UDim.new(0, 8),
			Parent = KeySystemPaint.Frame,
		})

		local UIStroke = New("UIStroke", {
			Transparency = 0.5,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeTag = { Color = "AcrylicBorder" },
			Parent = KeySystemPaint.Frame,
		})

		local ButtonHolder = New("Frame", { Size = UDim2.new(1, 0, 0, 76), Position = UDim2.new(0, 0, 1, -76), ThemeTag = { BackgroundColor3 = "DialogHolder" }, Parent = KeySystemPaint.Frame }, { New("Frame", { Size = UDim2.new(1, 0, 0, 1), ThemeTag = { BackgroundColor3 = "DialogHolderLine" } }) })
		local Title = New("TextLabel", {
			Size = UDim2.new(1, -64, 0, 26),
			Position = UDim2.fromOffset(20, 22),
			Text = Config.Title or "Key System",
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextSize = 22,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			ThemeTag = { TextColor3 = "Text" },
			Parent = KeySystemPaint.Frame,
		})

		local SubTitle = New("TextLabel", {
			Size = UDim2.new(1, -64, 0, 20),
			Position = UDim2.fromOffset(20, 52),
			Text = Config.SubTitle or "Verification Required",
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
			TextSize = 13,
			TextTransparency = 0.4,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			ThemeTag = { TextColor3 = "Text" },
			Parent = KeySystemPaint.Frame,
		})

		local TextboxFrame = New("Frame", {
			Size = UDim2.new(1, -48, 0, 46),
			Size = UDim2.new(1, -40, 0, 38),
			Position = UDim2.fromOffset(20, 84),
			BackgroundTransparency = 0.15,
			ThemeTag = { BackgroundColor3 = "DialogInput" },
			Parent = KeySystemPaint.Frame,
		}, {
			New("UICorner", { CornerRadius = UDim.new(0, 6) }),
			New("UIStroke", {
				Transparency = 0.5,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				ThemeTag = { Color = "DialogInputLine" },
			})
		})

		local Input = New("TextBox", {
			Size = UDim2.new(1, -54, 1, 0),
			Position = UDim2.fromOffset(10, 0),
			BackgroundTransparency = 1,
			Text = "",
			PlaceholderText = "Enter key here...",
			PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
			TextTransparency = 1,
			TextSize = 14,
			ClearTextOnFocus = false,
			TextXAlignment = Enum.TextXAlignment.Left,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
			ThemeTag = { TextColor3 = "Text", PlaceholderColor3 = "SubText" },
			Parent = TextboxFrame,
		})
		local MaskLabel = New("TextLabel", { Size = UDim2.new(1, -54, 1, 0), Position = UDim2.fromOffset(10, 0), BackgroundTransparency = 1, Text = "", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"), ThemeTag = { TextColor3 = "Text" }, Parent = TextboxFrame })
		local RevealButton = New("TextButton", { Size = UDim2.fromOffset(52, 36), Position = UDim2.new(1, -54, 0, 1), BackgroundTransparency = 1, Text = "Show", TextSize = 13, ThemeTag = { TextColor3 = "SubText" }, Parent = TextboxFrame })
		local StatusLabel = New("TextLabel", { Size = UDim2.new(1, -40, 0, 18), Position = UDim2.fromOffset(20, 127), BackgroundTransparency = 1, Text = "", TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ThemeTag = { TextColor3 = "SubText" }, Parent = KeySystemPaint.Frame })
		local GetKeyButton = New("TextButton", { Size = UDim2.new(0.5, -20, 0, 32), Position = UDim2.fromOffset(20, 150), BackgroundTransparency = 1, Text = "Get Key", TextSize = 14, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal), TextXAlignment = Enum.TextXAlignment.Left, ThemeTag = { TextColor3 = "Accent" }, Parent = KeySystemPaint.Frame })
		local DiscordButton = Config.Discord and New("TextButton", { Size = UDim2.new(0.5, -20, 0, 32), Position = UDim2.new(0.5, 0, 0, 150), BackgroundTransparency = 1, Text = "Discord", TextSize = 14, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal), TextXAlignment = Enum.TextXAlignment.Right, ThemeTag = { TextColor3 = "SubText" }, Parent = KeySystemPaint.Frame }) or nil
		local VerifyButton = New("TextButton", { Size = UDim2.new(1, -40, 0, 36), Position = UDim2.fromOffset(20, 20), BackgroundTransparency = 0, Text = "Verify Key", TextSize = 14, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal), ThemeTag = { BackgroundColor3 = "DialogButton", TextColor3 = "Text" }, Parent = ButtonHolder }, { New("UICorner", { CornerRadius = UDim.new(0, 4) }), New("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Transparency = 0.65, ThemeTag = { Color = "DialogButtonBorder" } }) })
		local Spinner = New("TextLabel", { Size = UDim2.fromOffset(18, 18), Position = UDim2.new(0.5, -62, 0, 29), BackgroundTransparency = 1, Text = "|", TextSize = 15, Visible = false, ThemeTag = { TextColor3 = "Text" }, Parent = ButtonHolder })
		local CloseButton = New("TextButton", { Size = UDim2.fromOffset(34, 34), Position = UDim2.new(1, -40, 0, 8), BackgroundTransparency = 1, Text = "X", TextSize = 13, ThemeTag = { TextColor3 = "Text", BackgroundColor3 = "Text" }, Parent = KeySystemPaint.Frame }, { New("UICorner", { CornerRadius = UDim.new(0, 7) }) })
		local ReopenButton = New("TextButton", { Size = UDim2.fromOffset(54, 34), Position = UDim2.new(1, -70, 1, -50), BackgroundTransparency = 0.08, Text = "KEY", TextSize = 11, Visible = false, ThemeTag = { BackgroundColor3 = "AcrylicMain", TextColor3 = "Text" }, Parent = KeySystemGui }, { New("UICorner", { CornerRadius = UDim.new(0, 7) }), New("UIStroke", { Transparency = 0.5, ThemeTag = { Color = "TitleBarLine" } }) })

		local TweenService = game:GetService("TweenService")
		local KeyVisible = false
		local SpinnerTween = TweenService:Create(Spinner, TweenInfo.new(0.7, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), { Rotation = 360 })
		local function UpdateMaskedText()
			MaskLabel.Text = KeyVisible and "" or string.rep("*", #Input.Text)
		end
		Input:GetPropertyChangedSignal("Text"):Connect(UpdateMaskedText)
		RevealButton.Activated:Connect(function()
			KeyVisible = not KeyVisible
			Input.TextTransparency = KeyVisible and 0 or 1
			RevealButton.Text = KeyVisible and "Hide" or "Show"
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
					VerifyButton.BackgroundColor3 = Creator.GetThemeProperty("DialogButton") or Color3.fromRGB(45, 45, 45)
					VerifyButton.TextColor3 = Creator.GetThemeProperty("SubText") or Color3.fromRGB(170, 170, 170)
					task.wait(1)
					TimeLeft = TimeLeft - 1
				end
				IsLocked = false
				Attempts = 0
				SetInputEnabled(true)
				VerifyButton.Text = "Verify Key"
				VerifyButton.BackgroundColor3 = Creator.GetThemeProperty("DialogButton") or Color3.fromRGB(45, 45, 45)
				VerifyButton.TextColor3 = Creator.GetThemeProperty("Text") or Color3.fromRGB(240, 240, 240)
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
			VerifyButton.BackgroundColor3 = Creator.GetThemeProperty("DialogButton") or Color3.fromRGB(45, 45, 45)
			VerifyButton.TextColor3 = Creator.GetThemeProperty("SubText") or Color3.fromRGB(170, 170, 170)

			task.spawn(function()
				local Correct = VerifyKey(Entered)
				
				if Correct then
					SpinnerTween:Cancel()
					Spinner.Visible = false
					StatusLabel.Text = "Key verified successfully."
					StatusLabel.TextColor3 = Color3.fromRGB(110, 220, 150)
					if SaveKey then
						if SessionStore then SessionStore[SavePath] = Entered end
						if type(writefile) == "function" then
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
					VerifyButton.BackgroundColor3 = Creator.GetThemeProperty("DialogButton") or Color3.fromRGB(45, 45, 45)
					VerifyButton.TextColor3 = Creator.GetThemeProperty("Text") or Color3.fromRGB(240, 240, 240)
					StatusLabel.Text = "Invalid key. Please try again."
					StatusLabel.TextColor3 = Color3.fromRGB(245, 115, 115)

					local Stroke = TextboxFrame:FindFirstChildOfClass("UIStroke")
					if Stroke then
						Stroke.Color = Color3.fromRGB(245, 115, 115)
						task.spawn(function()
							task.wait(1.5)
							if Stroke.Parent then
								Stroke.Color = Creator.GetThemeProperty("DialogInputLine") or Color3.fromRGB(160, 160, 160)
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
