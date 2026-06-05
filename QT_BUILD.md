# Qt Build Instructions for HyprPrompt

## Prerequisites

### Arch Linux
```bash
sudo pacman -S qt6-base qt6-declarative qt6-wayland cmake
```

### Ubuntu/Debian
```bash
sudo apt install qt6-base-dev qt6-declarative-dev qt6-wayland-dev cmake
```

### Fedora
```bash
sudo dnf install qt6-qtbase-devel qt6-qtdeclarative-devel qt6-qtwayland-devel cmake
```

## Build

### From source
```bash
# Clone and navigate to repo
cd hyprprompt

# Create build directory
mkdir build
cd build

# Configure with CMake
cmake -DCMAKE_BUILD_TYPE=Release ..

# Build
make -j$(nproc)

# Install (optional)
sudo make install
```

### Run binary
```bash
# If installed:
hyprprompt

# If built locally:
./build/hyprprompt
```

### Test with Lua socket

1. First, start a simple Lua listener:
```bash
# In terminal 1, create a test listener
lua << 'EOF'
local socket = require("socket")
socket.remove("/tmp/hyprprompt.sock")
local server = socket.unix()
server:bind("/tmp/hyprprompt.sock")
server:listen(1)
print("Listening on /tmp/hyprprompt.sock...")
while true do
  local client = server:accept()
  if client then
    print("Client connected")
    local msg = client:receive("*l")
    if msg then
      print("Received:", msg)
    end
    client:close()
  end
  socket.sleep(0.1)
end
EOF
```

2. Then run the Qt app in another terminal:
```bash
# In terminal 2
./build/hyprprompt
```

3. Type something and press Enter - you should see it printed in terminal 1

## Troubleshooting

### "Qt components not found"
Ensure Qt6 development files are installed. Check:
```bash
pkg-config --cflags-only-I Qt6Core
```

### CMake can't find Qt6
Specify Qt6 path:
```bash
cmake -DQt6_DIR=/usr/lib/cmake/Qt6 ..
```

### QML loading fails
Ensure `ui/Main.qml` is in the repo and `ui/resources.qrc` references it correctly.

### Socket connection fails
- Check that Lua socket listener is running
- Verify socket path: `/tmp/hyprprompt.sock`
- Check permissions: `ls -la /tmp/hyprprompt.sock`

## Development

### Editing QML
- Edit `ui/Main.qml` directly
- Rebuild with `make` (will auto-recompile QML resources)

### Adding C++ features
- Edit `ui/main.h` and `ui/main.cpp`
- Rebuild with `make`

### Debug output
Qt debug output goes to stdout:
```bash
./build/hyprprompt 2>&1 | grep HyprPrompt
```
