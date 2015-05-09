------------------------------------------------------------------------------------------------
--  FasterLootPlus ver. @project-version@
--  Authored by Chrono Syz -- Entity-US / Wildstar
--  Based on FasterLoot by Chimpy Evans -- Entity-US / Wildstar
--  Build @project-hash@
--  Copyright (c) Chronosis. All rights reserved
--
--  https://github.com/chronosis/FasterLootPlus
------------------------------------------------------------------------------------------------
-- FasterLoot-Defaults.lua
------------------------------------------------------------------------------------------------

require "Window"

local FasterLootPlus = Apollo.GetAddon("FasterLootPlus")
local Info = Apollo.GetAddonInfo("FasterLootPlus")

local tBaseRuleSet = {
  label = "",
  lootRules = {}
}

local tBaseLootRule = {
  label = "",
  itemName = "",
  itemType = nil,
  itemQuality = nil,
  itemLevel = {
    compareOp = nil,
    level = nil
  },
  mode = "",
  randomAssign = false,
  patternMatch = false,
  assignees = {},
  enabled = false
}

local tDefaultLootRules = {
  [1] = {
    label = "Eldan Runic Modules",
    itemName = "^Eldan Runic Module$",
    itemType = nil,
    randomAssign = false,
    patternMatch = false,
    itemQuality = nil,
    itemLevel = {
      compareOp = nil,
      level = nil
    },
    mode = "",
    assignees = { },
    enabled = true
  },
  [2] = {
    label = "Eldan Signs",
    itemName = "^Sign of %a+ %- Eldan$",
    itemType = nil,
    randomAssign = false,
    patternMatch = false,
    itemQuality = nil,
    itemLevel = {
      compareOp = nil,
      level = nil
    },
    mode = "",
    assignees = { },
    enabled = true
  },
  [3] = {
    label = "Biophage Clusters",
    itemName = "^Suspended Biophage Cluster$",
    itemType = nil,
    randomAssign = false,
    patternMatch = false,
    itemQuality = nil,
    itemLevel = {
      compareOp = nil,
      level = nil
    },
    mode = "",
    assignees = { },
    enabled = true
  },
  [4] = {
    label = "Archivos Recipes",
    itemName = "Archivos.*",
    itemType = -10,
    randomAssign = false,
    patternMatch = true,
    itemQuality = nil,
    itemLevel = {
      compareOp = nil,
      level = nil
    },
    mode = "",
    assignees = { },
    enabled = true
  },
  [5] = {
    label = "Primal Patterns",
    itemName = "Partial Primal Pattern",
    itemType = nil,
    randomAssign = false,
    patternMatch = false,
    itemQuality = nil,
    itemLevel = {
      compareOp = nil,
      level = nil
    },
    mode = "",
    assignees = { },
    enabled = true
  },
  [6] = {
    label = "Eldan Gifts",
    itemName = "Tarnished Eldan Gift",
    itemType = nil,
    randomAssign = false,
    patternMatch = false,
    itemQuality = nil,
    itemLevel = {
      compareOp = nil,
      level = nil
    },
    mode = "",
    assignees = { },
    enabled = true
  },
  [7] = {
    label = "Warplot Boss",
    itemName = ".*Warplot Boss",
    itemType = nil,
    randomAssign = false,
    patternMatch = true,
    itemQuality = nil,
    itemLevel = {
      compareOp = nil,
      level = nil
    },
    mode = "",
    assignees = { },
    enabled = true
  },
  [8] = {
    label = "Hoverboard Mount",
    itemName = ".*Hoverboard Mount",
    itemType = nil,
    randomAssign = false,
    patternMatch = true,
    itemQuality = nil,
    itemLevel = {
      compareOp = nil,
      level = nil
    },
    mode = "",
    assignees = { },
    enabled = true
  },
  [9] = {
    label = "Ground Mount",
    itemName = ".*Ground Mount",
    itemType = nil,
    randomAssign = false,
    patternMatch = true,
    itemQuality = nil,
    itemLevel = {
      compareOp = nil,
      level = nil
    },
    mode = "",
    assignees = { },
    enabled = true
  },
  [10] = {
    label = "Trash Purples",
    itemName = "",
    itemType = nil,
    randomAssign = true,
    patternMatch = false,
    itemQuality = Item.CodeEnumItemQuality.Superb,
    itemLevel = {
      compareOp = "lte",
      level = "55"
    },
    mode = "",
    assignees = {},
    enabled = true
  },
  [11] = {
    label = "Trash Blues",
    itemName = "",
    itemType = nil,
    randomAssign = true,
    patternMatch = false,
    itemQuality = Item.CodeEnumItemQuality.Excellent,
    itemLevel = {
      compareOp = nil,
      level = nil
    },
    mode = "",
    assignees = {},
    enabled = true
  },
  [12] = {
    label = "Trash Greens",
    itemName = "",
    itemType = nil,
    randomAssign = true,
    patternMatch = false,
    itemQuality = Item.CodeEnumItemQuality.Good,
    itemLevel = {
      compareOp = nil,
      level = nil
    },
    mode = "",
    assignees = {},
    enabled = true
  }
}

FasterLootPlus.tItemTypeAggregates = {
  [-10] = { 254, 255, 256, 257, 258, 259 },
  [-9] = { 184, 185, 186, 187, 188, 189, 332, 450 },
  [-8] = { 1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13, 15, 16, 17, 18, 19, 20, 53, 298, 299, 301 },
  [-7] = { 45, 46, 48, 51, 79, 204 },
  [-6] = { 328, 329, 336, 338, 361, 74, 285, 286, 291, 293, 347 },
  [-5] = { 197, 198, 202, 206, 207, 208, 211, 213, 214, 219, 221, 266, 268, 269, 270, 271 },  -- TODO: All Crafting Mats
  [-4] = { 155, 164 },
  [-3] = { 339, 340, 341, 342, 343, 344, 345 },
  [-2] = { 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491 },
  [-1] = { 405, 408, 414, 423 }
}

FasterLootPlus.tItemTypes = {
  [-10] = "- Any Recipe -",
  [-9] = "- Any Costume -",
  [-8] = "- Any Armor -",
  [-7] = "- Any Weapon -",
  [-6] = "- Any Consumable -",
  [-5] = "- Any Crafting -",
  [-4] = "- Any Housing -",
  [-3] = "- Any Element -",
  [-2] = "- Any Tokens -",
  [-1] = "- Any Rune -",
  [1] = "Armor - Light - Chest",
  [2] = "Armor - Light - Legs",
  [3] = "Armor - Light - Head",
  [4] = "Armor - Light - Shoulder",
  [5] = "Armor - Light - Feet",
  [6] = "Armor - Light - Hands",
  [8] = "Armor - Medium - Chest",
  [9] = "Armor - Medium - Legs",
  [10] = "Armor - Medium - Head",
  [11] = "Armor - Medium - Shoulders",
  [12] = "Armor - Medium - Feet",
  [13] = "Armor - Medium - Hands",
  [15] = "Armor - Heavy - Chest",
  [16] = "Armor - Heavy - Legs",
  [17] = "Armor - Heavy - Head",
  [18] = "Armor - Heavy - Shoulder",
  [19] = "Armor - Heavy - Feet",
  [20] = "Armor - Heavy - Hands",
  [45] = "Pistols",
  [46] = "Psyblade",
  [48] = "Claws",
  [51] = "Greatsword",
  [53] = "Energy Shield",
  [74] = "Food",
  [79] = "Resonators",
  [134] = "Bag",
  [143] = "Untyped (Consumable/Flair/etc.)",
  [153] = "Untyped (Usable Quest)",
  [155] = "Decor",
  [164] = "Improvement",
  [170] = "Untyped (Reputation Item)",
  [171] = "Untyped (Quest Turn-in -- Skull)",
  [183] = "Untyped (Mount)",
  [184] = "Costume - Chest",
  [185] = "Costume - Legs",
  [186] = "Costume - Head",
  [187] = "Costume - Shoulder",
  [188] = "Costume - Feet",
  [189] = "Costume - Hands",
  [197] = "Ore",
  [198] = "Herb",
  [200] = "Treasure - Junk",
  [201] = "Tool - Mining",
  [202] = "Omni-Plasm",
  [204] = "Heavy Gun",
  [206] = "Power Core",
  [207] = "Leather",
  [208] = "Meat",
  [211] = "Cloth",
  [213] = "Seeds",
  [214] = "Relic Parts",
  [215] = "Gadget",
  [219] = "Wood",
  [221] = "Produce",
  [226] = "Cloth Scraps - Junk",
  [227] = "Essence - Junk",
  [228] = "Eyeball - Junk",
  [230] = "Fin - Junk",
  [231] = "Fur - Junk",
  [232] = "Gland - Junk",
  [236] = "Knick-Knacks - Junk",
  [237] = "Metal Scraps - Junk",
  [246] = "Spores - Junk",
  [249] = "Tooth - Junk",
  [250] = "Totem - Junk",
  [251] = "Tusk - Junk",
  [254] = "Tailor Pattern",
  [255] = "Outfitter Guide",
  [256] = "Armorer Design",
  [257] = "Weaponsmith Schematic",
  [258] = "Technologist Formula",
  [259] = "Cooking Recipe",
--[260] = "???",
--[261] = "???",
--[262] = "???",
--[263] = "???",
--[264] = "???",
--[265] = "???",
  [266] = "Fish",
--[267] = "???",
  [268] = "Bug Meat",
  [269] = "Poultry",
  [270] = "Gem",
  [271] = "Crystal",
  [272] = "Tool - Relic Hunter",
  [273] = "Tool - Survivalist",
  [274] = "Pelt",
  [285] = "Meat Meal",
  [286] = "Poultry Meal",
  [291] = "Deradune Victuals",
  [293] = "Ellevar Edibles",
  [298] = "Weapon Attachment",
  [299] = "Support System",
  [300] = "Key",
  [301] = "Implant",
  [321] = "Technologist Catalyst",
  [322] = "Cooking Catalyst",
  [326] = "Farming - No Commodity",
  [328] = "Medishot",
  [329] = "Boost",
  [330] = "Cloth - No Commodity",
  [332] = "Dye",
  [336] = "Elder Meals",
  [338] = "Datascape Meals",
  [339] = "Water Element",
  [340] = "Life Element",
  [341] = "Earth Element",
  [342] = "Fusion Element",
  [343] = "Fire Element",
  [344] = "Logic Element",
  [345] = "Air Element",
  [347] = "Special Diet",
  [359] = "Rune Fragment",
  [361] = "Field Tech",
  [391] = "Tradeskill Reagent",
  [392] = "Imbuement Material",
  [393] = "Security Key Material",
  [394] = "Warrior Amp",
  [395] = "Engineer Amp",
  [396] = "Medic Amp",
  [397] = "Stalker Amp",
  [398] = "Esper Amp",
  [399] = "Spellslinger Amp",
  [400] = "Carcass - Beast",
  [405] = "General Rune Sets",
  [408] = "Attribute Rune",
  [414] = "Class Rune Sets",
  [423] = "Elder Rune Sets",
  [428] = "Attribute Rune",
  [448] = "Tradeskill Loot Bag",
  [449] = "Loot Bag",
  [450] = "Dye Loot Bag",
  [455] = "Nexus Nourishments",
  [465] = "Runic Flux",
  [470] = "Token - Heavy Armor - Legs",
  [471] = "Token - Heavy Armor - Hands",
  [484] = "Token - Medium Armor - Shoulder",
  [487] = "Token - Medium Armor - Hands",
  [489] = "Token - Light Armor - Head",
  [490] = "Token - Light Armor - Shoulder",
  [491] = "Token - Light Armor - Chest"
}

FasterLootPlus.tComparisonOps = {
  ["eq"] = "=",
  ["gte"] = "≥",
  ["gt"] = "˃",
  ["lte"] = "≤",
  ["lt"] = "˂",
  ["neq"] = "≠"
}

FasterLootPlus.tItemQuality = {
  [Item.CodeEnumItemQuality.Inferior] = {
    Abbreviation  = "In",
    Name          = Apollo.GetString("CRB_Inferior"),
    Color			    = "ItemQuality_Inferior",
    BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Silver",
    HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Silver",
    SquareSprite	= "BK3:UI_BK3_ItemQualityGrey",
    CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetGrey",
    NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Silver",
  },
  [Item.CodeEnumItemQuality.Average] = {
    Abbreviation  = "Av",
    Name			    = Apollo.GetString("CRB_Average"),
    Color		   	  = "ItemQuality_Average",
    BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_White",
    HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_White",
    SquareSprite	= "BK3:UI_BK3_ItemQualityWhite",
    CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetWhite",
    NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_White",
  },
  [Item.CodeEnumItemQuality.Good]	= {
    Abbreviation  = "Gd",
    Name    			= Apollo.GetString("CRB_Good"),
    Color 		   	= "ItemQuality_Good",
    BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Green",
    HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Green",
    SquareSprite	= "BK3:UI_BK3_ItemQualityGreen",
    CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetGreen",
    NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Green",
  },
  [Item.CodeEnumItemQuality.Excellent] = {
    Abbreviation  = "Ex",
    Name    			= Apollo.GetString("CRB_Excellent"),
    Color 		   	= "ItemQuality_Excellent",
    BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Blue",
    HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Blue",
    SquareSprite	= "BK3:UI_BK3_ItemQualityBlue",
    CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetBlue",
    NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Blue",
  },
  [Item.CodeEnumItemQuality.Superb] = {
    Abbreviation  = "Sb",
    Name    			= Apollo.GetString("CRB_Superb"),
    Color 		   	= "ItemQuality_Superb",
    BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Purple",
    HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Purple",
    SquareSprite	= "BK3:UI_BK3_ItemQualityPurple",
    CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetPurple",
    NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Purple",
  },
  [Item.CodeEnumItemQuality.Legendary] = {
    Abbreviation  = "Ld",
    Name    			= Apollo.GetString("CRB_Legendary"),
    Color 		   	= "ItemQuality_Legendary",
    BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Orange",
    HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Orange",
    SquareSprite	= "BK3:UI_BK3_ItemQualityOrange",
    CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetOrange",
    NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Orange",
  },
  [Item.CodeEnumItemQuality.Artifact] = {
    Abbreviation  = "Af",
    Name    			= Apollo.GetString("CRB_Artifact"),
    Color 		   	= "ItemQuality_Artifact",
    BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Pink",
    HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Pink",
    SquareSprite	= "BK3:UI_BK3_ItemQualityMagenta",
    CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetPink",
    NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Pink",
  }
}

FasterLootPlus.tLootRules =
{
  [GroupLib.LootRule.Master]          = Apollo.GetString("Group_MasterLoot"),
  [GroupLib.LootRule.RoundRobin]      = Apollo.GetString("Group_RoundRobin"),
  [GroupLib.LootRule.NeedBeforeGreed] = Apollo.GetString("Group_NeedBeforeGreed"),
  [GroupLib.LootRule.FreeForAll]      = Apollo.GetString("Group_FFA")
}

FasterLootPlus.tHarvestLootRules =
{
  [GroupLib.HarvestLootRule.FirstTagger] 		= Apollo.GetString("Group_FFA"),
  [GroupLib.HarvestLootRule.RoundRobin] 		= Apollo.GetString("Group_RoundRobin"),
}

function FasterLootPlus:LoadDefaultLootRules()
  local currentSet = self.settings.user.currentRuleSet
  self.settings.ruleSets[currentSet].lootRules = deepcopy(tDefaultLootRules)
  self:RebuildLootRuleItems()
  self:RefreshUI()
end

function FasterLootPlus:GetBaseRule()
  return tBaseLootRule
end

function FasterLootPlus:GetBaseRuleSet()
  return tBaseRuleSet
end
