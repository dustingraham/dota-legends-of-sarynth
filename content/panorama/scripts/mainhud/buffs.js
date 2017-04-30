
function BuffUpdater()
{
    $.Schedule(0.03, BuffUpdater);

    var panel = $.GetContextPanel();
    var id = panel.targetFocusId;

    // TODD: Don't delete every time...
    // TODO: Fade in/out when created/removed.
    $('#Debuffs').RemoveAndDeleteChildren();
    $('#Buffs').RemoveAndDeleteChildren();

    if (id === -1) return;
    var num = Entities.GetNumBuffs(id);
    for(var i = 0; i < num; i++)
    {
        var buffId = Entities.GetBuff(id, i);
        if (Buffs.IsHidden(id, buffId)) continue;
        BuildBuffBlock(id, buffId);
    }
}

var BuildBuffBlock = function(id, buffId)
{
    var buffImage = 'raw://resource/flash3/images/spellicons/'+Buffs.GetTexture(id, buffId)+'.png';
    //var test = 'file://{images}/spellicons/brewmaster_earth_hurl_boulder.png';

    var parent = Buffs.IsDebuff(id, buffId) ? $('#Debuffs') : $('#Buffs');
    var panel = $.CreatePanel('Panel', parent, '');
    panel.BLoadLayoutSnippet('Buff');
    panel.FindChildTraverse('BuffImage').SetImage(buffImage);
    if (Buffs.IsDebuff(id, buffId))
    {
        panel.FindChildTraverse('BuffBorder').AddClass('is_debuff');
    }

    var stacks = Buffs.GetStackCount(id, buffId);
    if (stacks > 0)
    {
        // TODO!!
        $.Msg('Stacks: '+stacks);
    }

    var duration = Buffs.GetDuration(id, buffId);
    if (duration > 0)
    {
        var remaining = RemapVal(Buffs.GetRemainingTime(id, buffId), 0, duration, 0, 360);
        var elapsed = RemapVal(Buffs.GetElapsedTime(id, buffId), 0, duration, 0, 360);
        panel.FindChildTraverse('CircularDuration').style.clip = 'radial(50.0% 50.0%, '+elapsed+'deg, '+remaining+'deg)';
    }
};

BuffUpdater();
