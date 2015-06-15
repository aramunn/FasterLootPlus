------------------------------------------------------------------------------------------------
--  FasterLootPlus ver. @project-version@
--  Authored by Chimpy Evans, Chrono Syz -- Entity-US / Wildstar
--  Based on FasterLoot by Chimpy Evans -- Entity-US / Wildstar
--  Build @project-hash@
--  Copyright (c) Chronosis. All rights reserved
--
--  https://github.com/chronosis/FasterLootPlus
------------------------------------------------------------------------------------------------
-- FasterLoot-UI-Assignee.lua
------------------------------------------------------------------------------------------------

require "Window"

local FasterLootPlus = Apollo.GetAddon("FasterLootPlus")
local Info = Apollo.GetAddonInfo("FasterLootPlus")


---------------------------------------------------------------------------------------------------
-- FasterLootPlus EditLootRuleWindow-Assignee UI Functions
---------------------------------------------------------------------------------------------------

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


function FasterLootPlus:OnMoveAssigneeDown( wndHandler, wndControl, eMouseButton )
  local size = #self.state.currentAssignees
  local par = wndHandler:GetParent()
  local idx = par:GetData()
  if idx < size then
    local temp = deepcopy(self.state.currentAssignees[idx])
    self.state.currentAssignees[idx] = deepcopy(self.state.currentAssignees[idx+1])
    self.state.currentAssignees[idx+1] = deepcopy(temp)
    self:RebuildAssigneeItems()
  end
end

function FasterLootPlus:OnMoveAssigneeUp( wndHandler, wndControl, eMouseButton )
  local size = #self.state.currentAssignees
  local par = wndHandler:GetParent()
  local idx = par:GetData()
  if idx > 1 then
    local temp = deepcopy(self.state.currentAssignees[idx])
    self.state.currentAssignees[idx] = deepcopy(self.state.currentAssignees[idx-1])
    self.state.currentAssignees[idx-1] = deepcopy(temp)
    self:RebuildAssigneeItems()
  end
end


---------------------------------------------------------------------------------------------------
-- FasterLootPlus UI Maintenance Functions
---------------------------------------------------------------------------------------------------

function FasterLootPlus:ClearAssigneeItems()
  self:DestroyWindowList(self.state.listItems.assignees)
end

function FasterLootPlus:AddAssigneeItem(index, item)
  local wnd = Apollo.LoadForm(self.xmlDoc, "AssigneeListItem", self.state.windows.assigneeList, self)
  wnd:SetData(index)
  wnd:SetText(item)
  table.insert(self.state.listItems.assignees, wnd)
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
