------------------------------------------------------------------------------------------------
--  FasterLootPlus ver. @project-version@
--  Authored by Chimpy Evans, Chrono Syz -- Entity-US / Wildstar
--  Based on FasterLoot by Chimpy Evans -- Entity-US / Wildstar
--  Build @project-hash@
--  Copyright (c) Chronosis. All rights reserved
--
--  https://github.com/chronosis/FasterLootPlus
------------------------------------------------------------------------------------------------
-- FasterLoot-UI-Options.lua
------------------------------------------------------------------------------------------------

require "Window"
require "Item"
require "GameLib"

local FasterLootPlus = Apollo.GetAddon("FasterLootPlus")
local Info = Apollo.GetAddonInfo("FasterLootPlus")

-----------------------------------------------------------------------------------------------
-- FasterLootPlus OnConfigure
-----------------------------------------------------------------------------------------------
function FasterLootPlus:OnConfigure()
  if self.state.windows.options == nil then
    self.state.windows.options = Apollo.LoadForm(self.xmlDoc, "FasterLootPlusOptionsWindow", nil, self)
    self.state.windows.optionsPartyLootRuleItemType = self.state.windows.options:FindChild("PartyLootRule"):FindChild("PartyLootRuleDropdown")
    self.state.windows.optionsThresholdItemType = self.state.windows.options:FindChild("Threshold"):FindChild("ThresholdDropdown")
    self:PopulateThresholdDropdown()
    self:PopulatePartyLootRuleDropdown()
    -- Load Options
    self.state.windows.options:Show(true)
  end
  self.state.windows.options:ToFront()
end

-----------------------------------------------------------------------------------------------
-- FasterLootPlus Configuration UI Functions
-----------------------------------------------------------------------------------------------

function FasterLootPlus:OnOptionsSave( wndHandler, wndControl, eMouseButton )
  --local label = self.state.windows.options:FindChild("RuleSetName"):FindChild("Text"):GetText()
  --local item = shallowcopy(self:GetBaseRuleSet())
  --item.label = label

  self:CloseOptions()
end

function FasterLootPlus:OnOptionsCancel( wndHandler, wndControl, eMouseButton )
  self:CloseOptions()
end

function FasterLootPlus:OnOptionsClosed( wndHandler, wndControl )
  self:CloseOptions()
end

function FasterLootPlus:CloseOptions()
  self.state.windows.options:Show(false)
  self.state.windows.options:Destroy()
  self.state.windows.options = nil
  self.state.windows.optionsPartyLootRuleItemType = nil
  self.state.windows.optionsThresholdItemType = nil
end

function FasterLootPlus:OnThresholdTypeBtn( wndHandler, wndControl, eMouseButton )
  local bChecked = wndHandler:IsChecked()
  self.state.windows.optionsThresholdItemType:Show(bChecked)
  if bChecked == true then self.state.windows.optionsThresholdItemType:ToFront() end
end

function FasterLootPlus:OnPartyRuleTypeBtn( wndHandler, wndControl, eMouseButton )
  local bChecked = wndHandler:IsChecked()
  self.state.windows.optionsPartyLootRuleItemType:Show(bChecked)
  if bChecked == true then self.state.windows.optionsPartyLootRuleItemType:ToFront() end
end

function FasterLootPlus:OnThresholdSelectedUp( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY )
  -- Check that the user hasn't moved out of the selected item.
  if self.state.windows.selectedItem == wndHandler then
    local idx = wndHandler:GetData()
    local text = wndHandler:GetText()
    local wnd = self.state.windows.optionsThresholdItemType:GetParent()
    local select = wnd:FindChild("ThresholdSelection")
    local item = FasterLootPlus.tItemQuality[idx]
    select:SetCheck(false)
    select:SetText(item.Name)
    select:SetNormalTextColor(ApolloColor.new(item.Color))
    select:SetData(idx)
    wnd:FindChild("ThresholdDropdown"):Show(false)
  end
end

function FasterLootPlus:OnPartyLootRuleSelectedUp( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY )
  -- Check that the user hasn't moved out of the selected item.
  if self.state.windows.selectedItem == wndHandler then
    local idx = wndHandler:GetData()
    local text = wndHandler:GetText()
    local wnd = self.state.windows.optionsPartyLootRuleItemType:GetParent()
    local select = wnd:FindChild("PartyLootRuleSelection")
    select:SetCheck(false)
    select:SetText(text)
    select:SetData(idx)
    wnd:FindChild("PartyLootRuleDropdown"):Show(false)
  end
end

function FasterLootPlus:PopulateThresholdDropdown()
  local dropdown = self.state.windows.optionsThresholdItemType
  local list = self.state.listItems.thresholds
  local listItemName = "ThresholdListItem"
  --ItemTypeDropDownListItem
  self:DestroyWindowList(list)
  -- Loop through remaining items
  for idx,item in ipairs(FasterLootPlus.tItemQuality) do
    local wnd = self:CreateDownListItem(idx, item.Name, listItemName, dropdown, item.Color)
    table.insert(list, wnd)
  end
  dropdown:ArrangeChildrenVert()
end

function FasterLootPlus:PopulatePartyLootRuleDropdown()
  local dropdown = self.state.windows.optionsPartyLootRuleItemType
  local list = self.state.listItems.partyLootRules
  local listItemName = "PartyLootRuleListItem"
  --ItemTypeDropDownListItem
  self:DestroyWindowList(list)
  -- Loop through remaining items
  for key,value in pairs(FasterLootPlus.tLootRules) do
    local wnd = self:CreateDownListItem(key, value, listItemName, dropdown)
    table.insert(list, wnd)
  end
  dropdown:ArrangeChildrenVert()
end
