---
--@type QuestRepository
QuestRepository = QuestRepository or class({})

-- To split them out...
-- LoadKeyValues('scripts/data/quests/introduction.kv')
-- function MergeTables( t1, t2 ) for name,info in pairs(t2) do t1[name] = info end end
-- MergeTables(QuestService.data, LoadKeyValues(...))

function QuestRepository:Activate()
    QuestRepository.nameCache = {}
    
    local kvFileName = 'scripts/data/'..GetMapName()..'/quests.kv'
    local data = LoadKeyValues(kvFileName)
    
    if not data then
        Debug('QuestRepository', '[ERROR] Likely KV Syntax Error: ', kvFileName)
        self.data = {}
        return
    end
    
    for id,quest in pairs(data) do
        data[id].id = id
        QuestRepository.nameCache[quest.name] = quest
        for k,v in pairs(quest.objectives) do
            if type(v.npc) == "string" then v.npc = Split(v.npc) end
        end
    end
    
    QuestRepository.data = data
end

function QuestRepository:GetQuestByName(key)
    return QuestRepository.nameCache[key]
end

function QuestRepository:GetQuestById(id)
    return QuestRepository.data[id]
end

function QuestRepository:GetQuest(key)
    return QuestRepository.data[key] or QuestRepository.nameCache[key]
end

if not QuestRepository.initialized then
    QuestRepository.initialized = true
    Event:Listen('Activate', Dynamic_Wrap(QuestRepository, 'Activate'), QuestRepository)
end
