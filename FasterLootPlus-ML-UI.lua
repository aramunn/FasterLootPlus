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

------------------------------------------------------------------------------------------------
--- Constants Handlers
------------------------------------------------------------------------------------------------
local FasterLoot.tClassToIcon =
{
	[-2] = "CRB_GroupFrame:sprGroup_Disconnected", -- Disconnected / OOR
	[-1] = "ClientSprites:GroupRandomLootIcon", -- Random loot
	[GameLib.CodeEnumClass.Medic]       	= "Icon_Windows_UI_CRB_Medic",
	[GameLib.CodeEnumClass.Esper]       	= "Icon_Windows_UI_CRB_Esper",
	[GameLib.CodeEnumClass.Warrior]     	= "Icon_Windows_UI_CRB_Warrior",
	[GameLib.CodeEnumClass.Stalker]     	= "Icon_Windows_UI_CRB_Stalker",
	[GameLib.CodeEnumClass.Engineer]    	= "Icon_Windows_UI_CRB_Engineer",
	[GameLib.CodeEnumClass.Spellslinger]  	= "Icon_Windows_UI_CRB_Spellslinger",
}

FasterLoot.tItemQuality =
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
  },
}


------------------------------------------------------------------------------------------------
--- Event Handlers
------------------------------------------------------------------------------------------------
function FasterLootPlus:OnLootAssigned(objItem, strLooter)
	Event_FireGenericEvent("GenericEvent_LootChannelMessage", String_GetWeaselString(Apollo.GetString("CRB_MasterLoot_AssignMsg"), objItem:GetName(), strLooter))
end

function FasterLootPlus:DelayMasterLootWindowMoved( wndHandler, wndControl, nOldLeft, nOldTop, nOldRight, nOldBottom )
	self.settings.locations.delayedMasterLoot = self.state.windows.delayedMasterLoot:GetLocation():ToTable()
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
	if wndHandler ~= wndControl then
		return
	end

	local tItem = wndControl:GetData()
	if Tooltip ~= nil and Tooltip.GetItemTooltipForm ~= nil then
		Tooltip.GetItemTooltipForm(self, wndControl, tItem.itemDrop, {bPrimary = true, bSelling = false, itemCompare = tItem.itemDrop:GetEquippedItemForItemType()})
	end
end

function FasterLootPlus:OnMLItemSelected( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	-- Alter Background of this and change background of previous selection
	-- Set selection value
	-- Populate Looter List
end

function FasterLootPlus:OnMLLooterSelected( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	-- Alter Background of this and change background of previous selection
	-- Set selection value
	-- Populate Looter List
end

function FasterLootPlus:OnMLAssign( wndHandler, wndControl, eMouseButton )
	-- Check both selections
	-- Check that user isn't OOR and not valid
	-- Perform actual assignment based on selections
	-- if random assign randomly
	-- if not random assign to person
end

function FasterLootPlus:OnButtonFlash()
	self.state.isFlashShown = not self.state.isFlashShown
	local nOpacity = 0
	if self.state.isFlashShown then nOpacity = 1 end
	self.state.windows.delayedMasterLoot:FindChild("Flash"):SetOpacity(nOpacity, 2)
end
------------------------------------------------------------------------------------------------
--- Master Loot Logic
------------------------------------------------------------------------------------------------
function FasterLootPlus:OpenMLWindow()
	-- Make sure no ML window is open
	if self.state.windows.masterLoot then
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
	if not self.state.windows.masterLoot then
		-- if ML window is not shown, then show the delay button and flash it
		self:OpenDelayedMLWindow()
	else
		-- if the ML window is shown then update the contents of the ML window
		self:OpenMLWindow()
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
		vardump(tItem)
		wnd:FindChild("ItemText"):SetTextColor(self.tItemQuality[iQuality].Color)
		wnd:FindChild("ItemText"):SetText(name)
		wnd:FindChild("ItemType"):SetText(type)
		wnd:FindChild("ItemBorder"):SetSprite(self.tItemQuality[iQuality].SquareSprite)
		wnd:FindChild("ItemBorder"):SetText("")
		wnd:FindChild("ItemBorder"):FindChild("ItemIcon"):SetSprite(icon)

		wnd:SetData(item)
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
end

function FasterLootPlus:PopulateMLLooterLists(item)
	-- Save scoll location and check selection
	local nVPos = self.state.windows.masterLootRecipients:GetVScrollPos()
	self.state.listItems.validLooters = {}

	self:EmptyMLLooterLists()
	local wnd
	wnd = self:AddMLLooter(" - Random - ", -1, nil)
	wnd:SetData(-1)

	for idx, unitLooter in pairs(item.tLooters) do
		local name = unitLooter:GetName()
		local class = unitLooter:GetClassId()
		local level = unitLooter:GetBasicStats().nLevel
		local wnd = self:AddMLLooter(name, class, level)
		wnd:SetData(unitLooter)
	end

	-- Check Range
	if item.tLootersOutOfRange and next(item.tLootersOutOfRange) then
		for idx, strLooterOOR in pairs(item.tLootersOutOfRange) do
			self.state.listItems.validLooters[strLooterOOR] = true
			local wnd = self.state.listItems.masterLootRecipients[strLooterOOR]
			local name = String_GetWeaselString(Apollo.GetString("Group_OutOfRange"), strLooterOOR)
			if not wnd then
				wnd = self:AddMLLooter(name, -2, nil)
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
end
