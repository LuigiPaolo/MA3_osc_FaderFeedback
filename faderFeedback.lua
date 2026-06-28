-- Copyright (c) 2026 Luigi Paolo Favini
-- Plugin: Chataigne Fader Feedback for grandMA3
-- Licensed under the Apache License 2.0

local osc_line = 1        -- Your OSC line number
local update_rate = 0.05  -- 20Hz, optimal balance

local last_fader_values = {-1, -1, -1, -1, -1, -1, -1, -1}
local last_master_value = -1

local function FaderFeedbackLoop()
    while true do
        
        -- 1. FADER CONTROL
        for fader_index = 1, 8 do
            local exec_num = 200 + fader_index 
            local my_exec = GetExecutor(exec_num)
            
            local is_valid_fader = false
            local current_val = 0
            
            -- If the executor exists (even as a blank placeholder)
            if my_exec ~= nil then
                -- Use pcall to query the API safely and avoid crashes
                pcall(function()
                    -- The .Object property is nil if the executor has no assignments (e.g., Sequence)
                    if my_exec.Object ~= nil then
                        local fader_check = my_exec:GetFader({})
                        -- If it has a readable fader, it's valid
                        if fader_check ~= nil then
                            current_val = fader_check
                            is_valid_fader = true
                        end
                    end
                end)
            end
            
            if is_valid_fader then
                -- CASE A: The executor is ACTIVE and VALID
                if current_val ~= last_fader_values[fader_index] then
                    local osc_val = current_val / 100
                    Cmd(string.format('SendOSC %d "/xtouch/fader/%d,f,%.3f"', osc_line, fader_index, osc_val))
                    last_fader_values[fader_index] = current_val
                end
            else
                -- CASE B: The executor is EMPTY or unassigned (Page change to empty)
                -- If the physical fader isn't already at zero, lower it immediately
                if last_fader_values[fader_index] ~= 0 then
                    Cmd(string.format('SendOSC %d "/xtouch/fader/%d,f,0.000"', osc_line, fader_index))
                    last_fader_values[fader_index] = 0
                end
            end
        end
        
        -- 2. MASTER CONTROL (Fader 9)
        local master_obj = Root().ShowData.Masters.Grand.Master
        if master_obj ~= nil then
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

return FaderFeedbackLoop
