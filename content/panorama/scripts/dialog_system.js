
var panel = $.GetContextPanel();
var dialog = $.GetContextPanel().FindChild('QuestDialog');

function OnDialogStart(data) {
    //$.Msg('[JS] On Questgiver Open');

    if (data.panelType === 'quest_start')
    {
        UpdateQuestStartPanel(data);
    }
    else if (data.panelType === 'quest_complete')
    {
        UpdateQuestCompletePanel(data);
    }
    else if (data.panelType === 'teleport')
    {
        UpdateTeleportDialog(data);
    }
    else
    {
        $.Msg('Unknown panel type');
        $.Msg(data);
    }

    dialog.SetHasClass('hidden', false);
}

GameEvents.Subscribe('dialog_start', OnDialogStart);
GameEvents.Subscribe('dialog_close', function()
{
    dialog.SetHasClass('hidden', true);
});

function UpdateBasics(panel, data)
{
    panel.FindChildrenWithClassTraverse('quest-dialog-icon').forEach(function(icon) {
        icon.style.visibility = 'collapse';
    });
    panel.FindChildTraverse('icon_'+data.panelType).style.visibility = 'visible';

    panel.FindChildTraverse('QuestMainTitle').text = data.title;
    panel.FindChildTraverse('MainDialog').text = data.dialog_text;

    panel.FindChildTraverse('TeleportOptions').RemoveAndDeleteChildren();
}

function UpdateTeleportDialog(data)
{
    var panel = $.GetContextPanel();
    panel.selectedTeleport = false;

    data.title = 'Manaflow Transporter';
    var text = 'Welcome to the Manaflow Transporter!<br><br>';

    if (data.justUnlocked)
    {
        text += '<span class="highlight">You have unlocked this location as a transport destination option.</span><br><br>';
    }
    if (!data.hasOptions)
    {
        text += 'As you explore new areas, be sure to unlock other locations in order to quickly navigate around the world.';
    }
    else
    {
        text += 'Where would you like to go?';
    }

    data.dialog_text = text;

    UpdateBasics(panel, data);

    // Station unlocked!
    // Where would you like to flow today?
    panel.FindChildTraverse('ObjectiveTitle').style.visibility = 'collapse';
    panel.FindChildTraverse('MainObjectives').style.visibility = 'collapse';
    panel.FindChildTraverse('ItemRewardBlock').style.visibility = 'collapse';
    panel.FindChildTraverse('MainRewards').style.visibility = 'collapse';
    panel.FindChildTraverse('RewardsTitle').style.visibility = 'collapse';

    $.Msg(data);

    // Build Options
    var $teleportOptions = $('#TeleportOptions');
    if (data.hasOptions)
    {
        $teleportOptions.RemoveAndDeleteChildren();
        QuestAccept('Go!', true, function()
        {
            // Ignore if no selection yet.
            if (!panel.selectedTeleport) return;
            $.Msg('Kick off teleport to: '+panel.selectedTeleport);
            GameEvents.SendCustomGameEventToServer('dialog_event', {
                result: true,
                destination: panel.selectedTeleport
            });
            dialog.SetHasClass('hidden', true);
        });

        // panel.FindChildTraverse('QuestAccept').AddClass('disabled');
        // panel.FindChildTraverse('QuestAcceptText').text = 'Go!';
        // panel.FindChildTraverse('QuestAccept').SetPanelEvent('onactivate', function()
        // {
        //     $.Msg('Teleport On Activate');
        // });
        panel.FindChildTraverse('QuestDeclineText').text = 'Cancel';
        panel.FindChildTraverse('QuestDecline').style.visibility = 'visible';

        // Selection List
        $.Each(data.teleportOptions, function(v, k)
        {
            $.Msg('K: '+k+' V: '+v+' T:'+$.Localize(v));
            var $option = $.CreatePanel('Button', $teleportOptions, '');
            $option.BLoadLayoutSnippet('TeleportOption');
            $option.FindChildTraverse('Name').text = $.Localize(v);
            $option.SetPanelEvent('onactivate', function() {
                panel.selectedTeleport = k;
                $.Each($teleportOptions.Children(), function($btn) {
                    $btn.RemoveClass('checked');
                });
                $option.AddClass('checked');
                panel.FindChildTraverse('QuestAccept').RemoveClass('disabled');
            });
        });
        $teleportOptions.style.visibility = 'visible';
    }
    else
    {
        $teleportOptions.style.visibility = 'collapse';
        panel.FindChildTraverse('QuestDecline').style.visibility = 'collapse';
        QuestAccept('Okay!');
        // panel.FindChildTraverse('QuestAcceptText').text = 'Okay!';
        // panel.FindChildTraverse('QuestAccept').RemoveClass('disabled');
        // panel.FindChildTraverse('QuestAccept').SetPanelEvent('onactivate', function()
        // {
        //     QuestDialog(true);
        // });
    }
}

function QuestAccept(title, disabled, callback)
{
    if (disabled === undefined) disabled = false;
    if (callback === undefined) callback = function() {
        QuestDialog(true);
    };

    var $accept = $('#QuestAccept');
    $('#QuestAcceptText').text = title;
    $accept.SetHasClass('disabled', disabled);
    $accept.SetPanelEvent('onactivate', callback);
}

//
// function TmpActivate(id)
// {
//     var $target = $('#TeleportOption'+id);
//     $.Msg('TmpActivate : ' + id);
//     if ($target.BHasClass('checked'))
//     {
//         return;
//
//         $.Msg('Removing...');
//         $target.RemoveClass('checked');
//     }
//     else
//     {
//         $('#TeleportOption1').RemoveClass('checked');
//         $('#TeleportOption2').RemoveClass('checked');
//         $('#TeleportOption3').RemoveClass('checked');
//
//         $.Msg('Adding...');
//         $target.AddClass('checked');
//     }
// }

function UpdateQuestStartPanel(data)
{
    var panel = $.GetContextPanel();
    UpdateBasics(panel, data);

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
        rewards += '• '+data.rewards.experience + ' experience';
    }

    if (data.rewards.item_choose)
    {
        // $.Msg(data.rewards.item_choose['01']);
        panel.FindChildTraverse('RewardItem').itemname = data.rewards.item_choose['01'];
        panel.FindChildTraverse('ItemRewardBlock').style.visibility = 'visible';
    }
    else
    {
        panel.FindChildTraverse('ItemRewardBlock').style.visibility = 'collapse';
    }

    panel.FindChildTraverse('RewardsTitle').style.visibility = 'visible';
    panel.FindChildTraverse('MainRewards').style.visibility = 'visible';
    panel.FindChildTraverse('MainRewards').text = rewards;
    QuestAccept('Accept');
    // panel.FindChildTraverse('QuestAcceptText').text = 'Accept';
    // panel.FindChildTraverse('QuestAccept').RemoveClass('disabled');
    // panel.FindChildTraverse('QuestAccept').SetPanelEvent('onactivate', function()
    // {
    //     QuestDialog(true);
    // });
    panel.FindChildTraverse('QuestDeclineText').text = 'Decline';
    panel.FindChildTraverse('QuestDecline').style.visibility = 'visible';
}

function UpdateQuestCompletePanel(data)
{
    var panel = $.GetContextPanel();
    UpdateBasics(panel, data);

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
        // TODO: Hide if no reward.
        // rewards += '• Maybe an item...<br>';
        panel.FindChildTraverse('RewardItem').itemname = data.rewards.item_choose['01'];
        panel.FindChildTraverse('ItemRewardBlock').style.visibility = 'visible';
    }
    else
    {
        panel.FindChildTraverse('ItemRewardBlock').style.visibility = 'collapse';
    }

    panel.FindChildTraverse('RewardsTitle').style.visibility = 'visible';
    panel.FindChildTraverse('MainRewards').text = rewards;

    QuestAccept('Complete');
    // panel.FindChildTraverse('QuestAcceptText').text = 'Complete';
    // panel.FindChildTraverse('QuestAccept').RemoveClass('disabled');
    // panel.FindChildTraverse('QuestAccept').SetPanelEvent('onactivate', function()
    // {
    //     QuestDialog(true);
    // });
    panel.FindChildTraverse('QuestDecline').style.visibility = 'collapse';
}

function QuestDialog(response) {
    // $.Msg('Dialog Response: ' + response)
    GameEvents.SendCustomGameEventToServer('dialog_event', { result: response });
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
                        activeQuests[key] = BuildQuestBlock(params);
                        $('#QuestProgressContainer').style.visibility = (Object.keys(activeQuests).length > 0) ? 'visible' : 'collapse';
                    }
                });
                $.Each(deletions, function(params, key)
                {
                    RemoveQuestBlock(key);
                });
            });
    }

    // Grab data if it is already available.
    var quests = PlayerTables.GetAllTableValues(playerTableKey);
    if (quests)
    {
        $.Each(quests, function(params, key)
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
    }
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
