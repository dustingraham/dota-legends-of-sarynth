---
-- Music
-- Author: Sarynth
Music = Music or class({})

--GameRules:GetGameModeEntity():EmitSound('jboberg_01.music.ui_hero_select')
Music.Zones = {
    zone_start_area = 'Music.Zone.Start',
    zone_town = 'Music.Zone.Town',
    zone_kobolds = 'Music.Zone.Kobolds',
    zone_webbed = 'Music.Zone.Webbed',
    zone_dark = 'Music.Zone.Dark',
    zone_druids = 'Music.Zone.Druids',
    zone_snow = 'Music.Zone.Snow',
}

-- Reference:
-- https://github.com/SteamDatabase/GameTracking-Dota2/blob/master/game/dota/pak01_dir/soundevents/music/dsadowski_02/soundevents_music.vsndevts
-- 'soundevents/music/deadmau5_01/soundevents_music.vsndevts',
-- 'soundevents/music/dsadowski_02/soundevents_music.vsndevts',
-- 'soundevents/music/jlin_01/soundevents_music.vsndevts',

Music.Fights = {
    -- Dark Boss Fight
    dark_boss_start = 'jboberg_01.music.roshan',
    dark_boss_end = 'jboberg_01.music.roshan_end',
}

Music.Current = {}

function Music:Play(sound, pid)
    Debug('Music', 'Play', sound, 'for player', pid)
    if Music.Current[pid] then
        Sounds:Stop(Music.Current[pid], pid)
    end
    Music.Current[pid] = sound
    Sounds:Start(sound, pid)
end

function Music:OnZoneIn(_, event)
    local pid = event.hero:GetPlayerOwnerID()
    local sound = Music.Zones[event.zone]
    if sound then
        self:Play(sound, pid)
    else
        Debug('Music', 'Missing music zone declaration for...', event.zone)
    end
end

function Music:Activate()
    Event:Listen('ZoneIn', Dynamic_Wrap(Music, 'OnZoneIn'), Music)
end
Event:BindActivate(Music)
