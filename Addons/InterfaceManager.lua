local httpService = game:GetService("HttpService")

local InterfaceManager = {} do
	InterfaceManager.Folder = "FluentSettings"
    InterfaceManager.Settings = {
        Theme = "Dark",
        Acrylic = true,
        Transparency = true,
        ReducedMotion = false,
        MenuKeybind = "LeftControl",
        CompactMode = false,
        Language = "en"
    }

    function InterfaceManager:SetFolder(folder)
		self.Folder = folder;
		self:BuildFolderTree()
	end

    function InterfaceManager:SetLibrary(library)
		self.Library = library
	end

    function InterfaceManager:BuildFolderTree()
		local paths = {}

		local parts = self.Folder:split("/")
		for idx = 1, #parts do
			paths[#paths + 1] = table.concat(parts, "/", 1, idx)
		end

		table.insert(paths, self.Folder)
		table.insert(paths, self.Folder .. "/settings")

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

    function InterfaceManager:SaveSettings()
        writefile(self.Folder .. "/options.json", httpService:JSONEncode(InterfaceManager.Settings))
    end

    function InterfaceManager:LoadSettings()
        local path = self.Folder .. "/options.json"
        if isfile(path) then
            local data = readfile(path)
            local success, decoded = pcall(httpService.JSONDecode, httpService, data)

            if success then
                for i, v in next, decoded do
                    InterfaceManager.Settings[i] = v
                end
            end
        end
    end

    function InterfaceManager:BuildInterfaceSection(tab)
        assert(self.Library, "Must set InterfaceManager.Library")
		local Library = self.Library
        local Settings = InterfaceManager.Settings

        InterfaceManager:LoadSettings()
        
        Library:SetLanguage(Settings.Language or "en")
        Library:SetCompactMode(Settings.CompactMode or false)

		local section = tab:AddSection(Library:Translate("InterfaceSection"))

		local InterfaceTheme = section:AddDropdown("InterfaceTheme", {
			Title = Library:Translate("Theme"),
			Description = Library:Translate("ThemeDesc"),
			Values = Library.Themes,
			Default = Settings.Theme,
			Callback = function(Value)
				Library:SetTheme(Value)
                Settings.Theme = Value
                InterfaceManager:SaveSettings()
			end
		})

        InterfaceTheme:SetValue(Settings.Theme)
	
		if Library.UseAcrylic then
			section:AddToggle("AcrylicToggle", {
				Title = Library:Translate("Acrylic"),
				Description = Library:Translate("AcrylicDesc"),
				Default = Settings.Acrylic,
				Callback = function(Value)
					Library:ToggleAcrylic(Value)
                    Settings.Acrylic = Value
                    InterfaceManager:SaveSettings()
				end
			})
		end
	
		section:AddToggle("TransparentToggle", {
			Title = Library:Translate("Transparency"),
			Description = Library:Translate("TransparencyDesc"),
			Default = Settings.Transparency,
			Callback = function(Value)
				Library:ToggleTransparency(Value)
				Settings.Transparency = Value
                InterfaceManager:SaveSettings()
			end
		})

		section:AddToggle("CompactModeToggle", {
			Title = Library:Translate("CompactMode"),
			Description = Library:Translate("CompactModeDesc"),
			Default = Settings.CompactMode,
			Callback = function(Value)
				Library:SetCompactMode(Value)
				Settings.CompactMode = Value
				InterfaceManager:SaveSettings()
			end
		})

		section:AddToggle("ReducedMotionToggle", {
			Title = Library:Translate("ReducedMotion"),
			Description = Library:Translate("ReducedMotionDesc"),
			Default = Settings.ReducedMotion,
			Callback = function(Value)
				Library:SetReducedMotion(Value)
				Settings.ReducedMotion = Value
				InterfaceManager:SaveSettings()
			end
		})

		local LanguageDropdown = section:AddDropdown("InterfaceLanguage", {
			Title = Library:Translate("Language"),
			Description = Library:Translate("LanguageDesc"),
			Values = {"en", "th"},
			Default = Settings.Language or "en",
			Callback = function(Value)
				Library:SetLanguage(Value)
				Settings.Language = Value
				InterfaceManager:SaveSettings()
			end
		})
		LanguageDropdown:SetValue(Settings.Language or "en")
	
		local MenuKeybind = section:AddKeybind("MenuKeybind", { Title = Library:Translate("MinimizeBind"), Default = Settings.MenuKeybind })
		MenuKeybind:OnChanged(function()
			Settings.MenuKeybind = MenuKeybind.Value
            InterfaceManager:SaveSettings()
		end)
		Library.MinimizeKeybind = MenuKeybind
    end
end

return InterfaceManager
