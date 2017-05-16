var GetPanel = function(panel)
{
    // $.Msg('---');
    // $.Msg('Panel Find Attempt');
    // $.Msg(panel);

    // If numeric, prepend slot prefix.
    if (typeof panel === 'number')
    {
        panel = 'slot'+panel;
    }
    // If string, lookup panel.
    if (typeof panel === 'string')
    {
        panel = inventory.panels[panel];
    }

    // $.Msg('Panel Find Result');
    // $.Msg(panel);

    // Return the panel object.
    return panel;
};

var $backpack = $('#Backpack');
var $equipment = $('#Equipment');

var $shopForSale = $('#ForSale');
var $shopBuyBack = $('#BuyBack');

var inventory = {
    panels: {},
    ActivateItem: function()
    {
        $.Msg('No Activation');
    },
    OnDragStart: function(panel, dragCallbacks)
    {
        panel = GetPanel(panel);
        if (panel.BHasClass('empty'))
        {
            // Nothing to do here.
            return true;
        }

        // $.Msg('Drag Start: '+panel.panelId);

        var itemName = panel.FindChildTraverse('TheItemImage').itemname;

        var displayPanel = $.CreatePanel( "DOTAItemImage", $.GetContextPanel(), "dragImage" );
        displayPanel.itemname = itemName;
        displayPanel.panelId = panel.panelId;
        displayPanel.foundDestination = false;
        displayPanel.originalPanel = panel;
        displayPanel.slotType = Abilities.GetSpecialValueFor(panel.eid, 'slot_type');

        // $.Msg('Dragging Slot Type: '+displayPanel.slotType);
        if (displayPanel.slotType > 0)
        {
            // Highlight available targets...
            $equipment.FindChildrenWithClassTraverse('slot-type-'+displayPanel.slotType).forEach(function(e) {
                e.AddClass('compatible_drop_target');
            });

            // var slots = $equipment.FindChildrenWithClassTraverse('slot-type-'+displayPanel.slotType);
            // $.Msg('Found compatible...');
            // $.Msg(slots);
        }

        // displayPanel.contextEntityIndex = m_Item;
        // displayPanel.m_DragItem = m_Item;
        // displayPanel.m_contID = m_contID;
        // displayPanel.m_QueryUnit = m_QueryUnit;

        // hook up the display panel, and specify the panel offset from the cursor
        dragCallbacks.displayPanel = displayPanel;
        dragCallbacks.offsetX = 0;
        dragCallbacks.offsetY = 0;

        panel.AddClass('dragging_from');
        return true;
    },
    OnDragEnd: function(panelId, draggedPanel)
    {
        // $.Msg('Drag End: '+panelId);
        if (!draggedPanel.foundDestination)
        {
            // World drop.
            var position = GameUI.GetScreenWorldPosition(GameUI.GetCursorPosition());
            GameEvents.SendCustomGameEventToServer('Inventory_OnDragWorld', {
                slotFrom:draggedPanel.originalPanel.panelId,
                position:position
            });
        }

        // Remove compatibility highlights.
        $equipment.FindChildrenWithClassTraverse('compatible_drop_target').forEach(function(e) {
            e.RemoveClass('compatible_drop_target');
        });

        draggedPanel.DeleteAsync( 0 );
        draggedPanel.originalPanel.RemoveClass('dragging_from');

        return true;
    },
    OnDragEnter: function(panel, draggedPanel)
    {
        // $.Msg('Drag Enter: '+panel.panelId);
        // $.Msg('Drag Enter Type: '+panel.slotType);
        // $.Msg('Drag Drrrg Type: '+draggedPanel.slotType);

        panel.AddClass('potential_drop_target');
        if (panel.slotType > 0 && panel.slotType !== draggedPanel.slotType)
        {
            panel.AddClass('bad_drag_target');
        }

        return true;
    },
    OnDragDrop: function(panel, draggedPanel)
    {
        draggedPanel.foundDestination = true;
        // If they dropped back in same location.
        if (panel === draggedPanel.originalPanel)
        {
            // Dropped on self, nothing to do.
            return true;
        }
        // If they dropped on an invalid slot.
        if (panel.slotType > 0 && panel.slotType !== draggedPanel.slotType)
        {
            return true;
        }

        var targetItemName = panel.FindChildTraverse('TheItemImage').itemname;
        var targetRare = panel.tmpRare;
        var targetEid = panel.eid;
        var draggedRare = draggedPanel.originalPanel.tmpRare;
        var draggedEid = draggedPanel.originalPanel.eid;
        var draggedItemName = draggedPanel.itemname;

        // Containers_OnDragFrom
        GameEvents.SendCustomGameEventToServer('Inventory_OnDragDrop', {
            slotFrom:draggedPanel.originalPanel.panelId,
            slotTo:panel.panelId
        });

        // JS SWAP!
        // RemoveItem(panel.panelId);
        // RemoveItem(draggedPanel.originalPanel.panelId);
        // AddItem(panel, draggedEid, draggedItemName, draggedRare);
        // AddItem(draggedPanel.originalPanel, targetEid, targetItemName, targetRare);

        return true;
    },
    OnDragLeave: function(panel, draggedPanel)
    {
        //$.Msg('Drag Leave: '+panel.panelId);
        panel.RemoveClass('potential_drop_target');
        panel.RemoveClass('bad_drag_target');
        return true;
    },
    OnMouseOver: function(panel, thing)
    {
        $.Msg('Mouse Over Works');
        // ItemShowTooltip();
        //var itemName = Abilities.GetAbilityName( m_Item );
        //$.DispatchEvent( "DOTAShowAbilityTooltipForEntityIndex", $.GetContextPanel(), itemName, m_QueryUnit );
    },
    OnContextMenu: function(panel, thing)
    {
        $.Msg('Right clicked.');
    }
};

var AddItem = function(panel, eid, itemName, itemRarity)
{
    panel = GetPanel(panel);

    if (itemName === '' || itemName === 'null') return;

    panel.RemoveClass('empty');
    panel.AddClass('has-item');

    panel.FindChildTraverse('TheItemImage').itemname = itemName;
    if (panel.currentRarity)
    {
        // If we're swapping items, remove old rarity.
        panel.FindChildTraverse('TheItemImage').SetHasClass(panel.currentRarity, false);
    }
    panel.FindChildTraverse('TheItemImage').SetHasClass(itemRarity, true);
    panel.currentRarity = itemRarity;
    panel.eid = eid;
};

var RemoveItem = function(panel)
{
    panel = GetPanel(panel);

    panel.AddClass('empty');
    panel.RemoveClass('has-item');

    panel.FindChildTraverse('TheItemImage').itemname = null;
    panel.FindChildTraverse('TheItemImage').SetHasClass(panel.currentRarity, false);
    panel.currentRarity = false;
};

var panelSlotTypes = {
    1: 3, // Helm
    2: 4, // Neck
    3: 5, // Chest
    // 4 reserved sholders
    // 5 reserved gloves
    // 6 reserved pants
    // 7 reserved belt
    8: 11, // ring1
    9: 11, // ring2
    10: 10, // boots
    11: 1, // weapon
    12: 2 // offhand
};

// Item Data Slot Types
// 0  = non-equipment
// 1  = weapon
// 2  = offhand
// 3  = Helm
// 4  = Neck
// 5  = Chest
// 6  = sholders
// 7  = gloves
// 8  = pants
// 9  = belt
// 10 = boots
// 11 = ring

var BuildItemBlock = function(attachTo, slotId, slotType)
{
    var panelId = 'slot' + slotId;
    var panel = $.CreatePanel('Panel', attachTo, panelId);

    panel.panelId = panelId;
    panel.slotType = slotType;
    inventory.panels[panelId] = panel;

    panel.BLoadLayoutSnippet('ItemBlock');
    panel.AddClass('slot-type-'+slotType);
    //panel.AddClass('empty');
    //panel.tmp = panelId;

    $.RegisterEventHandler('Activated', panel, inventory.ActivateItem);
    $.RegisterEventHandler('ContextMenu', panel, inventory.OnContextMenu);
    $.RegisterEventHandler('DragStart', panel, inventory.OnDragStart);
    $.RegisterEventHandler('DragEnd', panel, inventory.OnDragEnd );
    $.RegisterEventHandler('DragEnter', panel, function(_, dragged) { inventory.OnDragEnter(panel, dragged); });
    $.RegisterEventHandler('DragDrop', panel, function(_, dragged) { inventory.OnDragDrop(panel, dragged); });
    $.RegisterEventHandler('DragLeave', panel, function(_, dragged) { inventory.OnDragLeave(panel, dragged); });
    //panel.SetPanelEvent('onmouseover', inventory.OnMouseOver);
    // item_kobold_weapon_2
    //panel.SetItem( -1, params.contID, params.id, $.GetContextPanel() );
};

// For reloadingness.
$backpack.RemoveAndDeleteChildren();
$equipment.RemoveAndDeleteChildren();

$shopForSale.RemoveAndDeleteChildren();
$shopBuyBack.RemoveAndDeleteChildren();

// Equipment panels.
var BuildEquipmentPanel = function(position, start, end)
{
    var panel = $.CreatePanel('Panel', $equipment, 'equipment_' + position);
    panel.AddClass('equipment-panel-group');
    for (var i = start; i <= end; i++)
    {
        BuildItemBlock(panel, i, panelSlotTypes[i]);
    }
};
BuildEquipmentPanel('left', 1, 3);
BuildEquipmentPanel('right', 8, 10);
BuildEquipmentPanel('bottom', 11, 12);

// Six rows of six for backpack.
for (i = 0; i <= 5; i++) {
    var row = $.CreatePanel('Panel', $backpack, 'row' + i);
    row.AddClass('backpack-panel-group');
    for (var j = 1; j <= 6; j++) {
        // Offset by 12.
        var slotId = 12 + j + i * 6;
        BuildItemBlock(row, slotId, 0);
    }
}

var MakeShopDialog = function()
{
    // Testing:
    $('#InventoryDialog').SetHasClass('hide', false);

    // Convert to shop dialog.
    $('#DialogImage').SetHasClass('shop-dialog', true);

    // Five rows of six for shop.
    for (i = 0; i <= 5; i++) {
        var row = $.CreatePanel('Panel', $shopForSale, 'forsale-row' + i);
        row.AddClass('backpack-panel-group');
        for (var j = 1; j <= 6; j++) {
            // Offset by 12.
            var slotId = 100 + j + i * 6;
            BuildItemBlock(row, slotId, 0);
        }
    }
    // Five rows of six for shop.
    for (i = 0; i <= 0; i++) {
        var row = $.CreatePanel('Panel', $shopBuyBack, 'buyback-row' + i);
        row.AddClass('backpack-panel-group');
        for (var j = 1; j <= 6; j++) {
            // Offset by 12.
            var slotId = 150 + j + i * 6;
            BuildItemBlock(row, slotId, 0);
        }
    }
};

var DebutTestShop = false;
if (DebutTestShop) {
    MakeShopDialog();
}
else
{
    $('#DialogImage').SetHasClass('shop-dialog', false);
}

var colorMap = {
    // Special based on level.
    '-1': 'item_rarity_junk',
    '0': 'item_rarity_quest',
    '1': 'item_rarity_common',

    // Based on ItemQuality Color
    '-16732885': 'item_rarity_uncommon',
    '-161510': 'item_rarity_rare',
    '-126533': 'item_rarity_epic',
    '-16736538': 'item_rarity_legendary'
};

var PlaceAllItems = function(items)
{
    $.Each(items, function(eid, slot)
    {
        // $.Msg('Slot is: '+slot);
        // $.Msg('Level is: '+Abilities.GetLevel(eid));

        var itemName = Abilities.GetAbilityName(eid);
        var colorId = Items.GetItemColor(eid);
        if (colorId === -1)
        {
            colorId = Abilities.GetLevel(eid);
        }

        var rarityClass = colorMap[colorId];
        AddItem(slot, eid, itemName, rarityClass);
    });
};

function isEmptyObject(obj) {
    for(var prop in obj) {
        if (Object.prototype.hasOwnProperty.call(obj, prop)) {
            return false;
        }
    }
    return true;
}

var InventoryTableChange = function(tableName, changes, deletions) {
    // $.Msg('PlayerTableUpdate happened: '+tableName);
    if (!isEmptyObject(deletions))
    {
        //$.Msg('Deletions happened.');
        //$.Msg(deletions);
        $.Each(deletions, function(eid, slotId)
        {
            RemoveItem(slotId)
        });
    }
    if (!isEmptyObject(changes))
    {
        //$.Msg('Changes happened.');
        //$.Msg(changes);
        PlaceAllItems(changes);
    }
};

var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
var playerId = Game.GetLocalPlayerID();
var playerTableKey = 'player_items_'+playerId;
if ($.GetContextPanel().OldListenerId !== undefined)
{
    // If we reload JS, we re-subscribe...
    PlayerTables.UnsubscribeNetTableListener($.GetContextPanel().OldListenerId);
}
$.GetContextPanel().OldListenerId = PlayerTables.SubscribeNetTableListener(playerTableKey, InventoryTableChange);

// var rarity = Abilities.GetSpecialValueFor(m_Item, 'rarity');
// $.GetContextPanel().SetHasClass('item_rarity_junk', !isEmpty && rarity == 1);
// $.GetContextPanel().SetHasClass('item_rarity_quest', !isEmpty && rarity == 2);
// $.GetContextPanel().SetHasClass('item_rarity_common', !isEmpty && rarity == 3);
// $.GetContextPanel().SetHasClass('item_rarity_uncommon', !isEmpty && rarity == 4);
// $.GetContextPanel().SetHasClass('item_rarity_rare', !isEmpty && rarity == 5);
// $.GetContextPanel().SetHasClass('item_rarity_epic', !isEmpty && rarity == 6);
// $.GetContextPanel().SetHasClass('item_rarity_legendary', !isEmpty && rarity == 7);

// Retrieve values on the client
//$.Msg(playerTableKey);
var currentValues = PlayerTables.GetAllTableValues(playerTableKey);
if (currentValues)
{
    //$.Msg('Placing known entities.');
    PlaceAllItems(currentValues);
}

function numberWithCommas(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

Game.KeyInventoryToggle = function()
{
    $('#InventoryDialog').ToggleClass('hide');

    // Update text fields.
    var panel = $.GetContextPanel();
    var playerId = Game.GetLocalPlayerID();
    var heroId = Players.GetPlayerHeroEntityIndex(playerId);
    var heroName = unitNamesToClass[Entities.GetUnitName(heroId)];

    panel.FindChildTraverse('HeroClassLabel').text = heroName;
    panel.FindChildTraverse('HeroLevelLabel').text = 'Level '+Entities.GetLevel(heroId);
    panel.FindChildTraverse('HeroGoldLabel').text = numberWithCommas(Players.GetGold(playerId));
};

var unitNamesToClass= {
    npc_dota_hero_dragon_knight: 'Warrior',
    npc_dota_hero_omniknight: 'Paladin',
    npc_dota_hero_bounty_hunter: 'Rogue',
    npc_dota_hero_windrunner: 'Ranger',
    npc_dota_hero_invoker: 'Mage',
    npc_dota_hero_warlock: 'Sorcerer'
};
