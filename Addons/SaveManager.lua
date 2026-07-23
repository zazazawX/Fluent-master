local httpService = game:GetService("HttpService")

local SaveManager = {} do
	SaveManager.Folder = "FluentSettings"
	SaveManager.Ignore = {}
	SaveManager.SchemaVersion = 2
	SaveManager.Migrations = {}
	SaveManager.OptionCategories = {}
	SaveManager.Defaults = {}
	SaveManager.Metadata = {
		gameId = game.GameId,
		placeId = game.PlaceId,
	}

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

	local function CloneSerializable(value)
		local encodeSuccess, encoded = pcall(httpService.JSONEncode, httpService, value)
		if not encodeSuccess then
			return nil
		end
		local decodeSuccess, cloned = pcall(httpService.JSONDecode, httpService, encoded)
		return decodeSuccess and cloned or nil
	end

	local function NormalizeSelection(selection)
		if selection == nil then
			return nil
		end

		local normalized = {}
		for key, value in next, selection do
			if type(key) == "number" then
				normalized[tostring(value)] = true
			elseif value == true then
				normalized[tostring(key)] = true
			end
		end
		return normalized
	end

	function SaveManager:SetMetadata(metadata)
		assert(type(metadata) == "table", "metadata must be a table")
		for key, value in next, metadata do
			self.Metadata[key] = value
		end
	end

	function SaveManager:SetOptionCategory(index, category)
		assert(type(index) == "string" and index ~= "", "option index must be a non-empty string")
		assert(type(category) == "string" and category ~= "", "category must be a non-empty string")
		self.OptionCategories[index] = category
	end

	function SaveManager:SetCategoryIndexes(category, indexes)
		assert(type(category) == "string" and category ~= "", "category must be a non-empty string")
		assert(type(indexes) == "table", "indexes must be a table")
		for _, index in next, indexes do
			self:SetOptionCategory(index, category)
		end
	end

	function SaveManager:GetOptionCategory(index)
		return self.OptionCategories[index]
	end

	function SaveManager:GetCategories()
		local seen = {}
		local categories = {}
		for _, category in next, self.OptionCategories do
			if not seen[category] then
				seen[category] = true
				table.insert(categories, category)
			end
		end
		table.sort(categories)
		return categories
	end

	function SaveManager:IsOptionIncluded(index, options)
		if self.Ignore[index] then
			return false
		end

		local categories = options and NormalizeSelection(options.categories)
		if not categories then
			return true
		end

		local category = self.OptionCategories[index]
		return category ~= nil and categories[category] == true
	end

	function SaveManager:BuildData(options)
		local data = {
			version = self.SchemaVersion,
			fluentVersion = self.Library and self.Library.Version or nil,
			savedAt = os.time(),
			metadata = CloneSerializable(self.Metadata) or {},
			objects = {}
		}

		for idx, option in next, SaveManager.Options do
			if not self.Parser[option.Type] then continue end
			if not self:IsOptionIncluded(idx, options) then continue end

			local parserSuccess, serialized = pcall(self.Parser[option.Type].Save, idx, option)
			if not parserSuccess then
				return nil, "failed to serialize option " .. tostring(idx)
			end
			serialized.category = self.OptionCategories[idx]
			table.insert(data.objects, serialized)
		end

		return data
	end

	function SaveManager:EncodeData(data)
		local success, encoded = pcall(httpService.JSONEncode, httpService, data)
		if not success then
			return nil, "failed to encode config"
		end
		return encoded
	end

	function SaveManager:DecodeData(content, options)
		if type(content) ~= "string" or content:match("^%s*$") then
			return nil, "invalid content string"
		end

		local success, decoded = pcall(httpService.JSONDecode, httpService, content)
		if not success or type(decoded) ~= "table" then
			return nil, "decode error"
		end

		local migrateSuccess, migrated = self:Migrate(decoded)
		if not migrateSuccess then
			return nil, migrated
		end
		decoded = migrated
		if type(decoded.objects) ~= "table" then
			return nil, "invalid config format"
		end

		local metadata = type(decoded.metadata) == "table" and decoded.metadata or {}
		local strictGame = not options or options.strictGame ~= false
		if strictGame and metadata.gameId and self.Metadata.gameId
			and tonumber(metadata.gameId) ~= tonumber(self.Metadata.gameId) then
			return nil, "config belongs to a different game"
		end

		if options and options.strictPlace and metadata.placeId and self.Metadata.placeId
			and tonumber(metadata.placeId) ~= tonumber(self.Metadata.placeId) then
			return nil, "config belongs to a different place"
		end

		if options and options.strictVersion and metadata.appVersion and self.Metadata.appVersion
			and tostring(metadata.appVersion) ~= tostring(self.Metadata.appVersion) then
			return nil, string.format(
				"config app version %s does not match %s",
				tostring(metadata.appVersion),
				tostring(self.Metadata.appVersion)
			)
		end

		return decoded
	end

	function SaveManager:CaptureDefaults()
		self.Defaults = {}
		for idx, option in next, self.Options or {} do
			local parser = self.Parser[option.Type]
			if parser then
				local success, serialized = pcall(parser.Save, idx, option)
				if success then
					self.Defaults[idx] = CloneSerializable(serialized)
				end
			end
		end
	end

	function SaveManager:Reset(options)
		local resetCount = 0
		for idx, data in next, self.Defaults do
			if self:IsOptionIncluded(idx, options) then
				local parser = self.Parser[data.type]
				if parser then
					local success = pcall(parser.Load, idx, data)
					if success then
						resetCount += 1
					end
				end
			end
		end
		return true, resetCount
	end

	function SaveManager:PreviewImport(content, options)
		local decoded, decodeError = self:DecodeData(content, options)
		if not decoded then
			return false, decodeError
		end

		local preview = {
			mode = options and options.mode == "replace" and "replace" or "merge",
			metadata = decoded.metadata or {},
			changes = {},
			skipped = {},
		}
		local incomingIndexes = {}
		local function ComparableJSON(value)
			local comparable = CloneSerializable(value)
			if type(comparable) == "table" then
				comparable.category = nil
			end
			return comparable and self:EncodeData(comparable) or nil
		end

		for _, incoming in next, decoded.objects do
			local index = type(incoming) == "table" and incoming.idx or nil
			if index then
				incomingIndexes[index] = true
			end
			local currentOption = index and self.Options[index] or nil
			local parser = type(incoming) == "table" and self.Parser[incoming.type] or nil
			if index and currentOption and parser and self:IsOptionIncluded(index, options) then
				local currentSuccess, current = pcall(self.Parser[currentOption.Type].Save, index, currentOption)
				if currentSuccess then
					local currentJSON = ComparableJSON(current)
					local incomingJSON = ComparableJSON(incoming)
					if currentJSON ~= incomingJSON then
						table.insert(preview.changes, {
							index = index,
							type = incoming.type,
							category = self.OptionCategories[index] or incoming.category,
							current = current,
							incoming = incoming,
						})
					end
				end
			else
				table.insert(preview.skipped, index or "unknown")
			end
		end

		if preview.mode == "replace" then
			for index, default in next, self.Defaults do
				local currentOption = self.Options[index]
				if not incomingIndexes[index] and currentOption and self:IsOptionIncluded(index, options) then
					local parser = self.Parser[currentOption.Type]
					local success, current = false, nil
					if parser then
						success, current = pcall(parser.Save, index, currentOption)
					end
					if success and ComparableJSON(current) ~= ComparableJSON(default) then
						table.insert(preview.changes, {
							index = index,
							type = default.type,
							category = self.OptionCategories[index],
							current = current,
							incoming = default,
							reset = true,
						})
					end
				end
			end
		end

		return true, preview
	end

	function SaveManager:ApplyData(decoded, options)
		local mode = options and options.mode == "replace" and "replace" or "merge"
		if mode == "replace" then
			self:Reset(options)
		end

		local applied = 0
		for _, option in next, decoded.objects do
			if type(option) == "table" and self.Parser[option.type]
				and self.Options[option.idx] and self:IsOptionIncluded(option.idx, options) then
				local loadSuccess, loadError = pcall(self.Parser[option.type].Load, option.idx, option)
				if not loadSuccess then
					return false, "failed to load option " .. tostring(option.idx) .. ": " .. tostring(loadError)
				end
				applied += 1
			end
		end
		return true, applied
	end

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

		local data, buildError = self:BuildData()
		if not data then
			return false, buildError
		end
		local encoded, encodeError = self:EncodeData(data)
		if not encoded then
			return false, encodeError
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

	function SaveManager:ExportString(options)
		local data, buildError = self:BuildData(options)
		if not data then
			return nil, buildError
		end
		return self:EncodeData(data)
	end

	function SaveManager:ImportString(content, options)
		local decoded, decodeError = self:DecodeData(content, options)
		if not decoded then
			return false, decodeError
		end
		return self:ApplyData(decoded, options)
	end

	function SaveManager:ExportFile(name, options)
		local path, normalizedName = self:GetConfigPath(name)
		if not path then
			return false, normalizedName
		end

		local content, exportError = self:ExportString(options)
		if not content then
			return false, exportError
		end

		local success, writeError = pcall(writefile, path, content)
		if not success then
			return false, "failed to write export: " .. tostring(writeError)
		end
		return true, path
	end

	function SaveManager:ImportFile(name, options)
		local path, normalizedName = self:GetConfigPath(name)
		if not path then
			return false, normalizedName
		end
		if not isfile(path) then
			return false, "invalid file"
		end

		local success, content = pcall(readfile, path)
		if not success then
			return false, "failed to read import: " .. tostring(content)
		end
		return self:ImportString(content, options)
	end

	function SaveManager:SetShareProvider(provider)
		assert(type(provider) == "table", "share provider must be a table")
		assert(type(provider.Upload) == "function", "share provider requires Upload(json)")
		assert(type(provider.Download) == "function", "share provider requires Download(code)")
		self.ShareProvider = provider
	end

	function SaveManager:CreateShareCode(options)
		if not self.ShareProvider then
			return false, "share provider is not configured"
		end
		local content, exportError = self:ExportString(options)
		if not content then
			return false, exportError
		end
		local success, code = pcall(self.ShareProvider.Upload, self.ShareProvider, content)
		if not success or type(code) ~= "string" or code == "" then
			return false, "share provider failed to create a code"
		end
		return true, code
	end

	function SaveManager:ImportShareCode(code, options)
		if not self.ShareProvider then
			return false, "share provider is not configured"
		end
		if type(code) ~= "string" or code == "" then
			return false, "invalid share code"
		end
		local success, content = pcall(self.ShareProvider.Download, self.ShareProvider, code)
		if not success or type(content) ~= "string" then
			return false, "share provider failed to download the config"
		end
		return self:ImportString(content, options)
	end

	function SaveManager:SetCloudProvider(provider)
		assert(type(provider) == "table", "cloud provider must be a table")
		assert(type(provider.Save) == "function", "cloud provider requires Save(key, json)")
		assert(type(provider.Load) == "function", "cloud provider requires Load(key)")
		self.CloudProvider = provider
	end

	function SaveManager:SaveCloud(key, options)
		if not self.CloudProvider then
			return false, "cloud provider is not configured"
		end
		if type(key) ~= "string" or key == "" then
			return false, "invalid cloud key"
		end
		local content, exportError = self:ExportString(options)
		if not content then
			return false, exportError
		end
		local success, result = pcall(self.CloudProvider.Save, self.CloudProvider, key, content)
		return success and result ~= false, success and result or tostring(result)
	end

	function SaveManager:LoadCloud(key, options)
		if not self.CloudProvider then
			return false, "cloud provider is not configured"
		end
		if type(key) ~= "string" or key == "" then
			return false, "invalid cloud key"
		end
		local success, content = pcall(self.CloudProvider.Load, self.CloudProvider, key)
		if not success or type(content) ~= "string" then
			return false, "cloud provider failed to load the config"
		end
		return self:ImportString(content, options)
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
		self:CaptureDefaults()
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
		self:CaptureDefaults()

		local section = tab:AddSection("ConfigSection")
		local function GetTransferOptions()
			local selectedCategories = SaveManager.Options.SaveManager_CategoryList.Value
			if type(selectedCategories) == "table" and next(selectedCategories) == nil then
				selectedCategories = nil
			end
			local selectedMode = SaveManager.Options.SaveManager_ImportMode.Value
			return {
				categories = selectedCategories,
				mode = type(selectedMode) == "string" and selectedMode:lower() or "merge",
				strictGame = true,
			}
		end

		section:AddInput("SaveManager_ConfigName",    { Title = "ConfigName" })
		section:AddDropdown("SaveManager_ConfigList", { Title = "ConfigList", Values = self:RefreshConfigList(), AllowNull = true })
		section:AddInput("SaveManager_ImportJSON", {
			Title = "ImportJSON",
			Description = "ImportJSONDesc",
			Placeholder = '{"version":2,"objects":[]}',
		})
		section:AddInput("SaveManager_TransferFile", {
			Title = "TransferFile",
			Placeholder = "shared-config",
		})
		section:AddDropdown("SaveManager_CategoryList", {
			Title = "ExportCategories",
			Description = "ExportCategoriesDesc",
			Values = self:GetCategories(),
			Multi = true,
			Default = {},
		})
		section:AddDropdown("SaveManager_ImportMode", {
			Title = "ImportMode",
			Values = { "Merge", "Replace" },
			Default = "Merge",
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
			local content, exportError = self:ExportString(GetTransferOptions())
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
			local success, importError = self:ImportString(content, GetTransferOptions())
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

		section:AddButton({Title = "PreviewImport", Callback = function()
			local content = SaveManager.Options.SaveManager_ImportJSON.Value
			local transferOptions = GetTransferOptions()
			local success, preview = self:PreviewImport(content, transferOptions)
			if not success then
				return self.Library:Notify({
					Title = "Interface",
					Content = "Config loader",
					SubContent = self.Library:Translate("ImportFail", preview),
					Duration = 7
				})
			end

			local lines = {
				self.Library:Translate("PreviewResult", #preview.changes, #preview.skipped),
				"",
			}
			for index = 1, math.min(#preview.changes, 12) do
				local change = preview.changes[index]
				local current = self:EncodeData(change.current) or "?"
				local incoming = self:EncodeData(change.incoming) or "?"
				table.insert(lines, string.format(
					"%s%s\n  %s\n  -> %s",
					change.index,
					change.reset and " (reset)" or "",
					current:sub(1, 90),
					incoming:sub(1, 90)
				))
			end
			if #preview.changes > 12 then
				table.insert(lines, string.format("\n+%d more", #preview.changes - 12))
			end

			self.Library.Window:Dialog({
				Title = self.Library:Translate("PreviewImport"),
				Content = table.concat(lines, "\n"),
				Buttons = {
					{
						Title = self.Library:Translate("ApplyImport"),
						Callback = function()
							local imported, importError = self:ImportString(content, transferOptions)
							self.Library:Notify({
								Title = "Interface",
								Content = "Config loader",
								SubContent = imported
									and self.Library:Translate("ImportSuccess")
									or self.Library:Translate("ImportFail", importError),
								Duration = 7
							})
						end,
					},
					{
						Title = self.Library:Translate("CancelImport"),
						Callback = function() end,
					},
				},
			})
		end})

		section:AddButton({Title = "ExportJSONFile", Callback = function()
			local name = SaveManager.Options.SaveManager_TransferFile.Value
			local success, result = self:ExportFile(name, GetTransferOptions())
			self.Library:Notify({
				Title = "Interface",
				Content = "Config loader",
				SubContent = success
					and self.Library:Translate("ExportFileSuccess", result)
					or self.Library:Translate("ExportFail", result),
				Duration = 7
			})
		end})

		section:AddButton({Title = "ImportJSONFile", Callback = function()
			local name = SaveManager.Options.SaveManager_TransferFile.Value
			local success, result = self:ImportFile(name, GetTransferOptions())
			self.Library:Notify({
				Title = "Interface",
				Content = "Config loader",
				SubContent = success
					and self.Library:Translate("ImportSuccess")
					or self.Library:Translate("ImportFail", result),
				Duration = 7
			})
		end})

		section:AddButton({Title = "ResetConfig", Callback = function()
			local _, count = self:Reset(GetTransferOptions())
			self.Library:Notify({
				Title = "Interface",
				Content = "Config loader",
				SubContent = self.Library:Translate("ResetSuccess", count),
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
			"SaveManager_TransferFile",
			"SaveManager_CategoryList",
			"SaveManager_ImportMode",
		})
	end

	SaveManager:BuildFolderTree()
end

return SaveManager
