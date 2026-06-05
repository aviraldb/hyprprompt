#!/usr/bin/env lua

-- HyprPrompt Lua API Tests
-- Run with: lua tests/test_lua_api.lua

local prompt = require("lua.init")
local socket = require("socket")

local tests_passed = 0
local tests_failed = 0
local test_errors = {}

-- Helper function to assert
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
        table.insert(test_errors, msg .. " - Expected true, got " .. tostring(value))
        return false
    end
    tests_passed = tests_passed + 1
    return true
end

local function assert_false(value, msg)
    if value then
        tests_failed = tests_failed + 1
        table.insert(test_errors, msg .. " - Expected false, got " .. tostring(value))
        return false
    end
    tests_passed = tests_passed + 1
    return true
end

local function assert_type(value, expected_type, msg)
    if type(value) ~= expected_type then
        tests_failed = tests_failed + 1
        table.insert(test_errors, msg .. " - Expected type: " .. expected_type .. " Got: " .. type(value))
        return false
    end
    tests_passed = tests_passed + 1
    return true
end

print("\n========== HyprPrompt Lua API Tests ==========\n")

-- Test 1: Module loads
print("[Test 1] Module loads")
assert_true(prompt ~= nil, "Prompt module should load")
assert_type(prompt, "table", "Prompt should be a table")
print("✓ Module loads\n")

-- Test 2: Initial state is IDLE
print("[Test 2] Initial state is IDLE")
assert_equal(prompt.get_state(), "IDLE", "Initial state should be IDLE")
assert_false(prompt.is_open(), "Prompt should not be open initially")
print("✓ Initial state is IDLE\n")

-- Test 3: API functions exist
print("[Test 3] API functions exist")
assert_type(prompt.show, "function", "prompt.show should be a function")
assert_type(prompt.poll, "function", "prompt.poll should be a function")
assert_type(prompt.get_state, "function", "prompt.get_state should be a function")
assert_type(prompt.is_open, "function", "prompt.is_open should be a function")
assert_type(prompt.shutdown, "function", "prompt.shutdown should be a function")
print("✓ All API functions exist\n")

-- Test 4: prompt.show requires table argument
print("[Test 4] prompt.show validates arguments")
local ok, err = pcall(function() prompt.show(nil) end)
assert_false(ok, "prompt.show(nil) should error")
local ok, err = pcall(function() prompt.show("string") end)
assert_false(ok, "prompt.show(string) should error")
print("✓ prompt.show validates arguments\n")

-- Test 5: prompt.show validates callbacks
print("[Test 5] prompt.show validates callbacks")
local ok, err = pcall(function()
    prompt.show({
        on_submit = "not a function"
    })
end)
assert_false(ok, "on_submit must be a function")
print("✓ prompt.show validates callbacks\n")

-- Test 6: prompt.show opens prompt
print("[Test 6] prompt.show opens prompt")
local result = prompt.show({
    placeholder = "test:",
    on_submit = function(text) end,
    on_cancel = function() end
})
assert_true(result, "prompt.show should return true")
assert_equal(prompt.get_state(), "OPEN", "State should be OPEN")
assert_true(prompt.is_open(), "Prompt should be open")
print("✓ prompt.show opens prompt\n")

-- Test 7: Can't open prompt twice
print("[Test 7] Can't open prompt twice")
local result = prompt.show({
    on_submit = function() end
})
assert_false(result, "Second prompt.show should return false")
print("✓ Can't open prompt twice\n")

-- Test 8: poll is non-blocking
print("[Test 8] poll is non-blocking")
local start = socket.gettime()
prompt.poll()
local elapsed = socket.gettime() - start
assert_true(elapsed < 0.1, "poll should be non-blocking (< 100ms)")
print("✓ poll is non-blocking\n")

-- Test 9: Shutdown works
print("[Test 9] Shutdown works")
prompt.shutdown()
print("✓ Shutdown works\n")

-- Print results
print("\n========== Test Results ==========\n")
print("Passed: " .. tests_passed)
print("Failed: " .. tests_failed)

if tests_failed > 0 then
    print("\nErrors:\n")
    for i, err in ipairs(test_errors) do
        print("  " .. i .. ". " .. err)
    end
    os.exit(1)
else
    print("\n✅ All tests passed!")
    os.exit(0)
end
