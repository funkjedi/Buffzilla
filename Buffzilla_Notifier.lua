
function Buffzilla:CreateNotifier()
	self.notifier = CreateFrame("Button", "BuffzillaNotifier", UIParent, "SecureActionButtonTemplate")
	self.notifier:SetClampedToScreen(true)
	self.notifier:SetPoint("CENTER", 0, 0)
	self.notifier:SetWidth(32)
	self.notifier:SetHeight(32)
	self.notifier:EnableMouse(true)
	self.notifier:SetMovable(true)
	self.notifier:SetAttribute("type", "spell")
	self.notifier:Hide()

	-- setup the texture and strings
	self.notifier.icon = self.notifier:CreateTexture("OVERLAY")
	self.notifier.icon:SetTexCoord(0.08,0.92,0.08,0.92)

	self.notifier.unit = self.notifier:CreateFontString("OVERLAY", nil, "GameFontHighlightLarge")
	self.notifier.unit:SetPoint("TOPLEFT", self.notifier, "TOPRIGHT", 2, 1)
	self.notifier.unit:SetFont("Interface\\AddOns\\Buffzilla\\Fonts\\Custom.ttf", 24)

	self.notifier.spell = self.notifier:CreateFontString("OVERLAY", nil, "GameFontNormalSmall")
	self.notifier.spell:SetPoint("TOPLEFT", self.notifier.unit, "BOTTOMLEFT", 1, 4)
	self.notifier.spell:SetFont("Interface\\AddOns\\Buffzilla\\Fonts\\Custom.ttf", 14)


	-- enable the notifier to be dragged
	self.notifier:RegisterForDrag("RightButton")
	self.notifier:SetScript("OnDragStop", function(self, button) self:StopMovingOrSizing() end)
	self.notifier:SetScript("OnDragStart", function(self, button) 
		if not Buffzilla.db.profile.notifier.lock then self:StartMoving() end
	end)
end

function Buffzilla:UpdateNotifier()
	local buff = Buffzilla:FindMissingBuffs()
	if (not buff) then
		self:ClearNotifier()
		return
	end


	if (buff.inrange) then
		self.notifier:SetAttribute("unit", buff.person)
		self.notifier:SetAttribute("spell", buff.spellname)
	else
		self.notifier:SetAttribute("unit", nil)
		self.notifier:SetAttribute("spell", nil)
	end

	-- display the notifier widget
	if self.db.profile.notifier.enable then
		self.notifier.unit:SetText(buff.person)
		self.notifier.spell:SetText(buff.spellname)
		self.notifier.icon:SetTexture(GetSpellTexture(buff.spellname))
		self.notifier.icon:SetAllPoints()
		if (buff.inrange) then
			self.notifier.unit:SetVertexColor(1,1,0)
			self.notifier.spell:SetVertexColor(1,1,1)
			self.notifier.icon:SetVertexColor(1,1,1)
		else
			self.notifier.unit:SetVertexColor(0.6,0.6,0.8)
			self.notifier.spell:SetVertexColor(0.6,0.6,0.8)
			self.notifier.icon:SetVertexColor(0.4,0.4,0.8)
		end
		self.notifier:Show()
	end
end

function Buffzilla:ClearNotifier()
	self.notifier:SetAttribute("unit", nil)
	self.notifier:SetAttribute("spell", nil)
	self.notifier:Hide()
end

function Buffzilla:ShowHideNotifier()
	if self.db.profile.notifier.enable then
		self.notifier:Show()
		self.notifier:SetScale(Buffzilla.db.profile.notifier.scale)
		self.notifier:SetAlpha(Buffzilla.db.profile.notifier.alpha)
	else
		self.notifier:Hide()
	end
end
