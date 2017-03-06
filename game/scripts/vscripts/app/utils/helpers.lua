--[[
    Utility Functions for RPG
    Author: Sarynth
]]

-- Table Merge t2 into t1.
function TableMerge(t1, t2)
    for k, v in pairs(t2) do
        if (type(v) == "table") then
            if (type(t1[k] or false) ~= "table") then
                -- Prevent referencing
                t1[k] = {}
            end
            TableMerge(t1[k], t2[k]) -- TODO just use v?
        else
            t1[k] = v
        end
    end
end

-- String Split
-- maxNb 0 for no limit.
function Split(str, delim, maxNb)
    delim = delim or ','
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end

-- Used by barebones libs.
function PrintTable(table)
    Debug('PrintTable', inspect(table))
end
