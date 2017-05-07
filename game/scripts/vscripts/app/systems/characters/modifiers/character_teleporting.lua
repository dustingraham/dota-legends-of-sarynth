character_teleporting = character_teleporting or class({})

function character_teleporting:OnCreated(params)
    if IsServer() then
        self.teleport_from = params.from
        self.teleport_to = params.to
        self:GetCaster():ParticleOn('particles/transport_bird/transport_bird.vpcf')
        -- Some Noise
        Sounds:Start('Teleport.Liftoff', self:GetCaster():GetPlayerOwnerID())
        Sounds:Start('rune_idle_02', self:GetCaster():GetPlayerOwnerID())

        self.trackTime = 0

        PlayerResource:SetCameraTarget(self:GetCaster():GetPlayerOwnerID(), self:GetCaster())

        self.nextPoint = nil
        self:StartIntervalThink(1/32)
    end
end

function character_teleporting:OnDestroy()
    if IsServer() then
        local hero = self:GetCaster()
        local position = hero:GetAbsOrigin()
        local PlayerID = hero:GetPlayerOwnerID()
        hero:ParticleOff('particles/transport_bird/transport_bird.vpcf')
        Sounds:Start('ui.herochallenge_complete', PlayerID)
        Timers(0.25, function()
            Sounds:Stop('rune_idle_02', PlayerID)
            -- Fix collision
            ResolveNPCPositions(position, 300)
        end)
        -- Unlock camera
        PlayerResource:SetCameraTarget(PlayerID, nil)
    end
end

function character_teleporting:CheckState()
    return {
        [MODIFIER_STATE_FLYING] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_ATTACK_IMMUNE] = true,
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true, -- Definitely
    }
end

function character_teleporting:IsPassive()
    return true
end

function character_teleporting:IsPurgable()
    return false
end

function character_teleporting:RemoveOnDeath()
    return true
end

function character_teleporting:IsHidden()
    return true
end

function character_teleporting:OnIntervalThink()
    local caster = self:GetParent()

    -- Move towards destination...
    self:UpdateDirection()
    caster:SetAbsOrigin(caster:GetAbsOrigin() + self.targetDir * self.speed)
end

-- From -> To
local waypointGuide = {
    ['teleport_tower_ice'] = {
        ['teleport_tower_town'] = {
            'teleport_waypoint_10',
            'teleport_waypoint_9',
            'teleport_waypoint_8',
            'teleport_waypoint_7',
            'teleport_waypoint_6',
            'teleport_waypoint_5',
            'teleport_waypoint_4',
            'teleport_waypoint_3',
            'teleport_waypoint_2',
            'teleport_waypoint_1',
            'teleport_tower_town',
        }
    },
    ['teleport_tower_town'] = {
        ['teleport_tower_ice'] = {
            'teleport_waypoint_1',
            'teleport_waypoint_2',
            'teleport_waypoint_3',
            'teleport_waypoint_4',
            'teleport_waypoint_5',
            'teleport_waypoint_6',
            'teleport_waypoint_7',
            'teleport_waypoint_8',
            'teleport_waypoint_9',
            'teleport_waypoint_10',
            'teleport_tower_ice'
        },
        ['teleport_tower_kobolds'] = {
            'teleport_waypoint_1',
            'teleport_waypoint_2',
            'teleport_waypoint_3',
            'teleport_waypoint_11',
            'teleport_tower_kobolds',
        },
        ['teleport_tower_webbed'] = {
            'teleport_waypoint_1',
            'teleport_waypoint_2',
            'teleport_waypoint_3',
            'teleport_waypoint_12',
            'teleport_waypoint_13',
            'teleport_tower_webbed',
        },
        ['teleport_tower_dark'] = {
            'teleport_waypoint_1',
            'teleport_waypoint_2',
            'teleport_waypoint_3',
            'teleport_waypoint_14',
            'teleport_waypoint_15',
            'teleport_waypoint_16',
            'teleport_tower_dark',
        }
    },
    ['teleport_tower_kobolds'] = {
        ['teleport_tower_ice'] = {
            'teleport_waypoint_11',
            'teleport_waypoint_3',
            'teleport_waypoint_4',
            'teleport_waypoint_5',
            'teleport_waypoint_6',
            'teleport_waypoint_7',
            'teleport_waypoint_8',
            'teleport_waypoint_9',
            'teleport_waypoint_10',
            'teleport_tower_ice'
        },
        ['teleport_tower_town'] = {
            'teleport_waypoint_11',
            'teleport_waypoint_3',
            'teleport_waypoint_2',
            'teleport_waypoint_1',
            'teleport_tower_town',
        },
        ['teleport_tower_webbed'] = {
            'teleport_waypoint_11',
            'teleport_waypoint_3',
            'teleport_waypoint_12',
            'teleport_waypoint_13',
            'teleport_tower_webbed',
        },
        ['teleport_tower_dark'] = {
            'teleport_waypoint_11',
            'teleport_waypoint_3',
            'teleport_waypoint_12',
            'teleport_waypoint_15',
            'teleport_waypoint_16',
            'teleport_tower_dark',
        }
    },
    ['teleport_tower_webbed'] = {
        ['teleport_tower_ice'] = {
            'teleport_waypoint_13',
            'teleport_waypoint_12',
            'teleport_waypoint_3',
            'teleport_waypoint_4',
            'teleport_waypoint_5',
            'teleport_waypoint_6',
            'teleport_waypoint_7',
            'teleport_waypoint_8',
            'teleport_waypoint_9',
            'teleport_waypoint_10',
            'teleport_tower_ice'
        },
        ['teleport_tower_town'] = {
            'teleport_waypoint_13',
            'teleport_waypoint_12',
            'teleport_waypoint_3',
            'teleport_waypoint_2',
            'teleport_waypoint_1',
            'teleport_tower_town',
        },
        ['teleport_tower_kobolds'] = {
            'teleport_waypoint_13',
            'teleport_waypoint_12',
            'teleport_waypoint_3',
            'teleport_waypoint_11',
            'teleport_tower_kobolds',
        },
        ['teleport_tower_dark'] = {
            'teleport_waypoint_14',
            'teleport_waypoint_15',
            'teleport_waypoint_16',
            'teleport_tower_dark',
        }
    },
    ['teleport_tower_dark'] = {
        ['teleport_tower_ice'] = {
            'teleport_waypoint_13',
            'teleport_waypoint_12',
            'teleport_waypoint_3',
            'teleport_waypoint_4',
            'teleport_waypoint_5',
            'teleport_waypoint_6',
            'teleport_waypoint_7',
            'teleport_waypoint_8',
            'teleport_waypoint_9',
            'teleport_waypoint_10',
            'teleport_tower_ice'
        },
        ['teleport_tower_town'] = {
            'teleport_waypoint_16',
            'teleport_waypoint_15',
            'teleport_waypoint_14',
            'teleport_waypoint_3',
            'teleport_waypoint_2',
            'teleport_waypoint_1',
            'teleport_tower_town',
        },
        ['teleport_tower_kobolds'] = {
            'teleport_waypoint_16',
            'teleport_waypoint_15',
            'teleport_waypoint_12',
            'teleport_waypoint_3',
            'teleport_waypoint_11',
            'teleport_tower_kobolds',
        },
        ['teleport_tower_webbed'] = {
            'teleport_waypoint_16',
            'teleport_waypoint_15',
            'teleport_waypoint_14',
            'teleport_tower_webbed',
        }
    }
}

function character_teleporting:UpdateDirection()
    if not self.nextWaypoint then
        -- Init
        self.speed = 45
        print(self.teleport_from)
        print(self.teleport_to)
        print(inspect(waypointGuide[self.teleport_from][self.teleport_to]))
        self.nextWaypoint = waypointGuide[self.teleport_from][self.teleport_to][1]
        self.nextEntity = Entities:FindByName(nil, self.nextWaypoint)
        self.nextPos = self.nextEntity:GetAbsOrigin()
    end
    local currentPos = self:GetParent():GetAbsOrigin()
    if (currentPos - self.nextPos):Length2D() < (self.speed + 140) then
        -- Find Next Waypoint
        for i,waypoint in ipairs(waypointGuide[self.teleport_from][self.teleport_to]) do
            if self.nextWaypoint == waypoint then
                local nextI = i + 1
                if not waypointGuide[self.teleport_from][self.teleport_to][nextI] then
                    self:Destroy()
                    return
                end
                self.nextWaypoint = waypointGuide[self.teleport_from][self.teleport_to][nextI]
                self.nextEntity = Entities:FindByName(nil, self.nextWaypoint)
                self.nextPos = self.nextEntity:GetAbsOrigin()
                break
            end
        end
    end

    -- Find waypoint after next, and when less than 200 pos from next, start curving?
    -- self.targetTeleport = 'teleport_tower_ice'

    self.targetDir = (self.nextPos - currentPos):Normalized()
    self:GetParent():SetForwardVector(self.targetDir)
end
