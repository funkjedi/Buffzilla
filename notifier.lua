

function Buffzilla:CreateNotifier()
	self.notifier = CreateFrame("Button", "BuffzillaNotifier", UIParent, "SecureActionButtonTemplate")
	self.notifier:SetClampedToScreen(true)
	self.notifier:SetPoint("CENTER")
	self.notifier:SetWidth(32)
	self.notifier:SetHeight(32)
	self.notifier:EnableMouse(true)
	self.notifier:SetMovable(true)
	self.notifier:SetAttribute("type", "spell")
	self.notifier:SetScale(self.db.char.notifier.scale)
	self.notifier:SetAlpha(self.db.char.notifier.alpha)
	self.notifier:Hide()

	self.notifier.icon = self.notifier:CreateTexture("OVERLAY")
	self.notifier.icon:SetTexCoord(0.08,0.92,0.08,0.92)

	self.notifier.cooldown = CreateFrame("Cooldown", nil, self.notifier, "CooldownFrameTemplate")
	self.notifier.cooldown:SetPoint("TOPLEFT", self.notifier, "TOPLEFT", 0, -1)
	self.notifier.cooldown:SetWidth(32)
	self.notifier.cooldown:SetHeight(32)
	self.notifier.cooldown:Hide()

	self.notifier.unit = self.notifier:CreateFontString("OVERLAY", nil, "GameFontHighlightLarge")
	self.notifier.unit:SetPoint("TOPLEFT", self.notifier, "TOPRIGHT", 2, 1)
	self.notifier.unit:SetFont("Interface\\AddOns\\Buffzilla\\fonts\\bold.ttf", 24)

	self.notifier.spell = self.notifier:CreateFontString("OVERLAY", nil, "GameFontNormalSmall")
	self.notifier.spell:SetPoint("TOPLEFT", self.notifier.unit, "BOTTOMLEFT", 1, 4)
	self.notifier.spell:SetFont("Interface\\AddOns\\Buffzilla\\fonts\\bold.ttf", 14)

	-- enable the notifier to be dragged
	self.notifier:RegisterForDrag("RightButton")
	self.notifier:SetScript("OnDragStop", function(self, button) self:StopMovingOrSizing()	end)
	self.notifier:SetScript("OnDragStart", function(self, button)
		if not Buffzilla.db.char.notifier.locked then self:StartMoving() end
	end)
end

function Buffzilla:UpdateNotifier()
	local buff = self:GetHighestPriorityBuff()
	if not buff or (buff.oncooldown and buff.cooldown < 3) then 
		self:ClearNotifier()
		return
	end

	if not buff.oncooldown then
		self.notifier:SetAttribute("unit", buff.person)
		self.notifier:SetAttribute("spell", buff.spellname)
	else
		self.notifier:SetAttribute("unit", nil)
		self.notifier:SetAttribute("spell", nil)
	end

	if not self.db.char.notifier.enabled then
		self.notifier:Hide()
	else
		self.notifier.unit:SetText(buff.person)
		self.notifier.spell:SetText(buff.spellname)
		self.notifier.icon:SetTexture(GetSpellTexture(buff.spellname))
		self.notifier.icon:SetAllPoints()

		if buff.oncooldown then
			self.notifier.unit:SetVertexColor(0.8,0.6,0.6)
			self.notifier.spell:SetVertexColor(0.8,0.6,0.6)
			self.notifier.icon:SetVertexColor(0.8,0.4,0.4)
		else
			self.notifier.unit:SetVertexColor(1,1,0)
			self.notifier.spell:SetVertexColor(1,1,1)
			self.notifier.icon:SetVertexColor(1,1,1)
		end

		local start, duration, enable = GetSpellCooldown(buff.spellname)
		CooldownFrame_SetTimer(self.notifier.cooldown, start, duration, enable)
		self.notifier:Show()
	end

	-- stash the buff
	self.LastBuff = buff
end

function Buffzilla:ClearNotifier()
	self.notifier:SetAttribute("unit", nil)
	self.notifier:SetAttribute("spell", nil)
	self.notifier:Hide()

	self.LastBuff = nil
	CooldownFrame_SetTimer(self.notifier.cooldown, 0, 0, 0)
end

function Buffzilla:ShowHideNotifier()
	if self.db.char.notifier.enabled then
		self.notifier:Show()
		self.notifier:SetScale(self.db.char.notifier.scale)
		self.notifier:SetAlpha(self.db.char.notifier.alpha)
	else
		self.notifier:Hide()
	end
end

