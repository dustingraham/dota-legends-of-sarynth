ProjectileSystem = ProjectileSystem or class({}, {
    projectiles = {}
})

function ProjectileSystem:Activate()
    Timers:CreateTimer({
        callback = ProjectileSystem.UpdateAll,
        context = ProjectileSystem
    })
end
Event:BindActivate(ProjectileSystem)

function ProjectileSystem:AddProjectile(projectile)
    table.insert(self.projectiles, projectile)
    --print('We added a thing')
end

function ProjectileSystem:UpdateAll()
    -- Since we may remove a projectile, count from length down to 1.
    for i = #self.projectiles, 1, -1 do
        local projectile = self.projectiles[i]
        WrapException(function(projectile, i)
            if not projectile.destroyed then
                projectile:Update()
            else
                table.remove(self.projectiles, i)
                -- print('We removed a thing')
            end
        end, projectile, i)
    end

    return 0.01
end
