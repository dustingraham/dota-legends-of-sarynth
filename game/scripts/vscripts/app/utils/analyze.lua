---
--@author Sarynth
--
-- Developed to test watch the explosive table growth. Beyond the initial load, there's not much increase...
--

-- In Boot:Activate I had added...
--Timers(function()
--    AnalyzeReal()
--    return 0.2
--end)

-- Not currently included in requires, so this isn't doing anything atm.

recursivePreviousCount = 0
recursivePreviousValue = 0
recursiveCount = 0
recursiveValue = 0

function AnalyzeRecursive(t, seen)
    for k,v in pairs(t) do
        if k ~= 'GameItems' then
            if type(v) == 'table' then
                if not seen[v] then
                    seen[v] = 1
                    recursiveCount = recursiveCount + 1
                    AnalyzeRecursive(v, seen)
                else
                    seen[v] = seen[v] + 1
                end
            else
                recursiveValue = recursiveValue + 1
            end
        end
    end
end
function Analyze(t)
    local seen =  {}

    recursiveCount = 0
    recursiveValue = 0

    AnalyzeRecursive(t, seen)

    local diffCount = recursiveCount - recursivePreviousCount
    local diffValue = recursiveValue - recursivePreviousValue

    if diffCount ~= 0 or diffValue ~= 0 then
        print(diffCount, diffValue, recursiveCount, recursiveValue)
    end

    recursivePreviousCount = recursiveCount
    recursivePreviousValue = recursiveValue
    --print(seen)
    --DeepPrintTable(seen)
end

function AnalyzeTest()
    local recurse = {
        test = {
            yes = 3,
            no = 5,
            maybe = {}
        }
    }
    local x = {
        y = true,
        z = {
            b = yes,
        },
        p = recurse
    }
    recurse.x = x

    --print(x)
    --DeepPrintTable(x)
    Analyze(x)
end
function AnalyzeReal()
    Analyze(package.loaded)
end
--AnalyzeTest()
AnalyzeReal()
