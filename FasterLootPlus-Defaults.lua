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
    itemName = "Eldan Runic Module",
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
    itemName = "Sign of .* - Eldan",
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
  [3] = {
    label = "Biophage Clusters",
    itemName = "Suspended Bio-Phage Cluster",
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
    itemName = ".*Archivos.*",
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
    itemName = "Warplot Boss.*",
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

function FasterLootPlus:LoadDefaultLootRules(set)
  if set == nil then
    set = self.settings.user.currentRuleSet
  end
  self.settings.ruleSets[set].lootRules = deepcopy(tDefaultLootRules)
  self:RebuildLootRuleItems()
  self:RefreshUI()
end

function FasterLootPlus:GetBaseRule()
  return tBaseLootRule
end

function FasterLootPlus:GetBaseRuleSet()
  return tBaseRuleSet
end
