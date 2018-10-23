
var selectedSlot = -1;
var selectedClass = false;

var charDescriptions = {
    Warrior: 'Reliant on his sword and shield, the warrior is renowned for his strength. His heroic feats of unmatched power bring enemies to their knees. Just avoid confusing brawn with intellect.',
    Paladin: 'Blessed by the sanctity of light, the Paladin relies on fortitude and purity. He brings to the fight his unstoppable hammer coupled with a healing touch. His holy powers can smite evil and rejuvenate allies.',
    Rogue: 'Speed, agility and focus lead to devastating critical strikes that cripple enemy. Not necessarily reliant on the shadows, the rogue finds his balance in swift precision. Armor is a hindrance that is often neglected.',
    Ranger: 'One with her bow, the ranger rains death upon her enemies from afar. Through training and agility, she seeks to put every arrow on target while staying distant and untouched.',
    Mage: 'The mage is forever in training, as he continues to refine his control over the elements. From apprentice to master, and beyond, every aspect of the natural world becomes his medium.',
    Sorcerer: 'Dark arts consume the sorcerer, as he strives to avoid succumbing to pure evil. His chaotic good nature manifests itself as his ritualistic incantations rip apart enemies of the land. Fear the darkness.'
};
var charUnitNames = {
    Warrior: 'npc_dota_hero_dragon_knight',
    Paladin: 'npc_dota_hero_omniknight',
    Rogue: 'npc_dota_hero_bounty_hunter',
    Ranger: 'npc_dota_hero_windrunner',
    Mage: 'npc_dota_hero_invoker',
    Sorcerer: 'npc_dota_hero_warlock'
};

var InitCharacterPickListeners = function() {
    var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
    var playerId = Game.GetLocalPlayerID();
    var playerTableKey = 'player_'+playerId+'_characters';

    // Subscribe to changes on the client
    if (undefined === $.GetContextPanel().subscription_id)
    {
        $.GetContextPanel().subscription_id = PlayerTables.SubscribeNetTableListener(
            playerTableKey,
            function(tableName, changes, deletions) {
                $.Msg('[JS] Table Change: '+tableName);
                //$.Msg(JSON.stringify(changes));
                //$.Msg(JSON.stringify(deletions));

                // If the server is slow to respond.
                // TODO: Display a "loading" symbol until this data is available.
                $.Each(PlayerTables.GetAllTableValues(playerTableKey), function(data)
                {
                    ReplaceCharacterBlock(data);
                });
            });
    }

    // Grab data if it is already available.
    var blocks = PlayerTables.GetAllTableValues(playerTableKey);
    if (blocks) {
        $.Each(blocks, function(data)
        {
            ReplaceCharacterBlock(data);
        });
    }
};

var playerSaveSlotCount = 0;
var LoadExtraSlots = function()
{
    var $welcomeScreen = $('#WelcomeScreen');
    if (!$welcomeScreen.BHasClass('double-slots'))
    {
        // If user has 3 characters, build 3 more.
        $welcomeScreen.AddClass('double-slots');
        for (var i = 3; i < 6; i++)
        {
            BuildCharacterBlock(i);
        }
    }
};

function ConfirmClassPick()
{
    $.Msg('[JS] Picked '+selectedClass);
    
    GameEvents.SendCustomGameEventToServer('character_pick', {
        character: selectedClass,
        slotId: selectedSlot
    });

    // Hide Pick Screen
    var panel = $.GetContextPanel().FindChild('CharacterPanelContainer');
    panel.style.opacity = '0.0';
    $.Schedule(1, function()
    {
        // Collapse to prevent hittest.
        panel.style.visibility = 'collapse';
        panel.hittestchildren = false;
    });
}
function NewCharacter()
{
    $('#WelcomeScreen').style.opacity = '0.0';
    $.Schedule(0.25, function() {
        $('#ChooseClass').style.opacity = '1.0';
    });
    $.Schedule(1, function()
    {
        // Collapse to prevent hittest.
        //panel.style.visibility = 'collapse';
        //panel.hittestchildren = false;
    });
}
function PickBack()
{
    $('#ChooseClass').style.opacity = '0.0';
    $.Schedule(0.25, function() {
        $('#WelcomeScreen').style.opacity = '1.0';
    });
    $.Schedule(0.5, function()
    {
        // Reset
        $.DispatchEvent('DOTAGlobalSceneSetCameraEntity', 'MapPortrait', 'cam', 0);
        $('#ClassDetails').style.opacity = '0.0';
        transit = 1.2;
    });
}
function CharacterTest()
{
    //$.Msg('Testing character.');
    //$.DispatchEvent("DOTAGlobalSceneFireEntityInput", "MapPortrait", "ranger_entity_alt", 'spawn', 0);
}

function ReplaceCharacterBlock(data)
{
    // If we already have extra slots, load them now.
    if (data.slot_id > 2) LoadExtraSlots();
    // Count to 3 slots. If they have 3 full, show next row.
    playerSaveSlotCount = playerSaveSlotCount + 1;
    if (playerSaveSlotCount >= 3) LoadExtraSlots();

    var slotIdKey = 'slotId'+data.slot_id;
    var panel = $('#'+slotIdKey);

    // Set Gameplay Time
    var minutes = Math.ceil(data.gametime / 60);
    var hours = Math.ceil(minutes / 60);
    var playtime = '';
    if (hours > 1)
    {
        playtime = hours + ' hours';
    }
    else if (minutes > 1)
    {
        playtime = minutes + ' minutes';
    }
    else
    {
        playtime = data.gametime + ' seconds';
    }

    panel.FindChildTraverse('CharacterDetailsInfo').text =
        'Level: <span class="detail">'+data.level+'</span><br>' +
        (data.zone ? ('Location: <span class="detail">'+$.Localize('zone_name_'+data.zone)+'</span><br>') : '') +
        'Playtime: <span class="detail">'+playtime+'</span><br>' +
        'Experience: <span class="detail">'+data.experience+'</span>';

    panel.FindChildTraverse('CharacterDetailPortraitContainer').SetHasClass('hide', false);

    panel.FindChildTraverse('CharacterDetailsName').text = data.character;

    panel.FindChildTraverse('CharacterDetailPortraitContainer').SetHasClass('hide', false);
    panel.FindChildTraverse('CharacterDetailsPortrait').heroname = charUnitNames[data.character];

    panel.FindChildTraverse('CreateCharacterButton').SetHasClass('hide', true);
    panel.FindChildTraverse('LoadCharacterButton').SetHasClass('hide', false);
    panel.FindChildTraverse('LoadCharacterButton').SetPanelEvent('onactivate', function()
    {
        $.Msg('[JS] LoadCharacter!');
        $.Msg('[JS] For slot id: ', data.slot_id);
    
        GameEvents.SendCustomGameEventToServer('character_load', {
            slotId: data.slot_id
        });

        // Hide Pick Screen
        var panel = $.GetContextPanel().FindChild('CharacterPanelContainer');
        panel.style.opacity = '0.0';
        $.Schedule(1, function()
        {
            // Collapse to prevent hittest.
            panel.style.visibility = 'collapse';
            panel.hittestchildren = false;
        });
    });
}

function BuildCharacterBlock (slotId)
{
    var slotIdKey = 'slotId'+slotId;
    var checkPanel = $('#'+slotIdKey);
    if (checkPanel) {
        return;
        // Useful for recreating the XML, but timing screws up writing blocks.
        //checkPanel.DeleteAsync(0);
    }

    var blockSlotId = slotId;
    var panel = $.CreatePanel('Panel', $('#CharacterBlocks'), slotIdKey);
    panel.BLoadLayoutSnippet('CharacterBlock');
    panel.SetHasClass(slotIdKey, true);
    panel.FindChildTraverse('CreateCharacterButton').SetPanelEvent('onactivate', function()
    {
        selectedSlot = blockSlotId;
        $('#WelcomeScreen').style.opacity = '0.0';
        $.Schedule(0.25, function() {
            $('#ChooseClass').style.opacity = '1.0';
        });
    });
}

// Delete all debug
if (false) {

    $.Schedule(2, function () {
        $.Each($.GetContextPanel().FindChildrenWithClassTraverse('character-info-wrapper'), function (panel) {
            panel.DeleteAsync(0);
        });
    });
}

// Build the first 3 blocks.
for (var i = 0; i < 3; i++)
{
    BuildCharacterBlock(i);
}

InitCharacterPickListeners();

var transit = 1.2;
function SelectCharacter(character)
{
    selectedClass = character;
    $.Schedule(0.45, function() {
        $('#ClassDetails').style.opacity = '1.0';
    });

    $.Msg('Switching to: '+character);
    //$('#MapPortrait').camera = character;
    $.DispatchEvent('DOTAGlobalSceneSetCameraEntity', 'MapPortrait', character, transit );
    transit = 0.7;

    $('#ClassDetailsName').text = character;
    $('#ClassDetailsInfo').text = charDescriptions[character];
    $('#ClassDetailsPortrait').heroname = charUnitNames[character];
}

function OnCharacterPicked(event)
{
    // Hide Pick Screen
    var panel = $.GetContextPanel().FindChild('CharacterPanelContainer');
    panel.style.opacity = '0.0';
    $.Schedule(1, function()
    {
        // Collapse to prevent hittest.
        panel.style.visibility = 'collapse';
        panel.hittestchildren = false;
    });
}

// Game loads to black screen, remove once scenes are loaded.
function CheckSceneLoad()
{
    var overlay = $.GetContextPanel().FindChild('LoadingOverlay');
    if (overlay.style.opacity == '0.0')
    {
        // Already removed.
        return;
    }

    var mapInfo = Game.GetMapInfo();
    var mapName = mapInfo.map_display_name;
    if (mapName == 'testmap')
    {
        $.Msg('Character pick not currently used.');

        // Hide Overlay
        overlay.style.opacity = '0.0';
        overlay.style.visibility = 'collapse';
        overlay.hittest = false;
        overlay.hittestchildren = false;

        // Hide Pick
        var panel = $.GetContextPanel().FindChild('CharacterPanelContainer');
        panel.style.opacity = '0.0';
        panel.style.visibility = 'collapse';
        panel.hittest = false;
        panel.hittestchildren = false;

        // Return
        return;
    }

    var characters = $.GetContextPanel().FindChildrenWithClassTraverse('Character');
    var allLoaded = true;
    $.Each(characters, function(panel) {
        if (!panel.BHasClass('SceneLoaded'))
        {
            allLoaded = false;
        }
    });

    if (allLoaded)
    {
        overlay.style.opacity = '0.0';
        $.Schedule(1, function()
        {
            overlay.style.visibility = 'collapse';
            overlay.hittest = false;
            overlay.hittestchildren = false;
        });
    }
    else
    {
        $.Schedule(1, CheckSceneLoad);
    }
}
CheckSceneLoad();

GameEvents.Subscribe('character_picked', OnCharacterPicked);

var panel = $.GetContextPanel();
if (!panel.dashboardButton)
{
    panel.dashboardButton = panel.GetParent().GetParent().GetParent().FindChildTraverse('DashboardButton');
}
function MoveDashboardButtonIn()
{
    panel.dashboardButton.SetParent($.GetContextPanel());
}
function MoveDashboardButtonOut()
{
    var dashboardButtonContainer = panel.GetParent().GetParent().GetParent().FindChildTraverse('ButtonBar');
    panel.dashboardButton.SetParent(dashboardButtonContainer);
}
// We may just leave it in -- it "just works" still.
MoveDashboardButtonIn();
