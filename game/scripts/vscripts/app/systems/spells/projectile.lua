Projectile = Projectile or class({
    speed = 1000,
    width = 100,
    distance = 1000,
    damage = 100,

    speedMult = 1,

    isNew = 2,
    destroyed = false
})

function Projectile:constructor(params)
    self.uuid = DoUniqueString("projectile")
    self.hitList = {}

    -- Pull in params
    for k, v in pairs(params) do
        self[k] = v
    end

    if not self.owner then
        error('Owner is required.')
    end

    -- TODO, error if missing required params, like owner?

    self.owner = params.owner
    self.caster = (params.caster or params.owner)
    self.from = (params.from or params.owner)

    self.target = params.target

    -- Want targetPoint since hero can move away from where the line is drawn.
    --local direction = self.target:GetAbsOrigin()
    local direction = params.targetPoint
    direction = direction - self.caster:GetAbsOrigin()
    direction.z = 0.0
    direction = direction:Normalized()

    -- TODO...
    self.startPoint = self.caster:GetAbsOrigin()
    self.finalDestination = self.caster:GetAbsOrigin() + direction:Normalized() * self.distance

    -- TODO: Get Facing if direction is nil.
    self.angle = direction
    self.width = (params.width or self.width)

    self.position = self.caster:GetAbsOrigin()
    -- self:SetPos(self.from)

    self.velocity = self.speed * direction
    -- print('Constructively constructing: ', self.uuid)
end

function Projectile:Update()
    -- Called every 0.01, do the movement update.

    -- self.onHit(self, nil)
    --self:onHit(nil)

    local pos = self:GetNextPosition(self:GetPos())
    self:SetPos(pos)

    -- Check for hit.
    local targets = self.owner:FindEnemyUnitsInRadius(pos, self.width / 2)
    for _, target in ipairs(targets) do
        if self.constantDamage or not self.hitList[target] then
            self.hitList[target] = true
            WrapException(function(target)
                self:onHit(target)
            end, target)
        else
            -- print('Already hit by: ', self.uuid)
        end
    end

    -- TODO: Destroy after time, or after distance, or after hitting something.


    -- Destroying newly created particles needs to wait 2 frames.
    self.isNew = self.isNew - 1

    if (self.startPoint - pos):Length2D() > self.distance or self.isNew < -3000 then
        self:Destroy()
    end

    -- print('And Destroy')
    --self:Destroy()
end

function Projectile:Activate()
    self:SetGraphics(self.graphics)
    ProjectileSystem:AddProjectile(self)
    return self
end

function Projectile:Destroy()
    self.destroyed = true
    self:SetGraphics(nil)
end

function Projectile:GetUnit()
    return self.owner
end

function Projectile:GetPos()
    return self.position
end

function Projectile:SetPos(pos)
    self.position = pos

    -- What is prediction beneficial for?
    ParticleManager:SetParticleControl( self.particle, 0, self.position )
--    if self.disablePrediction then
--        self.particle:SetAbsOrigin(pos)
--    else
--        self.particle:SetAbsOrigin(self:GetNextPosition(self:GetNextPosition(pos)))
--    end
end

function Projectile:GetNextPosition(pos)
    return pos + (self.angle * (self:GetSpeed() / 30))
end

function Projectile:GetSpeed()
    return self.speed * self.speedMult
end

function Projectile:SetSpeed(speed)
    self.speed = speed
end

function Projectile:SetGraphics(graphics)
    if self.particle then
        -- Destroy existing
        local particle = self.particle
        local function cleaner()
            ParticleManager:DestroyParticle(particle, false)
            ParticleManager:ReleaseParticleIndex(particle)
        end

        -- Need to wait 2 frames if new.
        if self.isNew > 0 then
            Timers:CreateTimer(cleaner)
        else
            cleaner()
        end
    end

    -- Pass nil to simply remove existing particle.
    if graphics then
        -- self.particle = ParticleManager:CreateParticle(graphics, PATTACH_ABSORIGIN_FOLLOW, self:GetUnit())
        self.particle = ParticleManager:CreateParticle(graphics, PATTACH_POINT, self:GetUnit())
    end
end


function Projectile:BadActivate()
    local info = {
        EffectName = "particles/units/heroes/hero_venomancer/venomancer_venomous_gale.vpcf",
        --EffectName = "particles/econ/items/venomancer/veno_ti8_immortal_head/veno_ti8_immortal_gale.vpcf",
        Ability = nil,
        vSpawnOrigin = self.caster:GetOrigin(),
        fStartRadius = self.width,
        fEndRadius = self.width,
        vVelocity = self.velocity,
        fDistance = self.distance,
        Source = self.caster,
        --iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetTeam = DOTA_UNIT_TARGET_ALL,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    }
    ProjectileManager:CreateLinearProjectile(info)
end

function Projectile:BadOnProjectileHit(hTarget, vLocation)
    print('We has hitdown.')
    if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
        local damage = {
            victim = hTarget,
            attacker = self.caster,
            damage = self.damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self
        }
        ApplyDamage( damage )

        local vDirection = vLocation - self.caster:GetOrigin()
        vDirection.z = 0.0
        vDirection = vDirection:Normalized()

        local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_lina/lina_spell_dragon_slave_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget )
        ParticleManager:SetParticleControlForward( nFXIndex, 1, vDirection )
        ParticleManager:ReleaseParticleIndex( nFXIndex )
    end

    return false
end
