--[[

Simple Event

Event:Listen(eventName, function() print('Callback') end)

Event:Listen(eventName, function(self, event, params) print('Callback:',params.param) end, instance)

Event:Listen(eventName, Dynamic_Wrap(Event, 'OnEvent'), Event)

Event:Trigger(eventName, params)

]]
---
--@type Event
Event = Event or {}

---
--@function [parent=#Event] Listen
--@param self
--@param #string eventName
--@param #function callback
--@param #table context
function Event:Listen(eventName, callback, context)
    if not self.events then self.events = {} end
    if not self.events[eventName] then self.events[eventName] = {} end
    table.insert(self.events[eventName], { context = context, callback = callback })
end

-- Useful reference.
-- https://github.com/bmddota/barebones/blob/source2/game/dota_addons/barebones/scripts/vscripts/libraries/timers.lua


---
--@function [parent=#Event] Trigger
--@param self
--@param #string eventName
--@param #table params
function Event:Trigger(eventName, params)
    -- Debug('Event', 'Trigger', eventName)
    if not self.events or not self.events[eventName] then return end
    
    local event = {
        preventDefault = false,
        eventName = eventName,
        params = params
    }
    local status, nextCall
    for _,table in ipairs(self.events[eventName]) do
        
        if table.context then
            status, nextCall = xpcall(function()
                return table.callback(table.context, event, params)
            end,
            function (msg)
                return msg..'\n'..debug.traceback()..'\n'
            end)
        else
            status, nextCall = xpcall(function()
                return table.callback(event, params)
            end,
            function (msg)
                return msg..'\n'..debug.traceback()..'\n'
            end)
        end
        
        if status then
            -- Check return value (err)
            -- - nil or true : continue
            -- - false : stop executing
            if nextCall == false or event.preventDefault then
                -- Explicitly cancelled, bail out.
                return false
            end
        else
            -- Status was false, error occurred
            Debug('Event', '[ERROR] Callback', nextCall)
            
            -- Continue executing event callbacks.
        end
    end
    
    -- All good
    return true
end


-- Event:Listen('testing', function() print('Callback') end)

-- Event:Listen('testing', function(self, params)
--     print('Callbacking 1 for',params.name)
-- end)

-- Event:Listen('testing', function(self, params)
--     print('Callbacking 2 for',params.name)
-- end)

-- function Event:Test(params)
--     print('Callback from Event:Test with ',params.name)
-- end

-- Event:Listen('testing', Dynamic_Wrap(Event, 'Test'), Event)

-- ListenToGameEvent('entity_killed', Dynamic_Wrap(Drops, 'OnEntityKilled'), Drops)

-- Event:Trigger('testing', { name = 'yes' })
-- Event:Trigger('testing2', { name = 'yes' })

