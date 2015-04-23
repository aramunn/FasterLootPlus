------------------------------------------------------------------------------------------------
--  FasterLootPlus ver. @project-version@
--  Authored by Chimpy Evans, Chrono Syz -- Entity-US / Wildstar
--  Based on FasterLoot by Chimpy Evans -- Entity-US / Wildstar
--  Build @project-hash@
--  Copyright (c) Chronosis. All rights reserved
--
--  https://github.com/chronosis/FasterLootPlus
------------------------------------------------------------------------------------------------
-- FasterLoot-UI.lua
------------------------------------------------------------------------------------------------

require "Window"

local FasterLootPlus = Apollo.GetAddon("FasterLootPlus")
local Info = Apollo.GetAddonInfo("FasterLootPlus")

---------------------------------------------------------------------------------------------------
-- FasterLootPlus General UI Functions
---------------------------------------------------------------------------------------------------
function FasterLootPlus:OnToggleFasterLootPlus()
  if self.state.isOpen == true then
    self.state.isOpen = false
    self:SaveLocation()
    self:CloseMain()
  else
    self.state.isOpen = true
    self.state.windows.main:Invoke() -- show the window
  end
end

function FasterLootPlus:SaveLocation()
  self.settings.user.savedWndLoc = self.state.windows.main:GetLocation():ToTable()
end


function FasterLootPlus:CloseMain()
  self.state.windows.main:Close()
  if self.state.windows.editLootRule then
    self:CloseEditLootRule()
  end
  if self.state.windows.editRuleSets then
    self:CloseEditRuleSet()
  end
end

function FasterLootPlus:OnToggleRuleSetWindow()
  if self.state.isRuleSetOpen == true then
    self.state.isRuleSetOpen = false
  else
    self.state.isRuleSetOpen = true
  end
  self.state.windows.ruleSets:Show(self.state.isRuleSetOpen)
end

---------------------------------------------------------------------------------------------------
-- FasterLootPlus FasterLootPlusWindow UI Functions
---------------------------------------------------------------------------------------------------
function FasterLootPlus:OnFasterLootPlusClose( wndHandler, wndControl, eMouseButton )
  self.state.isOpen = false
  self:SaveLocation()
  self:CloseMain()
end

function FasterLootPlus:OnFasterLootPlusClosed( wndHandler, wndControl )
  self.state.isOpen = false
end

function FasterLootPlus:OnEnableChecked( wndHandler, wndControl, eMouseButton )
  self.settings.user.enabled = true
end

function FasterLootPlus:OnEnableUnchecked( wndHandler, wndControl, eMouseButton )
  self.settings.user.enabled = false
end

function FasterLootPlus:OnClearLootRules( wndHandler, wndControl, eMouseButton )
  self.state.windows.confirmClearRules = Apollo.LoadForm(self.xmlDoc, "ConfirmClearRulesWindow", nil, self)
end

function FasterLootPlus:OnCloseConfirmClearRules( wndHandler, wndControl )
  self:CloseConfirmClearRules()
end

function FasterLootPlus:OnCloseConfirmDeleteSet( wndHandler, wndControl )
  self:CloseConfirmDeleteSet()
end

function FasterLootPlus:OnConfirmClearRules( wndHandler, wndControl, eMouseButton )
  -- Clear Rules
  local current = self.settings.currentRuleSet
  self.settings.ruleSets[current].lootRules = {}
  self:CloseConfirmClearRules()
  self:RebuildLootRuleItems()
end

function FasterLootPlus:OnCancelClearRules( wndHandler, wndControl, eMouseButton )
  self:CloseConfirmClearRules()
end

function FasterLootPlus:CloseConfirmClearRules()
  self.state.windows.confirmClearRules:Show(false)
  self.state.windows.confirmClearRules:Destroy()
end

function FasterLootPlus:OnConfirmDeleteSet( wndHandler, wndControl, eMouseButton )
  -- Delete Set
  self:CloseConfirmDeleteSet()
  local idx = self.state.windows.confirmDeleteSet:GetData()
  table.remove(self.settings.ruleSets, idx)
  self:RebuildRuleSetItems()
  if self.settings.currentRuleSet == idx then
    -- Reset to Default if current rule is deleted
    self.settings.currentRuleSet = 0
    self:RebuildLootRuleItems()
  end
end

function FasterLootPlus:OnCancelDeleteSet( wndHandler, wndControl, eMouseButton )
  self:CloseConfirmDeleteSet()
end

function FasterLootPlus:CloseConfirmDeleteSet()
  self.state.windows.confirmDeleteSet:Show(false)
  self.state.windows.confirmDeleteSet:Destroy()
end


---------------------------------------------------------------------------------------------------
-- FasterLootPlus Rules UI Functions
---------------------------------------------------------------------------------------------------
function FasterLootPlus:OnAddLootRule( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
  -- Add a new loot rule
  self:CreateEditLootRuleWindow(nil)
end

function FasterLootPlus:CreateEditLootRuleWindow( wndHandler )
  if self.state.windows.editLootRule == nil then
    self.state.windows.editLootRule = Apollo.LoadForm(self.xmlDoc, "EditLootRuleWindow", nil, self)
    self.state.windows.editLootRule:Show(true)
    self.state.windows.assigneeList = self.state.windows.editLootRule:FindChild("ItemList")
    self.state.currentAssignees = {}

    if wndHandler ~= nil then
      -- Get Parent List item and associated item data.
      local idx = wndHandler:GetData()
      local currentSet = self.settings.currentRuleSet
      local item = self.settings.ruleSets[currentSet].lootRules[idx]

      -- Populate the Edit window
      self.state.windows.editLootRule:SetData(idx)
      self.state.windows.editLootRule:FindChild("RuleLabel"):FindChild("Text"):SetText(item.label)
      self.state.windows.editLootRule:FindChild("ItemName"):FindChild("Text"):SetText(item.itemName)
      self.state.windows.editLootRule:FindChild("ItemType"):FindChild("Text"):SetText(item.itemType)
      self.state.windows.editLootRule:FindChild("PatternMatchingCheckButton"):FindChild("Button"):SetCheck(item.randomAssign)
      self.state.windows.editLootRule:FindChild("RandomAssignCheckButton"):FindChild("Button"):SetCheck(item.patternMatch)
      -- Need to loop through and add each assignee
      for idx,value in pairs(item.assignees) do
        table.insert(self.state.currentAssignees, value)
      end
      self:RebuildAssigneeItems()
      self.state.windows.assigneeList:ArrangeChildrenVert()
    end
  end
end

---------------------------------------------------------------------------------------------------
-- FasterLootPlus LootRuleListItem UI Functions
---------------------------------------------------------------------------------------------------
function FasterLootPlus:OnLootRuleSelected( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
  if wndHandler ~= wndControl then
    return
  end

  if eMouseButton == 0 and bDoubleClick then -- Double Left Click
    -- Open the Loot Rule Window for this loot rule.
    self:CreateEditLootRuleWindow( wndHandler )
  end
end

function FasterLootPlus:OnDeleteLootRule( wndHandler, wndControl, eMouseButton )
  local par = wndHandler:GetParent()
  local idx = par:GetData()
  local currentSet = self.settings.currentRuleSet
  table.remove(self.settings.ruleSets[currentSet].lootRules, idx)
  self:RebuildLootRuleItems()
end

---------------------------------------------------------------------------------------------------
-- FasterLootPlus RuleSet UI Functions
---------------------------------------------------------------------------------------------------
function FasterLootPlus:OnAddRuleSet( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
  -- Add a new loot rule
  self:CreateEditRuleSetWindow(nil)
end

function FasterLootPlus:CreateEditLootRuleWindow( wndHandler )
  if self.state.windows.editRuleSets == nil then
    self.state.windows.editRuleSets = Apollo.LoadForm(self.xmlDoc, "EditLootRuleWindow", nil, self)
    self.state.windows.editRuleSets:Show(true)

    if wndHandler ~= nil then
      -- Get Parent List item and associated item data.
      local idx = wndHandler:GetData()
      local item = self.settings.ruleSets[idx]

      -- Populate the Edit window
      self.state.windows.editLootRule:SetData(idx)
      self.state.windows.editLootRule:FindChild("RuleSetName"):FindChild("Text"):SetText(item.label)
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
  self.settings.currentRuleSet = idx
  self:RebuildRuleSetItems()
  self:RebuildLootRuleItems()
end

function FasterLootPlus:OnDeleteRuleSet( wndHandler, wndControl, eMouseButton )
  -- Add a new loot rule
  local par = wndHandler:GetParent()
  local idx = par:GetData()
  -- Cant Delete the first rule, there always needs to be at least one set
  if idx ~= 0 then
    self.state.windows.confirmDeleteSet = Apollo.LoadForm(self.xmlDoc, "ConfirmClearRulesWindow", nil, self)
    self.state.windows.confirmDeleteSet:SetData(idx)
  end
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
    local item = shallow(self:GetBaseRuleSet())
    item.label = label
    table.insert(self.state.currentAssignees, item)
  end

  self:CloseEditRuleSet()
  self:RebuildRuleSetItems()
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
end

---------------------------------------------------------------------------------------------------
-- FasterLootPlus EditLootRuleWindow UI Functions
---------------------------------------------------------------------------------------------------

function FasterLootPlus:OnEditLootRuleSave( wndHandler, wndControl, eMouseButton )
  local item = shallowcopy(self:GetBaseRule())
  -- Pull values from form and assign them to the item
  item.label = self.state.windows.editLootRule:FindChild("RuleLabel"):FindChild("Text"):GetText()
  item.itemName = self.state.windows.editLootRule:FindChild("ItemName"):FindChild("Text"):GetText()
  item.itemType = self.state.windows.editLootRule:FindChild("ItemType"):FindChild("Text"):GetText()
  item.randomAssign = self.state.windows.editLootRule:FindChild("PatternMatchingCheckButton"):FindChild("Button"):IsChecked()
  item.patternMatch = self.state.windows.editLootRule:FindChild("RandomAssignCheckButton"):FindChild("Button"):IsChecked()
  item.assignees = {}
  for idx,value in pairs(self.state.currentAssignees) do
    table.insert(item.assignees, value)
  end

  local idx = self.state.windows.editLootRule:GetData()
  local currentSet = self.settings.currentRuleSet
  if idx then
    -- Update Existing Item
    self.settings.ruleSets[currentSet].lootRules[idx] = item
  else
    -- Add New Item
    table.insert(self.settings.ruleSets[currentSet].lootRules, item)
  end

  self:CloseEditLootRule()
  self:RebuildLootRuleItems()
end

function FasterLootPlus:OnEditLootRuleCancel( wndHandler, wndControl, eMouseButton )
  self:CloseEditLootRule()
end

function FasterLootPlus:OnEditLootRuleClosed( wndHandler, wndControl )
  self:CloseEditLootRule()
end

function FasterLootPlus:CloseEditLootRule()
  self.state.windows.editLootRule:Show(false)
  self.state.windows.editLootRule:Destroy()
  self.state.windows.editLootRule = nil
  self.state.windows.assigneeList = nil
  self.state.currentAssignees = {}
  -- Close dependant windows
  if self.state.windows.editAssignee then
    self:CloseEditAssignee()
  end
end

function FasterLootPlus:OnAddLootAssignee( wndHandler, wndControl, eMouseButton )
  self:CreateEditAssigneeWindow(nil)
end

function FasterLootPlus:OnAssigneeItemSelected( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
  if eMouseButton == 0 and bDoubleClick then -- Double Left Click
    -- Open the Loot Rule Window for this loot rule.
    self:CreateEditAssigneeWindow(wndHandler)
  end
end

function FasterLootPlus:OnDeleteListAssignee( wndHandler, wndControl, eMouseButton )
  local par = wndHandler:GetParent()
  local idx = par:GetData()
  table.remove(self.state.currentAssignees, idx)
  self:RebuildAssigneeItems()
end

function FasterLootPlus:CreateEditAssigneeWindow( wndHandler )
  if self.state.windows.editAssignee == nil then
    self.state.windows.editAssignee = Apollo.LoadForm(self.xmlDoc, "EditAssigneeWindow", nil, self)
    self.state.windows.editAssignee:Show(true)

    if wndHandler ~= nil then
      -- Get Parent List item and associated item data.
      local idx = wndHandler:GetData()
      local item = self.state.currentAssignees[idx]
      self.state.windows.editAssignee:SetData(idx)
      self.state.windows.editAssignee:FindChild("AssigneeName"):FindChild("Text"):SetText(item)
    end
  end
end

---------------------------------------------------------------------------------------------------
-- EditAssigneeWindow Functions
---------------------------------------------------------------------------------------------------

function FasterLootPlus:OnEditAssigneeSave( wndHandler, wndControl, eMouseButton )
  -- Do save logic
  local item = self.state.windows.editAssignee:FindChild("AssigneeName"):FindChild("Text"):GetText()

  local idx = self.state.windows.editAssignee:GetData()
  if idx then
    -- Update Existing Item
    self.state.currentAssignees[idx] = item
  else
    -- Add New Item
    table.insert(self.state.currentAssignees, item)
  end

  self:CloseEditAssignee()
  self:RebuildAssigneeItems()
end

function FasterLootPlus:OnEditAssigneeCancel( wndHandler, wndControl, eMouseButton )
  self:CloseEditAssignee()
end

function FasterLootPlus:OnEditAssigneeClosed( wndHandler, wndControl )
  self:CloseEditAssignee()
end

function FasterLootPlus:CloseEditAssignee()
  self.state.windows.editAssignee:Show(false)
  self.state.windows.editAssignee:Destroy()
  self.state.windows.editAssignee = nil
end


---------------------------------------------------------------------------------------------------
-- FasterLootPlus UI Maintenance Functions
---------------------------------------------------------------------------------------------------

function FasterLootPlus:ClearLootRuleItems()
  self:DestroyWindowList(self.state.ruleItems)
end

function FasterLootPlus:AddLootRuleItem(index, item)
  local wnd = Apollo.LoadForm(self.xmlDoc, "LootRuleListItem", self.state.windows.ruleList, self)
  wnd:SetData(index)
  -- TODO Populate List Items fields from the item data
  wnd:FindChild("Label"):SetText(item.label)
  wnd:FindChild("Pattern"):SetText(item.itemName)
  wnd:FindChild("Type"):SetText(item.itemType)

  table.insert(self.state.ruleItems, wnd)
end

function FasterLootPlus:RebuildLootRuleItems()
  local currentSet = self.settings.currentRuleSet
  self:SaveLocation()
  self:ClearLootRuleItems()
  for idx,item in ipairs(self.settings.ruleSets[currentSet].lootRules) do
    self:AddLootRuleItem(idx, item)
  end
  self:RefreshUI()
end

function FasterLootPlus:ClearAssigneeItems()
  self:DestroyWindowList(self.state.assigneeItems)
end

function FasterLootPlus:AddAssigneeItem(index, item)
  local wnd = Apollo.LoadForm(self.xmlDoc, "AssigneeListItem", self.state.windows.assigneeList, self)
  wnd:SetData(index)
  wnd:SetText(item)
  table.insert(self.state.assigneeItems, wnd)
end

function FasterLootPlus:RebuildAssigneeItems()
  -- Only rebuild if the Assignee list is showing
  self:SaveLocation()
  if self.state.windows.assigneeList then
    self:ClearAssigneeItems()
    for idx,item in ipairs(self.state.currentAssignees) do
      self:AddAssigneeItem(idx, item)
    end
    self.state.windows.assigneeList:ArrangeChildrenVert()
  end
end

function FasterLootPlus:ClearRuleSetItems()
  self:DestroyWindowList(self.state.ruleSetItems)
end

function FasterLootPlus:AddRuleSetItem(index, item)
  local wnd = Apollo.LoadForm(self.xmlDoc, "RuleSetListItem", self.state.windows.ruleSetList, self)
  wnd:SetData(index)
  wnd:FindChild("Label"):SetText(item.label)
  if index == currentSet then
    wnd:FindChild("Selected"):Show(true)
  else
    wnd:FindChild("Selected"):Show(false)
  end

  table.insert(self.state.ruleSetItems, wnd)
end

function FasterLootPlus:RebuildRuleSetItems()
  self:SaveLocation()
  self:ClearLootRuleItems()
  for idx,item in ipairs(self.settings.ruleSets) do
    self:AddRuleSetItem(idx, item)
  end
  self:RefreshUI()
end

---------------------------------------------------------------------------------------------------
-- FasterLootPlus UI Refresh
---------------------------------------------------------------------------------------------------

function FasterLootPlus:RefreshUI()
  -- Location Restore
  if self.settings.user.savedWndLoc then
    locSavedLoc = WindowLocation.new(self.settings.user.savedWndLoc)
    self.state.windows.main:MoveToLocation(locSavedLoc)
  end

  -- Set Enabled Flag
  self.state.windows.main:FindChild("EnabledButton"):SetCheck(self.settings.user.enabled)

  -- Sort List Items
  self.state.windows.ruleList:ArrangeChildrenVert()
  self.state.ruleSetItems:ArrangeChildrenVert()
  if self.state.windows.assigneeList ~= nil then
    self.state.windows.assigneeList:ArrangeChildrenVert()
  end
end
