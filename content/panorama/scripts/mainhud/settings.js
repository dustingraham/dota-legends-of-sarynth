var $button = $('#ActionBarFocus');
if (!$button.initialized)
{
    $button.initialized = true;
    $button.isFocusOn = true;
    
    $button.SetPanelEvent('onmouseover', function() {
        $.DispatchEvent(
            'DOTAShowTitleTextTooltip',
            $button,
            'Toggle Focus Target Casting',
            '<b>When Enabled:</b> Casting spells will automatically '+
            'target your currently focused enemy unit.<br><br>'+
            '<b>When Disabled:</b> Casting a spell will require you '+
            'to click your target with every spell, similar to standard DotA gameplay.');
            // 'Toggles whether to auto-cast unit target<br>abilities at the current focus target.');
    });
    $button.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideTitleTextTooltip', $button);
    });
}

Game.KeyFocusToggle = function()
{
    // Toggle State.
    $button.isFocusOn = !$button.isFocusOn;
    GameEvents.SendCustomGameEventToServer('settings_focus_target', { value: $button.isFocusOn });
    
    $button.FindChildTraverse('ActionBarFocusOn').visible = $button.isFocusOn;
    $button.FindChildTraverse('ActionBarFocusOff').visible = !$button.isFocusOn;
};
