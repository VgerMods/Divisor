-- Divisor by Vger-Azjol-Nerub
-- See Readme.htm for more information.

------------------------------------------------------------


------------------------------------------------------------
-- Interface Options
------------------------------------------------------------

function DivisorUI_OnLoad()
	-- Register the Interface Options page.
	DivisorUIFrame.name = "Divisor"
	InterfaceOptions_AddCategory(DivisorUIFrame)
	-- Update the version display.
	local Version = GetAddOnMetadata("Divisor", "Version")
	if Version then 
		DivisorUIFrame_AboutVersionLabel:SetText(string.format(DivisorUIFrame_AboutVersionLabel_Text, Version))
	end
end

function DivisorUI_Show()
	InterfaceOptionsFrame_OpenToCategory(DivisorUIFrame)
end
