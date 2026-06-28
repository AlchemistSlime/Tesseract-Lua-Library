# Tesseract
A powerful Lua library that brings useful features from Luau (Roblox Lua) and introduces custom utility functions for faster development.

## 🚀 Features

* `warn("text")` — Prints a custom yellow warning message.
* `error("text")` — Prints a custom red error message prefixed with `ERR:`.
* `color3.fromRGB(r, g, b)` — Creates a color object using RGB values.
* `color3.fromHEX("#HEX")` — Creates a color object using HEX color codes.
* `task.wait(seconds)` — Advanced non-blocking delay function.
* `task.spawn(function)` — Runs a function in a new thread immediately.
* `OS` — Returns the current Windows operating system version.
* `vector2` & `vector3` — Built-in vector types for 2D and 3D coordinate mathematics.
* `my_ip` — Retrieves the local IPv4 address of the computer.
* `my_hwid` — Retrieves the unique hardware ID (HWID) of the motherboard.
* `lang` — Detects the system language (e.g., outputs `en` or `ru`).
* `wait(seconds)` — A shorthand helper that saves you from writing complex `os.execute` loops.
* `pause(silent)` — Pauses script execution (accepts a boolean `true`/`false` for silent mode).
* `error_break("text")` — Terminates the script immediately with a red error message.
* `warn_break("text")` — Terminates the script immediately with a yellow warning message.
* **UI Features** — Built-in text interface components (see `example.lua` for details).

## 🛠️ Requirements
* **Lua Version**: Lua 5.1 or higher (fully tested and optimized on **Lua 5.4.2**).

## 📦 Installation & Usage

1. Download the `tesseract.lua` file and place it in your project directory.
2. Include the library in your script:
   ```lua
   local tesseract = require("tesseract")
   ```
3. *(Optional)* Create a shorter alias for convenience:
   ```lua
   local t = tesseract
   ```
4. Call any feature:
   ```lua
   t.warn("Hello World!")
   ```
