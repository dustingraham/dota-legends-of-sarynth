
function CharacterPick(name)
{
    // $.Msg('[JS] Picked '+name)
    GameEvents.SendCustomGameEventToServer('character_pick', { 'character': name });
    
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
