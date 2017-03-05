--[[
    lua test.lua
    Run tests, does not require, and does not support game libraries.
]]

function Debug(mod, ...) print('['..mod..']',...) end

print('\n[Executing Tests]')

--function testOne()
--    print('TestOne')
--    local y = nil
--    y.n:test()
--end
--
--local status, err, rtn = xpcall(testOne, err2)
--if not status then print('[ERRORRROR]', err) end
--print('STATUS', status)
--print('RTN', rtn)
--print('ERR', err)
--print('ERR2', err2)
--
--do return end

-- Event Test
require('boot/event')

Event:Listen('TestEvent', function(event, params)
    -- event.preventDefault = true
    print('Callback One')
end)

Event:Listen('TestEvent', function(event, params)
    -- event.preventDefault = true
    print('Callback Two')
    local y = nil
    y.test:fail()
end)

Event:Listen('TestEvent', function(event, params)
    -- event.preventDefault = true
    print('Callback Three')
end)

local testReturn = Event:Trigger('TestEvent', {})

print('TR', testReturn)

print('')
