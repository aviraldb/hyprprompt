# HyprPrompt Development Roadmap

## MVP (v0.1)

### Lua Core
- [ ] Implement `prompt.show(opts)` API
- [ ] Unix socket server setup
- [ ] IPC message parsing (SUBMIT, CANCEL)
- [ ] Callback storage and execution
- [ ] State machine (IDLE → OPEN → SUBMIT/CANCEL)
- [ ] Error handling

### Qt/QML Frontend
- [ ] Wayland native window
- [ ] QML layout with text input
- [ ] Keyboard input capture (Enter to submit, Escape to cancel)
- [ ] IPC client connection
- [ ] Send SUBMIT:text and CANCEL messages
- [ ] Window positioning (centered)
- [ ] Basic styling (rounded corners, transparency)

### IPC Layer
- [ ] Unix domain socket implementation
- [ ] Message serialization
- [ ] Connection handling
- [ ] Error recovery

### Testing
- [ ] Basic integration test
- [ ] Manual testing on Hyprland

### Documentation
- [ ] README
- [ ] Architecture guide
- [ ] Build instructions
- [ ] Usage examples

## Phase 2 (v0.2)

### Visual Polish
- [ ] Blur background effect
- [ ] Fade in animation
- [ ] Fade out animation
- [ ] Smooth scaling

### Lua Enhancements
- [ ] Timeout support
- [ ] Multiple prompt instances (queue)
- [ ] Custom placeholder styling hints

### Testing
- [ ] Animation tests
- [ ] Performance testing

## Phase 3 (v0.3)

### Advanced Features
- [ ] Theme API
- [ ] Icon support in prompt
- [ ] Command preview area
- [ ] Suggestions list
- [ ] History navigation (up/down arrows)
- [ ] Custom keybindings

### Lua Enhancements
- [ ] Validation callbacks
- [ ] Transform callbacks
- [ ] History API

### Documentation
- [ ] Theme API docs
- [ ] Plugin development guide
- [ ] Example plugins

## Beyond

- Fuzzy finder integration
- Database of commands/suggestions
- Performance optimization
- Platform-specific testing
- Community contributions
