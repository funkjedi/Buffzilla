local L = LibStub('AceLocale-3.0'):GetLocale('Buffzilla')
local wf = LibStub('LibWidgetFactory-1.0')

SLASH_BUFFZILLA1 = '/buffzilla'
SLASH_BUFFZILLA2 = '/bz'

SlashCmdList['BUFFZILLA'] = function(cmd)
    local _, _, spellname = string.find(cmd, L['WATCH_REGEX'])

    if (spellname) then
        if Buffzilla:AddRule(spellname) then
            Buffzilla:PrintF(L['WATCH_NOTICE'], spellname)
        else
            Buffzilla:PrintF(L['WATCH_ERROR'], spellname)
        end
        return
    end

    if cmd == L['CLEAR_REGEX'] then
        self:Print(L['CLEAR_NOTICE'])
        Buffzilla:ClearRules()
        return
    end

    InterfaceOptionsFrame_OpenToCategory(L['BUFFZILLA'])
end

function Buffzilla:CreateInterfaceOptions()
    local frame = CreateFrame('Frame', nil, InterfaceOptionsFrame)
    frame.name = L['BUFFZILLA']

    local category = Settings.RegisterCanvasLayoutCategory(frame, frame.name)
    Settings.RegisterAddOnCategory(category)

    local title = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
    title:SetText(L['WATCHLIST'])
    title:SetPoint('TOPLEFT', 16, -16)

    local subtitle = frame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
    subtitle:SetText(L['WATCHLIST_SUBTITLE'])
    subtitle:SetHeight(38)
    subtitle:SetPoint('TOPLEFT', title, 'BOTTOMLEFT', 0, -8)
    subtitle:SetPoint('RIGHT', frame, -32, 0)
    subtitle:SetNonSpaceWrap(true)
    subtitle:SetJustifyH('LEFT')
    subtitle:SetJustifyV('TOP')

    -- generic getter and setter functions for our watchlist
    local function getBuffs(key)
        local value = ''
        for _, rule in ipairs(Buffzilla.db.char.buffset) do
            if type(rule.spellname) == 'table' then
                for index = 1, #rule.spellname do
                    value = value .. (index == #rule.spellname and rule.spellname[index] or rule.spellname[index] .. ', ')
                end
            else
                value = value .. rule.spellname
            end
            value = value .. '\n'
        end
        return value
    end

    local function setBuffs(key, value)
        self:ClearRules()
        for _, spellstring in ipairs({ strsplit('\n', strtrim(value)) }) do
            local spells_found = Buffzilla:AddRule(spellstring)
            if not spells_found then
                Buffzilla:PrintF(L['WATCH_ERROR'], spellstring)
            end
        end
        self:UpdateNotifier()
    end

    local buffs =
        wf.factory('MultiLineEditBox', { key = 'buffset', parent = frame, width = 360, lines = 5, get = getBuffs, set = setBuffs })
    buffs.frame:SetPoint('TOPLEFT', subtitle, 'BOTTOMLEFT', 0, -8)
    buffs.button:HookScript('OnClick', function()
        buffs.editBox:SetText(getBuffs())
    end)

    -- handle incoming links
    local function ChatEdit_InsertLinkHook(text)
        if buffs.editBox:IsVisible() then
            local spellid = select(3, string.find(text, '|c%x+|Hspell:(.+)|h%[.*%]'))
            local spellname = GetSpellInfo(spellid)
            if spellname then
                if not buffs.editBox:HasFocus() then
                    buffs.editBox:SetFocus()
                    buffs.editBox:SetCursorPosition(buffs.editBox:GetNumLetters())
                end
                buffs.editBox:Insert(spellname)
                buffs.button:Enable()
            end
        end
    end

    hooksecurefunc('ChatEdit_InsertLink', ChatEdit_InsertLinkHook)

    -- add a clear button
    buffs.clearButton = CreateFrame('Button', 'BuffzillaWatchlistClearButton', buffs.frame, 'UIPanelButtonTemplate')
    buffs.clearButton:SetPoint('BOTTOMLEFT', buffs.button, 'BOTTOMRIGHT', 5, 0)
    buffs.clearButton:SetHeight(22)
    buffs.clearButton:SetWidth(buffs.label:GetStringWidth() + 24)
    buffs.clearButton:SetText(L['CLEAR_BTN'])

    buffs.clearButton:SetScript('OnClick', function()
        Buffzilla:ClearRules()
        buffs.clearButton:Disable()
        buffs:SetText(getBuffs())
    end)

    buffs:SetCallback('OnTextChanged', function()
        buffs.clearButton:Enable()
    end)

    -- generic getter and setter functions for our notifier
    local function getOption(key)
        return Buffzilla.db.char.notifier[key]
    end

    local function setOption(key, value)
        Buffzilla.db.char.notifier[key] = value
        Buffzilla:ShowHideNotifier()
    end

    local notifierTitle = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
    notifierTitle:SetText(L['NOTIFIER'])
    notifierTitle:SetPoint('TOPLEFT', buffs.frame, 'BOTTOMLEFT', 0, -20)

    notifierTitle.subtitle = frame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
    notifierTitle.subtitle:SetText(L['NOTIFIER_SUBTITLE'])
    notifierTitle.subtitle:SetHeight(32)
    notifierTitle.subtitle:SetPoint('TOPLEFT', notifierTitle, 'BOTTOMLEFT', 0, -8)
    notifierTitle.subtitle:SetPoint('RIGHT', frame, -32, 0)
    notifierTitle.subtitle:SetNonSpaceWrap(true)
    notifierTitle.subtitle:SetJustifyH('LEFT')
    notifierTitle.subtitle:SetJustifyV('TOP')

    local enableNotifier = wf.factory('CheckBox', {
        key = 'enabled',
        parent = frame,
        label = L['ENABLE_NOTIFIER'],
        width = 120,
        fontSize = 'small',
        get = getOption,
        set = setOption,
    })

    enableNotifier.frame:SetPoint('TOPLEFT', notifierTitle.subtitle, 'BOTTOMLEFT', 10, 0)

    local lockNotifier = wf.factory('CheckBox', {
        key = 'locked',
        parent = frame,
        label = L['LOCK_NOTIFIER'],
        tooltip = L['LOCK_NOTIFIER_TOOLTIP'],
        width = 120,
        fontSize = 'small',
        get = getOption,
        set = setOption,
    })

    lockNotifier.frame:SetPoint('LEFT', enableNotifier.frame, 'RIGHT', 20, 0)

    local scaleNotifier = wf.factory('Slider', {
        key = 'scale',
        parent = frame,
        label = L['NOTIFIER_SIZE'],
        width = 160,
        min = 0.5,
        max = 1.35,
        isPercent = true,
        get = getOption,
        set = setOption,
    })

    scaleNotifier.label:SetJustifyH('LEFT')
    scaleNotifier.slider:SetPoint('TOP', scaleNotifier.label, 'BOTTOM', 0, -35)
    scaleNotifier.frame:SetPoint('TOPLEFT', enableNotifier.frame, 'BOTTOMLEFT', -10, -10)

    scaleNotifier.subtitle = frame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
    scaleNotifier.subtitle:SetText(L['NOTIFIER_SIZE_SUBTITLE'])
    scaleNotifier.subtitle:SetHeight(32)
    scaleNotifier.subtitle:SetPoint('TOPLEFT', scaleNotifier.label, 'BOTTOMLEFT', 0, -8)
    scaleNotifier.subtitle:SetPoint('RIGHT', scaleNotifier.frame, -25, 0)
    scaleNotifier.subtitle:SetNonSpaceWrap(true)
    scaleNotifier.subtitle:SetJustifyH('LEFT')
    scaleNotifier.subtitle:SetJustifyV('TOP')

    local alphaNotifier = wf.factory('Slider', {
        key = 'alpha',
        parent = frame,
        label = L['NOTIFIER_OPACITY'],
        width = 160,
        min = 0,
        max = 1,
        isPercent = true,
        get = getOption,
        set = setOption,
    })

    alphaNotifier.label:SetJustifyH('LEFT')
    alphaNotifier.slider:SetPoint('TOP', scaleNotifier.label, 'BOTTOM', 0, -35)
    alphaNotifier.frame:SetPoint('LEFT', scaleNotifier.frame, 'RIGHT', 30, 0)

    alphaNotifier.subtitle = frame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
    alphaNotifier.subtitle:SetText(L['NOTIFIER_OPACITY_SUBTITLE'])
    alphaNotifier.subtitle:SetHeight(32)
    alphaNotifier.subtitle:SetPoint('TOPLEFT', alphaNotifier.label, 'BOTTOMLEFT', 0, -8)
    alphaNotifier.subtitle:SetPoint('RIGHT', alphaNotifier.frame, -32, 0)
    alphaNotifier.subtitle:SetNonSpaceWrap(true)
    alphaNotifier.subtitle:SetJustifyH('LEFT')
    alphaNotifier.subtitle:SetJustifyV('TOP')

    frame:SetScript('OnShow', function()
        buffs:SetText(getBuffs())
    end)

end
