-- Plugin: Chataigne Fader Feedback v2.0 (Solo OSC, Delta Tracking, Ghost/Null Fix)
-- Fix implementato: Riconoscimento "esecutori fantasma" su pagine vuote

local osc_line = 1        -- La tua riga OSC
local update_rate = 0.05  -- 20Hz, bilanciamento ottimale

local last_fader_values = {-1, -1, -1, -1, -1, -1, -1, -1}
local last_master_value = -1

local function FaderFeedbackLoop()
    while true do
        
        -- 1. CONTROLLO FADER
        for fader_index = 1, 8 do
            local exec_num = 200 + fader_index 
            local my_exec = GetExecutor(exec_num)
            
            local is_valid_fader = false
            local current_val = 0
            
            -- Se l'esecutore esiste (anche come placeholder vuoto)
            if my_exec ~= nil then
                -- Usiamo pcall per interrogare l'API in modo blindato ed evitare crash
                pcall(function()
                    -- La proprietà .Object è nil se l'esecutore non ha assegnazioni (es. Sequence)
                    if my_exec.Object ~= nil then
                        local fader_check = my_exec:GetFader({})
                        -- Se ha un fader leggibile, allora è valido
                        if fader_check ~= nil then
                            current_val = fader_check
                            is_valid_fader = true
                        end
                    end
                end)
            end
            
            if is_valid_fader then
                -- CASO A: L'esecutore è PIENO e VALIDO
                if current_val ~= last_fader_values[fader_index] then
                    local osc_val = current_val / 100
                    Cmd(string.format('SendOSC %d "/xtouch/fader/%d,f,%.3f"', osc_line, fader_index, osc_val))
                    last_fader_values[fader_index] = current_val
                end
            else
                -- CASO B: L'esecutore è VUOTO o non assegnato (Cambio pagina su vuoto)
                -- Se il fader fisico non è già a zero, lo abbassa immediatamente
                if last_fader_values[fader_index] ~= 0 then
                    Cmd(string.format('SendOSC %d "/xtouch/fader/%d,f,0.000"', osc_line, fader_index))
                    last_fader_values[fader_index] = 0
                end
            end
        end
        
        -- 2. CONTROLLO MASTER (Fader 9)
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
