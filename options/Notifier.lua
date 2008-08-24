

local L = BuffzillaLocals
local Heading, Checkbox, Slider = LibStub("tekKonfig-Heading"), LibStub("tekKonfig-Checkbox"), LibStub("tekKonfig-Slider")

local frame = CreateFrame("Frame", nil, InterfaceOptionsFrame)
frame.name = L["Buffzilla"]
frame:Hide()

InterfaceOptions_AddCategory(frame)
frame:SetScript("OnShow", function()
	local title, subtitle = Heading.new(frame, L["Buffzilla - Notifier"], L["Buffzilla provides a notifier that can be placed anywhere on the screen. It will notify you of any buffs that need to be refreshed."])

	-- enable/disable the notifier dialog
	local enablenotifier = Checkbox.new(frame, nil, L["Enable Notifier"], "TOPLEFT", subtitle, "BOTTOMLEFT", 10, -12)
	enablenotifier.tiptext = L["Toggles the floating notifier"]
	enablenotifier:SetChecked(Buffzilla.db.char.notifier.enabled)
	
	local hooked = enablenotifier:GetScript("OnClick")
	enablenotifier:SetScript("OnClick", function(self)
		Buffzilla.db.char.notifier.enabled = not Buffzilla.db.char.notifier.enabled
		Buffzilla:ShowHideNotifier()
		hooked(self)
	end)

	-- lock/unlock the notifier dialog
	local locknotifier = Checkbox.new(frame, nil, L["Lock Notifier"], "TOPLEFT", enablenotifier, "BOTTOMLEFT", 0, -4)
	locknotifier.tiptext = L["Locks the notifier, so it can't be moved accidentally"]
	locknotifier:SetChecked(Buffzilla.db.char.notifier.locked)
	
	local hooked = locknotifier:GetScript("OnClick")
	locknotifier:SetScript("OnClick", function(self)
		Buffzilla.db.char.notifier.locked = not Buffzilla.db.char.notifier.locked
		hooked(self)
	end)

	-- scale the notifier frame
	local scalenotifier, scaletext, scalecontainer = Slider.new(frame, L["Notifier Scale"], 0.5, 1.35, "TOPLEFT", locknotifier, "BOTTOMLEFT", 0, -60)
	scaletext:SetPoint("BOTTOMLEFT", scalecontainer, "TOPLEFT", -10, 30);
	scalenotifier:SetValue(Buffzilla.db.char.notifier.scale)

	local subtitle = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtitle:SetHeight(32)
	subtitle:SetPoint("TOPLEFT", scaletext, "BOTTOMLEFT", 0, -8)
	subtitle:SetPoint("RIGHT", frame, -32, 0)
	subtitle:SetNonSpaceWrap(true)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetJustifyV("TOP")
	subtitle:SetText(L["This setting allows you to change the scale of the notifier, making it larger or smaller"])

	scalenotifier:SetScript("OnValueChanged", function(self)
		Buffzilla.db.char.notifier.scale = self:GetValue()
		Buffzilla:ShowHideNotifier()
	end)

	-- change the frame opacity
	local alphanotifier, alphatext, alphacontainer = Slider.new(frame, L["Notifier Opacity"], 0, 1, "TOPLEFT", scalenotifier, "BOTTOMLEFT", 0, -70)
	alphatext:SetPoint("BOTTOMLEFT", alphacontainer, "TOPLEFT", -10, 30);
	alphanotifier:SetValue(Buffzilla.db.char.notifier.alpha)

	local subtitle = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtitle:SetHeight(32)
	subtitle:SetPoint("TOPLEFT", alphatext, "BOTTOMLEFT", 0, -8)
	subtitle:SetPoint("RIGHT", frame, -32, 0)
	subtitle:SetNonSpaceWrap(true)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetJustifyV("TOP")
	subtitle:SetText(L["This setting allows you to change the opacity of the notifier, making it transparent or opaque"])

	alphanotifier:SetScript("OnValueChanged", function(self)
		Buffzilla.db.char.notifier.alpha = self:GetValue()
		Buffzilla:ShowHideNotifier()
	end)


	frame:SetScript("OnShow", nil)
end)
