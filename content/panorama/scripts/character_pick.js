
var selectedSlot = -1;
var selectedClass = false;

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

var BuildCharacterBlock = function(params)
{
    var slotIdKey = 'slotId'+params.slotId;
    var blockSlotId = params.slotId;
    var panel = $.CreatePanel('Panel', $('#CharacterBlocks'), slotIdKey);
    panel.BLoadLayoutSnippet('CharacterBlock');
    panel.SetHasClass(slotIdKey, true);
    if (params.emptySlot)
    {
        panel.FindChildTraverse('CreateCharacterButton').SetPanelEvent('onactivate', function()
        {
            selectedSlot = blockSlotId;
            $('#WelcomeScreen').style.opacity = '0.0';
            $.Schedule(0.25, function() {
                $('#ChooseClass').style.opacity = '1.0';
            });
        });
    }
    else
    {
        // Populate with save data.
        panel.FindChildTraverse('CharacterClass').text = params.characterClassName;
    }
};

// Delete all debug
if (false) {

    $.Schedule(2, function () {
        $.Each($.GetContextPanel().FindChildrenWithClassTraverse('character-info-wrapper'), function (panel) {
            panel.DeleteAsync(0);
        });
    });
}

for (var i = 0; i < 3; i++)
{
    BuildCharacterBlock({ emptySlot: true, slotId: i });
}

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

var charDescriptions = {
    Warrior: 'Reliant on his sword and shield, the warrior is renowned for his strength. His heroic feats of unmatched power bring enemies to their knees. Just avoid confusing brawn with intellect.',
    Paladin: 'Blessed by the sanctity of light, the Paladin relies on fortitude and purity. He brings to the fight his unstoppable hammer coupled with a healing touch. His holy powers can rejuvenate allies, and repel evil.',
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
