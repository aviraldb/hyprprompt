#!/usr/bin/env lua

-- HyprPrompt Integration Tests
-- Run with: lua tests/test_integration.lua
-- This test simulates the full flow of prompt.show -> Qt connection -> message

local prompt = require("lua.init")
local socket = require("socket")

local tests_passed = 0
local tests_failed = 0
local test_errors = {}

local function assert_equal(actual, expected, msg)
    if actual ~= expected then
        tests_failed = tests_failed + 1
        table.insert(test_errors, msg .. " - Expected: " .. tostring(expected) .. " Got: " .. tostring(actual))
        return false
    end
    tests_passed = tests_passed + 1
    return true
end

local function assert_true(value, msg)
    if not value then
        tests_failed = tests_failed + 1
        table.insert(test_errors, msg)
        return false
    end
    tests_passed = tests_passed + 1
    return true
end

print("\n========== HyprPrompt Integration Tests ==========\n")

-- Test 1: Socket communication flow
print("[Test 1] Socket communication setup")
local submitted_text = nil
local cancelled = false

local result = prompt.show({
    placeholder = "test:",
    on_submit = function(text)
        submitted_text = text
    end,
    on_cancel = function()
        cancelled = true
    end
})

assert_true(result, "prompt.show should succeed")
assert_equal(prompt.get_state(), "OPEN", "State should be OPEN")
print("✓ Socket setup complete\n")

-- Test 2: Simulate Qt frontend connection and message
print("[Test 2] Simulate Qt frontend SUBMIT message")

-- Connect as client
local client = socket.unix()
local ok, err = client:connect("/tmp/hyprprompt.sock")

if not ok then
    tests_failed = tests_failed + 1
    table.insert(test_errors, "Failed to connect to socket: " .. err)
    print("✗ Could not connect to socket")
else
    -- Send SUBMIT message
    client:send("SUBMIT:hello world\n")
    
    -- Poll to receive message
    prompt.poll()
    
    -- Check if callback was triggered
    assert_equal(submitted_text, "hello world", "on_submit should receive correct text")
    assert_equal(prompt.get_state(), "IDLE", "State should return to IDLE")
    
    client:close()
    print("✓ SUBMIT message received and processed\n")
end

-- Test 3: Cancel message
print("[Test 3] Simulate Qt frontend CANCEL message")
submitted_text = nil
cancelled = false

local result = prompt.show({
    placeholder = "test:",
    on_submit = function(text)
        submitted_text = text
    end,
    on_cancel = function()
        cancelled = true
    end
})

assert_true(result, "prompt.show should succeed")

-- Connect and send CANCEL
local client = socket.unix()
local ok, err = client:connect("/tmp/hyprprompt.sock")

if not ok then
    tests_failed = tests_failed + 1
    table.insert(test_errors, "Failed to connect to socket: " .. err)
    print("✗ Could not connect to socket")
else
    client:send("CANCEL\n")
    prompt.poll()
    
    assert_true(cancelled, "on_cancel should be triggered")
    assert_equal(submitted_text, nil, "on_submit should not be triggered")
    assert_equal(prompt.get_state(), "IDLE", "State should return to IDLE")
    
    client:close()
    print("✓ CANCEL message received and processed\n")
end

-- Test 4: Multiple prompts in sequence
print("[Test 4] Multiple prompts in sequence")
local seq_1 = nil
local seq_2 = nil

-- First prompt
prompt.show({
    on_submit = function(text) seq_1 = text end
})

local client1 = socket.unix()
if client1:connect("/tmp/hyprprompt.sock") then
    client1:send("SUBMIT:first\n")
    prompt.poll()
    client1:close()
end

assert_equal(seq_1, "first", "First prompt should receive text")
assert_equal(prompt.get_state(), "IDLE", "Should return to IDLE")

-- Second prompt
prompt.show({
    on_submit = function(text) seq_2 = text end
})

local client2 = socket.unix()
if client2:connect("/tmp/hyprprompt.sock") then
    client2:send("SUBMIT:second\n")
    prompt.poll()
    client2:close()
end

assert_equal(seq_2, "second", "Second prompt should receive text")
print("✓ Multiple prompts work in sequence\n")

-- Test 5: Whitespace handling
print("[Test 5] Message whitespace handling")
local ws_text = nil

prompt.show({
    on_submit = function(text)
        ws_text = text
    end
})

local client = socket.unix()
if client:connect("/tmp/hyprprompt.sock") then
    -- Send with extra whitespace
    client:send("SUBMIT:  text with spaces  \n")
    prompt.poll()
    client:close()
end

assert_equal(ws_text, "text with spaces", "Whitespace should be trimmed")
print("✓ Whitespace handling works\n")

-- Cleanup
prompt.shutdown()

-- Print results
print("\n========== Integration Test Results ==========\n")
print("Passed: " .. tests_passed)
print("Failed: " .. tests_failed)

if tests_failed > 0 then
    print("\nErrors:\n")
    for i, err in ipairs(test_errors) do
        print("  " .. i .. ". " .. err)
    end
    os.exit(1)
else
    print("\n✅ All integration tests passed!")
    os.exit(0)
end
