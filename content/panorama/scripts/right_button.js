"use strict";
// Originally provided by Dreoh

GameUI.customCurrentFocusId = -1;

function OnLeftButtonPressed()
{
    var CONTINUE_PROCESSING_EVENT = false;
    var CONSUME_EVENT = true;
    
    var cursor = GameUI.GetCursorPosition();
    var mouseEntities = GameUI.FindScreenEntities(cursor);
    
    for ( var e of mouseEntities )
    {
        var entityIndex = e.entityIndex
        if (Entities.IsSelectable(entityIndex))
        {
            GameUI.customCurrentFocusId = entityIndex;
            
            var healthMax = Entities.GetMaxHealth(entityIndex);
            var health = Entities.GetHealth(entityIndex);
            var healthPercent = health / healthMax;
            if (isNaN(healthPercent)) healthPercent = 0;
            $.Msg('HP: '+(healthPercent*100) +'%');
            
            $.Msg(Entities.GetUnitName(entityIndex));
            
            // This will help prevent flickering of ability controls by
            // avoiding selection of the units. Still todo target unit frame.
            return CONSUME_EVENT;
        }
    }
    
    return CONTINUE_PROCESSING_EVENT;
}

// Handle Right Button events
function OnRightButtonPressed()
{
    // $.Msg("OnRightButtonPressed")

    var iPlayerID = Players.GetLocalPlayer();
    var mainSelected = Players.GetLocalPlayerPortraitUnit(); 
    var hero = Players.GetPlayerHeroEntityIndex( iPlayerID );
    var heroName = Entities.GetUnitName(hero);
    // $.Msg(heroName)
    
    //var mainSelectedName = Entities.GetUnitName( mainSelected );
    var cursor = GameUI.GetCursorPosition();
    var mouseEntities = GameUI.FindScreenEntities( cursor );
    //mouseEntities = mouseEntities.filter( function(e) { return e.entityIndex != mainSelected; } )
    
    //var pressedShift = GameUI.IsShiftDown();

    for ( var e of mouseEntities )
    {
        var entityIndex = e.entityIndex
        if (Entities.IsInvulnerable( entityIndex )){
            var order = {
                UnitIndex : hero,
                TargetIndex : entityIndex,
                OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_MOVE_TO_TARGET,
                QueueBehavior : OrderQueueBehavior_t.DOTA_ORDER_QUEUE_NEVER,
                ShowEffects : false
            };

            Game.PrepareUnitOrders( order );
            //$.Msg('Custom behavior');
            return true;
        }
        
        if (Entities.IsEnemy(entityIndex))
        {
            GameUI.customCurrentFocusId = entityIndex;
            return false;
        }
        
        // else if (IsShop (entityIndex) || IsHarvest (entityIndex) || IsBank(entityIndex)) {
        //     $.Msg('Shop Harvest Bank');
            
        //     var order = {
        //         UnitIndex : hero,
        //         TargetIndex : entityIndex,
        //         OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_MOVE_TO_TARGET,
        //         QueueBehavior : OrderQueueBehavior_t.DOTA_ORDER_QUEUE_NEVER,
        //         ShowEffects : false
        //     };

        //     Game.PrepareUnitOrders( order );

        //     return true;
        // } else if (IsSwitch (entityIndex)) {
            
        //     GameEvents.SendCustomGameEventToServer( "interactable", { pID: iPlayerID, unit: hero, target: entityIndex })

        //     return true;
        // }else if (IsNPC(entityIndex)){
        //     $.Msg("Unit is an NPC")
        //     $.Msg("Unit name is " +Entities.GetUnitName(entityIndex))

        //     GameEvents.SendCustomGameEventToServer( "npc_interact", { pID: iPlayerID, unit: hero, target: entityIndex })

        //     return true;
        // }else if (IsPotionFountain(entityIndex)){
        //     GameEvents.SendCustomGameEventToServer( "potion_refill", { pID: iPlayerID, unit: hero, target: entityIndex })
        //     return true;
        // }else if (IsEventUnit(entityIndex)){
        //     GameEvents.SendCustomGameEventToServer( "event_unit_clicked", { pID: iPlayerID, unit: hero, target: entityIndex })
        //     return true;
        // }else if (heroName == "npc_dota_hero_rattletrap" && Entities.GetTeamNumber(entityIndex) != Entities.GetTeamNumber(hero) && !Entities.IsItemPhysical(entityIndex)){
        //     //Gunner target aqcuire
        //     GameEvents.SendCustomGameEventToServer( "gunner_aqcuire_target", { pID: iPlayerID, unit: hero, target: entityIndex })
        //     return true;
        // }
    }

    // if (GameUI.IsAltDown() && heroName == "npc_dota_hero_rattletrap"){
    //     GameEvents.SendCustomGameEventToServer( "gunner_remove_target", { pID: iPlayerID, unit: hero })
    // }
    
    //$.Msg('Default behavior');
    return false;
}

function IsSwitch( entityIndex ){
    var name = Entities.GetUnitName(entityIndex)
    return (name=="npc_dota_creature_gate_03_button")   
}

function IsHarvest( entityIndex ){
    return (Entities.GetSelectionGroup(entityIndex) == "Harvest")
}

function IsNPC( entityIndex ){
    return (Entities.GetSelectionGroup(entityIndex) == "NPC")
}

function IsPotionFountain( entityIndex ){
    return (Entities.GetSelectionGroup(entityIndex) == "PotionRefill")
}

function IsEventUnit( entityIndex ){
    return (Entities.GetSelectionGroup(entityIndex) == "Event")
}

function IsShop( entityIndex ){
    return (Entities.GetSelectionGroup(entityIndex) == "Shop")
}

function IsHarvest( entityIndex ){
    return (Entities.GetSelectionGroup(entityIndex) == "Harvest")
}

function IsBank( entityIndex ){
    return (Entities.GetSelectionGroup(entityIndex) == "Bank")
}

function IsTeamControlled ( entityIndex ) {
    var iPlayerID = Players.GetLocalPlayer();
    var hero = Players.GetPlayerHeroEntityIndex( iPlayerID );
    var teamID = Entities.GetTeamNumber( hero )
    var playersOnTeam = Game.GetPlayerIDsOnTeam( teamID );
    for (var i = 0; i < playersOnTeam.length; i++)
    {
        if (Entities.IsControllableByPlayer( entityIndex, playersOnTeam[i] ))
        {
            return true
        }
    };
    return false
}

// Main mouse event callback
GameUI.SetMouseCallback(function( eventName, arg ) {
    var CONSUME_EVENT = true;
    var CONTINUE_PROCESSING_EVENT = false;
    var LEFT_CLICK = (arg === 0)
    var RIGHT_CLICK = (arg === 1)
    if ( GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE )
        return CONTINUE_PROCESSING_EVENT;

    var mainSelected = Players.GetLocalPlayerPortraitUnit()

    if ( eventName === "pressed" || eventName === "doublepressed")
    {
        if (LEFT_CLICK) 
        {
            return  OnLeftButtonPressed();
        }
        if (RIGHT_CLICK) 
        {
            return OnRightButtonPressed();
        }
    }
    
    return CONTINUE_PROCESSING_EVENT;
});
