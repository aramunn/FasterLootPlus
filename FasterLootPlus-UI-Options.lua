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
end
