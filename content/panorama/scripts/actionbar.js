
// Abilities -- Toggle for Debug
//$.GetContextPanel().FindChildTraverse('ActionBar').style.visibility = 'collapse';

if (!$.GetContextPanel().actionBarInit)
{
    $.GetContextPanel().actionBarInit = true;
    //$.Msg('Action Bar Init');

    // Take abilities and move them into our own container.
    var Hud = $.GetContextPanel().GetParent().GetParent().GetParent();

    // // Move elements of the default ability bar into our own containers.
    Hud.FindChildTraverse('abilities').SetParent($('#DefaultBar'));
    Hud.FindChildTraverse('buffs').SetParent($('#DefaultBuffBar'));
    Hud.FindChildTraverse('debuffs').SetParent($('#DefaultBuffBar'));

    Hud.FindChildTraverse('stats_container').style.marginLeft = '0';
    Hud.FindChildTraverse('stats_container').style.width = '229px';
    //Hud.FindChildTraverse('stats_container').style.backgroundColor = 'none';

    // Hide the rest.
    Hud.FindChildTraverse('center_with_stats').style.visibility = 'collapse';
    Hud.FindChildTraverse('stats_container_bg').style.visibility = 'collapse';
    Hud.FindChildTraverse('HUDSkinStatBranchBG').style.visibility = 'collapse';
    Hud.FindChildTraverse('HUDSkinStatBranchGlow').style.visibility = 'collapse';

    // A touch of resizement. A dash of style.
    var tooltipRegionStyle = Hud.FindChildTraverse('stats_tooltip_region').style;
    tooltipRegionStyle.width = '150px';
    tooltipRegionStyle.height = '75px';

    Hud.FindChildTraverse('stats').style.marginTop = '0';

    var strAgiIntStyle = Hud.FindChildTraverse('stragiint').style;
    strAgiIntStyle.marginTop = '3px';
    strAgiIntStyle.marginRight = '75px';
    strAgiIntStyle.width = '80px';

    Hud.FindChildTraverse('stats_container').SetParent($('#DefaultStatsBlock'));
}

function ActionBarButton(container) {
    GameEvents.SendCustomGameEventToServer('inventory_toggle', { container: container });
}

// if (abilityBar.customButtons === undefined)
// {
//     $.Msg('Initializing custom buttons.');
//     abilityBar.customButtons = {}
// }

function AbilityButton() {
    var which = 'test1';
    var button = {};
    if (abilityBar.customButtons[which] !== undefined)
    {
        // $.Msg('Abort. Exists.');
        // return;

        $.Msg('Reusing existing button.');
        button = abilityBar.customButtons[which];
    }
    else
    {
        $.Msg('Creating new button.');
        abilityBar.customButtons[which] = button;
    }

    var image = $.CreatePanel("Image", abilityBar, '');
    image.AddClass('action-bar-slot');
    image.SetImage('file://{images}/actionbar1/action_bar_slot.png');

    var abilityImage = $.CreatePanel('DOTAAbilityImage', image, '');
    abilityImage.AddClass('action-bar-ability');
    abilityImage.abilityname = 'dragon_knight_custom_1';

    var inside = $.CreatePanel("Panel", image, '');
    inside.AddClass('action-bar-inside');

    button.image = image;
    button.ability = abilityImage;
    button.inside = inside;

    // SetCooldown(10, 12, false, false);
}

function SetCooldown(remaining, cd, ready, activated)
{
    var abilityBar = $('#ActionBar');

    var which = 'test1';
    var inside = abilityBar.customButtons[which].inside;

    var progress = (-360 * (remaining / cd)).toString();

    if (progress == 0) {
        $.Msg('0 to -360');
        progress = -360;
    }

    $.Msg('Clipping to '+ "radial(50% 50%, 0deg, "+progress+"deg)");
    inside.style.clip = "radial(50% 50%, 0deg, "+progress+"deg)";
}


//AbilityButton();

var testCD = 10;
function Testing()
{
    testCD = testCD - 1;
    if (testCD == -1) testCD = 11;
    SetCooldown(testCD, 12, false, false);
    $.Schedule(1, Testing);
}
//Testing();
