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
local _state = "IDLE"
local _callbacks = {}
local _socket = nil
local _ui_process = nil

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
-- Sets up socket listener
local function init()
    -- TODO: Setup Unix domain socket listener
    -- Listen for SUBMIT:text and CANCEL messages from Qt frontend
end

--- Handle IPC message from Qt frontend
-- @param message string - IPC message ("SUBMIT:text" or "CANCEL")
local function handle_message(message)
    if message:sub(1, 7) == "SUBMIT:" then
        local text = message:sub(8)
        if _callbacks.on_submit then
            _callbacks.on_submit(text)
        end
        _state = STATE.IDLE
        _callbacks = {}
    elseif message == "CANCEL" then
        if _callbacks.on_cancel then
            _callbacks.on_cancel()
        end
        _state = STATE.IDLE
        _callbacks = {}
    end
end

--- Show the prompt
-- @param opts table - Options table
--   - placeholder (string): Placeholder text
--   - on_submit (function): Callback when user submits (receives text)
--   - on_cancel (function): Callback when user cancels
function prompt.show(opts)
    -- Validate state
    if _state ~= STATE.IDLE then
        print("[HyprPrompt] Prompt already open")
        return
    end
    
    -- Validate options
    if not opts or type(opts) ~= "table" then
        error("[HyprPrompt] opts must be a table")
    end
    
    -- Store callbacks
    _callbacks = {
        on_submit = opts.on_submit,
        on_cancel = opts.on_cancel
    }
    
    -- Store placeholder (pass to Qt frontend)
    local placeholder = opts.placeholder or ""
    
    -- Launch Qt frontend
    -- TODO: Start Qt process with placeholder parameter
    -- TODO: Send placeholder via IPC or command line arg
    
    _state = STATE.OPEN
end

-- Initialize on module load
init()

return prompt
