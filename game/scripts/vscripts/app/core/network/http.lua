---
--@type Http
Http = Http or class({})

-- Http:Save({experience = 3000,level=99,items={'red_fish','blue_fish'}}, function(data)
--     print('Successfully saved!')
--     Http:Load(function(data)
--         print('Load Called Back')
--         DeepPrintTable(data)
--     end)
-- end)

---
--@function [parent=#Http] SendExample
--@param self
--@param #string data
function Http:SendExample(data)
    
    local settings = {
        host = 'http://requestb.in/1c7am4o1'
    }
    
    local payload = {
        alpha = 'beta',
        gamma = 'normal'
    }
    local json = json.encode(payload)
    print(json)
    
    local request = CreateHTTPRequest('POST', settings.host)
    request:SetHTTPRequestRawPostBody('application/json', '{"beta":1}')
    --request:SetHTTPRequestGetOrPostParameter('payload', json)
    request:Send(function(response)
        if response.StatusCode ~= 200 then
            print('HTTP Status Error')
            print(response.StatusCode or "nil")
            return
        end
        
        if not response.Body then
            print('HTTP Server Error')
            print(response.Body or "nil")
            return
        end
        
        print('Success')
        -- local obj, pos, err = json.decode(res.Body, 1, nil)
        
        -- callback(err, obj)
    end)
end

---
--@function [parent=#Http] Send
--@param self
--@param #string api
--@param #string data
--@param #function callback
function Http:Send(api, data, callback)
    
    local settings = LoadKeyValues('scripts/vscripts/settings.kv')
    if not settings then
        Debug('Http', '[ERROR] settings.kv is required')
        return
    end
    
    if IsInToolsMode() then
        settings.host = settings.host_dev
    end
    
    local payload = json.encode(data)
    -- Debug('Http', payload) -- Can be really long.
    
    local url = settings.host..api..'?token='..sha1.hmac(settings.key, payload)
    -- url = 'http://requestb.in/ruxe6vru'..'?token='..sha1.hmac(settings.key, payload)
    -- Debug('Http', url)
    
    local request = CreateHTTPRequest('POST', url)
    request:SetHTTPRequestRawPostBody('application/json', payload)
    request:Send(function(response)
        if response.StatusCode ~= 200 then
            Debug('Http', 'HTTP Status Error')
            Debug('Http', response.StatusCode or 'nil')
            if response.StatusCode == 0 then
                Debug('Http', 'Is the server alive?')
            end
            return
        end
        
        if not response.Body then
            Debug('Http', 'HTTP Server Error')
            Debug('Http', response.Body or 'nil')
            return
        end
        
        local payload = json.decode(response.Body)
        
        if not payload or not payload.success then
            Debug('Http', 'HTTP Response Error')
            Debug('Http', not payload or payload.error)
            Debug('Http', response.Body)
            return
        end
        
        -- Success!
        if callback then callback(payload.data) end
    end)
end

---
--@function [parent=#Http] Save
--@param self
--@param #table data
--@param #function callback
function Http:Save(data, callback)
    Http:Send('/api/save', data, callback)
end

---
--@function [parent=#Http] Load
--@param self
--@param #table data
--@param #function callback
function Http:Load(data, callback)
    Http:Send('/api/load', data, callback)
end


---
--@function [parent=#Http] SendReport
--@param self
--@param #table params
function Http:SendReport(params)
    if DEBUG_SKIP_HTTP_REPORT then return end
    -- Need to throttle sends.
    -- Simple 30 second send pattern.
    -- Add to a table.
    table.insert(self.reports, params)
end

function Http:ThrottledSendReport()
    -- local payload = json.encode({
    --     steamId64 = steamId64,
    --     data = self.reports
    -- })
    -- print(payload)
    Http:Send('/api/reports', { data = self.reports })
end

function Http:Init()
    self.reports = {}
    Timers:CreateTimer(function()
        if #self.reports > 0 then
            Debug('Http', 'Throttled Send Execute')
            Http:ThrottledSendReport()
            self.reports = {}
        end
        
        -- Every 30 seconds.
        return 30.0
    end)
end

if not Http.initialized then
    Http.initialized = true
    Http:Init()
end
