# HyprPrompt Architecture

## Overview

```
┌──────────────────────────┐
│        HyprLua           │
│                          │
│   prompt.show()          │
│   on_submit()            │
│   on_cancel()            │
│                          │
└───────────┬──────────────┘
            │
            │ Unix Domain Socket
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

## State Machine

```
IDLE
  ↓
OPEN (prompt.show() called)
  ├─→ SUBMIT (user presses Enter)
  │     ↓
  │   Lua: on_submit(text)
  │     ↓
  │   IDLE
  │
  └─→ CANCEL (user presses Escape)
      ↓
    Lua: on_cancel()
      ↓
    IDLE
```

## Communication Protocol

### Simple, non-JSON IPC

**Submit message:**
```
SUBMIT:hello world
```

**Cancel message:**
```
CACEL
```

## Component Breakdown

### 1. Lua Core (`lua/init.lua`)

**Responsibilities:**
- Store callbacks (on_submit, on_cancel)
- Launch Qt frontend process
- Listen on Unix socket for IPC messages
- Trigger callbacks

**API Surface:**
```lua
prompt.show(opts)
```

**Does NOT:**
- Parse commands
- Execute anything
- Know about workspaces/windows
- Block execution

### 2. Qt/QML Frontend (`ui/`)

**Responsibilities:**
- Create native Wayland window
- Capture keyboard input
- Render prompt UI
- Send text to Lua via IPC

**Key Files:**
- `main.cpp` - Qt application entry point
- `main.h` - PromptWindow class
- `Main.qml` - QML UI layout

**Does NOT:**
- Know about Hyprland commands
- Execute anything
- Interpret input

### 3. IPC Layer (`ipc/`)

**Responsibilities:**
- Unix domain socket communication
- Message serialization
- Connection handling

**Key Files:**
- `socket.h/.cpp` - Socket implementation

## Window Properties

**Wayland Native:**
- Borderless
- Floating
- Always on top
- Focusable
- Transparent

**Hyprland Rules (user-configurable):**
```ini
windowrulev2 = float,class:^hyprprompt$
windowrulev2 = size 600 80,class:^hyprprompt$
windowrulev2 = center,class:^hyprprompt$
windowrulev2 = blur,class:^hyprprompt$
windowrulev2 = noborder,class:^hyprprompt$
```

## Non-Blocking Design

**Key Principles:**

1. **No blocking calls**
   - No `io.read()`
   - No `while waiting do end`
   - No synchronous waits

2. **Event-driven**
   - Callbacks for completion
   - Async IPC messages
   - Compositor continues rendering

3. **Stateless from compositor perspective**
   - Launch UI
   - Wait for message
   - Execute callback
   - Done

## Implementation Phases

### MVP (Phase 1)
- ✅ Lua API
- ✅ Qt window creation
- ✅ Input capture (Enter/Escape)
- ✅ IPC protocol
- ✅ Rounded corners
- ✅ Transparency
- ✅ Placeholder text

### Phase 2
- Blur effect
- Fade in/out animations
- Smooth scaling

### Phase 3
- Theme API
- Icon support
- Command preview
- Suggestions list

## Error Handling

- Only one prompt at a time (IDLE → OPEN → SUBMIT/CANCEL → IDLE)
- Invalid options raise errors
- Socket connection failures logged
- Graceful degradation if Qt unavailable
