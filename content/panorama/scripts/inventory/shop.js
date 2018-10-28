
var MakeShopDialog = function()
{
    var row, i, j, slotId;
    // Six rows of six for shop.
    for (i = 0; i <= 5; i++) {
        row = $.CreatePanel('Panel', $shopForSale, 'forsale-row' + i);
        row.AddClass('backpack-panel-group');
        for (j = 1; j <= 6; j++) {
            // Offset to start at 101, through 136.
            slotId = 100 + j + i * 6;
            BuildItemBlock(row, slotId, ITEM_SLOT_SHOP);
        }
    }
    
    // One row of six for buyback.
    for (i = 0; i <= 0; i++) {
        row = $.CreatePanel('Panel', $shopBuyBack, 'buyback-row' + i);
        row.AddClass('backpack-panel-group');
        for (j = 1; j <= 6; j++) {
            // Offset to start at 151.
            slotId = 150 + j + i * 6;
            BuildItemBlock(row, slotId, ITEM_SLOT_BUYBACK);
        }
    }
};

var ShowShopDialog = function()
{
    var $dialog = $('#InventoryDialog');
    
    // Ensure the shop flag is true.
    $('#DialogImage').SetHasClass('shop-dialog', true);
    
    // If the dialog WAS hidden, do some updates before showing it.
    if ($dialog.BHasClass('hide'))
    {
        // Update Gold fields.
        $.GetContextPanel().FindChildTraverse('HeroGoldLabel')
            .text = numberWithCommas(Players.GetGold(Game.GetLocalPlayerID()));
    
        var rand = Math.random();
        if (rand > 0.95)
            Game.EmitSound('pudge_pud_arc_rare_13');
        else if (rand > 0.90)
            Game.EmitSound('pudge_pud_rare_06');
        else if (rand > 0.80)
            Game.EmitSound('pudge_pud_arc_item_50_02');
        else if (rand > 0.70)
            Game.EmitSound('pudge_pud_arc_item_44');
        else
            Game.EmitSound('ui.report_open');
    }
    
    $dialog.SetHasClass('hide', false);
};

// For reloading.
$('#ForSale').RemoveAndDeleteChildren();
$('#BuyBack').RemoveAndDeleteChildren();

MakeShopDialog();
//ShowShopDialog();

GameEvents.Subscribe('shop_start', function()
{
    $.Msg("Subscribe is activated.");
    
    // May need to populate current NPC's items.
    // For now, only one shopkeepa.
    
    //dialog.SetHasClass('hidden', true);
    ShowShopDialog();
});

// var BuySellItem = function(panel)
// {
//     // Check whether we can/should?
//     // If it is unsellable, do nothing.
//     // Quest item, or other flag?
//
//     $.Msg('Right clicked. Shopping; sell it!');
//
//     // We do want to sell it. Figure out where it will move.
//     // First slot on the left, shift others if needed.
//
//     // SlotTo is false, forcing server to decide where to move it.
//     // For drag and drop, we will let the user pick the target slot.
//     GameEvents.SendCustomGameEventToServer('Inventory_OnSell', {
//         slotFrom:panel.panelId
//     });
//
//     // Give gold. Make sound. Make particle/visual.
// };
