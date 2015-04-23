------------------------------------------------------------------------------------------------
--  FasterLootPlus ver. @project-version@
--  Authored by Chimpy Evans, Chrono Syz -- Entity-US / Wildstar
--  Based on FasterLoot by Chimpy Evans -- Entity-US / Wildstar
--  Build @project-hash@
--  Copyright (c) Chronosis. All rights reserved
--
--  https://github.com/chronosis/FasterLootPlus
------------------------------------------------------------------------------------------------
-- FasterLoot-Utils.lua
------------------------------------------------------------------------------------------------

require "Window"

local FasterLootPlus = Apollo.GetAddon("FasterLootPlus")
local Info = Apollo.GetAddonInfo("FasterLootPlus")

-----------------------------------------------------------------------------------------------
-- Wrappers for debug functionality
-----------------------------------------------------------------------------------------------
function FasterLootPlus:ToggleDebug()
  if self.settings.user.debug then
    self:PrintDB("Debug turned off")
    self.settings.user.debug = false
  else
    self.settings.user.debug = true
    self:PrintDB("Debug turned on")
  end
end

function FasterLootPlus:PrintParty(str)
  pprint("[FasterLootPlus]: " .. str)
end

function FasterLootPlus:PrintDB(str)
  if self.settings.user.debug then
    debug("[FasterLootPlus]: " .. str)
  end
end

function FasterLootPlus:DestroyWindowList(list)
  for key,value in pairs(list) do
    list[key]:Destroy()
  end
  list = {}
end
