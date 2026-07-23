local httpService = game:GetService("HttpService")

local SaveManager = {} do
	SaveManager.Folder = "FluentSettings"
	SaveManager.Ignore = {}
	SaveManager.SchemaVersion = 2
	SaveManager.Migrations = {}

	local function NormalizeConfigName(name)
		if type(name) ~= "string" then
			return false, "no config file is selected"
		end

		name = name:match("^%s*(.-)%s*$")
		if name == "" then
			return false, "config name cannot be empty"
		end
		if #name > 64 then
			return false, "config name is too long"
		end
		if name == "." or name == ".." or name:sub(-1) == "." then
			return false, "config name is invalid"
		end
		if name:find("/", 1, true) or name:find(string.char(92), 1, true) or name:find("%c") then
			return false, "config name contains invalid characters"
		end

		for _, character in ipairs({ "<", ">", ":", '"', "|", "?", "*" }) do
			if name:find(character, 1, true) then
				return false, "config name contains invalid characters"
			end
		end

		return true, name
	end

	SaveManager.Migrations[1] = function(data)
		for _, option in next, data.objects or {} do
			if type(option) == "table" then
				if option.type == "Colorpicker" and option.transparency == nil then
					option.transparency = 0
				elseif option.type == "Dropdown" and option.multi and type(option.value) == "table" then
					local normalized = {}
					for key, selected in next, option.value do
						local value = type(key) == "number" and selected or key
						if value ~= nil and (type(key) == "number" or selected == true) then
							normalized[value] = true
						end
					end
					option.value = normalized
				end
			end
		end
		data.version = 2
		return data
	end

	function SaveManager:RegisterMigration(fromVersion, callback)
		assert(type(fromVersion) == "number" and fromVersion % 1 == 0, "Migration version must be an integer")
		assert(type(callback) == "function", "Migration callback must be a function")
		self.Migrations[fromVersion] = callback
	end

	function SaveManager:Migrate(data)
		local version = tonumber(data.version) or 1
		if version % 1 ~= 0 or version < 1 then
			return false, "invalid config version"
		end
		if version > self.SchemaVersion then
			return false, string.format(
				"config version %d is newer than supported version %d",
				version,
				self.SchemaVersion
			)
		end

		local originalVersion = version
		while version < self.SchemaVersion do
			local previousVersion = version
			local migration = self.Migrations[version]
			if not migration then
				return false, string.format("missing migration from version %d", version)
			end
			local success, migrated = pcall(migration, data)
			if not success or type(migrated) ~= "table" then
				return false, string.format("failed to migrate config from version %d", version)
			end
			data = migrated
			version = tonumber(data.version) or (version + 1)
			if version % 1 ~= 0 then
				return false, "migration produced an invalid config version"
			end
			if version <= previousVersion then
				return false, "migration did not advance config version"
			end
			if version > self.SchemaVersion then
				return false, "migration advanced beyond the supported config version"
			end
		end
		data.version = self.SchemaVersion
		return true, data, originalVersion
	end

	SaveManager.Parser = {
		Toggle = {
			Save = function(idx, object) 
				return { type = "Toggle", idx = idx, value = object.Value } 
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Slider = {
			Save = function(idx, object)
				return { type = "Slider", idx = idx, value = object.Value }
			end,
			Load = function(idx, data)
				local value = tonumber(data.value)
				if SaveManager.Options[idx] and value then
					SaveManager.Options[idx]:SetValue(value)
				end
			end,
		},
		Dropdown = {
			Save = function(idx, object)
				return { type = "Dropdown", idx = idx, value = object.Value, multi = object.Multi }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Colorpicker = {
			Save = function(idx, object)
				return { type = "Colorpicker", idx = idx, value = object.Value:ToHex(), transparency = object.Transparency }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
				end
			end,
		},
		Keybind = {
			Save = function(idx, object)
				return { type = "Keybind", idx = idx, mode = object.Mode, key = object.Value }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.key, data.mode)
				end
			end,
		},

		Input = {
			Save = function(idx, object)
				return { type = "Input", idx = idx, text = object.Value }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] and type(data.text) == "string" then
					SaveManager.Options[idx]:SetValue(data.text)
				end
			end,
		},
	}

	function SaveManager:SetIgnoreIndexes(list)
		for _, key in next, list do
			self.Ignore[key] = true
		end
	end

	function SaveManager:SetFolder(folder)
		self.Folder = folder;
		self:BuildFolderTree()
	end

	function SaveManager:GetConfigPath(name)
		local valid, normalizedName = NormalizeConfigName(name)
		if not valid then
			return nil, normalizedName
		end

		return self.Folder .. "/settings/" .. normalizedName .. ".json", normalizedName
	end

	function SaveManager:Save(name)
		local fullPath, normalizedName = self:GetConfigPath(name)
		if not fullPath then
			return false, normalizedName
		end

		local data = {
			version = self.SchemaVersion,
			fluentVersion = self.Library and self.Library.Version or nil,
			savedAt = os.time(),
			objects = {}
		}

		for idx, option in next, SaveManager.Options do
			if not self.Parser[option.Type] then continue end
			if self.Ignore[idx] then continue end

			local parserSuccess, serialized = pcall(self.Parser[option.Type].Save, idx, option)
			if not parserSuccess then
				return false, "failed to serialize option " .. tostring(idx)
			end
			table.insert(data.objects, serialized)
		end	

		local success, encoded = pcall(httpService.JSONEncode, httpService, data)
		if not success then
			return false, "failed to encode data"
		end

		local writeSuccess, writeError = pcall(writefile, fullPath, encoded)
		if not writeSuccess then
			return false, "failed to write config: " .. tostring(writeError)
		end

		return true, normalizedName
	end

	function SaveManager:Load(name)
		local file, normalizedName = self:GetConfigPath(name)
		if not file then
			return false, normalizedName
		end
		if not isfile(file) then return false, "invalid file" end

		local readSuccess, content = pcall(readfile, file)
		if not readSuccess then
			return false, "failed to read config: " .. tostring(content)
		end

		local success, decoded = pcall(httpService.JSONDecode, httpService, content)
		if not success then return false, "decode error" end
		if type(decoded) ~= "table" then
			return false, "invalid config format"
		end
		local migrateSuccess, migrated, originalVersion = self:Migrate(decoded)
		if not migrateSuccess then
			return false, migrated
		end
		decoded = migrated
		if type(decoded.objects) ~= "table" then
			return false, "invalid config format"
		end

		if originalVersion < self.SchemaVersion then
			pcall(writefile, file .. ".v" .. tostring(originalVersion) .. ".bak", content)
			local encodeSuccess, migratedContent = pcall(httpService.JSONEncode, httpService, decoded)
			if encodeSuccess then
				pcall(writefile, file, migratedContent)
			end
		end

		for _, option in next, decoded.objects do
			if type(option) == "table" and self.Parser[option.type] then
				local parser = self.Parser[option.type]
				local optionData = option
				local optionIdx = option.idx
				task.spawn(function()
					local loadSuccess, loadError = pcall(parser.Load, optionIdx, optionData)
					if not loadSuccess then
						warn("Failed to load config option:", optionIdx, loadError)
					end
				end)
			end
		end

		return true, normalizedName
	end

	function SaveManager:ExportString()
		local data = {
			version = self.SchemaVersion,
			fluentVersion = self.Library and self.Library.Version or nil,
			savedAt = os.time(),
			objects = {}
		}

		for idx, option in next, SaveManager.Options do
			if not self.Parser[option.Type] then continue end
			if self.Ignore[idx] then continue end

			local parserSuccess, serialized = pcall(self.Parser[option.Type].Save, idx, option)
			if parserSuccess then
				table.insert(data.objects, serialized)
			end
		end	

		local success, encoded = pcall(httpService.JSONEncode, httpService, data)
		if success then
			return encoded
		end
		return nil, "failed to encode config"
	end

	function SaveManager:ImportString(content)
		if type(content) ~= "string" or content == "" then
			return false, "invalid content string"
		end

		local success, decoded = pcall(httpService.JSONDecode, httpService, content)
		if not success then return false, "decode error" end
		if type(decoded) ~= "table" then
			return false, "invalid config format"
		end
		local migrateSuccess, migrated = self:Migrate(decoded)
		if not migrateSuccess then
			return false, migrated
		end
		decoded = migrated
		if type(decoded.objects) ~= "table" then
			return false, "invalid config format"
		end

		for _, option in next, decoded.objects do
			if type(option) == "table" and self.Parser[option.type] then
				local parser = self.Parser[option.type]
				local optionData = option
				local optionIdx = option.idx
				task.spawn(function()
					local loadSuccess, loadError = pcall(parser.Load, optionIdx, optionData)
					if not loadSuccess then
						warn("Failed to load config option:", optionIdx, loadError)
					end
				end)
			end
		end

		return true
	end

	function SaveManager:IgnoreThemeSettings()
		self:SetIgnoreIndexes({ 
			"InterfaceTheme", "AcrylicToggle", "TransparentToggle", "ReducedMotionToggle", "MenuKeybind"
		})
	end

	function SaveManager:BuildFolderTree()
		local paths = {
			self.Folder,
			self.Folder .. "/settings"
		}

		for i = 1, #paths do
			local str = paths[i]
			local success, folderError = pcall(function()
				if not isfolder(str) then
					makefolder(str)
				end
			end)
			if not success then
				return false, "failed to create settings folder: " .. tostring(folderError)
			end
		end

		return true
	end

	function SaveManager:RefreshConfigList()
		local success, list = pcall(listfiles, self.Folder .. "/settings")
		if not success or type(list) ~= "table" then
			return {}
		end

		local out = {}
		for i = 1, #list do
			local file = list[i]
			local normalizedPath = file:gsub(string.char(92), "/")
			local name = normalizedPath:match("([^/]+)%.json$")
			if name and name ~= "options" then
				table.insert(out, name)
			end
		end
		
		table.sort(out)
		return out
	end

	function SaveManager:SetLibrary(library)
		self.Library = library
        self.Options = library.Options
	end

	function SaveManager:SetAutoloadConfig(name)
		local configPath, normalizedName = self:GetConfigPath(name)
		if not configPath then
			return false, normalizedName
		end
		if not isfile(configPath) then
			return false, "invalid file"
		end

		local success, writeError = pcall(
			writefile,
			self.Folder .. "/settings/autoload.txt",
			normalizedName
		)
		if not success then
			return false, "failed to write autoload config: " .. tostring(writeError)
		end

		return true, normalizedName
	end

	function SaveManager:GetAutoloadConfig()
		local path = self.Folder .. "/settings/autoload.txt"
		if not isfile(path) then
			return nil
		end

		local success, name = pcall(readfile, path)
		if not success then
			return nil, tostring(name)
		end

		local valid, normalizedName = NormalizeConfigName(name)
		if not valid then
			return nil, normalizedName
		end

		return normalizedName
	end

	function SaveManager:LoadAutoloadConfig()
		local name, readError = self:GetAutoloadConfig()
		if not name then
			if readError then
				self.Library:Notify({
					Title = "Interface",
					Content = "Config loader",
					SubContent = self.Library:Translate("AutoloadFail", readError),
					Duration = 7
				})
			end
			return
		end

		local success, err = self:Load(name)
		if not success then
			return self.Library:Notify({
				Title = "Interface",
				Content = "Config loader",
				SubContent = self.Library:Translate("LoadFail", err),
				Duration = 7
			})
		end

		self.Library:Notify({
			Title = "Interface",
			Content = "Config loader",
			SubContent = self.Library:Translate("AutoloadLoaded", name),
			Duration = 7
		})
	end

	function SaveManager:BuildConfigSection(tab)
		assert(self.Library, "Must set SaveManager.Library")

		local section = tab:AddSection("ConfigSection")

		section:AddInput("SaveManager_ConfigName",    { Title = "ConfigName" })
		section:AddDropdown("SaveManager_ConfigList", { Title = "ConfigList", Values = self:RefreshConfigList(), AllowNull = true })
		section:AddInput("SaveManager_ImportJSON", {
			Title = "ImportJSON",
			Description = "ImportJSONDesc",
			Placeholder = '{"version":2,"objects":[]}',
		})

		section:AddButton({
            Title = "CreateConfig",
            Callback = function()
                local name = SaveManager.Options.SaveManager_ConfigName.Value

                local success, result = self:Save(name)
                if not success then
                    return self.Library:Notify({
						Title = "Interface",
						Content = "Config loader",
						SubContent = self.Library:Translate("SaveFail", result),
						Duration = 7
					})
                end
				name = result

				self.Library:Notify({
					Title = "Interface",
					Content = "Config loader",
					SubContent = self.Library:Translate("SaveSuccess", name),
					Duration = 7
				})

                SaveManager.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
                SaveManager.Options.SaveManager_ConfigList:SetValue(nil)
            end
        })

        section:AddButton({Title = "LoadConfig", Callback = function()
			local name = SaveManager.Options.SaveManager_ConfigList.Value

			local success, result = self:Load(name)
			if not success then
				return self.Library:Notify({
					Title = "Interface",
					Content = "Config loader",
					SubContent = self.Library:Translate("LoadFail", result),
					Duration = 7
				})
			end
			name = result

			self.Library:Notify({
				Title = "Interface",
				Content = "Config loader",
				SubContent = self.Library:Translate("LoadSuccess", name),
				Duration = 7
			})
		end})

		section:AddButton({Title = "OverwriteConfig", Callback = function()
			local name = SaveManager.Options.SaveManager_ConfigList.Value

			local success, result = self:Save(name)
			if not success then
				return self.Library:Notify({
					Title = "Interface",
					Content = "Config loader",
					SubContent = self.Library:Translate("OverwriteFail", result),
					Duration = 7
				})
			end
			name = result

			self.Library:Notify({
				Title = "Interface",
				Content = "Config loader",
				SubContent = self.Library:Translate("OverwriteSuccess", name),
				Duration = 7
			})
		end})

		section:AddButton({Title = "RefreshList", Callback = function()
			SaveManager.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
			SaveManager.Options.SaveManager_ConfigList:SetValue(nil)
		end})

		section:AddButton({Title = "ExportJSON", Callback = function()
			local content, exportError = self:ExportString()
			if not content then
				return self.Library:Notify({
					Title = "Interface",
					Content = "Config loader",
					SubContent = self.Library:Translate("ExportFail", exportError),
					Duration = 7
				})
			end

			local setClipboard = setclipboard or toclipboard or (Clipboard and Clipboard.set)
			if not setClipboard then
				return self.Library:Notify({
					Title = "Interface",
					Content = "Config loader",
					SubContent = self.Library:Translate("ClipboardUnavailable"),
					Duration = 7
				})
			end

			local copied, copyError = pcall(setClipboard, content)
			if not copied then
				return self.Library:Notify({
					Title = "Interface",
					Content = "Config loader",
					SubContent = self.Library:Translate("ExportFail", tostring(copyError)),
					Duration = 7
				})
			end

			self.Library:Notify({
				Title = "Interface",
				Content = "Config loader",
				SubContent = self.Library:Translate("ExportSuccess"),
				Duration = 5
			})
		end})

		section:AddButton({Title = "ImportJSONButton", Callback = function()
			local content = SaveManager.Options.SaveManager_ImportJSON.Value
			local success, importError = self:ImportString(content)
			if not success then
				return self.Library:Notify({
					Title = "Interface",
					Content = "Config loader",
					SubContent = self.Library:Translate("ImportFail", importError),
					Duration = 7
				})
			end

			self.Library:Notify({
				Title = "Interface",
				Content = "Config loader",
				SubContent = self.Library:Translate("ImportSuccess"),
				Duration = 5
			})
		end})

		local AutoloadButton
		AutoloadButton = section:AddButton({Title = "SetAutoload", Description = self.Library:Translate("AutoloadDesc", self.Library:Translate("AutoloadNone")), Callback = function()
			local name = SaveManager.Options.SaveManager_ConfigList.Value
			local success, result = self:SetAutoloadConfig(name)
			if not success then
				return self.Library:Notify({
					Title = "Interface",
					Content = "Config loader",
					SubContent = self.Library:Translate("AutoloadFail", result),
					Duration = 7
				})
			end
			name = result
			AutoloadButton:SetDesc(self.Library:Translate("AutoloadDesc", name))
			self.Library:Notify({
				Title = "Interface",
				Content = "Config loader",
				SubContent = self.Library:Translate("AutoloadSet", name),
				Duration = 7
			})
		end})

		local autoloadName = self:GetAutoloadConfig()
		if autoloadName then
			AutoloadButton:SetDesc(self.Library:Translate("AutoloadDesc", autoloadName))
		end

		self.Library:OnLanguageChanged(function()
			local currentAutoload = self:GetAutoloadConfig() or self.Library:Translate("AutoloadNone")
			AutoloadButton:SetDesc(self.Library:Translate("AutoloadDesc", currentAutoload))
		end)

		SaveManager:SetIgnoreIndexes({
			"SaveManager_ConfigList",
			"SaveManager_ConfigName",
			"SaveManager_ImportJSON",
		})
	end

	SaveManager:BuildFolderTree()
end

return SaveManager
