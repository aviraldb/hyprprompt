-- HyprPrompt - Non-blocking command prompt module for HyprLua
-- 
-- Usage:
--   local prompt = require("hyprprompt")
--   prompt.show({
--       placeholder = "Enter text...",
--       on_submit = function(text) end,
--       on_cancel = function() end
--   })

local prompt = {}
local socket = require("socket")

local _state = "IDLE"
local _callbacks = {}
local _server_socket = nil
local _client_socket = nil
local _ui_process = nil
local _pending_messages = {}  -- Buffer for multi-line messages

-- IPC Socket path
local SOCKET_PATH = "/tmp/hyprprompt.sock"

-- State machine
local STATE = {
    IDLE = "IDLE",
    OPEN = "OPEN",
    SUBMIT = "SUBMIT",
    CANCEL = "CANCEL"
}

--- Initialize the prompt module
-- Sets up Unix domain socket listener
local function init()
    -- Remove old socket file if it exists
    os.remove(SOCKET_PATH)
    
    -- Create Unix domain socket server
    _server_socket = socket.unix()
    
    -- Bind to socket path
    local ok, err = _server_socket:bind(SOCKET_PATH)
    if not ok then
        print("[HyprPrompt] Failed to bind socket: " .. err)
        return false
    end
    
    -- Listen for connections (backlog of 1)
    local ok, err = _server_socket:listen(1)
    if not ok then
        print("[HyprPrompt] Failed to listen on socket: " .. err)
        return false
    end
    
    -- Set socket to non-blocking mode
    _server_socket:settimeout(0)
    
    print("[HyprPrompt] Socket listener initialized at " .. SOCKET_PATH)
    return true
end

--- Accept incoming connection from Qt frontend
-- Non-blocking, returns immediately if no connection available
local function accept_connection()
    if not _server_socket then
        return false
    end
    
    local client, err = _server_socket:accept()
    
    if client then
        -- Set client socket to non-blocking
        client:settimeout(0)
        _client_socket = client
        print("[HyprPrompt] Client connected")
        return true
    end
    
    return false
end

--- Read message from client socket
-- Non-blocking, returns nil if no data available
-- Handles newline-terminated messages
local function read_message()
    if not _client_socket then
        return nil
    end
    
    -- Try to read a line (terminated by \n)
    local data, err = _client_socket:receive("*l")
    
    if data then
        -- Successfully read a complete line
        return data
    elseif err == "closed" then
        -- Client disconnected
        _client_socket:close()
        _client_socket = nil
        print("[HyprPrompt] Client disconnected")
        return nil
    elseif err == "timeout" then
        -- No data available (non-blocking)
        return nil
    else
        print("[HyprPrompt] Socket error: " .. err)
        if _client_socket then
            _client_socket:close()
            _client_socket = nil
        end
        return nil
    end
end

--- Poll for IPC messages
-- Should be called regularly from HyprLua event loop
-- Non-blocking, returns immediately
local function poll()
    -- Try to accept new connection if state is OPEN
    if _state == STATE.OPEN and not _client_socket then
        accept_connection()
    end
    
    -- Try to read message from client
    local message = read_message()
    if message then
        handle_message(message)
    end
end

--- Handle IPC message from Qt frontend
-- @param message string - IPC message ("SUBMIT:text" or "CANCEL")
local function handle_message(message)
    -- Trim whitespace
    message = message:gsub("^%s+", ""):gsub("%s+$", "")
    
    if message:sub(1, 7) == "SUBMIT:" then
        local text = message:sub(8)  -- Extract text after "SUBMIT:"
        if _callbacks.on_submit then
            _callbacks.on_submit(text)
        end
        _state = STATE.IDLE
        _callbacks = {}
        
        -- Close client connection
        if _client_socket then
            _client_socket:close()
            _client_socket = nil
        end
        
        print("[HyprPrompt] Submitted: " .. text)
        
    elseif message == "CANCEL" then
        if _callbacks.on_cancel then
            _callbacks.on_cancel()
        end
        _state = STATE.IDLE
        _callbacks = {}
        
        -- Close client connection
        if _client_socket then
            _client_socket:close()
            _client_socket = nil
        end
        
        print("[HyprPrompt] Cancelled")
    else
        print("[HyprPrompt] Unknown message: " .. message)
    end
end

--- Launch Qt frontend process
-- @param placeholder string - Placeholder text to display
local function launch_ui(placeholder)
    -- Build command to launch Qt frontend
    local cmd = "hyprprompt"
    
    -- Pass placeholder as command line argument
    if placeholder and placeholder ~= "" then
        cmd = cmd .. " --placeholder '" .. placeholder .. "'"
    end
    
    -- Launch in background, suppress output
    local ok = os.execute(cmd .. " > /dev/null 2>&1 &")
    if not ok then
        print("[HyprPrompt] Failed to launch UI")
        return false
    end
    
    print("[HyprPrompt] UI process launched with placeholder: " .. (placeholder or "default"))
    return true
end

--- Show the prompt
-- @param opts table - Options table
--   - placeholder (string): Placeholder text
--   - on_submit (function): Callback when user submits (receives text)
--   - on_cancel (function): Callback when user cancels
-- @return boolean - true if prompt was shown, false if already open
function prompt.show(opts)
    -- Validate state
    if _state ~= STATE.IDLE then
        print("[HyprPrompt] Prompt already open")
        return false
    end
    
    -- Validate options
    if not opts or type(opts) ~= "table" then
        error("[HyprPrompt] opts must be a table")
    end
    
    -- Validate callbacks are functions if provided
    if opts.on_submit and type(opts.on_submit) ~= "function" then
        error("[HyprPrompt] on_submit must be a function")
    end
    if opts.on_cancel and type(opts.on_cancel) ~= "function" then
        error("[HyprPrompt] on_cancel must be a function")
    end
    
    -- Store callbacks
    _callbacks = {
        on_submit = opts.on_submit,
        on_cancel = opts.on_cancel
    }
    
    -- Get placeholder text
    local placeholder = opts.placeholder or ""
    
    -- Update state
    _state = STATE.OPEN
    
    -- Launch Qt frontend
    if not launch_ui(placeholder) then
        _state = STATE.IDLE
        _callbacks = {}
        return false
    end
    
    print("[HyprPrompt] Waiting for input...")
    return true
end

--- Get current state
-- @return string - Current state (IDLE, OPEN, SUBMIT, or CANCEL)
function prompt.get_state()
    return _state
end

--- Check if prompt is open
-- @return boolean - true if prompt is currently open
function prompt.is_open()
    return _state == STATE.OPEN
end

--- Cleanup and shutdown
function prompt.shutdown()
    if _client_socket then
        _client_socket:close()
        _client_socket = nil
    end
    if _server_socket then
        _server_socket:close()
        _server_socket = nil
    end
    os.remove(SOCKET_PATH)
    print("[HyprPrompt] Shutdown complete")
end

-- Export poll function for event loop integration
prompt.poll = poll

-- Initialize on module load
init()

return prompt
