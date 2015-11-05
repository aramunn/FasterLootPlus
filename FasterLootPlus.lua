------------------------------------------------------------------------------------------------
--  FasterLootPlus ver. @project-version@
--  Authored by Chimpy Evans, Chrono Syz -- Entity-US / Wildstar
--  Based on FasterLoot by Chimpy Evans -- Entity-US / Wildstar
--  Build @project-hash@
--  Copyright (c) Chronosis. All rights reserved
--
--  https://github.com/chronosis/FasterLootPlus
------------------------------------------------------------------------------------------------
-- FasterLoot.lua
------------------------------------------------------------------------------------------------

require "Window"
require "GroupLib"
require "ChatSystemLib"

-----------------------------------------------------------------------------------------------
-- FasterLootPlus Module Definition
-----------------------------------------------------------------------------------------------
local FasterLootPlus = {}
local Utils = Apollo.GetPackage("SimpleUtils").tPackage
local RegExp = Apollo.GetPackage("RegExpUtils").tPackage
local ZoneHelper = Apollo.GetPackage("ZoneHelper").tPackage

local addonCRBML = Apollo.GetAddon("MasterLoot")

-----------------------------------------------------------------------------------------------
-- FasterLootPlus constants
-----------------------------------------------------------------------------------------------
local Major, Minor, Patch, Suffix = 0, 7, 5, -1
local FASTERLOOTPLUS_CURRENT_VERSION = string.format("%d.%d.%d", Major, Minor, Patch)

local tDefaultSettings = {
  version = FASTERLOOTPLUS_CURRENT_VERSION,
  debug = false,
  fieldTestMode = true,
  user = {
    savedWndLoc = {},
    isEnabled = true,
    currentRuleSet = 0
  },
  options = {
    autoSetMasterLootWhenLeading = false,
    autoEnableInRaid = false,
    autoEnableInDungeon = false,
    autoDisableUponExitInstance = true,
    masterLootRule = GroupLib.LootRule.NeedBeforeGreed,
    masterLootQualityThreshold = GroupLib.LootThreshold.Excellent
  },
  ruleSets = {
    [0] = {
      label = "Default",
      lootRules = {}
    }
  }
}

local tDefaultState = {
  isOpen = false,
  isRuleSetOpen = false,
  windows = {           -- These store windows for lists
    main = nil,
    ruleList = nil,
    editLootRule = nil,
    editLootRuleItemType = nil,
    editLootRuleQualityType = nil,
    editLootRuleILvlComparisonType = nil,
    assigneeList = nil,
    editAssignee = nil,
    editRuleSets = nil,
    ruleSets = nil,
    ruleSetList = nil,
    confirmDeleteSet = nil,
    confirmClearRules = nil,
    options = nil,
    optionsPartyLootRuleItemType = nil,
    optionsThresholdItemType = nil,
    selectedItem = nil
  },
  listItems = {         -- These store windows for lists
    itemTypes = {},
    itemQualities = {},
    itemLevelComparitors = {},
    ruleSets = {},
    rules = {},
    assignees = {},
    thresholds = {},
    partyLootRules = {}
  },
  buttons = {
    editRuleIncILvlHeld = false,
    editRuleDecILvlHeld = false
  },
  player = {
    isInRaid = false,
    isInDungeon = false,
    isLeader = false,
    lootSetSinceLeader = false,
    currentContinent = 0,
    name = ""
  },
  currentAssignees = {}, -- List of current Assignees for the item
}

-----------------------------------------------------------------------------------------------
-- FasterLootPlus Constructor
-----------------------------------------------------------------------------------------------
function FasterLootPlus:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  -- Saved and Restored values are stored here.
  o.settings = deepcopy(tDefaultSettings)
  -- Volatile values are stored here. These are impermenant and not saved between sessions
  o.state = deepcopy(tDefaultState)

  return o
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus Init
-----------------------------------------------------------------------------------------------
function FasterLootPlus:Init()
  local bHasConfigureFunction = true
  local strConfigureButtonText = "FasterLootPlus"
  local tDependencies = {
    -- "UnitOrPackageName",
  }
  Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)

  self.settings = deepcopy(tDefaultSettings)
  -- Volatile values are stored here. These are impermenant and not saved between sessions
  self.state = deepcopy(tDefaultState)

  self.tOldMasterLootList = {}
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus OnLoad
-----------------------------------------------------------------------------------------------
function FasterLootPlus:OnLoad()
  Apollo.LoadSprites("FasterLootPlusSprites.xml")

  self.xmlDoc = XmlDoc.CreateFromFile("FasterLootPlus.xml")
  self.xmlDoc:RegisterCallback("OnDocLoaded", self)



  Apollo.RegisterEventHandler("Generic_ToggleFasterLootPlus", "OnToggleFasterLootPlus", self)
  Apollo.RegisterEventHandler("InterfaceMenuListHasLoaded", "OnInterfaceMenuListHasLoaded", self)
  -- Handles when the Group is Updated
  Apollo.RegisterEventHandler("Group_Updated", "OnGroupUpdated", self)
  Apollo.RegisterEventHandler("SubZoneChanged", "OnZoneChanging", self)
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus OnDocLoaded
-----------------------------------------------------------------------------------------------
function FasterLootPlus:OnDocLoaded()
  if self.xmlDoc == nil then
    return
  end

  -- Delayed timer to fix Carbine's MasterLoot on /reloadui
  --Apollo.RegisterTimerHandler("FixCRBML_Delay", "FixCRBML", self)

  Apollo.RegisterEventHandler("MasterLootUpdate", "OnMasterLootUpdate", self)

  self.state.windows.main = Apollo.LoadForm(self.xmlDoc, "FasterLootPlusWindow", nil, self)
  self.state.windows.ruleList = self.state.windows.main:FindChild("ItemList")
  self.state.windows.ruleSets = self.state.windows.main:FindChild("RuleSetsWindow")
  self.state.windows.ruleSetList = self.state.windows.ruleSets:FindChild("ItemList")
  self.state.isRuleSetOpen = false

  -- Initialize all the UI Items
  self:RebuildRuleSetItems()
  self:RebuildLootRuleItems()
  self.state.windows.main:Show(false)
  self.state.windows.ruleSets:Show(false)

  Apollo.RegisterSlashCommand("fasterloot", "OnSlashCommand", self)
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus OnSlashCommand
-----------------------------------------------------------------------------------------------
-- Handle slash commands
function FasterLootPlus:OnSlashCommand(cmd, params)
  args = params:lower():split("[ ]+")

  if args[1] == "debug" then
    if #args == 2 then
      if args[2] == "update" then
        self:OnMasterLootUpdate(true)
      end
    else
      self:ToggleDebug()
    end
  elseif args[1] == "show" then
    self.state.windows.main:Show(true)
  elseif args[1] == "defaults" then
    self:LoadDefaultLootRules()
  else
    Utils:cprint("FasterLootPlus v" .. self.settings.version)
    Utils:cprint("Usage:  /fasterloot <command>")
    Utils:cprint("====================================")
    Utils:cprint("   show           Open Rules Window")
    Utils:cprint("   debug          Toggle Debug")
    Utils:cprint("   debug update   Update the Window")
    Utils:cprint("   defaults       Loads default sample rules in current ruleset")
  end
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus OnInterfaceMenuListHasLoaded
-----------------------------------------------------------------------------------------------
function FasterLootPlus:OnInterfaceMenuListHasLoaded()
  Event_FireGenericEvent("InterfaceMenuList_NewAddOn", "FasterLootPlus", {"Generic_ToggleFasterLootPlus", "", "FasterLootPlusSprites:FastCoins32"})
  Event_FireGenericEvent("OneVersion_ReportAddonInfo", "FasterLootPlus", Major, Minor, Patch, Suffix, false)
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus GatherMasterLoot
-----------------------------------------------------------------------------------------------
-- Returns a table of all Master Lootable items. Filters
-- out those items which are not supposed to go through MasterLoot
function FasterLootPlus:GatherMasterLoot()
  -- tLootList is a table
  -- index => {
  --   tLooters => Table of valid looters, used in AssignMasterLoot
  --   itemDrop => Actual item (e.g.: GetDetailedData())
  --   nLootId => Loot drop ID, used in AssignMasterLoot
  --   bIsMaster => If the item is valid master loot fodder
  -- }

  -- Get all loot
  local tLootList = GameLib.GetMasterLoot()

  -- Gather all the master lootable items
  local tMasterLootList = {}
  for idxNewItem, tCurMasterLoot in pairs(tLootList) do
    if tCurMasterLoot.bIsMaster then
      table.insert(tMasterLootList, tCurMasterLoot)
    end
  end

  return tMasterLootList
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus AssignLoot
-----------------------------------------------------------------------------------------------
function FasterLootPlus:AssignLoot(id, looter, item, mode)
  local strAlert = "Assigning {item} to {user} ({mode})"
  local itemLink = item:GetChatLinkString()
  local itemName = item:GetName()
  local looterName = looter:GetName()

  self:PrintDB(strAlert.gsub("{item}", itemLink).gsub("{user}", looterName).gsub("{mode}", mode))
  self:PrintParty(strAlert.gsub("{item}", itemName).gsub("{user}", looterName).gsub("{mode}", mode))
  GameLib.AssignMasterLoot(id, looter)
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus GetRandomLooter
-----------------------------------------------------------------------------------------------
function FasterLootPlus:GetRandomLooter(looters)
  return looters[math.random(1, #looters)]
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus OnMasterLootUpdate
-----------------------------------------------------------------------------------------------
-- When Master Loot is updated, check each one for filtering, and random those
-- drops that fit the filter.
function FasterLootPlus:OnMasterLootUpdate(bForceOpen)
  local tMasterLootList = self:GatherMasterLoot()

  if self.settings.user.isEnabled == true then
    -- Check each item against each rule filter
    for idxMasterItem, tCurMasterLoot in pairs(tMasterLootList) do
      self:ProcessItem(tCurMasterLoot)
    end
  end

  -- Update the old master loot list
  self.tOldMasterLootList = tMasterLootList
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus CompareItemType
-----------------------------------------------------------------------------------------------
function FasterLootPlus:CompareItemType(item, rule)
  if rule.itemType ~= nil then
    -- Check if the rule is an aggregate type
    if rule.itemType < 0 then
      return ItemHelper:IsItemTypeOfGroup(item.type, rule.itemType)
    else
      -- Check if the item type matches one the rule
      if item.type == rule.itemType then return true end
      return false
    end
  end
  return true
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus CompareItemName
-----------------------------------------------------------------------------------------------
function FasterLootPlus:CompareItemName(item, rule)
  if rule.itemName ~= nil and rule.itemName ~= "" then
    -- Use Pattern Matching to find the item if pattern mode is on, else use simple matching
    if rule.patternMatch == true then
      -- RegExp Match
      local regex = RegExp.compile(rule.itemName)
      local find = regex:search(item.name)
      if find then return true end
      return false
    else
      -- Standard Lua Pattern Match
      return string.match(item.name, rule.itemName)
    end
  end
  return true
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus CompareItemQuality
-----------------------------------------------------------------------------------------------
function FasterLootPlus:CompareItemQuality(item, rule)
  if rule.itemQuality ~= nil and rule.itemQuality ~= "" then
    if item.quality ~= rule.itemQuality then return false end
  end
  return true
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus CompareItemLevel
-----------------------------------------------------------------------------------------------
function FasterLootPlus:CompareItemLevel(item, rule)
  local iLvl = item.nEffectiveLevel
  return self:CompareOp(rule.itemLevel.compareOp, iLvl, tonumber(rule.itemLevel.level))
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus CheckItem
-----------------------------------------------------------------------------------------------
function FasterLootPlus:ProcessItem(loot)
  local current = self.settings.user.currentRuleSet
  local item = loot.itemDrop
  for idx,rule in ipairs(self.settings.ruleSets[current]) do
    -- Only check the rule if it is enabled
    if rule.enabled == true then
      -- Compares Item to all filter criteria
      local check = self:CompareItemType(item,rule) and self:CompareItemName(item,rule) and self:CompareItemQuality(item,rule) and self:CompareItemLevel(item,rule)
      -- The item meets the filter criteria, lets do something and return
      if check == true then
        -- Do something with the item and exit
        local looters = self:GetPossibleLooters(loot.tLooters, rule.assignees)

        if rule.randomAssign == true and #rule.assignees <= 0 then
          -- No looters and random, random out the item
          self:AssignLoot(loot.nLootId, self:GetRandomLooter(loot.tLooters), item, "Random")
        elseif rule.randomAssign == true and #rule.assignees > 0 then
          -- Looters and random, random out to one of the designated looters
          local lootr = self:GetRandomLooter(looters)
          if lootr ~= nil then
            self:AssignLoot(loot.nLootId, lootr, item, "Random-Assigned")
          end
        elseif rule.randomAssign == false and #looters > 0 then
          -- Not random but looters assigned, assign to first priority looter
          self:AssignLoot(loot.nLootId, looters[1], item, "Assigned")
        else
          -- Not random and no assignee available, skip
          self:PrintDB("Item (" .. item:GetName() .. ") found to assign, but no assignee available.")
        end
        -- We only want to process an item exactly once, so we must return
        return
      end
    end
  end
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus GetLooters
-----------------------------------------------------------------------------------------------
function FasterLootPlus:GetPossibleLooters(availableLooters, assignees)
  local looters = {}
  for idx,looter in ipairs(availableLooters) do
    for idx,assignee in ipairs(assignees) do
      if looter:GetName() == assignee then
        table.insert(looters,looter:GetName())
      end
    end
  end
  return looters
end

-----------------------------------------------------------------------------------------------
-- Save/Restore functionality
-----------------------------------------------------------------------------------------------
function FasterLootPlus:OnSave(eType)
  if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then return end

  return deepcopy(self.settings)
end

function FasterLootPlus:OnRestore(eType, tSavedData)
  if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then return end
  self.tOldMasterLootList = self:GatherMasterLoot()


  if tSavedData and tSavedData.user then
    -- Copy the settings wholesale
    self.settings = deepcopy(tSavedData)

    -- Fill in any missing values from the default options
    -- This Protects us from configuration additions in the future versions
    for key, value in pairs(tDefaultSettings) do
      if self.settings[key] == nil then
        self.settings[key] = deepcopy(tDefaultSettings[key])
      end
    end

    -- Check to see if there are any loot rules loaded for the default ruleset, if there are not then load the default rules.
    if #self.settings.ruleSets[0].lootRules <= 0 then
      self:LoadDefaultLootRules(0)
    end

    -- This section is for converting between versions that saved data differently

    -- Now that we've turned the save data into the most recent version, set it
    self.settings.user.version = FASTERLOOTPLUS_CURRENT_VERSION

  else
    self.settings = deepcopy(tDefaultSettings)
  end

  -- if #self.tOldMasterLootList > 0 and addonCRBML ~= nil then
  --   -- Try every second to bring the window back up...
  --   Apollo.CreateTimer("FixCRBML_Delay", 1, false)
  --   Apollo.StartTimer("FixCRBML_Delay")
  -- end
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus GetDesignatedLooter
-----------------------------------------------------------------------------------------------
-- This function is called on a timer from OnRestore to attempt to open Carbine's MasterLoot addon,
-- which doesn't automatically open if loot exists
-- function FasterLootPlus:FixCRBML()
--   -- Hack, Carbine's ML OnLoad sets this field
--   -- We use it to determine when Carbine is done loading
--   if addonCRBML.tOld_MasterLootList ~= nil then
--     self:PrintDB("Trying to open up MasterLoot!")
--     addonCRBML:OnMasterLootUpdate(true)
--     self:OnMasterLootUpdate(false)
--   else
--     self:PrintDB("MasterLoot not ready, trying again")
--     Apollo.CreateTimer("FixCRBML_Delay", 1, false)
--     Apollo.StartTimer("FixCRBML_Delay")
--   end
-- end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus Group Update Logic
-----------------------------------------------------------------------------------------------
function FasterLootPlus:OnGroupUpdated()
  local oldState = self.state.player.isLeader
  self.state.player.isLeader = GroupLib.AmILeader()
  if oldState == false and self.state.player.isLeader == true then
    self:OnZoneChanging()
  elseif self.state.player.isLeader == false then
    self.state.player.lootSetSinceLeader = false
  else
    -- Do Nothing
  end
end

function FasterLootPlus:OnZoneChanging()
  local zoneMap = GameLib.GetCurrentZoneMap()
  if zoneMap and zoneMap.continentId then
    self.state.player.currentContinent = zoneMap.continentId
    self.state.player.isInRaid = ZoneHelper:IsContinentRaid(self.state.player.currentContinent)
    self.state.player.isInDungeon = ZoneHelper:IsContinentDungeon(self.state.player.currentContinent)
  end
  self.state.player.lootSetSinceLeader = false
  self:ProcessOptions()
end

function FasterLootPlus:ProcessOptions()
  -- Check if we need to turn on or off the addon based on option flags
  if self.settings.options.autoEnableInRaid == true and self.state.player.isInRaid == true or self.settings.options.autoEnableInDungeon == true and self.state.player.isInDungeon == true then
    self.settings.user.isEnabled = true
  end
  -- Similarly if we are not in a raid or dungeon and we are set to disable on exit
  if self.settings.options.autoDisableUponExitInstance == true and self.state.player.isInRaid == false and self.state.player.isInDungeon == false then
    self.settings.user.isEnabled = false
  end

  -- If we're the leader and the functionality is currently enabled then process the options
  if self.state.player.isLeader == true and self.settings.user.isEnabled and not self.state.player.lootSetSinceLeader then
    -- The option for master loot is enabled then check if we're in the correct instance types
    if self.settings.options.autoSetMasterLootWhenLeading == true then
      self:SetGroupLootRules()
      self.state.player.lootSetSinceLeader = true
    end
  end
end

function FasterLootPlus:SetGroupLootRules()
  local curLootRule = GroupLib.GetLootRules()
  -- Only change the loot settings if they are not the same as what is currently set
  if curLootRule.eNormalRule ~= self.settings.options.masterLootRule and curLootRule.eThresholdRule ~= GroupLib.LootRule.Master and curLootRule.eThresholdQuality ~= self.settings.options.masterLootQualityThreshold then
    GroupLib.SetLootRules(self.settings.options.masterLootRule, GroupLib.LootRule.Master, self.settings.options.masterLootQualityThreshold, curLootRule.eHarvestRule)
  end
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus Instance
-----------------------------------------------------------------------------------------------
local FasterLootPlusInst = FasterLootPlus:new()
FasterLootPlusInst:Init()
