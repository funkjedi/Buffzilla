function Buffzilla:CreateNotifier()
    self.notifier = CreateFrame('Button', 'BuffzillaNotifier', UIParent, 'SecureActionButtonTemplate')
    self.notifier:RegisterForClicks('AnyDown', 'AnyUp')
    self.notifier:SetClampedToScreen(true)
    self.notifier:SetPoint('CENTER')

    if self.db.char.notifier.framePosition then
        self.notifier:ClearAllPoints();
        self.notifier:SetPoint(unpack(self.db.char.notifier.framePosition))
    end

    self.notifier:SetWidth(32)
    self.notifier:SetHeight(32)
    self.notifier:EnableMouse(true)
    self.notifier:SetMovable(true)
    self.notifier:SetAttribute('type', 'spell')
    self.notifier:SetScale(self.db.char.notifier.scale)
    self.notifier:SetAlpha(self.db.char.notifier.alpha)
    self.notifier:Hide()

    self.notifier.icon = self.notifier:CreateTexture('OVERLAY')
    self.notifier.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    self.notifier.cooldown = CreateFrame('Cooldown', nil, self.notifier, 'CooldownFrameTemplate')
    self.notifier.cooldown:SetPoint('TOPLEFT', self.notifier, 'TOPLEFT', 0, -1)
    self.notifier.cooldown:SetWidth(32)
    self.notifier.cooldown:SetHeight(32)
    self.notifier.cooldown:Hide()

    self.notifier.spell = self.notifier:CreateFontString('OVERLAY', nil, 'GameFontHighlightLarge')
    self.notifier.spell:SetPoint('LEFT', self.notifier, 'RIGHT', 4, 0)
    self.notifier.spell:SetFont('Interface\\AddOns\\Buffzilla\\fonts\\bold.ttf', 24)

    -- enable the notifier to be dragged
    self.notifier:RegisterForDrag('RightButton')

    self.notifier:SetScript('OnDragStop', function(self, button)
        self:StopMovingOrSizing()
        Buffzilla.db.char.notifier.framePosition = { self:GetPoint() }
    end)

    self.notifier:SetScript('OnDragStart', function(self, button)
        if not Buffzilla.db.char.notifier.locked then
            self:StartMoving()
        end
    end)
end

function Buffzilla:UpdateNotifier()
    if InCombatLockdown() then
        return
    end

    local buff = self:GetHighestPriorityBuff()
    if not buff then
        self:ClearNotifier()
        return
    end

    -- prevent buffs notification from being repainted over and over
    if self.lastbuff and self.lastbuff.spellname == buff.spellname and buff.oncooldown then
        return
    end

    if UnitAffectingCombat(buff.person) then
        return
    end

    if not buff.oncooldown then
        self.notifier:SetAttribute('unit', buff.person)
        self.notifier:SetAttribute('spell', buff.spellname)
    else
        self.notifier:SetAttribute('unit', nil)
        self.notifier:SetAttribute('spell', nil)
    end

    if not self.db.char.notifier.enabled then
        self.notifier:Hide()
    else
        self.notifier.spell:SetText(buff.spellname)
        self.notifier.icon:SetTexture(GetSpellTexture(buff.spellname))
        self.notifier.icon:SetAllPoints()

        if buff.oncooldown then
            self.notifier.spell:SetVertexColor(0.8, 0.6, 0.6)
            self.notifier.icon:SetVertexColor(0.8, 0.4, 0.4)
        else
            self.notifier.spell:SetVertexColor(1, 1, 1)
            self.notifier.icon:SetVertexColor(1, 1, 1)
        end

        local start, duration, enable = GetSpellCooldown(buff.spellname)
        CooldownFrame_Set(self.notifier.cooldown, start, duration, enable)
        self.notifier:Show()
    end

    -- stash the buff
    self.lastbuff = buff
end

function Buffzilla:ClearNotifier()
    self.notifier:SetAttribute('unit', nil)
    self.notifier:SetAttribute('spell', nil)
    self.notifier:Hide()

    self.lastbuff = nil
    CooldownFrame_Set(self.notifier.cooldown, 0, 0, 0)
end

function Buffzilla:ShowHideNotifier()
    if not self.db.char.notifier.enabled then
        self.notifier:Hide()
        return
    end

    -- local old_scale = self.notifier:GetScale()

    self.notifier:Show()
    self.notifier:SetScale(self.db.char.notifier.scale)
    self.notifier:SetAlpha(self.db.char.notifier.alpha)

    local scale = self.notifier:GetScale()
    local point, relativeTo, relativePoint, xOfs, yOfs = self.notifier:GetPoint()

    -- self.notifier:ClearAllPoints()
    -- self.notifier:SetPoint(point, relativeTo, relativePoint, xOfs / scale * old_scale, yOfs / scale * old_scale)
end
