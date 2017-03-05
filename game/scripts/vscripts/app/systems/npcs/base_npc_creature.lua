local creature = CDOTA_BaseNPC_Creature

function creature:CheckNpc()
    print('Checked: Creature', self:GetName(), self:GetClassname(), self:GetUnitName())
end


-- Reference concept.
--
--local entity = CBaseEntity
--function entity:CheckNpc()
--    print('Checked: Raw Entity', self:GetName(), self:GetClassname())
--end
--
--local npc = CDOTA_BaseNPC
--function npc:CheckNpc()
--    print('Checked: BaseNpc', self:GetName(), self:GetClassname(), self:GetUnitName())
--end
--
--local creature = CDOTA_BaseNPC_Creature
--function creature:CheckNpc()
--    print('Checked: Creature', self:GetName(), self:GetClassname(), self:GetUnitName())
--end
--
--local hero = CDOTA_BaseNPC_Hero
--function hero:CheckNpc()
--    print('Checked: Hero', self:GetName(), self:GetClassname(), self:GetUnitName())
--end
