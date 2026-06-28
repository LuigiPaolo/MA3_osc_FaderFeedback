-- Plugin: Chataigne Fader Feedback (Solo OSC, Delta Tracking, Pagina Attiva)
-- Architettura ottimizzata per live: nessun traffico superfluo e zero conflitti MIDI.

local osc_line = 1        -- INSERISCI QUI la riga del tuo setup OSC in MA3 (es. 1, 2, 3...)
local update_rate = 0.05  -- 50 millisecondi (20Hz). Bilanciamento perfetto tra reattività e carico CPU

-- Tabelle per tracciare lo stato precedente. 
-- Inizializzate a -1 in modo che al primo avvio aggiornino subito i motori.
local last_fader_values = {-1, -1, -1, -1, -1, -1, -1, -1}
local last_master_value = -1

local function FaderFeedbackLoop()
    while true do
        
        -- 1. CONTROLLO DEGLI 8 FADER SULLA PAGINA ATTIVA
        for fader_index = 1, 8 do
            local exec_num = 200 + fader_index 
            
            -- GetExecutor(numero) restituisce l'esecutore sulla PAGINA ATTIVA. (Velocissimo)
            local my_exec = GetExecutor(exec_num)
            
            if my_exec ~= nil then
                -- Legge il valore attuale del fader (0 - 100)
                local current_val = my_exec:GetFader({}) 
                
                -- DELTA TRACKING: Invia l'OSC SOLO se il fader è stato mosso o è cambiata la pagina
                if current_val ~= last_fader_values[fader_index] then
                    
                    local osc_val = current_val / 100
                    -- Invia a Chataigne (es: /xtouch/fader/1,f,0.850)
                    Cmd(string.format('SendOSC %d "/xtouch/fader/%d,f,%.3f"', osc_line, fader_index, osc_val))
                    
                    -- Aggiorna la memoria
                    last_fader_values[fader_index] = current_val
                end
            else
                -- GESTIONE DEL VUOTO: Se cambi su una pagina dove l'esecutore è vuoto (nil), 
                -- il motore del fader deve andare a zero, ma solo una volta.
                if last_fader_values[fader_index] ~= 0 then
                    Cmd(string.format('SendOSC %d "/xtouch/fader/%d,f,0.0"', osc_line, fader_index))
                    last_fader_values[fader_index] = 0
                end
            end
        end
        
        -- 2. CONTROLLO DEL GRAND MASTER (Fader 9 sull'X-Touch)
        local master_obj = Root().ShowData.Masters.Grand.Master
        if master_obj ~= nil then
            local current_master = master_obj.NormedValue
            
            if current_master ~= last_master_value then
                local osc_val = current_master / 100
                -- Invia a Chataigne (es: /xtouch/master,f,0.500)
                Cmd(string.format('SendOSC %d "/xtouch/master,f,%.3f"', osc_line, osc_val))
                last_master_value = current_master
            end
        end

        -- Rilascia il thread per non bloccare il sistema (essenziale per la stabilità in live)
        coroutine.yield(update_rate) 
    end
end

return FaderFeedbackLoop
