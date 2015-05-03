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

function FasterLootPlus:ListToLineSeperatedString(list)
  local i = 0
  local str = ""
  if list ~= nil then
    for idx,value in ipairs(list) do
      if i > 0 then
        str = str .. "\n"
      end
      str = str .. value
      i = i + 1
    end
  end
  return str
end

function FasterLootPlus:CompareOp(op, a, b)
  if op ~= nil then
    if op == "eq" then
      return (a == b)
    elseif op == "lt" then
      return (a < b)
    elseif op == "lte" then
      return (a <= b)
    elseif op == "gt" then
      return (a > b)
    elseif op == "gte" then
      return (a >= b)
    elseif op == "neq" then
      return (a ~= b)
    else
      return true
    end
  end
  return true
end
