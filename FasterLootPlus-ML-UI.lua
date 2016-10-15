------------------------------------------------------------------------------------------------
--  FasterLootPlus ver. @project-version@
--  Authored by Chimpy Evans, Chrono Syz -- Entity-US / Wildstar
--  Based on FasterLoot by Chimpy Evans -- Entity-US / Wildstar
--  Build @project-hash@
--  Copyright (c) Chronosis. All rights reserved
--
--  https://github.com/chronosis/FasterLootPlus
------------------------------------------------------------------------------------------------
-- FasterLoot-ML-UI.lua
------------------------------------------------------------------------------------------------

require "Window"

local FasterLootPlus = Apollo.GetAddon("FasterLootPlus")
local Info = Apollo.GetAddonInfo("FasterLootPlus")
local Utils = Apollo.GetPackage("SimpleUtils").tPackage

------------------------------------------------------------------------------------------------
--- Constants Handlers
------------------------------------------------------------------------------------------------
FasterLootPlus.tClassToIcon =
{
	[-2] = "FasterLootPlusSprites:FastCoins32", -- Roll Off Timer
	[-1] = "ClientSprites:GroupRandomLootIcon", -- Random loot
	[0] = "CRB_GroupFrame:sprGroup_Disconnected", -- Disconnected / OOR
	[GameLib.CodeEnumClass.Medic]       	= "Icon_Windows_UI_CRB_Medic",
	[GameLib.CodeEnumClass.Esper]       	= "Icon_Windows_UI_CRB_Esper",
	[GameLib.CodeEnumClass.Warrior]     	= "Icon_Windows_UI_CRB_Warrior",
	[GameLib.CodeEnumClass.Stalker]     	= "Icon_Windows_UI_CRB_Stalker",
	[GameLib.CodeEnumClass.Engineer]    	= "Icon_Windows_UI_CRB_Engineer",
	[GameLib.CodeEnumClass.Spellslinger]  	= "Icon_Windows_UI_CRB_Spellslinger",
}

FasterLootPlus.tItemQuality =
{
  [Item.CodeEnumItemQuality.Inferior] =
  {
    Name			= "Inferior",
    Color			= "ItemQuality_Inferior",
    BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Silver",
    HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Silver",
    SquareSprite	= "BK3:UI_BK3_ItemQualityGrey",
    CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetGrey",
    NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Silver",
  },
  [Item.CodeEnumItemQuality.Average] =
  {
    Name			= "Average",
    Color		   	= "ItemQuality_Average",
    BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_White",
    HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_White",
    SquareSprite	= "BK3:UI_BK3_ItemQualityWhite",
    CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetWhite",
    NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_White",
	},
  [Item.CodeEnumItemQuality.Good]	=
  {
    Name			= "Good",
    Color		   	= "ItemQuality_Good",
    BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Green",
    HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Green",
    SquareSprite	= "BK3:UI_BK3_ItemQualityGreen",
    CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetGreen",
    NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Green",
  },
  [Item.CodeEnumItemQuality.Excellent] =
  {
    Name			= "Excellent",
    Color		   	= "ItemQuality_Excellent",
    BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Blue",
    HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Blue",
    SquareSprite	= "BK3:UI_BK3_ItemQualityBlue",
    CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetBlue",
    NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Blue",
  },
  [Item.CodeEnumItemQuality.Superb] =
  {
    Name			= "Superb",
    Color		   	= "ItemQuality_Superb",
    BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Purple",
    HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Purple",
    SquareSprite	= "BK3:UI_BK3_ItemQualityPurple",
    CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetPurple",
    NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Purple",
	},
  [Item.CodeEnumItemQuality.Legendary] =
  {
    Name			= "Legendary",
    Color		   	= "ItemQuality_Legendary",
    BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Orange",
    HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Orange",
    SquareSprite	= "BK3:UI_BK3_ItemQualityOrange",
    CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetOrange",
    NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Orange",
  },
  [Item.CodeEnumItemQuality.Artifact] =
  {
    Name			= "Artifact",
    Color		   	= "ItemQuality_Artifact",
    BarSprite	   	= "CRB_Tooltips:sprTooltip_RarityBar_Pink",
    HeaderSprite	= "CRB_Tooltips:sprTooltip_Header_Pink",
    SquareSprite	= "BK3:UI_BK3_ItemQualityMagenta",
    CompactIcon	 	= "CRB_TooltipSprites:sprTT_HeaderInsetPink",
    NotifyBorder	= "ItemQualityBrackets:sprItemQualityBracket_Pink",
  }
}


------------------------------------------------------------------------------------------------
--- Event Handlers
------------------------------------------------------------------------------------------------
function FasterLootPlus:OnLootAssigned(tLootInfo) --objItem, strLooter)
	local strItem = tLootInfo.itemLoot:GetChatLinkString()
	local nCount = tLootInfo.itemLoot:GetStackCount()
	local strLooter = tLootInfo.strPlayer
	Event_FireGenericEvent("GenericEvent_LootChannelMessage", String_GetWeaselString(Apollo.GetString("CRB_MasterLoot_AssignMsg"), strItem, strLooter))
end

function FasterLootPlus:DelayMasterLootWindowMoved( wndHandler, wndControl, nOldLeft, nOldTop, nOldRight, nOldBottom )
	self.settings.locations.delayedMasterLoot = self.state.windows.delayedMasterLoot:GetLocation():ToTable()
end

function FasterLootPlus:OnMasterLooterWindowMoved( wndHandler, wndControl, nOldLeft, nOldTop, nOldRight, nOldBottom )
	self.settings.locations.masterLooter = self.state.windows.masterLoot:GetLocation():ToTable()
end

function FasterLootPlus:OnMasterLootWindowMoved( wndHandler, wndControl, nOldLeft, nOldTop, nOldRight, nOldBottom )
	self.settings.locations.masterLoot = self.state.windows.masterLoot:GetLocation():ToTable()
end

function FasterLootPlus:OnDelayedMasterLootOpen( wndHandler, wndControl, eMouseButton )
	self:CloseDelayedMLWindow()
	self:OpenMLWindow()
end

function FasterLootPlus:OnCloseMLWindow( wndHandler, wndControl, eMouseButton )
	self:CloseMLWindow()
end

function FasterLootPlus:OnGroupLeft()
	self:CloseMLWindow()
end

function FasterLootPlus:OnToggleGroupBag()
	self:RefreshMLWindow()
end

function FasterLootPlus:OnGenerateTooltip( wndHandler, wndControl, eToolTipType, x, y )
	wndControl:SetTooltipDoc(nil)
	local data = wndHandler:GetData()
	if data then
		local item = data.itemDrop
		local itemEquipped = item:GetEquippedItemForItemType()
		Tooltip.GetItemTooltipForm(self, wndControl, item, {bPrimary = true, bSelling = false, itemCompare = itemEquipped})
	end
end

function FasterLootPlus:OnMLItemSelected( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	if wndHandler then
		local item = wndHandler:GetData()
		if eMouseButton == 1 then
			if Apollo.IsShiftKeyDown() then
				Event_FireGenericEvent("ItemLink", item.itemDrop)
			else
				-- Direct Link to Party Chat
				Event_FireGenericEvent("ItemLink", item.itemDrop)
			end
		end
		-- Alter Background of this and change background of previous selection
		if self.state.selection.masterLootItem then
			self.state.selection.masterLootItem:SetSprite("BK3:btnHolo_ListView_SimpleNormal")
		end
		wndHandler:SetSprite("BK3:btnHolo_ListView_SimplePressed")
		-- Set selection value
		self.state.selection.masterLootItem = wndHandler
		self.state.selection.masterLootItemId = item.nLootId
		-- Populate Looter List if this is the looter window
		if wndHandler:GetParent():GetParent():GetName() == "MasterLooterWindow" then
			self:PopulateMLLooterLists(item)
		end
	end
end

function FasterLootPlus:OnMLLooterSelected( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	if wndHandler then
		local data = wndHandler:GetData()
		local unitLooter = data.looter
		local lootType = data.type
		local class = data.classID
		-- Alter Background of this and change background of previous selection
		if self.state.selection.masterLootRecipients then
			self.state.selection.masterLootRecipients:SetSprite("BK3:btnHolo_ListView_SimpleNormal")
		end
		wndHandler:SetSprite("BK3:btnHolo_ListView_SimplePressed")
		-- Set selection value
		self.state.selection.masterLootRecipients = wndHandler
		if lootType == -1 then
			self.state.selection.masterLootRecipientsId = " - Random - "
		elseif lootType == -2 then
			self.state.selection.masterLootRecipientsId = " - Initiate Roll-off - "
		elseif lootType == 0 then
			-- Out of Range Character
		else
			self.state.selection.masterLootRecipientsId = unitLooter:GetName()
		end
	end
end

function FasterLootPlus:OnMLAssign( wndHandler, wndControl, eMouseButton )
	-- Check both selections
	if not self.state.selection.masterLootRecipients or not self.state.selection.masterLootItem then
		return
	end
	local loot = self.state.selection.masterLootItem:GetData()
	local item = loot.itemDrop
	local data = self.state.selection.masterLootRecipients:GetData()
	local unitLooter = data.looter
	local class = data.classID
	local lootType = data.type
	-- Perform actual assignment based on selections
	if lootType == -2 then
		if self.state.isRollOffActive then
			Utils:cprint("[FasterLootPlus] Error: You can not start another roll-off while one is still active.")
			return
		end
		if not self.settings.user.rollTime then self.settings.user.rollTime = 12 end
		-- Start Roll-off Time
		self.state.listItems.rolls = {}
		self.state.isRollOffActive = true
		self.state.isTiedRollOff = false
		self.state.timers.rollOff = ApolloTimer.Create(self.settings.user.rollTime, false, "OnRollOffEnd", self)
		-- Save Roll-off Item
		self.state.rollOffItem = loot
		-- Announce Roll
		local itemLink = item:GetChatLinkString()
		Utils:pprint("==============================")
		Utils:pprint("[FasterLootPlus]: /rolling for Item " .. itemLink)
		Utils:pprint("[FasterLootPlus]: Closing rolls in " .. self.settings.user.rollTime .. "s")
		Utils:pprint("==============================")
	elseif lootType == -1 then
		-- if random assign randomly
		local validLooter = false
		local looter
		while validLooter == false do
			looter = self:GetRandomLooter(loot.tLooters)
			validLooter = self.state.listItems.validLooters[looter:GetName()]
		end
		self:AssignLoot(loot.nLootId, looter, item, "Manual-Random")
		self.state.selection.masterLootItem = nil
		self.state.selection.masterLootRecipients = nil
		return
	elseif lootType == 0 then
		-- Do nothing cause this is OOR
	else
		local name = unitLooter:GetName()
		if self.state.listItems.validLooters[name] then
			self:AssignLoot(loot.nLootId, unitLooter, item, "Manual-Assigned")
			self.state.selection.masterLootItem = nil
			self.state.selection.masterLootRecipients = nil
		end
		return
	end
end

function FasterLootPlus:OnRollOffEnd()
	self.state.isRollOffActive = false
	local loot = self.state.rollOffItem
	local item = loot.itemDrop
	local itemLink = item:GetChatLinkString()
	Utils:pprint("[FasterLootPlus]: Rolls are now closed for " .. itemLink)
	-- Check all rolls
	local winners = self:GetRollOffWinners()
	if winners.result == "win" then
		local winner = winners.rollers[1]
		Utils:pprint("[FasterLootPlus]: " .. winner .. " wins with a roll of " .. winners.roll .. "!")
		-- look up user and assign loot
		local data = self.state.listItems.masterLootRecipients[winner]:GetData()
		local looter = data and data.looter or winner
		self:AssignLoot(loot.nLootId, looter, item, "Roll-off")
	elseif winners.result == "tie" then
		 self.state.listItems.tiedRollers = {}
		 local strRollers = ""
		 local c = 0
		for k,v in pairs( winners.rollers ) do
			if c ~= 0 then strRollers = strRollers .. ", " end
			strRollers = strRollers .. v
			c = c + 1
			self.state.listItems.tiedRollers[v] = true
		end
		self.state.nTiedRollersCount = c
		self.state.listItems.rolls = {}
		self.state.isTiedRollOff = true
		self.state.isRollOffActive = true
		Utils:pprint("[FasterLootPlus]: " .. strRollers .. " tied with a winning roll of " .. winners.roll .. "!")
		Utils:pprint("[FasterLootPlus]: Please /roll to break the tie")
	elseif winners.result == "none" then
		Utils:pprint("[FasterLootPlus]: No rolls recorded.")
	end
	Utils:pprint("==============================")
end

function FasterLootPlus:OnButtonFlash()
	self.state.isFlashShown = not self.state.isFlashShown
	local nOpacity = 0
	if self.state.isFlashShown then nOpacity = 1 end
	self.state.windows.delayedMasterLoot:FindChild("Flash"):SetOpacity(nOpacity, 2)
end

function FasterLootPlus:OnChatMessage(tChannel, tEventArgs)
	-- Check that it's a system message
	if (tChannel:GetType() == ChatSystemLib.ChatChannel_System) then
		-- Parse message to see if it's a roll
		local messages = tEventArgs.arMessageSegments
		local message = messages[1].strText
		if string.find(message,"rolls") ~= nil then
			-- Do something interesting
			local parts = message:split("[ ]+")
			local roller = parts[1] .. " " .. parts[2]
			local roll = tonumber(parts[4])
			local prerange = parts[5]
			local ranges = string.gsub(string.gsub(string.gsub(prerange, "%(", ""), "%)", ""), "-", " "):split("[ ]+")
			local low = tonumber(ranges[1])
			local high = tonumber(ranges[2])
			local t = {
				player = roller,
				roll = roll,
				range = {
					low = low,
					high = high
				}
			}
			Event_FireGenericEvent("PlayerRoll", t)
		end
	end
end

function FasterLootPlus:OnPlayerRoll(tEventArgs)
	-- Only record rolls if roll is active
	if self.state.isRollOffActive then
		-- Skip if in tied roll off and not a valid player
		if self.state.isTiedRollOff and not self.state.listItems.tiedRollers[tEventArgs.player] then return end
		-- Only record roll if it's 1 to 100
		if tEventArgs.range.low == 1 and tEventArgs.range.high == 100 then
			-- Only record first roll for the player
			if not self.state.listItems.rolls[tEventArgs.player] then
				self.state.listItems.rolls[tEventArgs.player] = tEventArgs.roll
				if self.state.isTiedRollOff then
					self.state.nTiedRollersCount = self.state.nTiedRollersCount - 1
					if self.state.nTiedRollersCount <= 0 then self:OnRollOffEnd() end
				end
			end
		end
	end
end
------------------------------------------------------------------------------------------------
--- Master Loot Logic
------------------------------------------------------------------------------------------------
function FasterLootPlus:OpenMLWindow()
	local nVPos = nil
	-- Make sure no ML window is open
	if self.state.windows.masterLoot then
		if self.state.windows.masterLootRecipients ~= nil then
			nVPos = self.state.windows.masterLootRecipients:GetVScrollPos()
		end
		self:CloseMLWindow()
	end

	-- Am I the ML or not?
	if self.state.player.isLeader then
		self.state.windows.masterLoot = Apollo.LoadForm(self.xmlDoc, "MasterLooterWindow", nil, self)
		if self.settings.locations.masterLooter then
			locSavedLoc = WindowLocation.new(self.settings.locations.masterLooter)
			self.state.windows.masterLoot:MoveToLocation(locSavedLoc)
		end
		self.state.windows.masterLootItems = self.state.windows.masterLoot:FindChild("ItemList")
		self.state.windows.masterLootRecipients = self.state.windows.masterLoot:FindChild("LooterList")
		if nVPos ~= nil then
			self.state.windows.masterLootRecipients:SetVScrollPos(nVPos)
		end
	else
		self.state.windows.masterLoot = Apollo.LoadForm(self.xmlDoc, "MasterLootWindow", nil, self)
		if self.settings.locations.masterLoot then
			locSavedLoc = WindowLocation.new(self.settings.locations.masterLoot)
			self.state.windows.masterLoot:MoveToLocation(locSavedLoc)
		end
		self.state.windows.masterLootItems = self.state.windows.masterLoot:FindChild("ItemList")
		self.state.windows.masterLootRecipients = nil
	end
	self:PopulateMLItemLists()
	self.state.windows.masterLoot:Show(true)
	self.state.isMasterLootOpen = true
end

function FasterLootPlus:CloseMLWindow()
	if self.state.windows.masterLoot then
		if self.state.windows.masterLootRecipients == nil then  -- masterLoot
			self.settings.locations.masterLooter = self.state.windows.masterLoot:GetLocation():ToTable()
		else -- masterLooter
			self.settings.locations.masterLoot = self.state.windows.masterLoot:GetLocation():ToTable()
		end
		self.state.windows.masterLoot:Show(false)
		self.state.windows.masterLoot:DestroyChildren()
		self.state.windows.masterLoot:Destroy()
	end
	self.state.isMasterLootOpen = false
	self.state.windows.masterLoot = nil
	self.state.selection.masterLootItem = nil
	self.state.selection.masterLootRecipients = nil
end

function FasterLootPlus:SetButtonFlash(active)
	if self.state.timers.flashUpdater then
		self.state.timers.flashUpdater:Stop()
		self.state.timers.flashUpdater = nil
	end
	if active then
		self.state.timers.flashUpdater = ApolloTimer.Create(0.5, true, "OnButtonFlash", self)
	end
end

function FasterLootPlus:OpenDelayedMLWindow()
	if not self.state.windows.delayedMasterLoot then
		-- Windows isn't open, so open
		self.state.windows.delayedMasterLoot = Apollo.LoadForm(self.xmlDoc, "MasterLootDelayOpenWindow", nil, self)
		if self.settings.locations.delayedMasterLoot ~= nil then
			locSavedLoc = WindowLocation.new(self.settings.locations.delayedMasterLoot)
			self.state.windows.delayedMasterLoot:MoveToLocation(locSavedLoc)
		end
	end
	self.state.windows.delayedMasterLoot:Show(true,true)
	-- Start Flash
	self:SetButtonFlash(true)
end

function FasterLootPlus:CloseDelayedMLWindow()
	if self.state.windows.delayedMasterLoot then
		self.settings.locations.delayedMasterLoot = self.state.windows.delayedMasterLoot:GetLocation():ToTable()
		self.state.windows.delayedMasterLoot:Show(false)
		self.state.windows.delayedMasterLoot:Destroy()
	end
	--Stop Flash
	self:SetButtonFlash(false)
	self.state.windows.delayedMasterLoot = nil
end

function FasterLootPlus:RefreshMLWindow()
	if #self.state.listItems.masterLoot > 0 then
		if not self.state.windows.masterLoot then
			-- if ML window is not shown, then show the delay button and flash it
			self:OpenDelayedMLWindow()
		else
			-- if the ML window is shown then update the contents of the ML window
			self:OpenMLWindow()
		end
	else
		self:CloseDelayedMLWindow()
		self:CloseMLWindow()
	end
end

function FasterLootPlus:EmptyMLItemLists()
	self.state.windows.masterLootItems:DestroyChildren()
	self.state.listItems.masterLootItems = {}
end

function FasterLootPlus:EmptyMLLooterLists()
	self.state.windows.masterLootRecipients:DestroyChildren()
	self.state.listItems.masterLootRecipients = {}
end

function FasterLootPlus:AddMLItem(tItem)
	if self.state.windows.masterLootItems then
		local wnd = Apollo.LoadForm(self.xmlDoc, "MasterLootItemListItem", self.state.windows.masterLootItems, self)
		self.state.listItems.masterLootItems[tItem.nLootId] = wnd
		local item = tItem.itemDrop
		local iQuality = item:GetItemQuality()
		local name = item:GetName()
		local type = item:GetItemTypeName()
		local icon = item:GetIcon()
		--vardump(tItem)
		wnd:FindChild("ItemText"):SetTextColor(self.tItemQuality[iQuality].Color)
		wnd:FindChild("ItemText"):SetText(name)
		wnd:FindChild("ItemType"):SetText(type)
		wnd:FindChild("ItemBorder"):SetSprite(self.tItemQuality[iQuality].SquareSprite)
		wnd:FindChild("ItemBorder"):SetText("")
		wnd:FindChild("ItemBorder"):FindChild("ItemIcon"):SetSprite(icon)

		wnd:SetData(tItem)
	end
end

function FasterLootPlus:AddMLLooter(name, class, level)
	if self.state.windows.masterLootRecipients and name then
		local wnd = Apollo.LoadForm(self.xmlDoc, "MasterLootLooterListItem", self.state.windows.masterLootRecipients, self)
		self.state.listItems.masterLootRecipients[name] = wnd
		self.state.listItems.validLooters[name] = true

		wnd:FindChild("ClassBorder"):FindChild("ClassIcon"):SetSprite(self.tClassToIcon[class])
		wnd:FindChild("LooterName"):SetText(name)
		wnd:FindChild("LooterLevel"):SetText(level)

		wnd:SetName(name)

		return wnd
	end
	return nil
end

function FasterLootPlus:PopulateMLItemLists()
	-- Save scoll location and check selection
	local nVPos = self.state.windows.masterLootItems:GetVScrollPos()

	self:EmptyMLItemLists()
	for idx, tItem in pairs(self.state.listItems.masterLoot) do
		self:AddMLItem(tItem)
	end
	self.state.windows.masterLootItems:ArrangeChildrenVert()
	self.state.windows.masterLootItems:SetVScrollPos(nVPos)
	-- Restore Selected Item
	if self.state.selection.masterLootItemId then
		local wnd = self.state.listItems.masterLootItems[self.state.selection.masterLootItemId]
		self:OnMLItemSelected(wnd, wnd, 0)
	end
end

function FasterLootPlus:PopulateMLLooterLists(item)
	-- Save scoll location and check selection
	local nVPos = self.state.windows.masterLootRecipients:GetVScrollPos()
	self.state.listItems.validLooters = {}

	self:EmptyMLLooterLists()
	local wnd
	wnd = self:AddMLLooter(" - Random - ", -1, nil)
	wnd:SetData({looter = "Random", type = -1, classID = -1, level = nil})

	wnd = self:AddMLLooter(" - Initiate Roll-off - ", -2, nil)
	wnd:SetData({looter = "Roll-Off", type = -2, classID = -2, level = nil})

	for idx, unitLooter in pairs(item.tLooters) do
		local name = unitLooter:GetName()
		local class = unitLooter:GetClassId()
		local level = unitLooter:GetBasicStats().nLevel
		local wnd = self:AddMLLooter(name, class, level)
		wnd:SetData({looter = unitLooter, type = 1, classID = class, level = level})
		--wnd:SetData(unitLooter)
	end

	-- Check Range
	if item.tLootersOutOfRange and next(item.tLootersOutOfRange) then
		for idx, strLooterOOR in pairs(item.tLootersOutOfRange) do
			self.state.listItems.validLooters[strLooterOOR] = false
			local wnd = self.state.listItems.masterLootRecipients[strLooterOOR]
			local name = String_GetWeaselString(Apollo.GetString("Group_OutOfRange"), strLooterOOR)
			if not wnd then
				wnd = self:AddMLLooter(strLooterOOR, 0, nil)
				wnd:SetData({looter = strLooterOOR, type = 0, classID = 0, level = nil})
			end
			wnd:FindChild("ClassBorder"):FindChild("ClassIcon"):SetSprite("CRB_GroupFrame:sprGroup_Disconnected")
			wnd:FindChild("LooterName"):SetText(name)
			wnd:FindChild("LooterLevel"):SetText(nil)
		end
	end

	-- Arrange and sort children
	self.state.windows.masterLootRecipients:ArrangeChildrenVert(Window.CodeEnumArrangeOrigin.LeftOrTop, function (a,b)
		return a:FindChild("LooterName"):GetText() < b:FindChild("LooterName"):GetText()
	end)
	self.state.windows.masterLootRecipients:SetVScrollPos(nVPos)
	-- Restore Selected Item
	if self.state.selection.masterLootRecipientsId then
		local wnd = self.state.listItems.masterLootRecipients[self.state.selection.masterLootRecipientsId]
		self:OnMLLooterSelected(wnd, wnd, 0)
	end
end

function FasterLootPlus:GetRollOffWinners()
	local tRolls = {}
	local tPrintRolls = {}
	local tValues = {}
	-- put all pairs into a table of values
	for k,v in pairs(self.state.listItems.rolls) do
		if not tValues[v] then tValues[v] = {} end
		table.insert(tValues[v], k)
		table.insert(tPrintRolls, { roll = v, roller = k })
	end
	-- put all values into a table that can be sorted
	for k,v in pairs(tValues) do
		local t = { roll = k, rollers = v }
		table.insert(tRolls, t)
	end
	local results = table.sort(tRolls, function(a,b) return a.roll > b.roll end)
	local printResults = table.sort(tPrintRolls, function(a,b) return a.roll < b.roll end)
	-- Print all rolls
	for k,v in pairs(tPrintRolls) do
		Utils:pprint("[FasterLootPlus]: " .. v.roll .. " - " .. v.roller)
	end
	local tOutput = {}
	if #tRolls > 0 then
		if #tRolls[1].rollers > 1 then
			tOutput = {
				result = "tie",
				rollers = shallowcopy(tRolls[1].rollers),
				roll = tRolls[1].roll
			}
		else
			tOutput = {
				result = "win",
				rollers = shallowcopy(tRolls[1].rollers),
				roll = tRolls[1].roll
			}
		end
	else
		tOutput.result = "none"
	end
	return tOutput
end
