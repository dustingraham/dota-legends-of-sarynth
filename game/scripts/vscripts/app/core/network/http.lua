---
--@author Sarynth
--@type Http
Http = Http or class({
    forceSave = false
})

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

    -- local url = settings.host..api..'?token='..sha1.hmac(settings.key, payload)
    local url = settings.host..api..'?token='..Boot.MatchID
    --Debug('Http', url)

    -- BIN TEST
    --data.url = url
    --url = 'http://requestb.in/zm1zu7zm'

    local payload = json.encode(data)
    -- Debug('Http', payload) -- Can be really long.


    local request = CreateHTTPRequestScriptVM('POST', url)
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
--@function [parent=#Http] SendReport
--@param self
--@param #table params
function Http:SendReport(params)
    if DEBUG_SKIP_HTTP_REPORT then return end
    -- Throttles sends to 30 seconds.
    table.insert(self.reports, params)
end

function Http:ForceSave()
    if DEBUG_SKIP_HTTP_REPORT then return end
    self.forceSave = true
end

function Http:ThrottledSendReport()
    -- local payload = json.encode({
    --     steamId64 = steamId64,
    --     data = self.reports
    -- })
    -- print(payload)
    Http:Send('/api/reports', { data = self.reports })
end

function Http:Activate()
    self.reports = {}
    Timers:CreateTimer(function()
        if #self.reports > 0 or self.forceSave then
            Debug('Http', 'Throttled Send Execute')

            -- If we're sending anything, add current character data
            for PlayerID,player in pairs(PlayerService.players) do
                -- Ensure they have picked a slot/hero.
                if player.slot_id ~= nil then
                    table.insert(self.reports, Reporter:PullCharacterReport(PlayerID))
                end
            end
            Http:ThrottledSendReport()
            self.reports = {}
            self.forceSave = false
        end

        -- Every 30 seconds.
        return 30.0
    end)
end

Event:BindActivate(Http)

-- Move to boot sequence.
--if not Http.initialized then
--    Http.initialized = true
--    Http:Init()
--end
