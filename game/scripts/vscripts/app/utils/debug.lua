
-- TODO: Log : trace, debug, info, warn, error, fatal
function Log(severity, section, ...) Debug(severity, section, ...) end

function Debug(section, ...)
    if not DEBUG_PRINT then return end
    if not DEBUG_PRINT_ALL and not DEBUG_PRINT_SECTIONS[section] then return end
    
    section = string.format("%17s ", section)
    print('['..section..'] ', ...)
end

-- For serious debugging.
DEBUG_ALL_CALLS = false
function DebugAllCalls()
    if not DEBUG_ALL_CALLS then
        print("Starting DebugCalls")
        DEBUG_ALL_CALLS = true

        debug.sethook(function(...)
            local info = debug.getinfo(2)
            local src = tostring(info.short_src)
            local name = tostring(info.name)
            if name ~= "__index" then
                print("Call: ".. src .. " -- " .. name .. " -- " .. info.currentline)
            end
        end, "c")
    else
        print("Stopped DebugCalls")
        DEBUG_ALL_CALLS = false
        debug.sethook(nil, "c")
    end
end
