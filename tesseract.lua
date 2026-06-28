-- ================================================================
-- tesseract.lua – Cross-platform utility module (Windows/Linux/macOS)
-- Version: 1.8.2
-- ================================================================

-- Settings
local show_messages = false -- optional, false for clean log

-- ================================================================
-- OS Detection
-- ================================================================
local function detect_os()
    local sys = package.config:sub(1,1) == "\\" and "windows" or "unix"
    if sys == "unix" then
        local uname = io.popen("uname -s 2>/dev/null"):read("*l")
        if uname == "Darwin" then return "macos" end
        if uname == "Linux" then return "linux" end
        return "unix"
    end
    return "windows"
end
local OS = detect_os()


-- For Windows – enable UTF-8
if OS == "windows" then
    os.execute("chcp 65001 >nul 2>nul")

end

local _v = "1.8.2"
local module = {}

-- ANSI colors
local RED   = "\27[91m"
local YEL   = "\27[93m"
local RESET = "\27[0m"

-- ================================================================
-- Pause and exit (cross-platform)
-- ================================================================
local function pause_and_exit()
    print("\nPress any key to continue . . .")
    if OS == "windows" then
        os.execute("pause >nul 2>nul")
    else
        io.read()
    end
    os.exit()
end

-- ================================================================
-- Logging functions
-- ================================================================
function module.warn(msg)
    print(YEL .. tostring(msg) .. RESET)
end

function module.error(msg)
    print(RED .. "ERR: " .. tostring(msg) .. RESET)
end

function module.warn_break(msg)
    print(YEL .. "(BREAK): " .. tostring(msg) .. RESET)
    pause_and_exit()
end

function module.error_break(msg)
    print(RED .. "ERR (BREAK): " .. tostring(msg) .. RESET)
    pause_and_exit()
end

function module.script_break()
    os.exit()
end

-- ================================================================
-- Wait / Sleep (non-blocking delay)
-- ================================================================
function module.wait(seconds)
    seconds = seconds or 0
    if OS == "windows" then
        if seconds > 0 then
            os.execute("timeout /t " .. tostring(seconds) .. " /nobreak >nul 2>nul")
        else
            os.execute("timeout /t 0 /nobreak >nul 2>nul")
        end
    else
        if seconds > 0 then
            os.execute("sleep " .. tostring(seconds) .. " 2>/dev/null")
        else
            os.execute("sleep 0.1 2>/dev/null")
        end
    end
end
function module.pause(silent)
    if OS ~= "windows" then
        error("pause() is only available on Windows!")
    end
    if silent then
        os.execute("pause >nul")
    else
        os.execute("pause")
    end
end
-- ================================================================
-- Safe loadstring / loadfile (auto-detects loadstring/load)
-- ================================================================
function module.loadstring_safe(code, chunkname)
    chunkname = chunkname or "loadstring"
    local fn, err
    if loadstring then
        fn, err = loadstring(code, chunkname)
    elseif load then
        fn, err = load(code, chunkname)
    else
        module.custom_error("No loadstring/load function available")
        return nil, "No load function"
    end
    if not fn then
        module.custom_error("Loadstring error: " .. tostring(err))
        return nil, err
    end
    return fn
end

function module.loadfile_safe(filename)
    local fn, err
    if loadfile then
        fn, err = loadfile(filename)
    else
        module.custom_error("loadfile not available")
        return nil, "loadfile missing"
    end
    if not fn then
        module.custom_error("Loadfile error: " .. tostring(err))
        return nil, err
    end
    return fn
end

-- ================================================================
-- HttpGet (emulates game:HttpGet)
-- ================================================================
function module.HttpGet(url)
    if not url or url == "" then
        module.custom_error("HttpGet: URL is empty")
        return nil
    end

    local output = nil
    if OS == "windows" then
        local cmd = 'powershell -command "try { (Invoke-WebRequest -Uri \\"' .. url .. '\\" -UseBasicParsing).Content } catch { $null }"'
        local handle = io.popen(cmd)
        if handle then
            output = handle:read("*a")
            handle:close()
        end
        if not output or output == "" then
            local curl = io.popen('curl -s -L "' .. url .. '" 2>nul')
            if curl then
                output = curl:read("*a")
                curl:close()
            end
        end
    else
        local has_curl = io.popen("which curl 2>/dev/null"):read("*l") ~= ""
        local cmd = has_curl and ('curl -s -L "' .. url .. '"') or ('wget -qO- "' .. url .. '"')
        local handle = io.popen(cmd)
        if handle then
            output = handle:read("*a")
            handle:close()
        end
    end

    if not output or output == "" then
        module.custom_error("HttpGet: Failed to fetch URL: " .. tostring(url))
        return nil
    end
    return output
end

module.game = { HttpGet = module.HttpGet }

-- ================================================================
-- Vector2, Vector3, Color3
-- ================================================================
local Vector2 = {}
Vector2.__index = Vector2
function Vector2.new(x, y) return setmetatable({ x = x or 0, y = y or 0 }, Vector2) end
function Vector2:__add(v) return Vector2.new(self.x + v.x, self.y + v.y) end
function Vector2:__sub(v) return Vector2.new(self.x - v.x, self.y - v.y) end
function Vector2:__mul(s) return Vector2.new(self.x * s, self.y * s) end
function Vector2:__div(s) return Vector2.new(self.x / s, self.y / s) end
function Vector2:__unm() return Vector2.new(-self.x, -self.y) end
function Vector2:__eq(v) return self.x == v.x and self.y == v.y end
function Vector2:__tostring() return string.format("Vector2(%.2f, %.2f)", self.x, self.y) end
function Vector2:Magnitude() return math.sqrt(self.x^2 + self.y^2) end
function Vector2:Normalize() local m = self:Magnitude() return m == 0 and Vector2.new(0,0) or Vector2.new(self.x/m, self.y/m) end
function Vector2:Dot(v) return self.x * v.x + self.y * v.y end
module.Vector2 = Vector2

local Vector3 = {}
Vector3.__index = Vector3
function Vector3.new(x, y, z) return setmetatable({ x = x or 0, y = y or 0, z = z or 0 }, Vector3) end
function Vector3:__add(v) return Vector3.new(self.x + v.x, self.y + v.y, self.z + v.z) end
function Vector3:__sub(v) return Vector3.new(self.x - v.x, self.y - v.y, self.z - v.z) end
function Vector3:__mul(s) return Vector3.new(self.x * s, self.y * s, self.z * s) end
function Vector3:__div(s) return Vector3.new(self.x / s, self.y / s, self.z / s) end
function Vector3:__unm() return Vector3.new(-self.x, -self.y, -self.z) end
function Vector3:__eq(v) return self.x == v.x and self.y == v.y and self.z == v.z end
function Vector3:__tostring() return string.format("Vector3(%.2f, %.2f, %.2f)", self.x, self.y, self.z) end
function Vector3:Magnitude() return math.sqrt(self.x^2 + self.y^2 + self.z^2) end
function Vector3:Normalize() local m = self:Magnitude() return m == 0 and Vector3.new(0,0,0) or Vector3.new(self.x/m, self.y/m, self.z/m) end
function Vector3:Dot(v) return self.x * v.x + self.y * v.y + self.z * v.z end
function Vector3:Cross(v) return Vector3.new(self.y * v.z - self.z * v.y, self.z * v.x - self.x * v.z, self.x * v.y - self.y * v.x) end
module.Vector3 = Vector3

local Color3 = {}
Color3.__index = Color3
function Color3.fromRGB(r, g, b)
    local obj = { R = math.floor(math.max(0, math.min(255, r or 0))), G = math.floor(math.max(0, math.min(255, g or 0))), B = math.floor(math.max(0, math.min(255, b or 0))) }
    obj.ansi = string.format("\27[38;2;%d;%d;%dm", obj.R, obj.G, obj.B)
    return setmetatable(obj, Color3)
end
function Color3.fromHex(hex)
    hex = hex:gsub("^#", "")
    if #hex == 3 then hex = hex:gsub("(.)", "%1%1") end
    local r = tonumber(hex:sub(1,2), 16) or 0
    local g = tonumber(hex:sub(3,4), 16) or 0
    local b = tonumber(hex:sub(5,6), 16) or 0
    return Color3.fromRGB(r, g, b)
end
function Color3:__tostring() return self.ansi end
function Color3:format(text) return self.ansi .. tostring(text) .. RESET end
module.Color3 = Color3

-- ================================================================
-- String and table utilities (compatibility)
-- ================================================================
if not string.split then
    function string.split(str, sep)
        sep = sep or ","
        local result = {}
        for part in string.gmatch(str, "([^" .. sep .. "]+)") do
            table.insert(result, part)
        end
        return result
    end
end
if not table.clear then
    function table.clear(tbl) for k in pairs(tbl) do tbl[k] = nil end end
end
if not table.clone then
    function table.clone(tbl) local c = {} for k,v in pairs(tbl) do c[k]=v end return c end
end
if not table.getn then table.getn = function(t) return #t end end

-- ================================================================
-- Task Scheduler (coroutines-based)
-- ================================================================
local task = {}
module.task = task
local tasks, waiting, deferred = {}, {}, {}
local function resume_co(co, ...)
    if coroutine.status(co) == "dead" then return end
    local ok, err = coroutine.resume(co, ...)
    if not ok then module.custom_error("Task error: " .. tostring(err)) end
end
function task.spawn(f, ...)
    local co = coroutine.create(f)
    table.insert(tasks, { co = co, args = {...} })
    return co
end
function task.defer(f, ...)
    local co = coroutine.create(f)
    table.insert(deferred, { co = co, args = {...} })
    return co
end
function task.wait(seconds)
    seconds = seconds or 0
    local co = coroutine.running()
    if not co then module.custom_error("task.wait must be inside a coroutine") return end
    table.insert(waiting, { co = co, until_time = os.clock() + seconds })
    coroutine.yield()
end
function task.delay(seconds, f, ...)
    local args = {...}
    return task.spawn(function() task.wait(seconds); f(table.unpack(args)) end)
end
function task.step()
    for _, item in ipairs(deferred) do resume_co(item.co, table.unpack(item.args)) end
    deferred = {}
    local now = os.clock()
    local new_waiting = {}
    for _, item in ipairs(waiting) do
        if now >= item.until_time then resume_co(item.co) else table.insert(new_waiting, item) end
    end
    waiting = new_waiting
    local new_tasks = {}
    for _, item in ipairs(tasks) do
        if coroutine.status(item.co) ~= "dead" then
            resume_co(item.co, table.unpack(item.args))
            if coroutine.status(item.co) ~= "dead" then table.insert(new_tasks, item) end
        end
    end
    tasks = new_tasks
end
function task.run()
    while true do task.step(); module.wait(0.1) end
end

-- ================================================================
-- Constants (protected)
-- ================================================================
local CONST_DATA = { aboltus = 52 }
module.CONST = {}
setmetatable(module.CONST, {
    __index = CONST_DATA,
    __newindex = function(_, key, value) module.custom_error(string.format("attempt to assign to const variable %s.", tostring(key))) end,
    __metatable = "Access denied"
})
function module.const(key_or_table, value)
    if type(key_or_table) == "table" then for k,v in pairs(key_or_table) do module.const(k,v) end return end
    local key = key_or_table
    if CONST_DATA[key] ~= nil then module.custom_error(string.format("constant %s already defined.", tostring(key))) return end
    rawset(CONST_DATA, key, value)
end

-- ================================================================
-- System Information (full for Windows, basic for others)
-- ================================================================
local function get_os_version()
    if OS == "windows" then
        local build_handle = io.popen('reg query "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion" /v CurrentBuild')
        if build_handle then
            local output = build_handle:read("*a")
            build_handle:close()
            local build_num = tonumber(output:match("CurrentBuild%s+REG_SZ%s+(%d+)"))
            if build_num and build_num >= 22000 then return "Windows 11 Pro" else return "Windows 10 Pro" end
        end
        return "Windows"
    else
        return OS:gsub("^%l", string.upper) .. " (limited support)"
    end
end

local function get_hwid()
    if OS == "windows" then
        local hwid_handle = io.popen('reg query "HKLM\\SYSTEM\\CurrentControlSet\\Control\\IDConfigDB\\Hardware Profiles\\0001" /v HwProfileGuid')
        if hwid_handle then
            local output = hwid_handle:read("*a")
            hwid_handle:close()
            local matched = output:match("HwProfileGuid%s+REG_SZ%s+([^\r\n]+)")
            if matched then return matched:gsub("[%s%{%}]", "") end
        end
    end
    return "UNKNOWN"
end

local function get_ip()
    local ip = "127.0.0.1"
    if OS == "windows" then
        local ip_handle = io.popen("route print 0.0.0.0")
        if ip_handle then
            local output = ip_handle:read("*a")
            ip_handle:close()
            for line in output:gmatch("[^\r\n]+") do
                if line:match("^%s*0%.0%.0%.0") then
                    local chunks = {}
                    for chunk in line:gmatch("%S+") do table.insert(chunks, chunk) end
                    if chunks[4] and chunks[4]:match("^%d+%.%d+%.%d+%.%d+$") then
                        ip = chunks[4]
                        break
                    end
                end
            end
        end
    else
        local cmd = 'ip -4 addr show | grep -oP "(?<=inet\\s)\\d+(\\.\\d+){3}" | grep -v 127.0.0.1 | head -n1'
        local handle = io.popen(cmd)
        if handle then
            local res = handle:read("*l")
            if res and res ~= "" then ip = res end
            handle:close()
        end
    end
    return ip
end

local function get_lang()
    if OS == "windows" then
        local lang_handle = io.popen('reg query "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Nls\\Language" /v InstallLanguage')
        if lang_handle then
            local output = lang_handle:read("*a")
            lang_handle:close()
            local code = output:match("InstallLanguage%s+REG_SZ%s+(%x+)")
            if code and code:match("0419") then return "ru" end
        end
    end
    local lang = os.getenv("LANG") or os.getenv("LC_ALL") or ""
    return string.sub(lang, 1, 2):lower() ~= "" and string.sub(lang, 1, 2):lower() or "en"
end

local win_ver = get_os_version()
local my_hwid = get_hwid()
local my_ip = get_ip()
local active_lang = get_lang()

-- ================================================================
-- setclipboard – copy text to clipboard
-- ================================================================
function module.setclipboard(text)
    if not text or text == "" then
        module.custom_error("setclipboard: text is empty")
        return
    end
    local escaped = text:gsub('"', '\\"')
    if OS == "windows" then
        local cmd = 'powershell -command "Set-Clipboard -Value \\"' .. escaped .. '\\""'
        os.execute(cmd)
    else
        local cmd = 'echo ' .. escaped .. ' | xclip -selection clipboard 2>/dev/null'
        if OS == "macos" then
            cmd = 'echo ' .. escaped .. ' | pbcopy'
        end
        os.execute(cmd)
    end
    module.warn("Copied to clipboard: " .. tostring(text))
end

-- ================================================================
-- Localization (if locale files exist)
-- ================================================================
local function find_locales_dir()
    local paths = { "../../locales/", "locales/", "../locales/" }
    for _, path in ipairs(paths) do
        local f = io.open(path .. "en.json", "r")
        if f then f:close(); return path end
    end
    return nil
end
local LOCALES_DIR = find_locales_dir()
local t = {}
if LOCALES_DIR then
    local function load_locale_raw(lang_code, system_name)
        local full = LOCALES_DIR .. lang_code .. ".json"
        local file = io.open(full, "r")
        if not file then return nil end
        local content = file:read("*a")
        file:close()
        local tbl = {}
        for key, val in content:gmatch('"([^"]+)"%s*:%s*"([^"]+)"') do
            if val:find("{system}") then val = val:gsub("{system}", system_name) end
            tbl[key] = val
        end
        return tbl
    end
    local supported = { ru=true, en=true, de=true }
    local lang_code = supported[active_lang] and active_lang or "en"
    t = load_locale_raw(lang_code, win_ver) or load_locale_raw("en", win_ver) or {}
end
-- ================================================================
-- Simple Interactive Menu (create_interface) with auto-language
-- ================================================================
function module.create_interface(options)
    local lang = module.lang or "en"
    local strings = {
        ru = {
            title = "Меню",
            choice = "Ваш выбор: ",
            invalid = "Неверный выбор. Попробуйте снова.",
        },
        de = {
            title = "Menü",
            choice = "Ihre Wahl: ",
            invalid = "Ungültige Auswahl. Bitte versuchen Sie es erneut.",
        },
        en = {
            title = "Menu",
            choice = "Your choice: ",
            invalid = "Invalid choice. Please try again.",
        },
    }
    local loc = strings[lang] or strings.en

    local self = {
        items = options or {},
        visible = false,
        title = loc.title,
        lang = lang,
        loc = loc,
    }

    function self:set_title(title)
        self.title = title or self.loc.title
    end

    function self:render()
        if not self.visible then return end
        print("\n=== " .. self.title .. " ===")
        -- Сортировка ключей: сначала числа 1..100, потом 0, потом остальные
        local keys = {}
        for k, _ in pairs(self.items) do
            table.insert(keys, k)
        end
        table.sort(keys, function(a, b)
            local na = tonumber(a)
            local nb = tonumber(b)
            -- если оба числа
            if na and nb then
                -- 0 в конец
                if na == 0 then return false end
                if nb == 0 then return true end
                return na < nb
            end
            -- если a число (и не 0) - перед буквами
            if na then
                return true
            end
            if nb then
                return false
            end
            -- оба не числа - по алфавиту
            return a < b
        end)
        for _, key in ipairs(keys) do
            local item = self.items[key]
            print(string.format("  %s - %s", key, item.desc))
        end
        print(self.loc.choice)
    end

    function self:show()
        self.visible = true
        self:render()
    end

    function self:hide()
        self.visible = false
    end

    function self:handle(input)
        if not self.visible then return end
        local item = self.items[input]
        if item and item.action then
            item.action()
        else
            print(self.loc.invalid)
        end
        if self.visible then self:render() end
    end

    function self:run()
        self:show()
        while self.visible do
            local input = io.read()
            self:handle(input)
        end
    end

    return self
end
-- ================================================================
-- Open file with default application (cross-platform)
-- ================================================================
function module.open(filepath)
    if not filepath or filepath == "" then
        module.custom_error("open: filepath is empty")
        return false
    end
    -- Check if file exists
    local file = io.open(filepath, "r")
    if not file then
        module.custom_error("open: file not found: " .. filepath)
        return false
    end
    file:close()

    local cmd
    if OS == "windows" then
        cmd = 'start "" "' .. filepath .. '"'
    elseif OS == "macos" then
        cmd = 'open "' .. filepath .. '"'
    else -- linux/unix
        cmd = 'xdg-open "' .. filepath .. '"'
    end
    os.execute(cmd)
    module.warn("Opened: " .. filepath)
    return true
end

-- ================================================================
-- Download file from URL with options
-- ================================================================
function module.download(url, path, filename, open_after)
    -- Validate arguments
    if not url or url == "" then
        module.custom_error("ERR: usable of download: download(\"file link\", \"link where to download\", \"filename\", \"true or false to open file after downloading\")")
        return false
    end

    -- Handle optional parameters
    path = path or ""
    filename = filename or ""
    open_after = open_after or false

    -- If no filename, extract from URL
    if filename == "" then
        local extracted = url:match("([^/]+)$")
        if extracted then
            -- Remove query parameters
            filename = extracted:gsub("%?.*", "")
        else
            filename = "downloaded_file"
        end
    end

    -- Build full filepath
    local filepath
    if path ~= "" then
        -- Normalize path separators
        path = path:gsub("\\", "/")
        if path:sub(-1) ~= "/" then path = path .. "/" end
        filepath = path .. filename
    else
        filepath = filename
    end

    -- Show progress (simple)
    print("Downloading: " .. filename .. " ...")

    -- 1. Get content via HttpGet
    local content = module.HttpGet(url)
    if not content then
        module.custom_error("download: failed to fetch URL: " .. url)
        return false
    end

    -- 2. Create parent directories if needed
    local path_parts = {}
    for part in filepath:gmatch("[^\\/]+") do
        table.insert(path_parts, part)
    end
    if #path_parts > 1 then
        local dirs = {}
        for i = 1, #path_parts - 1 do
            table.insert(dirs, path_parts[i])
        end
        local dir_path = table.concat(dirs, "\\")
        if OS == "windows" then
            os.execute('mkdir "' .. dir_path .. '" 2>nul')
        else
            os.execute('mkdir -p "' .. dir_path .. '" 2>/dev/null')
        end
    end

    -- 3. Write file
    local file, err = io.open(filepath, "wb")
    if not file then
        module.custom_error("download: failed to open file for writing: " .. tostring(err))
        return false
    end
    file:write(content)
    file:close()

    module.warn("Download complete: " .. filepath .. " (" .. #content .. " bytes)")

    -- 4. Open if requested
    if open_after then
        module.open(filepath)
    end

    return true
end
function module.open_link(url)
    if not url or url == "" then
        module.custom_error("open_link: URL is empty")
        return false
    end
    if not url:match("^https?://") then
        url = "https://" .. url
    end
    local cmd
    if OS == "windows" then
        cmd = 'start "" "' .. url .. '"'
    elseif OS == "macos" then
        cmd = 'open "' .. url .. '"'
    else
        cmd = 'xdg-open "' .. url .. '"'
    end
    os.execute(cmd)
    module.warn("Opened link: " .. url)
    return true
end
-- ================================================================
-- Export
-- ================================================================
module.t = t
module.const = module.const
module.win_ver = win_ver
module.lang = active_lang
module.my_ip = my_ip
module.my_hwid = my_hwid
module._v = _v
module.OS = OS

-- Show loading message if enabled
if show_messages then
    module.warn("Tesseract " .. _v .. " loaded! (OS: " .. OS .. ")")
end

return module