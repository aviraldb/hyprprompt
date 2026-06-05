# HyprPrompt

A **non-blocking, generic command prompt module for HyprLua**.

Openachat interface for requesting user input in Hyprland without blocking the compositor.

## Features

- ✨ **Non-blocking** - Event-driven, callback-based API
- 🎯 **Generic** - No built-in command parsing or execution
- 🎨 **Beautiful** - Qt/QML powered with rounded corners, transparency, blur
- 🔌 **Modular** - Reusable prompt API for any HyprLua module
- ⚡ **Lightweight** - Minimal dependencies
- 🪟 **Wayland Native** - Works seamlessly with Hyprland

## Quick Start

### Installation

**Prerequisites:**
- HyprLua
- Qt 6
- CMake 3.16+
- Lua 5.1+ with LuaSocket

**Build:**
```bash
git clone https://github.com/aviraldb/hyprprompt.git
cd hyprprompt
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)
sudo make install
```

See [QT_BUILD.md](QT_BUILD.md) for detailed build instructions.

### Basic Usage

```lua
local prompt = require("hyprprompt")

-- Show a prompt
prompt.show({
    placeholder = "Enter command:",
    
    on_submit = function(text)
        print("You entered: " .. text)
    end,
    
    on_cancel = function()
        print("User cancelled")
    end
})

-- Call this regularly in your HyprLua event loop
prompt.poll()
```

## Architecture

```
┌──────────────────────────┐
│        HyprLua           │
│                          │
│   prompt.show()          │
│   prompt.poll()          │
│   on_submit()            │
│   on_cancel()            │
│                          │
└───────────┬──────────────┘
            │
            │ Unix Socket
            │ /tmp/hyprprompt.sock
            │
┌───────────▼──────────────┐
│      Qt/QML Frontend     │
│                          │
│   - Window Management    │
│   - Input Capture        │
│   - Rendering            │
│   - Animations           │
│                          │
└──────────────────────────┘
```

### Components

1. **Lua Core** (`lua/init.lua`) - API, callbacks, socket listener
2. **Qt/QML UI** (`ui/`) - Window, input, rendering
3. **IPC Layer** - Unix domain socket with simple protocol

## Advanced Usage

### HyprLua Integration

In your `hyprland.conf` or HyprLua config:

```lua
local prompt = require("hyprprompt")

-- Bind SUPER + : to open prompt
bind("SUPER", ":", function()
    prompt.show({
        placeholder = ":",
        on_submit = function(cmd)
            print("Command: " .. cmd)
            -- Your command handling here
        end
    })
end)

-- Poll in event loop (adjust timing as needed)
hyprland.on_tick = function()
    prompt.poll()
end
```

### Custom Placeholders

```lua
prompt.show({
    placeholder = "Search files...",
    on_submit = function(query)
        -- Search logic
    end
})
```

### State Checking

```lua
-- Check if prompt is open
if prompt.is_open() then
    print("Prompt is currently open")
end

-- Get current state
local state = prompt.get_state()
print("State: " .. state)  -- IDLE, OPEN, SUBMIT, or CANCEL
```

## IPC Protocol

### Message Format

**Submit:**
```
SUBMIT:hello world\n
```

**Cancel:**
```
CANCEL\n
```

Messages are newline-terminated and received via Unix domain socket at `/tmp/hyprprompt.sock`.

## Window Customization

### Hyprland Window Rules

You can apply standard Hyprland rules to the prompt window:

```ini
# hyprland.conf
windowrulev2 = float,class:^hyprprompt$
windowrulev2 = size 600 80,class:^hyprprompt$
windowrulev2 = center,class:^hyprprompt$
windowrulev2 = blur,class:^hyprprompt$
windowrulev2 = noborder,class:^hyprprompt$
```

### Theme

Window uses Catppuccin Mocha theme:
- Background: `#1e1e2e` (Crust)
- Text: `#cdd6f4` (Text)
- Accent: `#89b4fa` (Blue)
- Border: `#45475a` (Surface0)

## API Reference

### `prompt.show(opts)`

Show the prompt window.

**Arguments:**
- `opts` (table) - Configuration table
  - `placeholder` (string, optional) - Placeholder text in input field
  - `on_submit` (function, optional) - Callback when user submits
    - Receives: `text` (string) - User input
  - `on_cancel` (function, optional) - Callback when user cancels

**Returns:** `boolean` - true if prompt was shown, false if already open

**Example:**
```lua
prompt.show({
    placeholder = "Search:",
    on_submit = function(text)
        print("Searching for: " .. text)
    end,
    on_cancel = function()
        print("Search cancelled")
    end
})
```

### `prompt.poll()`

Poll for IPC messages from the Qt frontend. Non-blocking.

**Must be called regularly** in your HyprLua event loop or a separate thread.

**Example:**
```lua
-- Call this in your event loop
for i = 1, 100 do
    prompt.poll()
    socket.sleep(0.01)  -- Sleep 10ms between polls
end
```

### `prompt.is_open()`

Check if prompt is currently open.

**Returns:** `boolean` - true if open, false if idle

### `prompt.get_state()`

Get current prompt state.

**Returns:** `string` - One of: `IDLE`, `OPEN`, `SUBMIT`, `CANCEL`

### `prompt.shutdown()`

Cleanup and shutdown. Closes sockets and removes temporary files.

**Example:**
```lua
-- On config reload or exit
hyprland.on_exit = function()
    prompt.shutdown()
end
```

## Non-Blocking Design

HyprPrompt is designed to **never block** the Hyprland compositor:

1. **Event-driven callbacks** - No waiting or polling loops
2. **Non-blocking sockets** - Immediate return if no data
3. **Async window launch** - Qt process spawned in background
4. **Compositor continues** - Never interrupts rendering

## Troubleshooting

### "Failed to bind socket"
- Check `/tmp/hyprprompt.sock` doesn't exist or is stale
- Try: `rm /tmp/hyprprompt.sock`

### Qt window doesn't appear
- Ensure Qt 6 is installed: `pkg-config --cflags-only-I Qt6Core`
- Check logs: `journalctl -xe`
- Run with debug output: `hyprprompt 2>&1 | grep HyprPrompt`

### No socket connection
- Verify Lua module is loaded: `prompt.get_state()` should return `IDLE`
- Check socket exists: `ls -la /tmp/hyprprompt.sock`
- Ensure `prompt.poll()` is being called regularly

### Messages not received
- Make sure to call `prompt.poll()` in event loop
- Check Lua socket (`luasocket` or `socket` package) is installed
- Verify both processes are running: `ps aux | grep hyprprompt`

## Development

### Project Structure

```
hyprprompt/
├── lua/
│   └── init.lua           # Main Lua API
├── ui/
│   ├── main.h             # Qt C++ header
│   ├── main.cpp           # Qt C++ implementation
│   ├── Main.qml           # QML UI definition
│   └── resources.qrc      # Qt resource file
├── ipc/
│   ├── socket.h           # IPC socket header
│   └── socket.cpp         # IPC socket implementation
├── tests/
│   ├── test_lua_api.lua   # Lua API tests
│   └── test_integration.lua # Integration tests
├── CMakeLists.txt         # Build configuration
├── QT_BUILD.md            # Qt build guide
├── ARCHITECTURE.md        # Architecture documentation
├── ROADMAP.md             # Development roadmap
└── README.md              # This file
```

### Building from Source

See [QT_BUILD.md](QT_BUILD.md) for detailed instructions.

### Running Tests

```bash
lua tests/test_lua_api.lua
lua tests/test_integration.lua
```

## Roadmap

### MVP (v0.1) ✅
- [x] Lua API skeleton
- [x] Unix socket IPC
- [x] Qt/QML frontend
- [x] Keyboard input capture
- [x] Build system

### Phase 2 (v0.2)
- [ ] Blur effect
- [ ] Fade animations
- [ ] Timeout support
- [ ] Multiple instance queueing

### Phase 3 (v0.3)
- [ ] Theme API
- [ ] Command history
- [ ] Suggestions dropdown
- [ ] Custom keybindings

## License

MIT - See LICENSE file

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## Support

For issues and feature requests, please open a GitHub issue.
