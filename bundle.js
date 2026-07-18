const fs = require('fs');
const path = require('path');

const srcDir = path.join(__dirname, 'src');
const distDir = path.join(__dirname, 'dist');

if (!fs.existsSync(distDir)) {
    fs.mkdirSync(distDir);
}

// Map files to their module names
const modules = {};

function scanDir(dir) {
    const files = fs.readdirSync(dir);
    for (const file of files) {
        const fullPath = path.join(dir, file);
        const stat = fs.statSync(fullPath);
        if (stat.isDirectory()) {
            scanDir(fullPath);
        } else if (file.endsWith('.lua') || file.endsWith('.luau')) {
            const relPath = path.relative(srcDir, fullPath).replace(/\\/g, '/');
            let modName = relPath.replace(/\.luau?$/, '');
            if (modName.endsWith('/init')) {
                modName = modName.slice(0, -5);
            }
            modName = modName.replace(/\//g, '.');
            if (modName === 'init') {
                modName = 'main';
            }
            modules[modName] = fs.readFileSync(fullPath, 'utf8');
        }
    }
}

scanDir(srcDir);

// Static replacements for dynamic script:GetChildren() calls
modules['Elements'] = `
local Elements = {}
local btn = require("Elements.Button")
local cp = require("Elements.Colorpicker")
local dd = require("Elements.Dropdown")
local inp = require("Elements.Input")
local kb = require("Elements.Keybind")
local pg = require("Elements.Paragraph")
local sl = require("Elements.Slider")
local tg = require("Elements.Toggle")
local rs = require("Elements.RangeSlider")
local img = require("Elements.Image")
local cb = require("Elements.CopyButton")

table.insert(Elements, btn)
table.insert(Elements, cp)
table.insert(Elements, dd)
table.insert(Elements, inp)
table.insert(Elements, kb)
table.insert(Elements, pg)
table.insert(Elements, sl)
table.insert(Elements, tg)
table.insert(Elements, rs)
table.insert(Elements, img)
table.insert(Elements, cb)

return Elements
`;

modules['Themes'] = `
local Themes = {
	Names = {
		"Dark",
		"Darker",
		"Light",
		"Aqua",
		"Amethyst",
		"Rose",
	},
}

Themes["Dark"] = require("Themes.Dark")
Themes["Darker"] = require("Themes.Darker")
Themes["Light"] = require("Themes.Light")
Themes["Aqua"] = require("Themes.Aqua")
Themes["Amethyst"] = require("Themes.Amethyst")
Themes["Rose"] = require("Themes.Rose")

return Themes
`;

// Helper to resolve requires inside a module file
function processModule(name, code) {
    return code;
}

// Generate the bundle
let bundle = `
-- Bundled by bundle.js
local modules = {}
local loaded = {}

local function get_parent_path(path)
    if path == "" then
        return ""
    end
    local parent = path:match("^(.-)%.[^%.]+$")
    return parent or ""
end

local function create_mock_script(path)
    local mock
    mock = setmetatable({}, {
        __index = function(self, key)
            if key == "Parent" then
                return create_mock_script(get_parent_path(path))
            end
            local newPath = path == "" and key or (path .. "." .. key)
            return create_mock_script(newPath)
        end,
        __tostring = function(self)
            return path
        end
    })
    return mock
end

local function register(name, func)
    modules[name] = func
end

local function require(name)
    name = tostring(name)
    if name == "" then
        name = "main"
    end
    if loaded[name] then
        return loaded[name]
    end
    if not modules[name] then
        error("Module not found in bundle: " .. tostring(name))
    end
    local val = modules[name]()
    loaded[name] = val
    return val
end
`;

for (const [name, code] of Object.entries(modules)) {
    const processedCode = processModule(name, code);
    const scriptPath = name === 'main' ? '' : name;
    bundle += `\nregister("${name}", function()\nlocal script = create_mock_script("${scriptPath}")\n${processedCode}\nend)\n`;
}

bundle += `\nreturn require("main")\n`;

fs.writeFileSync(path.join(distDir, 'main.lua'), bundle, 'utf8');
console.log('Bundled successfully into dist/main.lua');
