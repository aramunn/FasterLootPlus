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
require "Item"
require "GameLib"

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

function FasterLootPlus:OnToggleRuleSetWindow( wndHandler, wndControl, eMouseButton )
  local checked = wndControl:IsChecked()
  if checked then
    wndControl:SetText("˂˂˂")
  else
    wndControl:SetText("˃˃˃")
  end
  self.state.isRuleSetOpen = checked
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
  self.state.windows.confirmClearRules = nil
end

function FasterLootPlus:OnConfirmDeleteSet( wndHandler, wndControl, eMouseButton )
  -- Delete Set
  local idx = self.state.windows.confirmDeleteSet:GetData()
  table.remove(self.settings.ruleSets, idx)
  if self.settings.currentRuleSet == idx then
    -- Reset to Default if current rule is deleted
    self.settings.currentRuleSet = 0
  end
  self:RebuildRuleSetItems()
  self:RebuildLootRuleItems()
  self:CloseConfirmDeleteSet()
end

function FasterLootPlus:OnCancelDeleteSet( wndHandler, wndControl, eMouseButton )
  self:CloseConfirmDeleteSet()
end

function FasterLootPlus:CloseConfirmDeleteSet()
  self.state.windows.confirmDeleteSet:Show(false)
  self.state.windows.confirmDeleteSet:Destroy()
  self.state.windows.confirmDeleteSet = nil
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
    self.state.windows.editLootRuleItemType = self.state.windows.editLootRule:FindChild("ItemType"):FindChild("ItemTypeDropdown")
    self.state.windows.editLootRuleQualityType = self.state.windows.editLootRule:FindChild("ItemQuality"):FindChild("QualityDropdown")
    self.state.windows.editLootRuleILvlComparisonType = self.state.windows.editLootRule:FindChild("ItemLevel"):FindChild("ItemLevelComparerDropdown")
    self.state.currentAssignees = {}
    -- Add all list items to the dropdown
    self:PopulateItemTypeDropdown()
    self:PopulateQualityDropdown()
    self:PopulateILevelCompareDropdown()

    --local eventData = svardump(Item.CodeEnumItemType)
    --self.state.windows.editLootRule:FindChild("CopyToClip"):SetActionData(GameLib.CodeEnumConfirmButtonType.CopyToClipboard, eventData )

    if wndHandler ~= nil then
      -- Get Parent List item and associated item data.
      local idx = wndHandler:GetData()
      local currentSet = self.settings.currentRuleSet
      local item = self.settings.ruleSets[currentSet].lootRules[idx]

      -- Populate the Edit window
      self.state.windows.editLootRule:SetData(idx)
      self.state.windows.editLootRule:FindChild("RuleLabel"):FindChild("Text"):SetText(item.label)
      self.state.windows.editLootRule:FindChild("ItemName"):FindChild("Text"):SetText(item.itemName)
      self.state.windows.editLootRule:FindChild("ItemType"):FindChild("ItemTypeSelection"):SetData(item.itemType)
      self.state.windows.editLootRule:FindChild("ItemType"):FindChild("ItemTypeSelection"):SetText(self.tItemTypes[item.itemType])
      self.state.windows.editLootRule:FindChild("ItemQuality"):FindChild("QualityTypeSelection"):SetData(item.itemQuality)
      if item.itemQuality ~= nil then
        self.state.windows.editLootRule:FindChild("ItemQuality"):FindChild("QualityTypeSelection"):SetText(self.tItemQuality[item.itemQuality].Name)
        self.state.windows.editLootRule:FindChild("ItemQuality"):FindChild("QualityTypeSelection"):SetNormalTextColor(ApolloColor.new(self.tItemQuality[item.itemQuality].Color))
      else
        self.state.windows.editLootRule:FindChild("ItemQuality"):FindChild("QualityTypeSelection"):SetText("")
      end
      self.state.windows.editLootRule:FindChild("ItemLevel"):FindChild("ItemLevelComparerSelection"):SetData(item.itemLevel.compareOp)
      if item.itemLevel.compareOp ~= nil then
        self.state.windows.editLootRule:FindChild("ItemLevel"):FindChild("ItemLevelComparerSelection"):SetText(self.tComparisonOps[item.itemLevel.compareOp])
      else
        self.state.windows.editLootRule:FindChild("ItemLevel"):FindChild("ItemLevelComparerSelection"):SetText("")
      end
      if item.itemLevel.level ~= nil then
        self.state.windows.editLootRule:FindChild("ItemLevel"):FindChild("Text"):SetText(item.itemLevel.level)
      else
        self.state.windows.editLootRule:FindChild("ItemLevel"):FindChild("Text"):SetText("0")
      end
      self.state.windows.editLootRule:FindChild("RandomAssignCheckButton"):FindChild("Button"):SetCheck(item.randomAssign)
      self.state.windows.editLootRule:FindChild("PatternMatchingCheckButton"):FindChild("Button"):SetCheck(item.patternMatch)
      self.state.windows.editLootRule:FindChild("EnabledCheckButton"):FindChild("Button"):SetCheck(item.enabled)

      -- Need to loop through and add each assignee
      for idx,value in ipairs(item.assignees) do
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

function FasterLootPlus:OnEditLootRule( wndHandler, wndControl, eMouseButton )
  local par = wndHandler:GetParent()
  self:CreateEditLootRuleWindow( par )
end


function FasterLootPlus:OnDeleteLootRule( wndHandler, wndControl, eMouseButton )
  local par = wndHandler:GetParent()
  local idx = par:GetData()
  local currentSet = self.settings.currentRuleSet
  table.remove(self.settings.ruleSets[currentSet].lootRules, idx)
  self:RebuildLootRuleItems()
end

function FasterLootPlus:OnLootRuleToggle( wndHandler, wndControl, eMouseButton )
  local par = wndHandler:GetParent()
  local idx = par:GetData()
  local currentSet = self.settings.currentRuleSet
  local checked = wndControl:IsChecked()
  self.settings.ruleSets[currentSet].lootRules[idx].enabled = checked
end

function FasterLootPlus:OnMoveLootRuleDown( wndHandler, wndControl, eMouseButton )
  local currentSet = self.settings.currentRuleSet
  local size = #self.settings.ruleSets[currentSet].lootRules
  local par = wndHandler:GetParent()
  local idx = par:GetData()
  if idx < size then
    local temp = shallowcopy(self.settings.ruleSets[currentSet].lootRules[idx+1])
    self.settings.ruleSets[currentSet].lootRules[idx+1] = shallowcopy(self.settings.ruleSets[currentSet].lootRules[idx])
    self.settings.ruleSets[currentSet].lootRules[idx] = shallowcopy(temp)
    self:RebuildLootRuleItems()
  end
end

function FasterLootPlus:OnMoveLootRuleUp( wndHandler, wndControl, eMouseButton )
  function FasterLootPlus:OnMoveLootRuleDown( wndHandler, wndControl, eMouseButton )
    local currentSet = self.settings.currentRuleSet
    local size = #self.settings.ruleSets[currentSet].lootRules
    local par = wndHandler:GetParent()
    local idx = par:GetData()
    if idx > 1 then
      local temp = shallowcopy(self.settings.ruleSets[currentSet].lootRules[idx])
      self.settings.ruleSets[currentSet].lootRules[idx] = shallowcopy(self.settings.ruleSets[currentSet].lootRules[idx-1])
      self.settings.ruleSets[currentSet].lootRules[idx-1] = shallowcopy(temp)
      self:RebuildLootRuleItems()
    end
  end
end


---------------------------------------------------------------------------------------------------
-- FasterLootPlus EditLootRuleWindow UI Functions
---------------------------------------------------------------------------------------------------

function FasterLootPlus:OnEditLootRuleSave( wndHandler, wndControl, eMouseButton )
  local item = shallowcopy(self:GetBaseRule())
  -- Pull values from form and assign them to the item
  item.label = self.state.windows.editLootRule:FindChild("RuleLabel"):FindChild("Text"):GetText()
  item.itemName = self.state.windows.editLootRule:FindChild("ItemName"):FindChild("Text"):GetText()
  item.itemType = self.state.windows.editLootRule:FindChild("ItemType"):FindChild("ItemTypeSelection"):GetData()
  item.patternMatch = self.state.windows.editLootRule:FindChild("PatternMatchingCheckButton"):FindChild("Button"):IsChecked()
  item.randomAssign = self.state.windows.editLootRule:FindChild("RandomAssignCheckButton"):FindChild("Button"):IsChecked()
  item.itemQuality = self.state.windows.editLootRule:FindChild("ItemQuality"):FindChild("QualityTypeSelection"):GetData()
  item.itemLevel.compareOp = self.state.windows.editLootRule:FindChild("ItemLevel"):FindChild("ItemLevelComparerSelection"):GetData()
  local lvl = self.state.windows.editLootRule:FindChild("ItemLevel"):FindChild("Text"):GetText()
  if tonumber(lvl) == nil then
    lvl = "0"
  end
  item.itemLevel.level = lvl
  item.enabled = self.state.windows.editLootRule:FindChild("EnabledCheckButton"):FindChild("Button"):IsChecked()
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
  self.state.windows.editLootRuleItemType:Show(false)
  self.state.windows.editLootRuleQualityType:Show(false)
  self.state.windows.editLootRuleILvlComparisonType:Show(false)
  self.state.windows.editLootRule:Destroy()
  self.state.windows.editLootRule = nil
  self.state.windows.assigneeList = nil
  self.state.windows.editLootRuleItemType = nil
  self.state.windows.editLootRuleQualityType = nil
  self.state.windows.editLootRuleILvlComparisonType = nil
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

function FasterLootPlus:OnEditAssignee( wndHandler, wndControl, eMouseButton )
  local par = wndHandler:GetParent()
  self:CreateEditAssigneeWindow(par)
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

function FasterLootPlus:OnItemTypeBtn( wndHandler, wndControl, eMouseButton )
  local bChecked = wndHandler:IsChecked()
  self.state.windows.editLootRuleItemType:Show(bChecked)
  self.state.windows.editLootRuleItemType:ToFront()
end

function FasterLootPlus:OnQualityTypeBtn( wndHandler, wndControl, eMouseButton )
  local bChecked = wndHandler:IsChecked()
  self.state.windows.editLootRuleQualityType:Show(bChecked)
  self.state.windows.editLootRuleQualityType:ToFront()
end

function FasterLootPlus:OnILvlCompareTypeBtn( wndHandler, wndControl, eMouseButton )
  local bChecked = wndHandler:IsChecked()
  self.state.windows.editLootRuleILvlComparisonType:Show(bChecked)
  self.state.windows.editLootRuleILvlComparisonType:ToFront()
end

function FasterLootPlus:PopulateItemTypeDropdown()
  local dropdown = self.state.windows.editLootRuleItemType
  local list = self.state.listItems.itemTypes
  local listItemName = "ItemTypeListItem"
  --ItemTypeListItem
  self:DestroyWindowList(list)
  -- Blank first item
  local wnd = self:CreateDownListItem(nil, "", listItemName, dropdown)
  table.insert(list, wnd)
  -- Loop through remaining items
  --for key,value in pairs(FasterLootPlus.tItemTypes) do
  for i = -100, 500, 1 do
    local v = FasterLootPlus.tItemTypes[i]
    if v then
      local wnd = self:CreateDownListItem(i, v, listItemName, dropdown)
      table.insert(list, wnd)
    end
  end
  dropdown:ArrangeChildrenVert()
end

function FasterLootPlus:PopulateQualityDropdown()
  local dropdown = self.state.windows.editLootRuleQualityType
  local list = self.state.listItems.itemQualities
  local listItemName = "ItemQualityListItem"
  --ItemTypeDropDownListItem
  self:DestroyWindowList(list)
  -- Blank first item
  local wnd = self:CreateDownListItem(nil, "", listItemName, dropdown)
  table.insert(list, wnd)
  -- Loop through remaining items
  for idx,item in ipairs(FasterLootPlus.tItemQuality) do
    local wnd = self:CreateDownListItem(idx, item.Name, listItemName, dropdown, item.Color)
    table.insert(list, wnd)
  end
  dropdown:ArrangeChildrenVert()
end

function FasterLootPlus:PopulateILevelCompareDropdown()
  local dropdown = self.state.windows.editLootRuleILvlComparisonType
  local list = self.state.listItems.itemLevelComparitors
  local listItemName = "ItemLevelComparitorListItem"
  --ItemTypeDropDownListItem
  self:DestroyWindowList(list)
  -- Blank first item
  local wnd = self:CreateDownListItem(nil, "", listItemName, dropdown)
  table.insert(list, wnd)
  -- Loop through remaining items
  for key,value in pairs(FasterLootPlus.tComparisonOps) do
    local wnd = self:CreateDownListItem(key, value, listItemName, dropdown)
    table.insert(list, wnd)
  end
  dropdown:ArrangeChildrenVert()
end

function FasterLootPlus:CreateDownListItem(key, value, itemType, dest, color)
  if color == nil then color = "ffffffff" end
  local wnd = Apollo.LoadForm(self.xmlDoc, itemType, dest, self)
  wnd:SetTextColor(ApolloColor.new(color))
  wnd:SetText(value)
  wnd:SetData(key)
  return wnd
end

function FasterLootPlus:OnListItemSelected( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
  -- Highlight
  wndHandler:SetSprite("BK3:btnHolo_ListView_MidPressed")
  self.state.windows.selectedItem = wndHandler
end

function FasterLootPlus:OnListItemEntered( wndHandler, wndControl, x, y )
  wndHandler:SetSprite("BK3:btnHolo_ListView_MidFlyby")
end

function FasterLootPlus:OnListItemExited( wndHandler, wndControl, x, y )
  wndHandler:SetSprite("BK3:btnHolo_ListView_MidNormal")
end

function FasterLootPlus:OnItemTypeSelectedUp( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY )
  -- Check that the user hasn't moved out of the selected item.
  if self.state.windows.selectedItem == wndHandler then
    local idx = wndHandler:GetData()
    local text = wndHandler:GetText()
    local wnd = self.state.windows.editLootRuleItemType:GetParent()
    local select = wnd:FindChild("ItemTypeSelection")
    select:SetCheck(false)
    select:SetText(text)
    select:SetData(idx)
    wnd:FindChild("ItemTypeDropdown"):Show(false)
  end
end

function FasterLootPlus:OnItemQualitySelectedUp( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY )
  -- Check that the user hasn't moved out of the selected item.
  if self.state.windows.selectedItem == wndHandler then
    local idx = wndHandler:GetData()
    local text = wndHandler:GetText()
    local wnd = self.state.windows.editLootRuleQualityType:GetParent()
    local select = wnd:FindChild("QualityTypeSelection")
    select:SetCheck(false)
    local item = FasterLootPlus.tItemQuality[idx]
    if item ~= nil then
      select:SetText(item.Name)
      select:SetNormalTextColor(ApolloColor.new(item.Color))
      select:SetData(idx)
    else
      select:SetText("")
      select:SetData(nil)
    end
    wnd:FindChild("QualityDropdown"):Show(false)
  end
end

function FasterLootPlus:OnItemLevelComparitorSelectedUp( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY )
  -- Check that the user hasn't moved out of the selected item.
  if self.state.windows.selectedItem == wndHandler then
    local idx = wndHandler:GetData()
    local text = wndHandler:GetText()
    local wnd = self.state.windows.editLootRuleILvlComparisonType:GetParent()
    local select = wnd:FindChild("ItemLevelComparerSelection")
    select:SetCheck(false)
    select:SetText(text)
    select:SetData(idx)
    wnd:FindChild("ItemLevelComparerDropdown"):Show(false)
  end
end

function FasterLootPlus:DecItemLevel( wndHandler, wndControl, eMouseButton )
  local par = wndHandler:GetParent()
  local txt = par:FindChild("Text")
  local str = txt:GetText()
  local value = tonumber(str)
  if value ~= nil then
    if value > 0 then
      value = value - 1
    end
  else
    value = 0
  end
  txt:SetText(tostring(value))
end

function FasterLootPlus:IncItemLevel( wndHandler, wndControl, eMouseButton )
  local par = wndHandler:GetParent()
  local txt = par:FindChild("Text")
  local str = txt:GetText()
  local value = tonumber(str)
  if value ~= nil then
    if value < 90 then
      value = value + 1
    end
  else
    value = 0
  end
  txt:SetText(tostring(value))
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
  -- Populate List Items fields from the item data
  wnd:FindChild("Label"):SetText(item.label)
  if item.patternMatch == true then
    wnd:FindChild("Pattern"):SetText("RegExp(" .. item.itemName .. ")")
  else
    wnd:FindChild("Pattern"):SetText(item.itemName)
  end
  wnd:FindChild("Type"):SetText(self.tItemTypes[item.itemType])
  if item.itemQuality ~= nil then
    wnd:FindChild("Quality"):SetText(self.tItemQuality[item.itemQuality].Name)
    wnd:FindChild("Quality"):SetTextColor(ApolloColor.new(self.tItemQuality[item.itemQuality].Color))
  else
    wnd:FindChild("Quality"):SetText("")
  end
  if item.itemLevel.compareOp ~= nil then
    local str = "ilvl " .. self.tComparisonOps[item.itemLevel.compareOp] .. " " .. item.itemLevel.level
    wnd:FindChild("ItemLevel"):SetText(str)
  else
    wnd:FindChild("ItemLevel"):SetText("")
  end
  wnd:FindChild("EnableRuleButton"):SetCheck(item.enabled)

  local str = ""
  if item.randomAssign == true then
    str = "-Randomized-\n"
  end
  str = str .. self:ListToLineSeperatedString(item.assignees)
  wnd:SetTooltip(str)

  table.insert(self.state.ruleItems, wnd)
end

function FasterLootPlus:RebuildLootRuleItems()
  local currentSet = self.settings.currentRuleSet
  local vScrollPos = self.state.windows.ruleList:GetVScrollPos()
  self:SaveLocation()
  self:ClearLootRuleItems()
  for idx,item in ipairs(self.settings.ruleSets[currentSet].lootRules) do
    self:AddLootRuleItem(idx, item)
  end
  self.state.windows.ruleList:SetVScrollPos(vScrollPos)
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
  local vScrollPos = self.state.windows.assigneeList:GetVScrollPos()
  self:SaveLocation()
  if self.state.windows.assigneeList then
    self:ClearAssigneeItems()
    for idx,item in ipairs(self.state.currentAssignees) do
      self:AddAssigneeItem(idx, item)
    end
    self.state.windows.assigneeList:ArrangeChildrenVert()
  end
  self.state.windows.assigneeList:SetVScrollPos(vScrollPos)
end

function FasterLootPlus:ClearRuleSetItems()
  self:DestroyWindowList(self.state.ruleSetItems)
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
  self.state.windows.ruleSetList:ArrangeChildrenVert()
  if self.state.windows.assigneeList ~= nil then
    self.state.windows.assigneeList:ArrangeChildrenVert()
  end
end
