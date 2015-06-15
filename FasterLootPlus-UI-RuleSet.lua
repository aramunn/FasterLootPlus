------------------------------------------------------------------------------------------------
--  FasterLootPlus ver. @project-version@
--  Authored by Chimpy Evans, Chrono Syz -- Entity-US / Wildstar
--  Based on FasterLoot by Chimpy Evans -- Entity-US / Wildstar
--  Build @project-hash@
--  Copyright (c) Chronosis. All rights reserved
--
--  https://github.com/chronosis/FasterLootPlus
------------------------------------------------------------------------------------------------
-- FasterLoot-UI-RuleSet.lua
------------------------------------------------------------------------------------------------

require "Window"
require "Item"
require "GameLib"

local FasterLootPlus = Apollo.GetAddon("FasterLootPlus")
local Info = Apollo.GetAddonInfo("FasterLootPlus")

---------------------------------------------------------------------------------------------------
-- FasterLootPlus RuleSet UI Functions
---------------------------------------------------------------------------------------------------
function FasterLootPlus:OnAddRuleSet( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
  -- Add a new loot rule
  self:CreateEditRuleSetWindow(nil)
end

function FasterLootPlus:CreateEditRuleSetWindow( wndHandler )
  if self.state.windows.editRuleSets == nil then
    self.state.windows.editRuleSets = Apollo.LoadForm(self.xmlDoc, "EditRuleSetWindow", nil, self)
    self.state.windows.editRuleSets:Show(true)

    if wndHandler ~= nil then
      -- Get Parent List item and associated item data.
      local idx = wndHandler:GetData()
      local item = self.settings.ruleSets[idx]

      -- Populate the Edit window
      self.state.windows.editRuleSets:SetData(idx)
      self.state.windows.editRuleSets:FindChild("RuleSetName"):FindChild("Text"):SetText(item.label)
      self:RebuildRuleSetItems()
      self.state.windows.ruleSetList:ArrangeChildrenVert()
    end
  end
end

---------------------------------------------------------------------------------------------------
-- FasterLootPlus RuleSetListItem UI Functions
---------------------------------------------------------------------------------------------------

function FasterLootPlus:OnLoadRuleSet( wndHandler, wndControl, eMouseButton )
  local par = wndHandler:GetParent()
  local idx = par:GetData()
  -- Change Selected Rule
  self.settings.user.currentRuleSet = idx
  self:RebuildRuleSetItems()
  self:RebuildLootRuleItems()
end

function FasterLootPlus:OnDeleteRuleSet( wndHandler, wndControl, eMouseButton )
  -- Add a new loot rule
  local par = wndHandler:GetParent()
  local idx = par:GetData()
  -- Cant Delete the first rule, there always needs to be at least one set
  if idx ~= 0 then
    self.state.windows.confirmDeleteSet = Apollo.LoadForm(self.xmlDoc, "ConfirmDeleteSetWindow", nil, self)
    self.state.windows.confirmDeleteSet:SetData(idx)
  end
end

function FasterLootPlus:OnEditRuleSet( wndHandler, wndControl, eMouseButton )
  -- Add a new loot rule
  local par = wndHandler:GetParent()
  local idx = par:GetData()
  self:CreateEditRuleSetWindow( par )
end

function FasterLootPlus:OnRuleSetSelected( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
  if wndHandler ~= wndControl then
    return
  end

  if eMouseButton == 0 and bDoubleClick then -- Double Left Click
    -- Open the Loot Rule Window for this loot rule.
    self:CreateEditRuleSetWindow( wndHandler )
  end
end

---------------------------------------------------------------------------------------------------
-- FasterLootPlus EditRuleSetWindow UI Functions
---------------------------------------------------------------------------------------------------

function FasterLootPlus:OnEditRuleSetSave( wndHandler, wndControl, eMouseButton )
  local label = self.state.windows.editRuleSets:FindChild("RuleSetName"):FindChild("Text"):GetText()
  local idx = self.state.windows.editRuleSets:GetData()

  if idx then
    -- Update Existing Item
    self.settings.ruleSets[idx].label = label
  else
    -- Add New Item
    local item = deepcopy(self:GetBaseRuleSet())
    item.label = label
    table.insert(self.settings.ruleSets, item)
  end

  self:RebuildRuleSetItems()
  self:CloseEditRuleSet()
end

function FasterLootPlus:OnEditRuleSetCancel( wndHandler, wndControl, eMouseButton )
  self:CloseEditRuleSet()
end

function FasterLootPlus:OnEditRuleSetClosed( wndHandler, wndControl )
  self:CloseEditRuleSet()
end

function FasterLootPlus:CloseEditRuleSet()
  self.state.windows.editRuleSets:Show(false)
  self.state.windows.editRuleSets:Destroy()
  self.state.windows.editRuleSets = nil
end

---------------------------------------------------------------------------------------------------
-- FasterLootPlus UI RuleSet Maintenance Functions
---------------------------------------------------------------------------------------------------

function FasterLootPlus:ClearRuleSetItems()
  self:DestroyWindowList(self.state.listItems.ruleSets)
end

function FasterLootPlus:AddRuleSetItem(index, item)
  local wnd = Apollo.LoadForm(self.xmlDoc, "RuleSetListItem", self.state.windows.ruleSetList, self)
  wnd:SetData(index)
  wnd:FindChild("Label"):SetText(item.label)
  if index == self.settings.user.currentRuleSet then
    wnd:FindChild("Selected"):Show(true)
  else
    wnd:FindChild("Selected"):Show(false)
  end
  -- Disable Delete for Root Set
  if index == 0 then
    wnd:FindChild("DeleteButton"):Enable(false)
  end

  table.insert(self.state.listItems.ruleSets, wnd)
end

function FasterLootPlus:RebuildRuleSetItems()
  local vScrollPos = self.state.windows.ruleSetList:GetVScrollPos()
  self:SaveLocation()
  self:ClearRuleSetItems()
  for key,item in pairs(self.settings.ruleSets) do
    self:AddRuleSetItem(key, item)
  end
  self.state.windows.ruleSetList:SetVScrollPos(vScrollPos)
  self:RefreshUI()
end
