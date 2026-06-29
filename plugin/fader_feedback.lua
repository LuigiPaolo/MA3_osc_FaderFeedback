-- Copyright (c) 2026 Luigi Paolo Favini
-- Plugin: Chataigne Full Console Feedback for grandMA3
-- Licensed under the Apache License 2.0

local osc_line = 1        -- Your OSC line number
local update_rate = 0.05  -- 20Hz, optimal balance

-- Dynamic table to store the last sent state for all executors
local last_state = {}
local last_master_value = -1
local enabled = false     -- Loop control variable

-- Helper function to process any executor dynamically
local function CheckExecutor(exec_num, has_level)
    -- GetExecutor is an Object-Free API function
    local my_exec = GetExecutor(exec_num)
    
    local is_valid = false
    local current_level_val = 0
    local current_key_val = 0  -- 0 = off, 1 = on
    
    -- Initialize state memory for this executor if it doesn't exist yet
    if not last_state[exec_num] then 
        last_state[exec_num] = { level = -1, key = -1 } 
    end
    local state = last_state[exec_num]
    
    -- Use IsObjectValid (Object-Free API) to verify the pointer hasn't been freed
    if IsObjectValid(my_exec) then
        -- pcall to safely query the API without crashing
        pcall(function()
            local assigned_obj = my_exec.Object
            
            -- Validate the assigned object (e.g. Sequence) still exists in the MA database
            if IsObjectValid(assigned_obj) then
                
                -- 1. Level Reading (Fader or Encoder)
                if has_level then
                    local level_check = my_exec:GetFader({})
                    if level_check ~= nil then
                        current_level_val = level_check
                        is_valid = true
                    end
                else
                    -- If it's a key-only executor (e.g., 1xx row), having a valid Object is enough
                    is_valid = true
                end
                
                -- 2. Playback State Reading (Key/LED status)
                if assigned_obj:HasActivePlayback() then
                    current_key_val = 1
                end
            end
        end)
    end
    
    if is_valid then
        -- CASE A: Executor is assigned and valid
        
        -- Update Fader/Encoder position if changed
        if has_level and current_level_val ~= state.level then
            local osc_val = current_level_val / 100
            Cmd(string.format('SendOSC %d "/xtouch/exec/%d/fader,f,%.3f"', osc_line, exec_num, osc_val))
            state.level = current_level_val
        end
        
        -- Update Key LED status if changed
        if current_key_val ~= state.key then
            Cmd(string.format('SendOSC %d "/xtouch/exec/%d/key,i,%d"', osc_line, exec_num, current_key_val))
            state.key = current_key_val
        end

    else
        -- CASE B: Executor is empty or invalid (e.g., user changed page)
        
        -- Pull down the physical fader/encoder on the controller
        if has_level and state.level ~= 0 then
            Cmd(string.format('SendOSC %d "/xtouch/exec/%d/fader,f,0.000"', osc_line, exec_num))
            state.level = 0
        end
        
        -- Turn off the physical LED on the controller
        if state.key ~= 0 then
            Cmd(string.format('SendOSC %d "/xtouch/exec/%d/key,i,0"', osc_line, exec_num))
            state.key = 0
        end
    end
end

local function FeedbackLoop()
    while enabled do
        
        -- Loop through columns 1 to 15
        for col = 1, 15 do
            -- Row 100 (Keys only, no level reading)
            CheckExecutor(100 + col, false)
            
            -- Row 200 (Faders + Keys)
            CheckExecutor(200 + col, true)
            
            -- Row 300 (Encoders + Keys)
            CheckExecutor(300 + col, true)
            
            -- Row 400 (Encoders + Keys)
            CheckExecutor(400 + col, true)
        end
        
        -- MASTER CONTROL (Grand Master)
        local master_obj = Root().ShowData.Masters.Grand.Master
        -- Check validity before reading the property
        if IsObjectValid(master_obj) then
            local current_master = master_obj.NormedValue
            if current_master ~= last_master_value then
                local osc_val = current_master / 100
                Cmd(string.format('SendOSC %d "/xtouch/master,f,%.3f"', osc_line, osc_val))
                last_master_value = current_master
            end
        end

        coroutine.yield(update_rate) 
    end
end

-- Toggle function to cleanly start and stop the loop
local function maintoggle() 
    if enabled then
        enabled = false
        Echo("Chataigne Feedback: STOPPED")
    else
        enabled = true
        Echo("Chataigne Feedback: STARTED")
        -- Clear memory to force immediate state update for all items on start
        last_state = {}
        last_master_value = -1
        FeedbackLoop()
    end
end

return maintoggle
