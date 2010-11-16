
Buffzilla = DongleStub('Dongle-1.2'):New('Buffzilla')
local L = LibStub('AceLocale-3.0'):GetLocale('Buffzilla')

function Buffzilla:Initialize(event, addon)
	self.db = self:InitializeDB('BuffzillaDB', {
		char = {
			buffset = {},
			bufflog = {},
			notifier = {
				enabled = true,
				locked = false,
				scale = 1.0,
				alpha = 1.0
			}
		}
	});

	self:CreateNotifier();
	self:CreateInterfaceOptions();
end

function Buffzilla:Enable()
	self:RegisterEvent('UPDATE_BINDINGS');
	self:RegisterEvent('PLAYER_REGEN_ENABLED');
	self:RegisterEvent('PLAYER_REGEN_DISABLED');
	self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED');
	self:PLAYER_REGEN_ENABLED();
end


--keybinding text
BINDING_HEADER_BUFFZILLA = L['BUFFZILLA'];
BINDING_NAME_BUFFZILLACASTBUTTON = L['KEYBINDING_DESC'];

function Buffzilla:UPDATE_BINDINGS()
	if not InCombatLockdown() then
		ClearOverrideBindings(self.notifier);

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
		Buffzilla:UpdateNotifier();
	end, 0.5);
end

-- when entering combat disable buff monitoring
-- removes the repeating timer checking for missing buffs
function Buffzilla:PLAYER_REGEN_DISABLED()
	self:CancelTimer('BUFFZILLA_BUFF_CHECK');
end

-- keeps track of all buffs and when they were last cast
function Buffzilla:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
	local timestamp, combatEvent, _, sourceName, _,_, destName, _, spellId, spellName, _, auraType = ...;
	if auraType == 'BUFF' and destName == UnitName('player') then
		if combatEvent == 'SPELL_AURA_APPLIED' or combatEvent == 'SPELL_AURA_REFRESH' or combatEvent == 'SPELL_AURA_REMOVED' then
			self.db.char.bufflog[spellName] = timestamp;
		end
	end
end

function Buffzilla:GetHighestPriorityBuff()
	local buffs = {}; -- cache current buffs in a lookup table
	for index = 1, 40 do
		local name, _,_,_,_,_, expirationTime, unitCaster, _,_,_, spellId = UnitAura('player', index, 'HELPFUL');
		if name then
			buffs[name] = {
				name = name,
				expirationTime = expirationTime,
				spellId = spellId,
				unitCaster = unitCaster,
			};
		else
			break;
		end
	end
	-- find any missing buffs
	local missingBuffs = {};
	for _, buffset in ipairs(self.db.char.buffset) do
		local spellname = false;
		if type(buffset.spellname) == "table" then
			-- multiple spells can be specified in a table
			-- spell priority is determine by the current or last cast
			-- then defaulting to the first buff in the list if none is found
			for _, spell in ipairs(buffset.spellname) do
				if buffs[spell] then
					spellname = spell;
					break;
				end
				if spellname then
					local a, b = self.db.char.bufflog[spellname], self.db.char.bufflog[spell]
				 	if a and b and a < b then
						spellname = spell;
					end
				else
					if self.db.char.bufflog[spell] then
						spellname = spell;
					end
				end
			end
			if not spellname then
				spellname = buffset.spellname[1];
			end
		else
			spellname = buffset.spellname;
		end
		-- if we know the buff and we're missing it add it to our list
		if spellname and GetSpellInfo(spellname) and not buffs[spellname] then
			local cooldown, oncooldown = select(2, GetSpellCooldown(spellname)), false;
			if cooldown and cooldown > 0 then
				oncooldown = true;
			end
			table.insert(missingBuffs, {
				person = UnitName('player'),
				spellname = spellname,
				priority = buffset.priority,
				oncooldown = oncooldown,
				cooldown = cooldown,
			});
		end
	end
	-- return the highest priority missing buff
	if #missingBuffs > 0 then
		local highest = 1;
		for index, buff in ipairs(missingBuffs) do
			if not buff.oncooldown and buff.priority < missingBuffs[highest].priority then
				highest = index;
			end
		end
		return missingBuffs[highest];
	end
end


function Buffzilla:AddRule(spellstring)
	local spells = {};
	local spell_found = true;
	string.gsub(spellstring, '%s*([^,]*[^, ])%s*,?%s*', function(spellname)
		local spellid = select(3, string.find(spellname, "|c%x+|Hspell:(.+)|h%[.*%]"));
		spellname = GetSpellInfo(spellid or spellname);
		if spellname then
			table.insert(spells, spellname);
		else
			spell_found = false;
		end
	end)
	if spell_found then
		table.insert(self.db.char.buffset, {
			spellname = #spells > 1 and spells or spells[1],
			priority = #self.db.char.buffset + 1
		});
		return true;
	end
end

function Buffzilla:ClearRules()
	wipe(self.db.char.buffset)
end

