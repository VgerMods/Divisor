-- Divisor  by Vger-Azjol-Nerub
-- 
-- English resources

------------------------------------------------------------


------------------------------------------------------------
-- Interface Options UI strings
------------------------------------------------------------

DivisorUIFrame_AboutTab_Text = "About"
DivisorUIFrame_AboutHeaderLabel_Text = "by Vger-Azjol-Nerub"
DivisorUIFrame_AboutVersionLabel_Text = "Version %s"
DivisorUIFrame_AboutTranslationLabel_Text = "Official English version" -- Translators: credit yourself here... "Klingon translation by Stovokor"
DivisorUIFrame_OptionsHeaderLabel_Text = "Divisor has no options UI."
DivisorUIFrame_OptionsSubHeaderLabel_Text = "Sorry!  Type /divisor to see how you can customize Divisor."


------------------------------------------------------------
-- UI strings
------------------------------------------------------------

DivisorLocal =
{
	-- Commands
	ResetOptionsCommand = "reset",
	ResetOptionsMessage = "Divisor stack sizes have been reset.",
	ListStacksCommand = "list stacks",
	ListStacksStackMessage = "%d %s",
	SetStackCommand = "stack ",
	SetStackUsage = "Usage:  /divisor stack (quantity) (item) -- where quantity is the desired stack size > 1, and item is the item name or link",
	SetStackMessage = "Divisor will now display prices for %s stacks of size %d.",
	DeleteStackCommand = "unstack ",
	DeleteStackUsage = "Usage:  /divisor unstack (item) -- where item is the item name or link",
	DeleteStackMessage = "Divisor will now display only individual prices for %s.",
	
	-- Initialization
	NeedNewerVgerCoreMessage = "Divisor needs a newer version of VgerCore.  Please use the version of VgerCore that came with Divisor.",
	
	-- Money formatting
	GoldLetter = "g",
	SilverLetter = "s",
	CopperLetter = "c",
	
	-- Tooltip text (there are in-game constants for these types of strings but they're not exactly what we want for the tooltip)
	MinimumBid = "Minimum bid",
	YourBid = "Your bid",
	Buyout = "Buyout",
	
	-- Slash commands
	Usage =
[[
Divisor by Vger-Azjol-Nerub
www.vgermods.com
 
/divisor stack (quantity) (item) -- sets a new custom stack size for an item
/divisor unstack (item) -- removes the custom stack size for an item
/divisor reset -- resets all stack sizes to the defaults
/divisor list stacks -- lists all stack sizes
 
For more information, see the readme file that comes with Divisor.
]],

}

------------------------------------------------------------
-- Item names
------------------------------------------------------------

-- This table lists items that are commonly stacked, matching the name of the item with the common stack size.  For example,
-- since 3 lesser eternal essences can be converted into 1 greater eternal essence, it's useful to know the price of 3 of them.
-- This list is far from complete.
function DivisorGetDefaultStacks()

	return {
	
	-- General crafting items
	["Mote of Shadow"] = 10,
	["Mote of Life"] = 10,
	["Mote of Fire"] = 10,
	["Mote of Earth"] = 10,
	["Mote of Air"] = 10,
	["Mote of Water"] = 10,
	["Mote of Mana"] = 10,
	["Crystallized Shadow"] = 10,
	["Crystallized Life"] = 10,
	["Crystallized Fire"] = 10,
	["Crystallized Earth"] = 10,
	["Crystallized Air"] = 10,
	["Crystallized Water"] = 10,
	
	-- Enchanting items
	["Spirit Dust"] = 5,
	["Lesser Magic Essence"] = 3,
	["Lesser Astral Essence"] = 3,
	["Lesser Mystic Essence"] = 3,
	["Lesser Nether Essence"] = 3,
	["Lesser Eternal Essence"] = 3,
	["Lesser Planar Essence"] = 3,
	["Lesser Cosmic Essence"] = 3,
	["Lesser Celestial Essence"] = 3,
	["Mysterious Essence"] = 3,
	["Greater Mysterious Essence"] = 3,
	["Small Prismatic Shard"] = 3,
	["Small Dream Shard"] = 3,
	["Small Heavenly Shard"] = 3,
	["Small Ethereal Shard"] = 3,
	["Ethereal Shard"] = 3,
	
	-- Reputation items, sorted alphabetically by faction
	
	-- Aldor
	["Mark of Kil'jaeden"] = 10,
	["Mark of Sargeras"] = 10,
	
	-- Argent Dawn
	["Bone Fragments"] = 30,
	["Core of Elements"] = 30,
	["Crypt Fiend Parts"] = 30,
	["Dark Iron Scraps"] = 30,
	["Savage Frond"] = 30,
	
	-- Cenarion Expedition
	["Unidentified Plant Parts"] = 10,
	
	-- The Consortium
	["Pair of Ivory Tusks"] = 3,
	["Oshu'gun Crystal Fragment"] = 10,
	
	-- Netherwing
	["Nethercite Ore"] = 40,
	["Netherdust Pollen"] = 40,
	["Nethermine Flayer Hide"] = 35,
	
	-- Scryers
	["Firewing Signet"] = 10,
	["Sunfury Signet"] = 10,
	
	-- Sha'tari Skyguard
	["Shadow Dust"] = 6,
	["Time-Lost Scroll"] = 10,
	
	-- Sons of Hodir
	["Relic of Ulduar"] = 10,
	
	-- Sporeggar
	["Fertile Spores"] = 10,
	["Sanguine Hibiscus"] = 5,
	
	}
	
end