
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
    
    // Toggle visibility based on whether we have a valid selection.
    // Consider checking if entity is hero and hiding anyways.
    var visibility = (Entities.GetLevel(entityId) == -1) ? 'collapse' : 'visible';
    panel.FindChildTraverse('HeroUnitFrame').style.visibility = visibility;
}

function UpdateUnitPanel() {
    // Hack
    $.Schedule(0.1, UpdateUnitPanel);
    
    var panel = $.GetContextPanel();
    
    // Wasn't available at init.
    var heroId = Players.GetPlayerHeroEntityIndex(playerId);
    
    // For now let's remain on the hero, until we have a proper target frame.
    //SetHeroUnitPanel(GameUI.customCurrentFocusId);
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

var dialog = $.GetContextPanel().FindChild('QuestDialog');
function QuestDialog(response) {
    // $.Msg('Dialog Response: ' + response)
    GameEvents.SendCustomGameEventToServer('questgiver_dialog_event', { result: response });
    dialog.SetHasClass('hidden', true);
}

var toggle = false;
function Toggle() {
    dialog.SetHasClass('hidden', toggle);
    toggle = !toggle;
    //$.Schedule(1, Toggle);
}

//$.Schedule(10, Toggle);
//Toggle();

function OnQuestgiverOpen(data) {
    //$.Msg('[JS] On Questgiver Open');
    
    UpdateQuestPanel(data);
    
    dialog.SetHasClass('hidden', false);
}

function UpdateQuestPanel(data)
{
    //$.Msg('[JS] Need to populate...');
    //$.Msg(data);
    
    var panel = $.GetContextPanel();
    panel.FindChildTraverse('QuestMainTitle').text = data.title;
    panel.FindChildTraverse('MainDialog').text = data.start.dialog;
    var objectives = '';
    $.Each(data.objectives, function(objective, i)
    {
        // $.Msg('ObjId: '+i);
        objectives += '• '+objective.long_description+'<br>';
    });
    // • Choose an item below.
    
    panel.FindChildTraverse('MainObjectives').text = objectives;
    
    var rewards = '';
    if (data.rewards.gold)
    {
        rewards += '• '+data.rewards.gold + ' gold pieces<br>';
    }
    if (data.rewards.experience)
    {
        rewards += '• '+data.rewards.experience + ' experience<br>';
    }
    
    if (data.rewards.item_choose)
    {
        // rewards += '• Maybe an item...<br>';
    }
    
    panel.FindChildTraverse('MainRewards').text = rewards;
}

GameEvents.Subscribe('questgiver_open', OnQuestgiverOpen);


if ($.GetContextPanel().activeQuests === undefined)
{
    $.GetContextPanel().activeQuests = {};
}
var activeQuests = $.GetContextPanel().activeQuests;


var BuildObjectivesHtml = function(objectives)
{
    var html = [];
    $.Each(objectives, function(o)
    {
        var oHtml = ''
        if (o.required > 1)
        {
            oHtml += o.current + '/' + o.required + ' ';
        }
        oHtml += o.description;
        if (o.current == o.required)
        {
            oHtml = '<span class="completed">'+oHtml+'</span>'
        }
        // $.Msg(o);
        html.push(oHtml);
    });
    return html.join('<br>');
};

var UpdateQuestBlock = function(panel, params)
{
    //$.Msg(params);
    // panel.FindChildTraverse('Title').text = params.title;
    
    var html = BuildObjectivesHtml(params.objectives);
    panel.FindChildTraverse('Progress').text = html;
    
    var allComplete = true;
    $.Each(params.objectives, function(o)
    {
        if (o.current != o.required)
        {
            allComplete = false;
        }
    });
    panel.SetHasClass('quest-complete', allComplete);
    
    // if (params.current == params.required)
    // {
    //     var text = panel.FindChildTraverse('Progress')
    //     text.style.color = 'gold';
    //     text.text = 'Done!';
    // }
    // else
    // {
    //      = 'ab<br>'+params.current + '/' + params.required;
    // }
};

var BuildQuestBlock = function(params)
{
    var panel = $.CreatePanel('Panel', $('#QuestBlocks'), '');
    panel.BLoadLayoutSnippet('QuestProgress');
    panel.FindChildTraverse('Title').text = params.title;
    panel.FindChildTraverse('Progress').text = BuildObjectivesHtml(params.objectives);
    
    return panel;
};

var RemoveQuestBlock = function(key)
{
    var panel = activeQuests[key];
    
    delete activeQuests[key];
    
    panel.DeleteAsync(0);
    
    $('#QuestProgressContainer').style.visibility = (Object.keys(activeQuests).length > 0) ? 'visible' : 'collapse';
    
    // $.Schedule(2, function()
    // {
    //     panel.DeleteAsync(0);
    // });
};
var InitQuestTableListener = function() {
    var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
    
    var playerId = Game.GetLocalPlayerID();
    var playerTableKey = 'player_'+playerId+'_quests';
    // GameEvents.Subscribe('bosses_new_boss', OnNewBoss);
    // GameEvents.Subscribe('bosses_boss_tick', OnNewBossTick);
    
    // Subscribe to changes on the client
    if (undefined === $.GetContextPanel().subscription_id)
    {
        $.GetContextPanel().subscription_id = PlayerTables.SubscribeNetTableListener(
            playerTableKey,
            function(tableName, changes, deletions) {
                //$.Msg('[JS] Table Change: '+tableName);
                //$.Msg(JSON.stringify(changes))
                //$.Msg(JSON.stringify(deletions))
                $.Each(changes, function(params, key)
                {
                    if (activeQuests[key])
                    {
                        UpdateQuestBlock(activeQuests[key], params);
                    }
                    else
                    {
                        activeQuests[key] = BuildQuestBlock(params)
                        $('#QuestProgressContainer').style.visibility = (Object.keys(activeQuests).length > 0) ? 'visible' : 'collapse';
                    }
                });
                $.Each(deletions, function(params, key)
                {
                    RemoveQuestBlock(key);
                });
            });
    }
    
    // Retrieve values on the client
    //$.Msg(PlayerTables.GetTableValue("player_0_quests", "count"));
    $.Each(PlayerTables.GetAllTableValues(playerTableKey), function(params, key)
    {
        if (activeQuests[key])
        {
            UpdateQuestBlock(activeQuests[key], params);
        }
        else
        {
            activeQuests[key] = BuildQuestBlock(params);
            $('#QuestProgressContainer').style.visibility = (Object.keys(activeQuests).length > 0) ? 'visible' : 'collapse';
        }
    });
};

var mapInfo = Game.GetMapInfo();
var mapName = mapInfo.map_display_name;
if (mapName == 'introduction')
{
    InitQuestTableListener();
}
else
{
    $.Msg('[Warning] Not Introduction Map');
}
