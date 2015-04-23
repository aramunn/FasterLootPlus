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
  itemType = 0,
  randomAssign = false,
  patternMatch = false,
  assignees = {}
}

local tDefaultLootRules = {
  ["1"] = {
    label = "Eldan Runic Modules",
    itemName = "^Eldan Runic Module$",
    itemType = nil,
    randomAssign = false,
    patternMatch = true,
    assignees = { [0] = "Milk Shakes" }
  },
  ["2"] = {
    label = "Eldan Signs",
    itemName = "^Sign of %a+ %- Eldan$",
    itemType = nil,
    randomAssign = false,
    patternMatch = true,
    assignees = { [0] = "Horns NLegs" }
  },
  ["3"] = {
    label = "Biophage Clusters",
    itemName = "^Suspended Biophage Cluster$",
    itemType = nil,
    randomAssign = false,
    patternMatch = true,
    assignees = { [0] = "Horns NLegs" }
  },
  ["4"] = {
    label = "Recipes",
    itemName = "Archivos",
    itemType = nil,
    randomAssign = false,
    patternMatch = true,
    assignees = { [0] = "Horns NLegs" }
  },
  ["5"] = {
    label = "Cloth",
    itemName = "Starloom",
    itemType = nil,
    randomAssign = false,
    patternMatch = true,
    assignees = { [0] = "Chimpii Evans" }
  },
  ["6"] = {
    label = "Primal Patterns",
    itemName = "Partial Primal Pattern",
    itemType = nil,
    randomAssign = true,
    patternMatch = false,
    assignees = {}
  },
  ["7"] = {
    label = "Eldan Gifts",
    itemName = "Tarnished Eldan Gift",
    itemType = nil,
    randomAssign = true,
    patternMatch = false,
    assignees = {}
  }
}

function FasterLootPlus:LoadDefaultLootRules()
end

function FasterLootPlus:GetBaseRule()
  return tBaseLootRule
end

function FasterLootPlus:GetBaseRuleSet()
  return tBaseRuleSet
end
