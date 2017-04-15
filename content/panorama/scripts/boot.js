
// May want a clock later...?
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_TIMEOFDAY, false );
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false );     //Heroes and team score at the top of the HUD.
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_FLYOUT_SCOREBOARD, false );      //Lefthand flyout scoreboard.
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_MENU_BUTTONS, false );     //Top-left menu buttons in the HUD.




// Other potential options.
//GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR_RADIANT_TEAM, false );
//GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR_DIRE_TEAM, false );
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_PANEL, true );     //Hero actions UI.
//GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_MINIMAP, false );     //Minimap.
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PANEL, false );      //Entire Inventory UI
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, false );     //Shop portion of the Inventory.
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_ITEMS, false );      //Player items.
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_QUICKBUY, false );     //Quickbuy.
//GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_COURIER, false );      //Courier controls.
//GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PROTECT, false );      //Glyph.
//GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_GOLD, false );     //Gold display.
//GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_SHOP_SUGGESTEDITEMS, false );      //Suggested items shop panel.
//GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_TEAMS, false );     //Hero selection Radiant and Dire player lists.
//GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_GAME_NAME, false );     //Hero selection game mode name display.
//GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_CLOCK, false );     //Hero selection clock.
//GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME, false );      //Endgame scoreboard.
//GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_BAR_BACKGROUND, false );     //Top-left menu buttons in the HUD.

$.Msg('[BOOT] Loaded');

var upDownHide = function(up, down) {
    var panel = $.GetContextPanel();
    while(panel != null)
    {
        if (panel.id == up) break;
        panel = panel.GetParent();
    }

    if (panel == null)
    {
        $.Msg('[UpDownHide] ERROR Failed to find UP target.')
    }
    else
    {
        panel = panel.FindChildTraverse(down);
        if (panel == null)
        {
            $.Msg('[UpDownHide] ERROR Failed to find DOWN target.')
        }
        else
        {
            panel.style.visibility = 'collapse';
        }
    }
};

upDownHide('Hud', 'topbar'); // Day/Night glow.
upDownHide('Hud', 'quickstats');
upDownHide('Hud', 'GlyphScanContainer');

// CONCEPT

// var timePressed = 0;
// Game.CustomOnPressedInventory = function()
// {
//     timePressed = Game.GetGameTime();
//     GameEvents.SendCustomGameEventToServer('inventory_open', {});
// };
// Game.CustomOnReleasedInventory = function()
// {
//     var delay = Game.GetGameTime() - timePressed;
//     if (delay > 1.0)
//     {
//         // Auto-close if held for more than 1 second.
//         GameEvents.SendCustomGameEventToServer('inventory_close', {});
//     }
// };

GameEvents.Subscribe('emit_client_sound', function(event)
{
    if (event.sound){
        //$.Msg(msg);
        Game.EmitSound(event.sound);
    }
});



// (function() {
//     var currentParent = panel.GetParent();
//     if (currentParent.id != 'lower_hud')
//     {
//         $.Msg('Moving develop_menu panel to lower_hud.');
//         var lowerHud = currentParent.GetParent().GetParent().FindChildTraverse('lower_hud');
//         panel.SetParent(lowerHud);

//         // Hide the glyph/scan container. Not used. (Not worried about hotkey invocation.)
//         lowerHud.FindChild('GlyphScanContainer').style.visibility = 'collapse';
//         lowerHud.FindChildTraverse('shop_launcher_block').style.visibility = 'collapse';
//         lowerHud.FindChildTraverse('inventory').style.visibility = 'collapse';
//         lowerHud.FindChildTraverse('right_flare').style.marginRight = '204px';
//         lowerHud.FindChildTraverse('center_block').style.marginLeft = '210px';
//     }

// })();

// function DevelopBoss(action, name) {
//     GameEvents.SendCustomGameEventToServer("develop_boss", { "action": action, "name": name });
// }

// function DevelopTest(key) {
//     GameEvents.SendCustomGameEventToServer("develop_test", { "key": key });
// }


// Probably need to wait for a certain game mode. 1 second seems to work.
//$.Schedule(1, function() {
    //GameUI.SetCameraPitchMax( 60 ); // Standard 60
    //GameUI.SetCameraPitchMin( 38 ); // Standard 38
    //GameUI.SetCameraDistance( 1134 ); // Standard 1134
    // Jarring.
    //var ID = Players.GetLocalPlayer();
    //GameUI.SetCameraTarget(Players.GetPlayerHeroEntityIndex( ID ))
//});
