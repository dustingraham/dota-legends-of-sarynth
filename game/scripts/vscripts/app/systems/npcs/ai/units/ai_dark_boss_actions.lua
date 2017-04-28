function AiDarkBossActions(ai)

    function ai:CreateShards()
        Debug('AiDarkBoss', 'Creating shards...')
        EmitSoundOn('death_prophet_dpro_laugh_012', self:GetParent())

        self.shardsCreated = true
        local caster = self:GetParent()
        local caster_location = caster:GetAbsOrigin()

        local shard1 = CreateUnitByName('dark_boss_summons', caster_location + RandomVector(200), true, caster, caster, caster:GetTeamNumber())
        shard1:MoveToTargetToAttack( self.aggroTarget )
        table.insert(self.shards, shard1)
        local shard2 = CreateUnitByName('dark_boss_summons', caster_location + RandomVector(200), true, caster, caster, caster:GetTeamNumber())
        shard2:MoveToTargetToAttack( self.aggroTarget )
        table.insert(self.shards, shard2)
        Timers(1.0, function()
            if IsValidEntity(shard1) then
                shard1:MoveToTargetToAttack( self.aggroTarget )
            end
            if IsValidEntity(shard2) then
                shard2:MoveToTargetToAttack( self.aggroTarget )
            end
        end)
    end

    function ai:KillShards()
        for _,s in pairs(self.shards) do
            if s and IsValidEntity(s) then
                s:ForceKill(false)
            end
        end
        self.shards = {}
        self.shardsCreated = false
    end

    function ai:EnergyLinkStart()
        -- We walked to it in theory, but ensure we're facing...
        self:GetParent():FaceTowards(self.energyParticle:GetAbsOrigin())

        -- Get happy about it...
        -- EmitSoundOn('death_prophet_dpro_laugh_06', self:GetParent())
        EmitSoundOn('death_prophet_dpro_attack_06', self:GetParent())

        -- Start Sound
        self:GetParent():EmitSound('Hero_DeathProphet.Exorcism')

        local pIdx = ParticleManager:CreateParticle("particles/units/dark_plains/boss/energy_pull/energy_pull.vpcf", PATTACH_ROOTBONE_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControlEnt(pIdx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(pIdx, 1, self.energyParticle:GetAbsOrigin() + Vector(0,0,300))
        self.energyLinkParticle = pIdx
    end

    function ai:EnergyLinkStop(dueToDeath)
        if not dueToDeath then
            EmitSoundOn('death_prophet_dpro_laugh_06', self:GetParent())
        end
        self:GetParent():StopSound('Hero_DeathProphet.Exorcism')
        if self.energyLinkParticle then
            ParticleManager:DestroyParticle(self.energyLinkParticle, false)
            ParticleManager:ReleaseParticleIndex(self.energyLinkParticle)
            self.energyLinkParticle = nil
        end
    end

    function ai:ToggleWall(toggleTo)
        -- Create the dummy if we don't have one already.
        if not self.dummyEntity then
            self.dummyEntity = CreateUnitByName('dummy_entity', self.energyParticle:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS)
        end
        -- Toggle the wall
        if self.toggleWall then
            self.toggleWall = false
            ParticleManager:DestroyParticle(self.particleIndex, false)
            ParticleManager:ReleaseParticleIndex(self.particleIndex)
            self.particleIndex = nil
            -- Opening wall, kill shards.
            self:KillShards()
        else
            self.toggleWall = true
            self.particleIndex = ParticleManager:CreateParticle('particles/dire_fx/bad_ancient_ambient.vpcf', PATTACH_ABSORIGIN, self.dummyEntity)
            ParticleManager:SetParticleControl(self.particleIndex, 0, self.energyParticle:GetAbsOrigin())
        end

        Debug('AiDarkBoss', 'Wall toggled to:', self.toggleWall)
        if self.toggleWall ~= toggleTo then
            Debug('AiDarkBoss', 'DANGER Wall Mismatch....')
        end

        -- Toggle the simple obstructions
        for _,obstruction in pairs(Entities:FindAllByName('dark_barricade_obstruction')) do
            obstruction:SetEnabled(self.toggleWall, false)
        end
    end

end
