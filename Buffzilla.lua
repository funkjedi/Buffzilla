--
--  Buffzilla by Funkjedi
--
--  EXAMPLES
--  /buffzilla buff Self with Arcane Intellect priority 25
--  /buffzilla buff Priest with Arcane Intellect priority 20
--  /buffzilla buff Everyone with Arcane Intellect
--

local L = BuffzillaLocals
Buffzilla = DongleStub("Dongle-1.1"):New("Buffzilla")

function Buffzilla:Initialize(event, addon)
	self.db = self:InitializeDB("BuffzillaDB", {
		char = {
			buffset = {},
			notifier = {
				enabled = true,
				oncooldown = true,
				outofrange = true,
				locked = false,
				scale = 1.0,
				alpha = 1.0,
			},
		},
	})

	self:RegisterEvent("UPDATE_BINDINGS")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")

	self:CreateNotifier()
	self:InitializeConfig()
	self:PLAYER_REGEN_ENABLED();
end

function Buffzilla:UPDATE_BINDINGS()
	if not InCombatLockdown() then
		ClearOverrideBindings(self.notifier)
	
		-- override the bindings for our secure button
		local key1, key2 = GetBindingKey("BUFFZILLACASTBUTTON")
		if key1 then SetOverrideBindingClick(self.notifier, false, key1, "BuffzillaNotifier") end
		if key2 then SetOverrideBindingClick(self.notifier, false, key2, "BuffzillaNotifier") end
	end
end


-- when leaving combat enable buff monitoring
-- creates a repeating timer to check for missing buffs
function Buffzilla:PLAYER_REGEN_ENABLED()
	self:ScheduleRepeatingTimer("BUFFZILLA_BUFF_CHECK", function() Buffzilla:UpdateNotifier() end, 1)
end

-- when entering combat disable buff monitoring
-- removes the repeating timer checking for missing buffs
function Buffzilla:PLAYER_REGEN_DISABLED()
	self:CancelTimer("BUFFZILLA_BUFF_CHECK")
end

-- refresh party cache when the party changes
function Buffzilla:PARTY_MEMBERS_CHANGED()
	self:CachePartyMembers()
end


-- cache all the missing buffs
function Buffzilla:FindMissingBuffs()
	self.NeededBuffs = {}
	self:BuildBuffCache()

	for _,buff in ipairs(self.db.char.buffset) do
		if buff.target == "Self" then
			Buffzilla:CheckBuff(self.PartyMembers.Player, buff)
		elseif self.PartyMembers[buff.target] then
			for _,person in ipairs(self.PartyMembers[buff.target]) do
				Buffzilla:CheckBuff(person, buff)
			end
		end
	end

	-- return the highest priority buff
	if #self.NeededBuffs > 0 then
		local highest = 1
		for index,buff in ipairs(self.NeededBuffs) do
			if buff.inrange and not buff.oncooldown and buff.priority > self.NeededBuffs[highest].priority then 
				highest = index
			end
		end
		return self.NeededBuffs[highest]
	end
end

-- check if person needs buff
function Buffzilla:CheckBuff(person,buff)
	local inrange = true
	if person ~= UnitName("player") then inrange = IsSpellInRange(buff.spellname, person) end

	local cooldown, oncooldown = select(2, GetSpellCooldown(buff.spellname)), false
	if cooldown > 0 then oncooldown = true end

	if not self.BuffCache[person][buff.spellname] then
		table.insert(self.NeededBuffs, {
			person = person,
			spellname = buff.spellname,
			priority = buff.priority,
			inrange = inrange,
			oncooldown = oncooldown,
			cooldown = cooldown,
		})
	end
end

-- cache the current buffs for everyone in our party
function Buffzilla:BuildBuffCache()
	if not self.PartyMembers then self:CachePartyMembers() end

	self.BuffCache = {}
	for _,person in ipairs(self.PartyMembers.Everyone) do
		self.BuffCache[person] = {}

		local index = 0	
		while true do
			index = index + 1
			local buffname = UnitBuff(person, index)
			if not buffname then break end
			self.BuffCache[person][buffname] = true
		end
	end
end

-- create a cache of our current party members
function Buffzilla:CachePartyMembers()
	self.PartyMembers = {
		Player = UnitName("player"),
		Everyone = {UnitName("player")},
	}

	local players = GetNumPartyMembers();
	if players then
		for person = 1, players do
			local unitname, unitclass = UnitName("party" .. person), UnitClass("party" .. person)
			if unitname and unitclass then
				if not self.PartyMembers[unitclass] then self.PartyMembers[unitclass] = {} end
				table.insert(self.PartyMembers[unitclass], unitname)
				table.insert(self.PartyMembers.Everyone, unitname)
			end
		end
	end
end


function Buffzilla:AddBuff(target, spellname, priority)
	if not GetSpellInfo(spellname) then return nil end
	if not priority then priority = 10 end

	table.insert(self.db.char.buffset, {target = target, spellname = spellname,	priority = priority})
	return true
end

function Buffzilla:ClearBuffs()
	self.db.char.buffset = {}
end
