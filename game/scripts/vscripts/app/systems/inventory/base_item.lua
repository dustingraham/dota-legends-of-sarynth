-- IsQuestItem
local item = CDOTA_Item

function item:IsQuestItem()
    if InventoryService:GetItemQuality(self:GetAbilityName()) == 'component' then
        if self:GetLevel() == 0 then
            return true
        end
    end
    return false
end
