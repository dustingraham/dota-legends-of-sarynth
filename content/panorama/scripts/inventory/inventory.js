var GetPanel = function(panel)
{
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

    // Return the panel object.
    return panel;
};

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

        $.Msg('Drag Start: '+panel.panelId);

        var itemName = panel.FindChildTraverse('TheItemImage').itemname;

        var displayPanel = $.CreatePanel( "DOTAItemImage", $.GetContextPanel(), "dragImage" );
        displayPanel.itemname = itemName;
        displayPanel.panelId = panel.panelId;
        displayPanel.foundDestination = false;
        displayPanel.originalPanel = panel;
        displayPanel.slotType = Abilities.GetSpecialValueFor(panel.eid, 'slot_type');
        $.Msg('Dragging Slot Type: '+displayPanel.slotType);

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
        $.Msg('Drag End: '+panelId);

        // TODO: World drop.

        draggedPanel.DeleteAsync( 0 );
        draggedPanel.originalPanel.RemoveClass('dragging_from');
        return true;
    },
    OnDragEnter: function(panel, draggedPanel)
    {
        $.Msg('Drag Enter: '+panel.panelId);
        $.Msg('Drag Enter Type: '+panel.slotType);
        $.Msg('Drag Drrrg Type: '+draggedPanel.slotType);

        panel.AddClass('potential_drop_target');
        if (panel.slotType !== draggedPanel.slotType)
        {
            panel.AddClass('bad_drag_target');
        }
        return true;
    },
    OnDragDrop: function(panel, draggedPanel)
    {
        if (panel === draggedPanel.originalPanel)
        {
            // Dropped on self, nothing to do.
            draggedPanel.foundDestination = true;
            return true;
        }

        $.Msg('Drag Drop: '+panel.panelId);

        draggedPanel.foundDestination = true;

        // Remove item from both panels.
        var targetItemName = panel.FindChildTraverse('TheItemImage').itemname;
        var targetRare = panel.tmpRare;
        var draggedRare = draggedPanel.originalPanel.tmpRare;
        var targetEid = panel.eid;
        $.Msg('Target: '+targetEid);
        $.Msg('Old: '+draggedPanel.originalPanel.eid);

        RemoveItem(panel.panelId);
        RemoveItem(draggedPanel.originalPanel.panelId);

        AddItem(panel, draggedPanel.originalPanel.eid, draggedPanel.itemname, draggedRare);
        AddItem(draggedPanel.originalPanel, targetEid, targetItemName, targetRare);

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
    }
};

var AddItem = function(panel, eid, itemName, itemRarity)
{
    panel = GetPanel(panel);

    if (itemName === '' || itemName === 'null') return;

    panel.RemoveClass('empty');
    panel.AddClass('has-item');

    panel.FindChildTraverse('TheItemImage').itemname = itemName;
    panel.FindChildTraverse('TheItemImage').SetHasClass(itemRarity, true);
    panel.tmpRare = itemRarity;
    panel.eid = eid;
};

var RemoveItem = function(panel)
{
    panel = GetPanel(panel);

    panel.AddClass('empty');
    panel.RemoveClass('has-item');

    panel.FindChildTraverse('TheItemImage').itemname = null;
    panel.FindChildTraverse('TheItemImage').SetHasClass(panel.tmpRare, false);
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
    // var panel = $.CreatePanel('Panel', $('#'+params.cont), 'myslot'+params.id);
    // panel.BLoadLayoutSnippet('TestItem');
    // //panel.SetItem(-1, 99, params.id, $.GetContextPanel());

    //$.Msg(params);

    //var child = $.CreatePanel( "Panel", params.row, "slot" + params.id);
    //child.BLoadLayout("file://{resources}/layout/custom_game/containers/inventory_item.xml", false, false);
    //child.SetItem( -1, params.contID, params.id, $.GetContextPanel() );

    var panelId = "slot" + slotId;
    var panel = $.CreatePanel( "Panel", params.row, panelId);

    panel.panelId = panelId;

    // Temp
    panel.slotType = slotId;

    //$.Msg('Build: '+panelId);
    inventory.panels[panelId] = panel;

    // panel.BLoadLayout("file://{resources}/layout/custom_game/containers/inventory_item.xml", false, false);
    panel.BLoadLayoutSnippet('ItemBlock');
    panel.tmp = panelId;

    //panel.FindChildTraverse('TheButton').onmouseover = function() { $.Msg('ok...'); };

    $.RegisterEventHandler('Activated', panel, inventory.ActivateItem);
    $.RegisterEventHandler('DragStart', panel, inventory.OnDragStart);
    $.RegisterEventHandler('DragEnd', panel, inventory.OnDragEnd );
    $.RegisterEventHandler('DragEnter', panel, function(_, dragged) { inventory.OnDragEnter(panel, dragged); });
    $.RegisterEventHandler('DragDrop', panel, function(_, dragged) { inventory.OnDragDrop(panel, dragged); });
    $.RegisterEventHandler('DragLeave', panel, function(_, dragged) { inventory.OnDragLeave(panel, dragged); });

    //panel.SetPanelEvent('onmouseover', inventory.OnMouseOver);

    //if (params.row.id == 'Eqmpt') { return; }
    panel.AddClass('empty');

    // item_kobold_weapon_2
    //panel.SetItem( -1, params.contID, params.id, $.GetContextPanel() );
};

Game.KeyInventoryToggle = function()
{
    $('#InventoryDialog').ToggleClass('hide');
};

// For reloadingness.
$('#ItmCnt').RemoveAndDeleteChildren();
$('#Eqmpt').RemoveAndDeleteChildren();

for (i = 1; i <= 12; i++)
{
    // Skip unused slots.
    if (i > 3 && i < 8) continue;

    BuildItemBlock($('#Eqmpt'), i, panelSlotTypes[i]);
}

// Six rows of six.
for (i = 0; i <= 5; i++) {
    var row = $.CreatePanel('Panel', $('#ItmCnt'), 'row' + i);
    row.AddClass('MyItemRow');

    for (var j = 1; j <= 6; j++) {
        // Offset by 12.
        var slotId = 12 + j + i * 6;
        BuildItemBlock(row, slotId, 0);
    }
}

// AddItem(20, 'item_kobold_amulet_unique', 'item_rarity_common');
// AddItem(4, 'item_kobold_armor_2', 'item_rarity_epic');
// AddItem(5, 'item_kobold_amulet_1', 'item_rarity_rare');
// AddItem(7, 'item_amulet_tier2', 'item_rarity_uncommon');
// AddItem(12, 'item_kobold_amulet_unique', 'item_rarity_epic');
// AddItem(15, 'item_kobold_armor_2', 'item_rarity_common');
// AddItem(16, 'item_kobold_amulet_1', 'item_rarity_rare');
// AddItem(17, 'item_kobold_weapon_1', 'item_rarity_uncommon');
// AddItem(18, 'item_broadsword_tier2', 'item_rarity_common');
// AddItem(19, 'item_armor_tier2', 'item_rarity_uncommon');
// AddItem(20, 'item_boots_leather_common', 'item_rarity_uncommon');

$.Msg('Rebuild Complete');

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

var PlaceItemTemp = function(eid, slot)
{
    $.Msg('Slot is: '+slot);
    $.Msg('Level is: '+Abilities.GetLevel(eid));

    var itemName = Abilities.GetAbilityName(eid);
    var colorId = Items.GetItemColor(eid);
    if (colorId === -1)
    {
        colorId = Abilities.GetLevel(eid);
    }

    var rarityClass = colorMap[colorId];
    AddItem(slot, eid, itemName, rarityClass);
};

var PlaceAllItems = function(items)
{
    $.Each(items, PlaceItemTemp);
};

var InventoryTableChange = function(tableName, changes, deletions) {
    $.Msg('Changes happened');
    $.Msg(tableName);
    $.Msg(changes);
    $.Msg(deletions);
    PlaceAllItems(changes);
    // $.Each(changes, function(eid, slot)
    // {
    //     var itemName = Abilities.GetAbilityName(eid);
    //     $.Msg(eid);
    //     $.Msg(itemName);
    //     //AddItem(3, 'item_kobold_amulet_unique', 'item_rarity_common');
    // });
    //$.Msg('Changes done.');
};

var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
var playerId = Game.GetLocalPlayerID();
var playerTableKey = 'player_items_'+playerId;
PlayerTables.SubscribeNetTableListener(playerTableKey, InventoryTableChange);

// var rarity = Abilities.GetSpecialValueFor(m_Item, 'rarity');
// $.GetContextPanel().SetHasClass('item_rarity_junk', !isEmpty && rarity == 1);
// $.GetContextPanel().SetHasClass('item_rarity_quest', !isEmpty && rarity == 2);
// $.GetContextPanel().SetHasClass('item_rarity_common', !isEmpty && rarity == 3);
// $.GetContextPanel().SetHasClass('item_rarity_uncommon', !isEmpty && rarity == 4);
// $.GetContextPanel().SetHasClass('item_rarity_rare', !isEmpty && rarity == 5);
// $.GetContextPanel().SetHasClass('item_rarity_epic', !isEmpty && rarity == 6);
// $.GetContextPanel().SetHasClass('item_rarity_legendary', !isEmpty && rarity == 7);

// Retrieve values on the client
//$.Msg(PlayerTables.GetTableValue("player_0_quests", "count"));
var currentValues = PlayerTables.GetAllTableValues(playerTableKey);
$.Msg(playerTableKey);
if (currentValues)
{
    PlaceAllItems(currentValues);
}
