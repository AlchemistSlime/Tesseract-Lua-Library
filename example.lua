--[[
    ============================================================================
    TESSERACT DEMO – Demonstration of all library features
    ============================================================================
    This script loads the tesseract module and provides an interactive menu
    where each item demonstrates a separate function.
    ============================================================================
--]]

local ok, tesseract = pcall(require, "tesseract")
if not ok or not tesseract then
    ok, tesseract = pcall(require, "../src/lua/tesseract")
    if not ok or not tesseract then
        print("\27[91mERR: TESSERACT LOADING FAILED\27[0m")
        if not ok then
            print("Loading error: " .. tostring(tesseract))
        else
            print("Error, module not found")
        end
        os.execute("pause")
        os.exit()
    end
end

local t = tesseract
local lang = t.lang or "en"

-- ============================================================================
--  LOCALIZATION (loads from locales/*.json files)
-- ============================================================================
-- t.t contains the table loaded from the locale file (e.g., ru.json)
-- Example: print(t.t.location)  -- prints the value of key "location"
-- Example: print(t.t.close)     -- prints the value of key "close"
--
-- To use localization:
--   1. Create a folder named "locales" next to the script.
--   2. Place files: en.json, ru.json, de.json (or others) inside it.
--   3. JSON format: { "key": "value", "key2": "value2" }
--   4. In code, access values via t.t.key
-- ============================================================================
print(t.t.location)   -- example usage of localization
-- print(t.t.close)    -- example usage (see the exit function below)

-- ============================================================================
--  USEFUL FEATURES NOT INCLUDED IN THE DEMO, BUT AVAILABLE:
-- ============================================================================
-- wait(seconds)          – blocking delay (timeout on Windows, sleep on Unix)
-- t.const("name", value) – creates a constant (protected from changes)
-- t.const({ a=1, b=2 })  – creates multiple constants at once (freezes the table)
-- ============================================================================

-- ============================================================================
--  HELPER FUNCTION FOR LOCALIZED OUTPUT
-- ============================================================================
local function _(str)
    -- Simple dictionary for common phrases (can be extended)
    local dict = {
        ["Demo"] = { ru = "Демонстрация", en = "Demo", de = "Demo" },
        ["Press Enter to continue..."] = { ru = "Нажмите Enter для продолжения...", en = "Press Enter to continue...", de = "Drücken Sie Enter zum Fortfahren..." },
        ["Goodbye!"] = { ru = "До свидания!", en = "Goodbye!", de = "Auf Wiedersehen!" },
    }
    local entry = dict[str]
    if entry and entry[lang] then return entry[lang] else return str end
end

-- ============================================================================
--  DEMO FUNCTIONS (each demonstrates one feature)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Logging (warn, error)
-- ----------------------------------------------------------------------------
function demo_logging()
    print("\n=== " .. _("Demo") .. ": Logging ===")
    t.warn("This is a warning (yellow)")      -- yellow warning
    t.error("This is an error (red, non-fatal)") -- red error (non-fatal)
    print(_("Press any button to continue..."))
    t.pause(true)   -- silent pause
end

-- ----------------------------------------------------------------------------
-- 2. Break functions (warn_break, error_break, script_break)
-- ----------------------------------------------------------------------------
function demo_breaks()
    print("\n=== " .. _("Demo") .. ": Break functions ===")
    print("1. warn_break  – shows yellow (BREAK) and exits")
    print("2. error_break – shows red ERR (BREAK) and exits")
    print("3. script_break – instantly closes without messages")
    print("Choose 1, 2, 3 or 0 to skip:")
    local choice = io.read()
    if choice == "1" then
        t.warn_break("This is warn_break demo")
    elseif choice == "2" then
        t.error_break("This is error_break demo")
    elseif choice == "3" then
        t.script_break()
    else
        print("Skipped break demos.")
    end
end

-- ----------------------------------------------------------------------------
-- 3. Colors (Color3 – RGB and HEX)
-- ----------------------------------------------------------------------------
function demo_colors()
    print("\n=== " .. _("Demo") .. ": Color3 ===")
    local red   = t.Color3.fromRGB(255, 0, 0)
    local green = t.Color3.fromRGB(0, 255, 0)
    local blue  = t.Color3.fromRGB(0, 0, 255)
    local gold  = t.Color3.fromHex("#FFD700")
    local dark  = t.Color3.fromHex("1A1A1A")
    print(red:format("Red"))
    print(green:format("Green"))
    print(blue:format("Blue"))
    print(gold:format("Gold (HEX)"))
    print(dark:format("Dark gray (HEX)"))
    print(_("Press any button to continue..."))
    t.pause(true)
end

-- ----------------------------------------------------------------------------
-- 4. Vectors (Vector2, Vector3) – math, normalisation, dot product, cross
-- ----------------------------------------------------------------------------
function demo_vectors()
    print("\n=== " .. _("Demo") .. ": Vectors ===")
    local v2  = t.Vector2.new(3, 4)
    local v3  = t.Vector3.new(1, 2, 3)
    local v3b = t.Vector3.new(4, 5, 6)
    print("Vector2(3,4) magnitude = " .. v2:Magnitude())
    print("Vector3(1,2,3) + Vector3(4,5,6) = " .. tostring(v3 + v3b))
    print("Cross product = " .. tostring(v3:Cross(v3b)))
    print(_("Press any button to continue..."))
    t.pause(true)
end

-- ----------------------------------------------------------------------------
-- 5. HTTP GET (HttpGet) – fetch data from URL
-- ----------------------------------------------------------------------------
function demo_http()
    print("\n=== " .. _("Demo") .. ": HttpGet ===")
    local data = t.HttpGet("https://api.github.com/repos/lua/lua") -- example
    if data then
        print("Received " .. #data .. " bytes")
        local name = data:match('"name"%s*:%s*"([^"]+)"')
        if name then print("Repo name: " .. name) end
    else
        print("HttpGet failed")
    end
    print(_("Press any button to continue..."))
    t.pause(true)
end

-- ----------------------------------------------------------------------------
-- 6. Clipboard (setclipboard) – copy text
-- ----------------------------------------------------------------------------
function demo_clipboard()
    print("\n=== " .. _("Demo") .. ": setclipboard ===")
    local text = "Tesseract clipboard test: Hello, world!"
    t.setclipboard(text)
    print("Text copied to clipboard: " .. text)
    print(_("Press any button to continue..."))
    t.pause(true)
end

-- ----------------------------------------------------------------------------
-- 7. Safe loadstring (compile string code)
-- ----------------------------------------------------------------------------
function demo_loadstring()
    print("\n=== " .. _("Demo") .. ": loadstring_safe ===")
    local code = [[
        print("Loaded code executed successfully!")
        return 42
    ]]
    local func, err = t.loadstring_safe(code)
    if func then
        local result = func()
        print("Result: " .. tostring(result))
    else
        print("Error: " .. tostring(err))
    end
    print(_("Press any button to continue..."))
    t.pause(true)
end

-- ----------------------------------------------------------------------------
-- 8. Download and open file (download + open)
-- ----------------------------------------------------------------------------
function demo_download()
    print("\n=== " .. _("Demo") .. ": download + open ===")
    local url = "https://raw.githubusercontent.com/lua/lua/master/README"
    local path = "./"
    local filename = "lua_readme.txt"
    print("Downloading " .. url .. " ...")
    local ok = t.download(url, path, filename, true) -- true = open after download
    if ok then
        print("Downloaded and opened: " .. path .. filename)
    else
        print("Download failed.")
    end
    print(_("Press any button to continue..."))
    t.pause(true)
end

-- ----------------------------------------------------------------------------
-- 9. Open link in browser (open_link)
-- ----------------------------------------------------------------------------
function demo_openlink()
    print("\n=== " .. _("Demo") .. ": open_link ===")
    print("Opening https://example.com in default browser...")
    t.open_link("https://example.com") -- can also be without protocol (auto-added)
    print(_("Press any button to continue..."))
    t.pause(true)
end

-- ----------------------------------------------------------------------------
-- 10. Async tasks (task scheduler)
-- ----------------------------------------------------------------------------
function demo_task()
    print("\n=== " .. _("Demo") .. ": Task Scheduler ===")
    t.task.spawn(function()
        print("[Task] Waiting 2 seconds...")
        t.task.wait(2)
        print("[Task] Done!")
    end)
    t.task.delay(1, function()
        print("[Delay] This runs after 1 second")
    end)
    print("Running task steps... (watch async output)")
    for i = 1, 6 do
        t.task.step()
        t.wait(0.1)
    end
    print(_("Press any button to continue..."))
    t.pause(true)
end

-- ----------------------------------------------------------------------------
-- 11. Pause with silent option (pause)
-- ----------------------------------------------------------------------------
function demo_pause()
    print("\n=== " .. _("Demo") .. ": pause ===")
    print("Calling pause() - you'll see 'Press any key...'")
    t.pause()
    print("Now calling pause(true) - silent (no message)")
    t.pause(true)
    print("Done.")
    print(_("Press Enter to continue..."))
    io.read()
end

-- ----------------------------------------------------------------------------
-- 12. System information (OS, HWID, IP, version, etc.)
-- ----------------------------------------------------------------------------
function demo_sysinfo()
    print("\n=== " .. _("Demo") .. ": System Info ===")
    print("OS: " .. t.OS)
    print("Windows version: " .. t.win_ver)
    print("Language: " .. t.lang)
    print("IP: " .. t.my_ip)
    print("HWID: " .. t.my_hwid)
    print("Tesseract version: " .. t._v)
    print(_("Press any button to continue..."))
    t.pause(true)
end

-- ----------------------------------------------------------------------------
-- 0. Exit
-- ----------------------------------------------------------------------------
function exit()
    print("\n=== " .. _("Demo") .. ": Exit ===")
    print(t.t.close)  -- prints closing message from locale file
    t.pause(true)
    t.script_break()
end

-- ============================================================================
--  MAIN MENU (with localized item descriptions)
-- ============================================================================
local menu_items = {
    ["1"] = { desc = (lang=="ru") and "Логирование (warn, error)" or "Logging (warn, error)", action = demo_logging },
    ["2"] = { desc = (lang=="ru") and "Функции остановки (break)" or "Break functions (warn_break, etc.)", action = demo_breaks },
    ["3"] = { desc = (lang=="ru") and "Цвета (Color3)" or "Colors (Color3)", action = demo_colors },
    ["4"] = { desc = (lang=="ru") and "Векторы (Vector2/3)" or "Vectors (Vector2/3)", action = demo_vectors },
    ["5"] = { desc = (lang=="ru") and "HTTP-запросы (HttpGet)" or "HTTP request (HttpGet)", action = demo_http },
    ["6"] = { desc = (lang=="ru") and "Буфер обмена (setclipboard)" or "Clipboard (setclipboard)", action = demo_clipboard },
    ["7"] = { desc = (lang=="ru") and "Безопасный loadstring" or "Safe loadstring (loadstring_safe)", action = demo_loadstring },
    ["8"] = { desc = (lang=="ru") and "Скачивание и открытие файла" or "Download and open file", action = demo_download },
    ["9"] = { desc = (lang=="ru") and "Открыть ссылку в браузере" or "Open link in browser", action = demo_openlink },
    ["10"] = { desc = (lang=="ru") and "Асинхронные задачи (task)" or "Async tasks (task scheduler)", action = demo_task },
    ["11"] = { desc = (lang=="ru") and "Пауза (pause)" or "Pause (pause)", action = demo_pause },
    ["12"] = { desc = (lang=="ru") and "Системная информация" or "System info", action = demo_sysinfo },
    ["0"] = { desc = (lang=="ru") and "Выход" or "Exit", action = exit },
}

--[[
-- Alternative way to create a menu (simpler for few options):
local menu = t.create_interface({
    ["1"] = {
        desc = "printer",
        action = function()
            print("printer")
            wait(3)
            t.warn_break("out of ink")
        end
    },
    ["0"] = {
        desc = "Exit",
        action = function()
            print("Goodbye!")
            menu:hide()
            os.exit()
        end
    }
})
menu:run()
--]]

local menu = t.create_interface(menu_items)
local title = (lang=="ru") and "Главное меню Tesseract (демонстрация всех функций)" or "Tesseract Main Menu (all features demo)"
menu:set_title(title)
menu:run()