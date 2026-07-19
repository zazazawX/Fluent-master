local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/zazazawX/Fluent-master/main/dist/main.lua?v=" .. tostring(math.random(1, 100000))))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/zazazawX/Fluent-master/main/Addons/SaveManager.lua?v=" .. tostring(math.random(1, 100000))))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/zazazawX/Fluent-master/main/Addons/InterfaceManager.lua?v=" .. tostring(math.random(1, 100000))))()
local KeySystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/zazazawX/Fluent-master/main/Addons/KeySystem.lua?v=" .. tostring(math.random(1, 100000))))()

KeySystem:SetLibrary(Fluent)

local EnableKeySystem = true -- Set to true to test the advanced Key System!

local function StartScript()
    local Window = Fluent:CreateWindow({
        Title = "Fluent " .. Fluent.Version,
        SubTitle = "by dawid",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

do
    Fluent:Notify({
        Title = "Notification",
        Content = "This is a notification",
        SubContent = "SubContent", -- Optional
        Duration = 5 -- Set to nil to make the notification not disappear
    })



    Tabs.Main:AddParagraph({
        Title = "Paragraph",
        Content = "This is a paragraph.\nSecond line!"
    })

    Tabs.Main:AddImage({
        Title = "Image Element",
        Description = "This is a simple image element",
        Image = "rbxassetid://10709791437",
        Size = UDim2.fromOffset(64, 64)
    })



    Tabs.Main:AddButton({
        Title = "Button",
        Description = "Very important button",
        Callback = function()
            Window:Dialog({
                Title = "Title",
                Content = "This is a dialog",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            print("Confirmed the dialog.")
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            print("Cancelled the dialog.")
                        end
                    }
                }
            })
        end
    })

    Tabs.Main:AddCopyButton({
        Title = "Copy Button",
        Description = "Copies the defined text to clipboard",
        Value = "Hello from Fluent!",
        Callback = function(Value)
            print("Copied text:", Value)
        end
    })



    local Toggle = Tabs.Main:AddToggle("MyToggle", {Title = "Toggle", Default = false })

    Toggle:OnChanged(function()
        print("Toggle changed:", Options.MyToggle.Value)
    end)

    Options.MyToggle:SetValue(false)


    
    local Slider = Tabs.Main:AddSlider("Slider", {
        Title = "Slider",
        Description = "This is a slider",
        Default = 2,
        Min = 0,
        Max = 5,
        Rounding = 1,
        Callback = function(Value)
            print("Slider was changed:", Value)
        end
    })

    Slider:OnChanged(function(Value)
        print("Slider changed:", Value)
    end)

    Slider:SetValue(3)

    local RangeSlider = Tabs.Main:AddRangeSlider("RangeSlider", {
        Title = "Range Slider",
        Description = "This is a range slider",
        Min = 0,
        Max = 10,
        Default = { 3, 7 },
        Rounding = 1,
        Callback = function(Value)
            print("RangeSlider was changed:", Value.Min, Value.Max)
        end
    })

    RangeSlider:OnChanged(function(Value)
        print("RangeSlider changed:", Value.Min, Value.Max)
    end)

    RangeSlider:SetValue(4, 8)



    local Dropdown = Tabs.Main:AddDropdown("Dropdown", {
        Title = "Dropdown",
        Values = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen"},
        Multi = false,
        Default = 1,
    })

    Dropdown:SetValue("four")

    Dropdown:OnChanged(function(Value)
        print("Dropdown changed:", Value)
    end)


    
    local MultiDropdown = Tabs.Main:AddDropdown("MultiDropdown", {
        Title = "Dropdown",
        Description = "You can select multiple values.",
        Values = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen"},
        Multi = true,
        Default = {"seven", "twelve"},
    })

    MultiDropdown:SetValue({
        three = true,
        five = true,
        seven = false
    })

    MultiDropdown:OnChanged(function(Value)
        local Values = {}
        for Value, State in next, Value do
            table.insert(Values, Value)
        end
        print("Mutlidropdown changed:", table.concat(Values, ", "))
    end)



    local Colorpicker = Tabs.Main:AddColorpicker("Colorpicker", {
        Title = "Colorpicker",
        Default = Color3.fromRGB(96, 205, 255)
    })

    Colorpicker:OnChanged(function()
        print("Colorpicker changed:", Colorpicker.Value)
    end)
    
    Colorpicker:SetValueRGB(Color3.fromRGB(0, 255, 140))



    local TColorpicker = Tabs.Main:AddColorpicker("TransparencyColorpicker", {
        Title = "Colorpicker",
        Description = "but you can change the transparency.",
        Transparency = 0,
        Default = Color3.fromRGB(96, 205, 255)
    })

    TColorpicker:OnChanged(function()
        print(
            "TColorpicker changed:", TColorpicker.Value,
            "Transparency:", TColorpicker.Transparency
        )
    end)



    local Keybind = Tabs.Main:AddKeybind("Keybind", {
        Title = "KeyBind",
        Mode = "Toggle", -- Always, Toggle, Hold
        Default = "LeftControl", -- String as the name of the keybind (MB1, MB2 for mouse buttons)

        -- Occurs when the keybind is clicked, Value is `true`/`false`
        Callback = function(Value)
            print("Keybind clicked!", Value)
        end,

        -- Occurs when the keybind itself is changed, `New` is a KeyCode Enum OR a UserInputType Enum
        ChangedCallback = function(New)
            print("Keybind changed!", New)
        end
    })

    -- OnClick is only fired when you press the keybind and the mode is Toggle
    -- Otherwise, you will have to use Keybind:GetState()
    Keybind:OnClick(function()
        print("Keybind clicked:", Keybind:GetState())
    end)

    Keybind:OnChanged(function()
        print("Keybind changed:", Keybind.Value)
    end)

    task.spawn(function()
        while true do
            wait(1)

            -- example for checking if a keybind is being pressed
            local state = Keybind:GetState()
            if state then
                print("Keybind is being held down")
            end

            if Fluent.Unloaded then break end
        end
    end)

    Keybind:SetValue("MB2", "Toggle") -- Sets keybind to MB2, mode to Hold


    local Input = Tabs.Main:AddInput("Input", {
        Title = "Input",
        Default = "Default",
        Placeholder = "Placeholder",
        Numeric = false, -- Only allows numbers
        Finished = false, -- Only calls callback when you press enter
        Callback = function(Value)
            print("Input changed:", Value)
        end
    })

    Input:OnChanged(function()
        print("Input updated:", Input.Value)
    end)
end


-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


    Window:SelectTab(1)

    Fluent:Notify({
        Title = "Fluent",
        Content = "The script has been loaded.",
        Duration = 8
    })

    -- You can use the SaveManager:LoadAutoloadConfig() to load a config
    -- which has been marked to be one that auto loads!
    SaveManager:LoadAutoloadConfig()
end

if EnableKeySystem then
    KeySystem:CreateKeySystem({
        Title = "Fluent Key System",
        SubTitle = "Verification Required",
        GetKeyLink = "https://linkvertise.com/example",
        Discord = "https://discord.gg/example",
        SaveKey = true, -- Auto-saves the key to a file
        SavePath = "fluent-key-demo.txt", -- File name
        BruteForceProtection = true,
        MaxAttempts = 5,
        LockoutDuration = 60,
        
        -- Option A: Simple hardcoded key
        Key = "secret-demo-key",
        
        -- Option B: Array of hardcoded keys
        -- Keys = {"key1", "key2"},
        
        -- Option C: Custom verification callback (ideal for custom APIs)
        -- Callback = function(Key)
        --     return Key == "secret-demo-key"
        -- end,
        
		-- Option D: PandaAuth V4 (set the service ID from your main script)
		-- Comment out the Key option above before enabling this preset.
		-- Preset = "PandaAuthV4",
		-- PresetConfig = {
		--     ServiceId = "YOUR_SERVICE_ID",
		--     Debug = false,
		--     KickOnDetect = false,
		--     Premium = false -- true requires a premium key
		-- },

		-- Legacy direct REST integration (PandaAuth V2)
		-- Preset = "PandaAuthV2",
		-- PresetConfig = {
		--     ServiceId = "YOUR_SERVICE_ID",
		--     Premium = false,
		--     BaseURL = "https://api.pandauth.com/api/v1",
		--     GetKeyBaseUrl = "https://ads.pandauth.com"
		-- },

		-- Other built-in presets: Luaguard, PandaAuth, Keyguard
		-- Preset = "Luaguard",
		-- PresetConfig = { Project = "MyProject" },

		-- Option E: Try multiple API providers in order
		-- Providers = {
		--     {
		--         URL = "https://api.example.com/verify?key={key}",
		--         Method = "GET",
		--         SuccessField = "data.valid"
		--     },
		--     {
		--         URL = "https://backup.example.com/verify",
		--         Method = "POST",
		--         Headers = { ["Content-Type"] = "application/json" },
		--         Body = { project = "MyProject" },
		--         KeyField = "licenseKey",
		--         SuccessField = "success"
		--     }
		-- },
        
        OnVerified = function()
            StartScript()
        end
    })
else
    StartScript()
end
