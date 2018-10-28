---
--@type ShopSystem
ShopSystem = ShopSystem or class({}, {
    ShopTable = {}
})

function ShopSystem:Activate()
    local kvFileName = 'scripts/data/'..GetMapName()..'/shoptable.kv'
    self.ShopTable = LoadKeyValues(kvFileName)

    if not self.ShopTable then
        Debug('ShopSystem', '[ERROR] Likely KV Syntax Error: ', kvFileName)
        self.ShopSystem = {}
        return
    end

    -- Event:Listen('InventoryAdd', Dynamic_Wrap(ShopSystem, 'OnInventoryChange'), ShopSystem)
    -- Event:Listen('InventoryDrop', Dynamic_Wrap(ShopSystem, 'OnInventoryChange'), ShopSystem)
end

function ShopSystem:StartShopDialog(hero, target)
    local player = hero:GetPlayerOwner()

    -- Sound? "WELCOME BUY FROM ME"
    Debug('ShopSystem', 'Starting shop dialog.')

    CustomGameEventManager:Send_ServerToPlayer(player, 'shop_start', {})
end
