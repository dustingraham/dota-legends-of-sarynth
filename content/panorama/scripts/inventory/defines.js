

// Item Data Slot Types
// 0  = non-equipment
// 1  = weapon
// 2  = offhand
// 3  = Helm
// 4  = Neck
// 5  = Chest
// 6  = sholders
// 7  = gloves
// 8  = pants
// 9  = belt
// 10 = boots
// 11 = ring
// 80 = shop
// 81 = buyback

var ITEM_SLOT_INVENTORY = 0;

var ITEM_SLOT_GEAR_MIN = 1;

var ITEM_SLOT_GEAR_WEAPON = 1;
var ITEM_SLOT_GEAR_OFFHAND = 2;
var ITEM_SLOT_GEAR_HELM = 3;
var ITEM_SLOT_GEAR_NECK = 4;
var ITEM_SLOT_GEAR_CHEST = 5;
var ITEM_SLOT_GEAR_BOOTS = 10;
var ITEM_SLOT_GEAR_RING = 11;

var ITEM_SLOT_GEAR_MAX = 11;

var ITEM_SLOT_SHOP = 80;
var ITEM_SLOT_BUYBACK = 81;

var panelSlotTypes = {
    1: ITEM_SLOT_GEAR_HELM, // Helm
    2: ITEM_SLOT_GEAR_NECK, // Neck
    3: ITEM_SLOT_GEAR_CHEST, // Chest
    // 4 reserved sholders
    // 5 reserved gloves
    // 6 reserved pants
    // 7 reserved belt
    8: ITEM_SLOT_GEAR_RING, // ring1
    9: ITEM_SLOT_GEAR_RING, // ring2
    10: ITEM_SLOT_GEAR_BOOTS, // boots
    11: ITEM_SLOT_GEAR_WEAPON, // weapon
    12: ITEM_SLOT_GEAR_OFFHAND // offhand
};

var unitNamesToClass= {
    npc_dota_hero_dragon_knight: 'Warrior',
    npc_dota_hero_omniknight: 'Paladin',
    npc_dota_hero_bounty_hunter: 'Rogue',
    npc_dota_hero_windrunner: 'Ranger',
    npc_dota_hero_invoker: 'Mage',
    npc_dota_hero_warlock: 'Sorcerer'
};
