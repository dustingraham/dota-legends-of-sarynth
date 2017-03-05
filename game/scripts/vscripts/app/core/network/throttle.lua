---
--@type Throttle
Throttle = Throttle or class({})

-- Throttles a function call
-- Need to queue requests as well.
-- Throttle:Throttle(function() end)
--

-- Queue
-- https://www.lua.org/pil/11.4.html

---
--@function [parent=#Throttle] Throttle
--@param self
--@param #function callback
function Throttle:Throttle(callback)
    callback()
end
