---
-- Scripts called by map entities.
-- 

---
-- Introductions - Area 2 Gate Demolish
-- 
function Area2_OnStartTouch(trigger)
    local hero = trigger.activator
    Debug('Triggers', 'Area2_OnStartTouch', thisEntity:GetName(), hero:GetUnitName())
    
    -- Check Quest Completed
    if QuestService:CheckIfCompleted('intro_worg_2', hero:GetPlayerOwnerID()) then
        Entities:FindByName(nil, 'area_2_relay'):Trigger()
        thisEntity:Destroy()
        Debug('Triggers', 'Area 2 Gate Opened')
    end
end
