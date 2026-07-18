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
    // 1. require(Root.X) -> require("X")
    code = code.replace(/require\(\s*Root\.([%w_]+)\s*\)/g, 'require("$1")');
    // 2. require(Components.X) -> require("Components.$1")
    code = code.replace(/require\(\s*Components\.([%w_]+)\s*\)/g, 'require("Components.$1")');
    // 3. require(script.Parent.Parent.Creator) -> require("Creator")
    code = code.replace(/require\(\s*script\.Parent\.Parent\.Creator\s*\)/g, 'require("Creator")');
    // 4. require(script.Parent.Parent.Packages.Flipper) -> require("Packages.Flipper")
    code = code.replace(/require\(\s*script\.Parent\.Parent\.Packages\.Flipper\s*\)/g, 'require("Packages.Flipper")');
    // 5. require(script.Parent.CreateAcrylic) -> require("Acrylic.CreateAcrylic")
    code = code.replace(/require\(\s*script\.Parent\.CreateAcrylic\s*\)/g, 'require("Acrylic.CreateAcrylic")');
    // 6. require(script.Parent.AcrylicPaint) -> require("Acrylic.AcrylicPaint")
    code = code.replace(/require\(\s*script\.Parent\.AcrylicPaint\s*\)/g, 'require("Acrylic.AcrylicPaint")');
    // 7. require(script.Parent.Utils) -> require("Acrylic.Utils")
    code = code.replace(/require\(\s*script\.Parent\.Utils\s*\)/g, 'require("Acrylic.Utils")');
    // 8. require(script.Parent.Assets) -> require("Components.Assets")
    code = code.replace(/require\(\s*script\.Parent\.Assets\s*\)/g, 'require("Components.Assets")');
    
    // Flipper sub-requires
    if (name.startsWith('Packages.Flipper')) {
        code = code.replace(/require\(\s*script\.Parent\.([%w_-]+)\s*\)/g, 'require("Packages.Flipper.$1")');
    }
    // Acrylic sub-requires
    if (name.startsWith('Acrylic')) {
        code = code.replace(/require\(\s*script\.Parent\.([%w_-]+)\s*\)/g, 'require("Acrylic.$1")');
    }

    return code;
}

// Generate the bundle
let bundle = `
-- Bundled by bundle.js
local modules = {}
local loaded = {}

local function register(name, func)
    modules[name] = func
end

local function require(name)
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
    bundle += `\nregister("${name}", function()\n${processedCode}\nend)\n`;
}

bundle += `\nreturn require("main")\n`;

fs.writeFileSync(path.join(distDir, 'main.lua'), bundle, 'utf8');
console.log('Bundled successfully into dist/main.lua');
