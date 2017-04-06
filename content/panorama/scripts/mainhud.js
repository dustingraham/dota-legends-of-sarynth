
/////////////////////////////////////////////////////////////
// ACTION BAR

var panel = $.GetContextPanel();

var expBar = panel.FindChildTraverse('ExperienceBar');
var expTip = panel.FindChildTraverse('ExperienceTooltip');
var expPercent = panel.FindChildTraverse('ExperiencePercent');
var expValue = panel.FindChildTraverse('ExperienceValue');
/* Panorama CSS makes it impossible to use 100%
so we get to use maths in javascript for 0 through 567px.
Also, to throw another variable, the tooltip will only
go to the edge of the top of the angled parts of the bar.
This means 0% of tooltip will need to apply to 0% through n%
of exp, then track evenly up to max.
0% exp = 0% tooltip
1.4% exp = 0% tooltip
97.6% exp = 100% tooltip
100% exp = 100% tooltip
*/


GameEvents.Subscribe('focus_target_updated', function(params)
{
    GameUI.customCurrentFocusId = params.id
});
function GetFocusTarget()
{
    return GameUI.customCurrentFocusId;
}

function SetFocusTarget(entityIndex)
{
    GameUI.customCurrentFocusId = entityIndex;
    GameEvents.SendCustomGameEventToServer('focus_target', {
        target: entityIndex
    });
}


function clamp(val, min, max) {
    return Math.min(Math.max(val, min), max);
}

function map_range(value, low1, high1, low2, high2) {
    return low2 + (high2 - low2) * (value - low1) / (high1 - low1);
}

function UpdateExperience(expCurrent, expGoal) {

    if (expGoal == 0)
    {
        expPercent.text = '10';
        expValue.text = 'Max Level';
        expTip.style.marginLeft = '286px';
        expBar.style.width = '100%';
        return;
    }

    var percent = expCurrent * 100 / expGoal;
    if (isNaN(percent)) percent = 0;

    expPercent.text = Math.round(percent)+'%';
    expValue.text = expCurrent + ' / '+expGoal+' XP';
    expBar.style.width = percent+'%';

    var px = percent;
    px = clamp(px, 1.4, 97.6);
    px = map_range(px, 1.4, 97.6, 0, 567);

    expTip.style.marginLeft = px+'px';
}

var globeHealth = panel.FindChildTraverse('GlobeHealth');
var globeMana = panel.FindChildTraverse('GlobeMana');

// May consider splitting out...
////////////////////////////////////////////////////////////

// This function is for the "focus" unit.
// Players.GetLocalPlayerPortraitUnit();

// var playerIdBad = Players.GetLocalPlayer(); // Didn't work for some reason...
var playerId = Game.GetLocalPlayerID();
// var heroId = Players.GetPlayerHeroEntityIndex(playerId); // Is just -1.

var currentLevelXp = 200;
var lastLevelXp = 0;

// $.Msg(Entities.GetUnitName(entityId))

function SetHeroUnitPanel(entityId)
{
    // Set the movie portrait
    panel.FindChildTraverse('HeroPortrait').heroname = Entities.GetUnitName(entityId);
    panel.FindChildTraverse('HeroLevel').text = Entities.GetLevel(entityId);

    var healthMax = Entities.GetMaxHealth(entityId);
    var health = Entities.GetHealth(entityId);
    var healthPercent = health / healthMax;
    if (isNaN(healthPercent)) healthPercent = 0;
    panel.FindChildTraverse('HealthBar').style.width = (healthPercent * 265)+'px';

    var manaMax = Entities.GetMaxMana(entityId);
    var mana = Entities.GetMana(entityId);
    var manaPercent = mana / manaMax;
    if (isNaN(manaPercent)) manaPercent = 0;
    panel.FindChildTraverse('ManaBar').style.width = (manaPercent * 246)+'px';

    var healthRegen = Entities.GetHealthThinkRegen(entityId).toFixed(1);
    var manaRegen = Entities.GetManaThinkRegen(entityId).toFixed(1);

    panel.FindChildTraverse('HeroHealthBarValue').text = health+'/'+healthMax + ' +'+healthRegen;
    panel.FindChildTraverse('HeroManaBarValue').text = mana+'/'+manaMax + ' +'+manaRegen;

    // Toggle visibility based on whether we have a valid selection.
    // Consider checking if entity is hero and hiding anyways.
    var visibility = (Entities.GetLevel(entityId) == -1) ? 'collapse' : 'visible';
    panel.FindChildTraverse('HeroUnitFrame').style.visibility = visibility;
}

function ChangeTargetUnitPanel(entityId)
{
    var panel = $.GetContextPanel();

    var heroEntId = Players.GetPlayerHeroEntityIndex(playerId);
    var heroLevel = Entities.GetLevel(heroEntId);
    var entityLevel = Entities.GetLevel(entityId);
    var diff = entityLevel - heroLevel;

    if (heroEntId == entityId || Entities.GetLevel(entityId) == -1 || entityId == -1)
    {
        panel.FindChildTraverse('TargetFrame').style.visibility = 'collapse';
    }
    else
    {
        panel.FindChildTraverse('TargetFrame').style.visibility = 'visible';
    }

    var entityName = Entities.GetUnitName(entityId);
    panel.FindChildTraverse('TargetName').text = $.Localize('#'+entityName);

    var container = panel.FindChildTraverse('TargetLevelContainer');

    container.SetHasClass('hard', diff >= 2);
    container.SetHasClass('normal', diff < 2 && diff >= -5);
    container.SetHasClass('easy', diff < -5);

    // It is not a state secret.
    panel.FindChildTraverse('TargetLevel').text = entityLevel;
}

function UpdateTargetUnitPanel()
{
    var panel = $.GetContextPanel();

    var entityId = GetFocusTarget();
    if (entityId == undefined) return;

    if (!Entities.IsValidEntity(entityId))
    {
        // If it isn't already -1.
        if (entityId != -1)
        {
            SetFocusTarget(-1)
        }
        entityId = -1;
    }

    if (panel.targetFocusId != entityId)
    {
        panel.targetFocusId = entityId;
        ChangeTargetUnitPanel(entityId);
    }

    var healthMax = Entities.GetMaxHealth(entityId);
    var health = Entities.GetHealth(entityId);
    var healthPercent = health / healthMax;
    if (isNaN(healthPercent)) healthPercent = 0;
    panel.FindChildTraverse('TargetHealthBar').style.width = (healthPercent * 246)+'px';

    // Toggle visibility based on whether we have a valid selection.
    // Consider checking if entity is hero and hiding anyways.
}

function UpdateUnitPanel() {
    // Hack
    $.Schedule(0.1, UpdateUnitPanel);

    UpdateTargetUnitPanel()

    var panel = $.GetContextPanel();

    // Wasn't available at init.
    var heroId = Players.GetPlayerHeroEntityIndex(playerId);

    // For now let's remain on the hero, until we have a proper target frame.
    SetHeroUnitPanel(heroId);

        // Action Bar
    var healthMax = Entities.GetMaxHealth(heroId);
    var health = Entities.GetHealth(heroId);
    var healthPercent = health / healthMax;
    if (isNaN(healthPercent)) healthPercent = 0;
    globeHealth.style.height = (healthPercent*100)+'%';

    var manaMax = Entities.GetMaxMana(heroId);
    var mana = Entities.GetMana(heroId);
    var manaPercent = mana / manaMax;
    if (isNaN(manaPercent)) manaPercent = 0;
    globeMana.style.height = (manaPercent*100)+'%';

    if (Entities.GetNeededXPToLevel(heroId) > currentLevelXp) {
        // Recompute
        lastLevelXp = currentLevelXp;
        currentLevelXp = Entities.GetNeededXPToLevel(heroId);
    }
    var currentForLevel = Entities.GetCurrentXP(heroId) - lastLevelXp;
    var needForLevel = Entities.GetNeededXPToLevel(heroId) - lastLevelXp;

    // Don't use less than zero.
    needForLevel = Math.max(needForLevel, 0);

    UpdateExperience(currentForLevel, needForLevel);
}

UpdateUnitPanel();

