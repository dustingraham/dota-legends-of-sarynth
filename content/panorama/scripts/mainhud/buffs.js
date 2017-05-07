///
// Track known buffs, and add/remove from unit target frame as needed.

var currentBuffTargetId = -1;
var currentBuffs = [];

function BuffUpdater()
{
    $.Schedule(0.03, BuffUpdater);

    var panel = $.GetContextPanel();
    var id = panel.targetFocusId;

    // TODO: Fade in/out when created/removed?

    if (currentBuffTargetId !== id)
    {
        currentBuffTargetId = id;
        currentBuffs = [];
        $('#Debuffs').RemoveAndDeleteChildren();
        $('#Buffs').RemoveAndDeleteChildren();
    }

    if (id === -1) return;

    var foundBuffs = [];
    var num = Entities.GetNumBuffs(id);
    for (var i = 0; i < num; i++)
    {
        var buffId = Entities.GetBuff(id, i);
        if (Buffs.IsHidden(id, buffId)) continue;
        BuildBuffBlock(id, buffId);
        foundBuffs[buffId] = true;
    }

    // Remove any that have disappeared.
    $.Each(currentBuffs, function(panel, buffId)
    {
        if (!foundBuffs[buffId])
        {
            panel.DeleteAsync(0);
            delete currentBuffs[buffId];
        }
    });
}

var BuildBuffBlock = function(id, buffId)
{
    var panel;
    if (currentBuffs[buffId])
    {
        panel = currentBuffs[buffId];
    }
    else
    {
        var buffImage = 'raw://resource/flash3/images/spellicons/'+Buffs.GetTexture(id, buffId)+'.png';
        var parent = Buffs.IsDebuff(id, buffId) ? $('#Debuffs') : $('#Buffs');
        panel = $.CreatePanel('Panel', parent, '');
        panel.BLoadLayoutSnippet('Buff');
        panel.FindChildTraverse('BuffImage').SetImage(buffImage);
        if (Buffs.IsDebuff(id, buffId))
        {
            panel.FindChildTraverse('BuffBorder').AddClass('is_debuff');
        }

        var buffName  = Buffs.GetName(id, buffId);
        var buffTitle = $.Localize('DOTA_Tooltip_'+buffName);
        var buffDesc  = $.Localize('DOTA_Tooltip_'+buffName+'_Description');

        panel.SetPanelEvent('onmouseover', function() {
            $.DispatchEvent('DOTAShowTitleTextTooltip', panel, buffTitle, buffDesc);
        });
        panel.SetPanelEvent('onmouseout', function() {
            $.DispatchEvent('DOTAHideTitleTextTooltip');
        });

        currentBuffs[buffId] = panel;
    }

    var duration = Buffs.GetDuration(id, buffId);
    if (duration > 0)
    {
        var remaining = RemapVal(Buffs.GetRemainingTime(id, buffId), 0, duration, 0, 360);
        var elapsed = RemapVal(Buffs.GetElapsedTime(id, buffId), 0, duration, 0, 360);
        panel.FindChildTraverse('CircularDuration').style.clip = 'radial(50.0% 50.0%, '+elapsed+'deg, '+remaining+'deg)';
    }
    else
    {
        panel.FindChildTraverse('CircularDuration').style.clip = 'radial(50.0% 50.0%, 0deg, 360deg)';
    }

    var stacks = Buffs.GetStackCount(id, buffId);
    if (stacks > 0)
    {
        panel.SetHasClass('has_stacks', true);
        panel.FindChildTraverse('StackCount').text = stacks;
    }
};

BuffUpdater();

// ["GetName","GetClass","GetTexture","GetDuration","GetDieTime","GetRemainingTime","GetElapsedTime","GetCreationTime","GetStackCount","IsDebuff","IsHidden","GetCaster","GetParent","GetAbility"]
