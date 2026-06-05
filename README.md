# HyprPrompt

A **non-blocking, generic command prompt module for HyprLua**.

Openachat interface for requesting user input in Hyprland without blocking the compositor.

## Features

- ✨ **Non-blocking** - Event-driven, callback-based API
- 🎯 **Generic** - No built-in command parsing or execution
- 🎨 **Beautiful** - Qt/QML powered with rounded corners, transparency, blur
- 🔌 **Modular** - Reusable prompt API for any HyprLua module
- ⚡ **Lightweight** - Minimal dependencies

## Usage

```lua
local prompt = require("hyprprompt")

prompt.show({
    placeholder = "Enter text...",

    on_submit = function(text)
        print("User entered: " .. text)
    end,

    on_cancel = function()
        print("User cancelled")
    end
})
```

## Architecture

```
┌──────────────────────────┐
│        HyprLua           │
│      prompt.show()       │
└───────────┬──────────────┘
            │
            │ Unix Socket
            │
┌───────────▼──────────────┐
│      Qt/QML Frontend     │
│   - Command Window       │
│   - Input Capture        │
│   - Animations           │
└──────────────────────────┘
```

### Components

1. **Lua Core** (`hyprprompt/lua/`) - API, callbacks, IPC listener
2. **Qt/QML UI** (`ui/`) - Window, input, rendering
3. **IPC Layer** - Unix domain socket communication

## Installation

### Requirements

- HyprLua
- Qt 6
- CMake 3.16+
- Lua 5.1+

### Build

```bash
mkdir build
cd build
cmake ..
make
```

## Development

### Project Structure

```
hyprprompt/
├── lua/              # Lua core module
│   └── init.lua      # Main API
├── ui/               # Qt/QML frontend
│   ├── main.cpp
│   ├── main.h
│   ├── Main.qml
│   └── components/
├── ipc/              # IPC layer
│   ├── socket.h
│   └── socket.cpp
├── CMakeLists.txt
└── README.md
```

## License

MIT
