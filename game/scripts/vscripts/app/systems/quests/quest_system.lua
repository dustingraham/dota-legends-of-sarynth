--[[

    Usage
    QuestSystem:Boot()
    
    QuestSystem:UpdateAvailableQuests(hero)
     - Loop through all quests:
     -- Ignore completed quests.
     -- Ignore quest if prerequisites 
     -- ? Don't highlight if < 5 levels
     - If available, light up npc.
    
    NpcAI - modifier for each npc that handles dialog and interactions
     - QuestNpc - reference to quest npc modifier to include quests in dialog options.
     - Handles right-click interactions.
    
    QuestNpc - modifier with particle for indication and right click interaction
    
    Quest
     - Quest Data
     - array[playerid] QuestProgress
     - reference to Quest NPC
    
    QuestData - the actual quest data, loaded from KV.
    QuestProgress - the individual hero's progress.
    
    
    QuestProgress
     - QuestID
     - PlayerID (redundant, convenience)
     - CharacterID
     - Objectives
     -- ObjectiveID
     -- CompletedCount
     
]]

---
-- @type QuestSystem
QuestSystem = QuestSystem or class({})


