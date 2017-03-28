
var focusSettings = $('#ToggleFocusTarget');
if (!focusSettings.initialized)
{
    focusSettings.initialized = true;
    focusSettings.SetPanelEvent('onactivate', function() {
        focusSettings.onOffState = !focusSettings.onOffState;
        GameEvents.SendCustomGameEventToServer('settings_focus_target', { value: !focusSettings.onOffState });
        focusSettings.SetHasClass('off', focusSettings.onOffState);
        focusSettings.SetHasClass('on', !focusSettings.onOffState);
    });
    focusSettings.SetPanelEvent('onmouseover', function() {
        $.DispatchEvent('DOTAShowTitleTextTooltip', focusSettings, 'Toggle Focus Target Casting', 'Toggles whether to auto-cast unit target<br>abilities at the current focus target.');
    });
    focusSettings.SetPanelEvent('onmouseout', function() {
        $.DispatchEvent('DOTAHideTitleTextTooltip', focusSettings);
    });
}
