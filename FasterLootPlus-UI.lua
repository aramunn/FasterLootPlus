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
  self.settings.locations.main = self.state.windows.main:GetLocation():ToTable()
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
  -- if checked then
  --   wndControl:SetText("˂˂˂")
  -- else
  --   wndControl:SetText("˃˃˃")
  -- end
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
  self.settings.user.isEnabled = true
end

function FasterLootPlus:OnEnableUnchecked( wndHandler, wndControl, eMouseButton )
  self.settings.user.isEnabled = false
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
  local current = self.settings.user.currentRuleSet
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
  if self.settings.user.currentRuleSet == idx then
    -- Reset to Default if current rule is deleted
    self.settings.user.currentRuleSet = 0
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

---------------------------------------------------------------------------------------------------
-- FasterLootPlus UI Refresh
---------------------------------------------------------------------------------------------------

function FasterLootPlus:RefreshUI()
  -- Location Restore
  if self.settings.locations.main then
    locSavedLoc = WindowLocation.new(self.settings.locations.main)
    self.state.windows.main:MoveToLocation(locSavedLoc)
  end

  -- Set Enabled Flag
  self.state.windows.main:FindChild("EnabledButton"):SetCheck(self.settings.user.isEnabled)

  -- Sort List Items
  self.state.windows.ruleList:ArrangeChildrenVert()
  self.state.windows.ruleSetList:ArrangeChildrenVert()
  if self.state.windows.assigneeList ~= nil then
    self.state.windows.assigneeList:ArrangeChildrenVert()
  end
end
