-- Divisor by Vger-Azjol-Nerub
-- www.vgermods.com
-- 
-- Version 1.1.8: battle pets fix
--
------------------------------------------------------------

-- Divisor requires this version of VgerCore:
local DivisorVgerCoreVersionRequired = 1.02

-- "Constants"
local FormatMoney_Gold = "|cffffffff%s |TInterface\\AddOns\\Divisor\\Textures\\Gold:12|t "
local FormatMoney_Silver = "|cffffffff%d |TInterface\\AddOns\\Divisor\\Textures\\Silver:12|t "
local FormatMoney_Copper = "|cffffffff%d |TInterface\\AddOns\\Divisor\\Textures\\Copper:12|t "

-- Frames
local DivisorCoreFrame = nil


------------------------------------------------------------
-- Divisor events
------------------------------------------------------------

-- Called when an event that Divisor cares about is fired.
function DivisorOnEvent(self, Event, arg1, ...)
	if Event == "VARIABLES_LOADED" then 
		DivisorInitialize()
	elseif Event == "ADDON_LOADED" then
		DivisorOnAddonLoaded(arg1, ...)
	end 
end

-- Initializes Pawn after all saved variables have been loaded.
function DivisorInitialize()

	-- Check the current version of VgerCore.
	if (not VgerCore) or (not VgerCore.Version) or (VgerCore.Version < DivisorVgerCoreVersionRequired) then
		if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cfffe8460" .. DivisorLocal.NeedNewerVgerCoreMessage) end
		message(DivisorLocal.NeedNewerVgerCoreMessage)
		return
	end

	SLASH_DIVISOR1 = "/divisor"
	SlashCmdList["DIVISOR"] = DivisorCommand

	-- Set any unset options to their default values.  If the user is a new Divisor user, all options
	-- will be set to default values.  If upgrading, only missing options will be set to default values.
	DivisorSetEmptyOptions()
	
end

-- Another add-on was loaded...
function DivisorOnAddonLoaded(AddonName)
	if AddonName == "Blizzard_AuctionUI" then
		-- After the auction UI is first loaded, we want to hook the item buttons and events.
		hooksecurefunc("AuctionFrameBrowse_Update", DivisorAuctionFrameUpdate)
		for i = 1, NUM_BROWSE_TO_DISPLAY do
			local self = getglobal("BrowseButton" .. i)
			VgerCore.HookInsecureScript(self, "OnEnter", function() DivisorAuctionItem_OnEnter(self, "list", i + FauxScrollFrame_GetOffset(BrowseScrollFrame)) end)
			VgerCore.HookInsecureScript(self, "OnLeave", function() DivisorAuctionItem_OnLeave() end)
		end
		for i = 1, NUM_BROWSE_TO_DISPLAY do
			local self = getglobal("BrowseButton" .. i .. "ClosingTime")
			VgerCore.HookInsecureScript(self, "OnEnter", function() DivisorAuctionItem_OnEnter(self, "list", i + FauxScrollFrame_GetOffset(BrowseScrollFrame)) end)
			VgerCore.HookInsecureScript(self, "OnLeave", function() DivisorAuctionItem_OnLeave() end)
		end
		for i = 1, NUM_BROWSE_TO_DISPLAY do
			local self = getglobal("BrowseButton" .. i .. "Item")
			VgerCore.HookInsecureScript(self, "OnLeave", function() DivisorAuctionItem_OnLeave() end)
		end
		for i = 1, NUM_BIDS_TO_DISPLAY do
			local self = getglobal("BidButton" .. i)
			VgerCore.HookInsecureScript(self, "OnEnter", function() DivisorAuctionItem_OnEnter(self, "bidder", i + FauxScrollFrame_GetOffset(BidScrollFrame)) end)
			VgerCore.HookInsecureScript(self, "OnLeave", function() DivisorAuctionItem_OnLeave() end)
		end
		for i = 1, NUM_BIDS_TO_DISPLAY do
			local self = getglobal("BidButton" .. i .. "ClosingTime")
			VgerCore.HookInsecureScript(self, "OnEnter", function() DivisorAuctionItem_OnEnter(self, "bidder", i + FauxScrollFrame_GetOffset(BidScrollFrame)) end)
			VgerCore.HookInsecureScript(self, "OnLeave", function() DivisorAuctionItem_OnLeave() end)
		end
		for i = 1, NUM_BIDS_TO_DISPLAY do
			local self = getglobal("BidButton" .. i .. "Item")
			VgerCore.HookInsecureScript(self, "OnLeave", function() DivisorAuctionItem_OnLeave() end)
		end
		for i = 1, NUM_AUCTIONS_TO_DISPLAY do
			local self = getglobal("AuctionsButton" .. i)
			VgerCore.HookInsecureScript(self, "OnEnter", function() DivisorAuctionItem_OnEnter(self, "owner", i + FauxScrollFrame_GetOffset(AuctionsScrollFrame)) end)
			VgerCore.HookInsecureScript(self, "OnLeave", function() DivisorAuctionItem_OnLeave() end)
		end
		for i = 1, NUM_AUCTIONS_TO_DISPLAY do
			local self = getglobal("AuctionsButton" .. i .. "ClosingTime")
			VgerCore.HookInsecureScript(self, "OnEnter", function() DivisorAuctionItem_OnEnter(self, "owner", i + FauxScrollFrame_GetOffset(AuctionsScrollFrame)) end)
			VgerCore.HookInsecureScript(self, "OnLeave", function() DivisorAuctionItem_OnLeave() end)
		end
		for i = 1, NUM_AUCTIONS_TO_DISPLAY do
			local self = getglobal("AuctionsButton" .. i .. "Item")
			VgerCore.HookInsecureScript(self, "OnLeave", function() DivisorAuctionItem_OnLeave() end)
		end
		-- Replace the event handler for the item icon so that the Blizzard per-item prices don't display.
		AuctionFrameItem_OnEnter = DivisorAuctionItemIcon_OnEnter
	end
end

-- Resets all Divisor options.  Used to set the saved variable to a default state.
function DivisorResetOptions()
	DivisorOptions = nil
	DivisorSetEmptyOptions();
end

-- Sets values for any options that don't have a value set yet.  Useful when upgrading.
function DivisorSetEmptyOptions()
	if not DivisorOptions then DivisorOptions = {} end
	
	if not DivisorOptions.Stacks then DivisorOptions.Stacks = DivisorGetDefaultStacks() end
end

-- Called after AuctionFrameBrowse_Update returns.
function DivisorAuctionFrameUpdate()
	DivisorTooltip:Hide()
end

-- Called instead of the default OnEnter handler for AuctionButton{Index}Item.
function DivisorAuctionItemIcon_OnEnter(self, type, index)
	-- Copied from AuctionFrameItem_OnEnter in Interface\AddOns\Blizzard_AuctionUI\Blizzard_AuctionUI.lua and modified.
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

	-- If it's a battle pet, show the battle pet tooltip instead.
	local hasCooldown, speciesID, level, breedQuality, maxHealth, power, speed, name = GameTooltip:SetAuctionItem(type, index)
	if (speciesID and speciesID > 0) then
		BattlePetToolTip_Show(speciesID, level, breedQuality, maxHealth, power, speed, name)
		return
	end

	-- Otherwise, continue normally.
	GameTooltip_ShowCompareItem()
	if (IsModifiedClick("DRESSUP")) then
		ShowInspectCursor()
	else
		ResetCursor()
	end

	-- Then, do our normal tooltip annotation.  Subtract out the offset so it won't be added a second time.
	DivisorAuctionItem_OnEnter(self, type, index)
end

-- Called after the default OnEnter handler for BrowseButton{Index}.
function DivisorAuctionItem_OnEnter(self, type, Index)
	local Button = DivisorGetButtonOfType(self, type)
	if not Button then return end
	
	local Name, _, Quantity, Quality, _, _, _, MinimumBid, MinimumIncrement, BuyoutPrice, BidAmount, IsHighBidder = GetAuctionItemInfo(type, Index)
	local DesiredStackSize = DivisorOptions.Stacks[Name]
	
	-- Prepare the tooltip.
	local AddedLine
	
	-- Add the prices for a single of this item.
	AddedLine = DivisorAnnotateAuctionTooltip(DivisorTooltip, Button, AddedLine, 1,
		Name, Quantity, Quality, MinimumBid, MinimumIncrement, BuyoutPrice, BidAmount, IsHighBidder)
	
	-- For certain items, we care about another stack size besides 1.
	AddedLine = DivisorAnnotateAuctionTooltip(DivisorTooltip, Button, AddedLine, DesiredStackSize,
		Name, Quantity, Quality, MinimumBid, MinimumIncrement, BuyoutPrice, BidAmount, IsHighBidder)
	
	-- Show the finished tooltip.  Don't do this until all modifications are complete.  Also, don't do this if we didn't
	-- have any annotations to make.
	if AddedLine then DivisorTooltip:Show() end
end

-- Called after the default OnLeave handler for AuctionButton{Index}.
function DivisorAuctionItem_OnLeave()
	-- NOTE: This function is not called when the display is scrolled, but DivisorAuctionFrameUpdate is.
	DivisorTooltip:Hide()
end

------------------------------------------------------------
-- Divisor core methods
------------------------------------------------------------

-- Processes a Divisor slash command.
function DivisorCommand(Command)
	if Command == DivisorLocal.ResetOptionsCommand then
		DivisorResetOptions()
		VgerCore.Message(DivisorLocal.ResetOptionsMessage)
	elseif Command == DivisorLocal.ListStacksCommand then
		DivisorListStacks()
	elseif string.sub(Command, 1, string.len(DivisorLocal.SetStackCommand)) == DivisorLocal.SetStackCommand then
		local StackLine = string.trim(string.sub(Command, string.len(DivisorLocal.SetStackCommand) + 1))
		local Pos, _, Quantity, ItemLink = string.find(StackLine, "^%s-(%d+)%s+(.-)$")
		Quantity = tonumber(Quantity)
		ItemLink = DivisorGetItemNameFromLink(ItemLink)
		if Quantity and Quantity > 0 and ItemLink then
			DivisorAddStack(ItemLink, Quantity)
		else
			VgerCore.Message(VgerCore.Color.Salmon .. DivisorLocal.SetStackUsage)
		end
	elseif string.sub(Command, 1, string.len(DivisorLocal.DeleteStackCommand)) == DivisorLocal.DeleteStackCommand then
		local ItemLink = DivisorGetItemNameFromLink(string.trim(string.sub(Command, string.len(DivisorLocal.DeleteStackCommand) + 1)))
		if ItemLink then
			DivisorDeleteStack(ItemLink)
		else
			VgerCore.Message(VgerCore.Color.Salmon .. DivisorLocal.DeleteStackUsage)
		end
	else
		DivisorUsage()
	end
end

-- Displays Divisor usage information.
function DivisorUsage()
	VgerCore.Message(" ")
	VgerCore.MultilineMessage(DivisorLocal.Usage)
	VgerCore.Message(" ")
end

-- Returns the item name from an item link, or if the string isn't an item link, returns the original string.
function DivisorGetItemNameFromLink(ItemLink)
	if not ItemLink then return nil end
	local Pos, _, ItemName = string.find(ItemLink, "^|c%x+|H.+|h%[(.+)%]|h|r$")
	if ItemName then return ItemName else return ItemLink end
end

-- Lists all of the stack sizes that are set, including the default ones.
function DivisorListStacks()
	for ItemName, Quantity in pairs(DivisorOptions.Stacks) do
		VgerCore.Message(string.format(DivisorLocal.ListStacksStackMessage, Quantity, ItemName))
	end
end

-- Adds an alternate stack size (other than 1) to a particular item.
function DivisorAddStack(ItemName, Quantity)
	DivisorOptions.Stacks[ItemName] = Quantity
	VgerCore.Message(string.format(DivisorLocal.SetStackMessage, ItemName, Quantity))
end

-- Removes the alternate stack size for an item, so Divisor will only show individual prices.
function DivisorDeleteStack(ItemName)
	DivisorOptions.Stacks[ItemName] = nil
	VgerCore.Message(string.format(DivisorLocal.DeleteStackMessage, ItemName))
end

-- Annotates an auction house UI tooltip.
-- Tooltip: the tooltip instance (such as GameTooltip) to modify.
-- TooltipOwner: the object that should own the tooltip.
-- AddedLine: true if we've already added one annotation to this tooltip already, or false if we still need to set it up.
-- TooltipQuantity: the number of the item you want to display on the tooltip.  Generally 1.
-- (Other parameters): the return values from GetAuctionItemInfo or an equivalent function.
-- Return value: true if an annotation was added OR if AddedLine was true.  The caller should set its own AddedLine to this value.
function DivisorAnnotateAuctionTooltip(Tooltip, TooltipOwner, AddedLine, TooltipQuantity, Name, Quantity, Quality, MinimumBid, MinimumIncrement, BuyoutPrice, BidAmount, IsHighBidder)
	-- If the tooltip quantity is invalid or matches the actual quantity, exit.
	if (not TooltipQuantity) or (TooltipQuantity == Quantity) then return AddedLine end
	
	-- If the price is 0, exit.  (This can happen for sold items.)
	if (not MinimumBid or MinimumBid == 0) then return AddedLine end

	-- Prepare the tooltip.
	if AddedLine then
		Tooltip:AddLine(" ")
	else
		Tooltip:SetOwner(TooltipOwner, "ANCHOR_RIGHT", 0, -AUCTIONS_BUTTON_HEIGHT)
		Tooltip:ClearLines()
	end
	
	-- Calculate the actual minimum bid.
	-- If you're the high bidder, then there's no reason to add the increment, because you can't rebid.
	local ActualMinimumBid = math.max(BidAmount, MinimumBid)
	if not IsHighBidder then ActualMinimumBid = ActualMinimumBid + MinimumIncrement end
	
	Tooltip:AddLine(tostring(TooltipQuantity) .. " " .. ITEM_QUALITY_COLORS[Quality].hex .. Name)

	if ActualMinimumBid > 0 and (BuyoutPrice == 0 or ActualMinimumBid < BuyoutPrice) then
		local Caption
		if IsHighBidder then Caption = DivisorLocal.YourBid else Caption = DivisorLocal.MinimumBid end
		Tooltip:AddDoubleLine(Caption, DivisorFormatMoney(ceil(TooltipQuantity * ActualMinimumBid / Quantity), true))
	end
	if BuyoutPrice > 0 then
		Tooltip:AddDoubleLine(DivisorLocal.Buyout, DivisorFormatMoney(ceil(TooltipQuantity * BuyoutPrice / Quantity), true))
	end
	return true
end

function DivisorGetButtonOfType(self, type)
	local index
	if self.GetID then
		index = self:GetID()
	end
	-- Check the parent so this function can be used on either item icons or the parent buttons.
	if not index or index == 0 then
		if self:GetParent().GetID then
			index = self:GetParent():GetID()
		else
			VgerCore.Fail("Could not get ID of button.")
			return
		end
	end
	
	local ButtonName
	if (type == "owner") then
		ButtonName = "AuctionsButton" .. index
	elseif (type == "bidder") then
		ButtonName = "BidButton" .. index
	elseif (type == "list") then
		ButtonName = "BrowseButton" .. index
	else
		VgerCore.Fail("Invalid value for 'type'.")
	end
	
	local Button = _G[ButtonName]
	if not Button then
		VgerCore.Fail("Failed to find " .. ButtonName .. ".")
	end
	return Button
end

function DivisorFormatMoney(TotalCopper, LongForm)
	local Gold = floor(TotalCopper / (COPPER_PER_SILVER * SILVER_PER_GOLD))
	local Silver = floor((TotalCopper - (Gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER)
	local Copper = mod(TotalCopper, COPPER_PER_SILVER)
	local FinalString = VgerCore.Color.White
	
	-- If LongForm is true, silver is always present when gold is present, and copper is always present when silver is present.
	if Gold > 0 then FinalString = FinalString .. string.format(FormatMoney_Gold, BreakUpLargeNumbers(Gold)) end
	if Silver > 0 or (LongForm and Gold > 0) then FinalString = FinalString .. string.format(FormatMoney_Silver, Silver) end
	if Copper > 0 or (not (Gold > 0 or Silver > 0)) or (LongForm and (Gold > 0 or Silver > 0)) then FinalString = FinalString .. string.format(FormatMoney_Copper, Copper) end
	
	return string.sub(FinalString, 0, -1) .. VgerCore.Color.Reset
end

------------------------------------------------------------

-- Core frame setup
if (not DivisorCoreFrame) then
	DivisorCoreFrame = CreateFrame("Frame", "DivisorCoreFrame")
end

DivisorCoreFrame:SetScript("OnEvent", DivisorOnEvent)

DivisorCoreFrame:RegisterEvent("VARIABLES_LOADED")
DivisorCoreFrame:RegisterEvent("ADDON_LOADED")
