function AiDruidsBossActions(ai)

    function ai:WallOn()
        local door = Entities:FindByName(nil, 'druids_building_door')
        door:SetAbsOrigin(door:GetAbsOrigin() + Vector(0,0,512))
        -- Remove the simple obstructions
        for _,obstruction in pairs(Entities:FindAllByName('druids_door_obstruction')) do
            obstruction:SetEnabled(true, false)
        end
    end

    function ai:WallOff()
        local door = Entities:FindByName(nil, 'druids_building_door')
        door:SetAbsOrigin(door:GetAbsOrigin() - Vector(0,0,512))
        -- Remove the simple obstructions
        for _,obstruction in pairs(Entities:FindAllByName('druids_door_obstruction')) do
            obstruction:SetEnabled(false, false)
        end
    end

end
