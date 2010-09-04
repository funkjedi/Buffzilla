

local L = LibStub('AceLocale-3.0'):GetLocale('Buffzilla')
local Heading, Checkbox, Slider = LibStub('tekKonfig-Heading'), LibStub('tekKonfig-Checkbox'), LibStub('tekKonfig-Slider')


local frame = CreateFrame('Frame', nil, InterfaceOptionsFrame)
frame.name = 'Buffzilla'

InterfaceOptions_AddCategory(frame)


--generic getter and setter functions for our notifier
local function getOption(self)
	return Buffzilla.db.char.notifier[self.db_key]
end
local function setOption(self)
	Buffzilla.db.char.notifier[self.db_key] = self.GetValue and self:GetValue() or not Buffzilla.db.char.notifier[self.db_key]
	Buffzilla:ShowHideNotifier()
end



local title, subtitle = Heading.new(frame, L['Notifier'], L['Buffzilla provides a notifier that can be placed anywhere on the screen. It will notify you of any buffs that need to be refreshed.'])

local enablenotifier = Checkbox.new(frame, nil, L['Enable Notifier'], 'TOPLEFT', subtitle, 'BOTTOMLEFT', 10, -12)
enablenotifier.tiptext = L['Toggles the floating notifier']
enablenotifier:SetScript('OnClick', setOption)
enablenotifier.db_key = 'enabled'

local locknotifier = Checkbox.new(frame, nil, L['Lock Notifier'], 'TOPLEFT', enablenotifier, 'BOTTOMLEFT', 0, -4)
locknotifier.tiptext = L['Locks the notifier, so it can\'t be moved accidentally']
locknotifier:SetScript('OnClick', setOption)
locknotifier.db_key = 'locked'

local scalenotifier, scaletext, scalecontainer = Slider.new(frame, L['Notifier Scale'], 0.5, 1.35, 'TOPLEFT', locknotifier, 'BOTTOMLEFT', 0, -60)
scaletext:SetPoint('BOTTOMLEFT', scalecontainer, 'TOPLEFT', -10, 30);
scalenotifier:SetScript('OnValueChanged', setOption)
scalenotifier.db_key = 'scale'

local scalesubtitle = frame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
scalesubtitle:SetText(L['This setting allows you to change the scale of the notifier, making it larger or smaller'])
scalesubtitle:SetHeight(32)
scalesubtitle:SetPoint('TOPLEFT', scaletext, 'BOTTOMLEFT', 0, -8)
scalesubtitle:SetPoint('RIGHT', frame, -32, 0)
scalesubtitle:SetNonSpaceWrap(true)
scalesubtitle:SetJustifyH('LEFT')
scalesubtitle:SetJustifyV('TOP')

local alphanotifier, alphatext, alphacontainer = Slider.new(frame, L['Notifier Opacity'], 0, 1, 'TOPLEFT', scalenotifier, 'BOTTOMLEFT', 0, -70)
alphatext:SetPoint('BOTTOMLEFT', alphacontainer, 'TOPLEFT', -10, 30);
alphanotifier:SetScript('OnValueChanged', setOption)
alphanotifier.db_key = 'alpha'

local alphasubtitle = frame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
alphasubtitle:SetText(L['This setting allows you to change the opacity of the notifier, making it transparent or opaque'])
alphasubtitle:SetHeight(32)
alphasubtitle:SetPoint('TOPLEFT', alphatext, 'BOTTOMLEFT', 0, -8)
alphasubtitle:SetPoint('RIGHT', frame, -32, 0)
alphasubtitle:SetNonSpaceWrap(true)
alphasubtitle:SetJustifyH('LEFT')
alphasubtitle:SetJustifyV('TOP')

frame:SetScript('OnShow', function()
	enablenotifier:SetChecked(getOption(enablenotifier))
	locknotifier:SetChecked(getOption(locknotifier))
	scalenotifier:SetValue(getOption(scalenotifier))
	alphanotifier:SetValue(getOption(alphanotifier))
end)

