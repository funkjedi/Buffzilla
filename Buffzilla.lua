
Buffzilla = DongleStub('Dongle-1.2'):New('Buffzilla')
local L = LibStub('AceLocale-3.0'):GetLocale('Buffzilla')

function Buffzilla:Initialize(event, addon)
	self.db = self:InitializeDB('BuffzillaDB', {
		char = {
			buffset = {},
			bufflog = {},
			notifier = {
				enabled = true,
				oncooldown = true,
				outofrange = true,
				locked = false,
				scale = 1.0,
				alpha = 1.0
			}
		}
	})

	self:CreateNotifier()
	self:CreateSlashCommands()
end

function Buffzilla:Enable()
	self:RegisterEvent('UPDATE_BINDINGS')
	self:RegisterEvent('PARTY_MEMBERS_CHANGED')
	self:RegisterEvent('PLAYER_REGEN_ENABLED')
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
	self:PARTY_MEMBERS_CHANGED()
	self:PLAYER_REGEN_ENABLED()
end


--keybinding text
BINDING_HEADER_BUFFZILLA = 'Buffzilla'
BINDING_NAME_BUFFZILLACASTBUTTON = L['Cast any missing buffs']

function Buffzilla:UPDATE_BINDINGS()
	if not InCombatLockdown() then
		ClearOverrideBindings(self.notifier)

		-- override the bindings for our secure button
		local key1, key2 = GetBindingKey('BUFFZILLACASTBUTTON')
		if key1 then SetOverrideBindingClick(self.notifier, false, key1, 'BuffzillaNotifier') end
		if key2 then SetOverrideBindingClick(self.notifier, false, key2, 'BuffzillaNotifier') end
	end
end

-- when leaving combat enable buff monitoring
-- creates a repeating timer to check for missing buffs
function Buffzilla:PLAYER_REGEN_ENABLED()
	self:ScheduleRepeatingTimer('BUFFZILLA_BUFF_CHECK', function()
		Buffzilla:UpdateNotifier()
	end, 0.25)
end

-- when entering combat disable buff monitoring
-- removes the repeating timer checking for missing buffs
function Buffzilla:PLAYER_REGEN_DISABLED()
	self:CancelTimer('BUFFZILLA_BUFF_CHECK')
end

-- refresh party cache when the party changes
function Buffzilla:PARTY_MEMBERS_CHANGED()
	self.units = {
		Me = UnitName('player'),
		Everyone = {UnitName('player')},
	}
	local party = GetNumPartyMembers();
	if party then
		for index = 1, party do
			local unitname, unitclass = UnitName('party' .. index), UnitClass('party' .. index)
			if unitname and unitclass then
				if not self.Players[unitclass] then
					self.Players[unitclass] = {}
				end
				table.insert(self.Players[unitclass], unitname)
				table.insert(self.Players.Everyone, unitname)
			end
		end
	end
end

-- keeps track of all buffs and when they were last cast
function Buffzilla:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
	local timestamp, combatEvent, _, sourceName, _,_, destName, _, spellId, spellName, _, auraType = ...;
	if auraType == 'BUFF' and (combatEvent == 'SPELL_AURA_APPLIED' or combatEvent == 'SPELL_AURA_REFRESH') then
		self.db.char.bufflog[destName .. spellName] = timestamp

		-- remove entries that are older the 1 hours as most buffs don't last longer than an hour
		local current_timestamp = time()
		for key, recorded_timestamp in pairs(self.db.char.bufflog) do
			if current_timestamp - recorded_timestamp > 3600 then
				self.db.char.bufflog[key] = nil
			end
		end
	end
end


function Buffzilla:CheckUnitForMissingBuff(unitname, rule)
	
	local spellname = false
	if type(rule.spellname) == "table" then
		for _, spell in ipairs(rule.spellname) do
			if spellname then
				local a, b = self.db.char.bufflog[unitname .. spellname], self.db.char.bufflog[unitname .. spell]
			 	if a and b and a < b then
					spellname = spell
				end
			else
				if self.db.char.bufflog[unitname .. spell] then
					spellname = spell
				end
			end
		end
		if not spellname then
			spellname = rule.spellname[1]
		end
	else
		spellname = rule.spellname
	end

	if not self.UnitBuffs[unitname][spellname] then
		local inrange = true
		if unitname ~= self.units.Me then
			inrange = IsSpellInRange(spellname, unitname)
		end
		local cooldown, oncooldown = select(2, GetSpellCooldown(spellname)), false
		if cooldown > 0 then
			oncooldown = true
		end
		table.insert(self.MissingUnitBuffs, {
			person = unitname,
			spellname = spellname,
			priority = rule.priority,
			inrange = inrange,
			oncooldown = oncooldown,
			cooldown = cooldown,
		})
	end

end

function Buffzilla:GetHighestPriorityBuff()

	-- cache the buffs
	self.UnitBuffs = {}
	self.MissingUnitBuffs = {}
	for _,person in ipairs(self.units.Everyone) do
		self.UnitBuffs[person] = {}
		for index = 1, 40 do
			local name, _,_,_,_,_, expirationTime, unitCaster, _,_,_, spellId = UnitAura(person, index, 'HELPFUL')
			if name then
				self.UnitBuffs[person][name] = {
					name = name,
					expirationTime = expirationTime,
					spellId = spellId,
					unitCaster = unitCaster,
				}
			else
				break
			end
		end
	end

	-- process any rules
	for _,rule in ipairs(self.db.char.buffset) do
		if rule.target == 'Self' then
			self:CheckUnitForMissingBuff(self.units.Me, rule)
		elseif self.units[rule.target] then
			for _,person in ipairs(self.units[rule.target]) do
				self:CheckUnitForMissingBuff(person, rule)
			end
		end
	end

	-- return the highest priority missing buff
	if #self.MissingUnitBuffs > 0 then
		local highest = 1
		for index,buff in ipairs(self.MissingUnitBuffs) do
			if buff.inrange and not buff.oncooldown and buff.priority > self.MissingUnitBuffs[highest].priority then 
				highest = index
			end
		end
		return self.MissingUnitBuffs[highest]
	end

end


function Buffzilla:AddRule(target, spellstring, priority)

	local spells = {}
	local spell_found = true
	string.gsub(spellstring, '%s*([^,]+)%s*,?%s*', function(spellname)
		local spellid = select(3, string.find(spellname, "|c%x+|Hspell:(.+)|h%[.*%]"))
		spellname = GetSpellInfo(spellid or spellname)
		if spellname then
			table.insert(spells, spellname)
		else
			spell_found = false
		end
	end)

	if spell_found then
		table.insert(self.db.char.buffset, {
			target = target,
			spellname = #spells > 1 and spells or spells[1],
			priority = priority and priority or 10
		})
		return true
	end

end



function Buffzilla:ClearRules()
	wipe(self.db.char.buffset)
end

