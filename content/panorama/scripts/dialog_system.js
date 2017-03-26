
var panel = $.GetContextPanel();
var dialog = $.GetContextPanel().FindChild('QuestDialog');

function OnDialogStart(data) {
    //$.Msg('[JS] On Questgiver Open');
    
    if (data.panelType == 'quest_start')
    {
        UpdateQuestStartPanel(data);
    }
    else if (data.panelType == 'quest_complete')
    {
        UpdateQuestCompletePanel(data);
    }
    else
    {
        $.Msg('Unknown panel type');
    }
    
    dialog.SetHasClass('hidden', false);
}


GameEvents.Subscribe('dialog_start', OnDialogStart);


function UpdateQuestStartPanel(data)
{
    $.Msg('[JS] Need to populate...');
    $.Msg(data);
    
    var panel = $.GetContextPanel();
    panel.FindChildTraverse('QuestMainTitle').text = data.title;
    panel.FindChildTraverse('MainDialog').text = data.dialog_text;
    
    var hide = true;
    var objectives = '';
    $.Each(data.objectives, function(objective, i)
    {
        hide = false;
        // $.Msg('ObjId: '+i);
        objectives += '• '+objective.long_description+'<br>';
    });
    panel.FindChildTraverse('MainObjectives').text = objectives;
    
    var setVisible = hide ? 'collapse' : 'visible';
    panel.FindChildTraverse('ObjectiveTitle').style.visibility = setVisible;
    panel.FindChildTraverse('MainObjectives').style.visibility = setVisible;
    
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
    
    panel.FindChildTraverse('QuestAcceptText').text = 'Accept';
    panel.FindChildTraverse('QuestDecline').style.visibility = 'visible';
}

function UpdateQuestCompletePanel(data)
{
    $.Msg('[JS] Need to populate...');
    $.Msg(data);
    
    var panel = $.GetContextPanel();
    panel.FindChildTraverse('QuestMainTitle').text = data.title;
    panel.FindChildTraverse('MainDialog').text = data.dialog_text;
    
    panel.FindChildTraverse('ObjectiveTitle').style.visibility = 'collapse';
    panel.FindChildTraverse('MainObjectives').style.visibility = 'collapse';
    
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
    
    panel.FindChildTraverse('QuestAcceptText').text = 'Complete';
    panel.FindChildTraverse('QuestDecline').style.visibility = 'collapse';
}

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
    panel.FindChildTraverse('TitleContainer').SetPanelEvent('onactivate', function() {
        // $.Msg('Quest: ', params);
    });
    
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
    InitQuestTableListener();
// if (mapName == 'introduction')
// {
//     InitQuestTableListener();
// }
// else
// {
//     $.Msg('[Warning] Not Introduction Map');
// }
