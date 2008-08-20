--
--  Buffzilla by Funkjedi
--
--  Credits:
--    Cladhaire - addon object and localization setup, love your coding style
--
--  EXAMPLES
--  /buffzilla buff Self with Arcane Intellect priority 25
--  /buffzilla buff Priest with Arcane Intellect priority 20
--  /buffzilla buff Everyone with Arcane Intellect
--


-- Create the addon object
Buffzilla = {
	events = {},
	eventFrame = CreateFrame("Frame"),
	RegisterEvent = function(self, event, method)
		self.eventFrame:RegisterEvent(event)
		self.events[event] = event or method
	end,
	UnregisterEvent = function(self, event)
		self.eventFrame:UnregisterEvent(event)
		self.events[event] = nil
	end,
	version = GetAddOnMetadata("Buffzilla", "Version")
}

Buffzilla.eventFrame:SetScript("OnEvent", function(self, event, ...)
	local method = Buffzilla.events[event]
	if method and Buffzilla[method] then
		Buffzilla[method](Buffzilla, event, ...)
	end
end)


Buffzilla:RegisterEvent("ADDON_LOADED")
function Buffzilla:ADDON_LOADED(event, addon)
	if addon == "Buffzilla" then
		self:UnregisterEvent("ADDON_LOADED")	
		self.defaults = {
			profile = {
				buffset = {},
				notifier = {
					enable = true,
					lock = false,
					scale = 1.0,
					alpha = 1.0,
				},
			},
		}

		self.db = LibStub("AceDB-3.0"):New("BuffzillaDB", self.defaults, "Default")

		self:RegisterEvent("UPDATE_BINDINGS")
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("PARTY_MEMBERS_CHANGED")
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		

		self:CreateNotifier()
	end
end

function Buffzilla:UPDATE_BINDINGS()
	ClearOverrideBindings(self.notifier)

	-- override the bindings for our secure button
	local key1, key2 = GetBindingKey("BUFFZILLACASTBUTTON")
	if key1 then SetOverrideBindingClick(self.notifier, false, key1, "BuffzillaNotifier") end
	if key2 then SetOverrideBindingClick(self.notifier, false, key2, "BuffzillaNotifier") end
end


function Buffzilla:PLAYER_ENTERING_WORLD()
	self:UpdateNotifier()
end

function Buffzilla:PARTY_MEMBERS_CHANGED()
	self:CachePartyMembers()
	self:UpdateNotifier()
end

-- when leaving combat enable buff monitoring
function Buffzilla:PLAYER_REGEN_ENABLED()
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:UpdateNotifier()
end

-- when entering combat disable buff monitoring
function Buffzilla:PLAYER_REGEN_DISABLED()
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:ClearNotifier()
end

function Buffzilla:COMBAT_LOG_EVENT_UNFILTERED()
	local events = {
		SPELL_CAST_SUCCESS = true,
		SPELL_AURA_APPLIED = true,
		SPELL_AURA_REFRESH = true,
		SPELL_AURA_REMOVED = true,
		SPELL_AURA_STOLEN = true,
	}

	if (events[arg2]) then Buffzilla:UpdateNotifier() end
end


-- cache all the missing buffs
function Buffzilla:FindMissingBuffs()
	self.NeededBuffs = {}
	self:BuildBuffCache()

	for _,buff in ipairs(self.db.profile.buffset) do
		if (buff.target == "Self") then
			Buffzilla:CheckBuff(self.PartyMembers.Player, buff)
		elseif (self.PartyMembers[buff.target]) then
			for _,person in ipairs(self.PartyMembers[buff.target]) do
				Buffzilla:CheckBuff(person, buff)
			end
		end
	end

	-- return the highest priority buff
	if (#self.NeededBuffs > 0) then
		local highest = 1
		for index,buff in ipairs(self.NeededBuffs) do
			if (buff.inrange and buff.priority > self.NeededBuffs[highest].priority) then highest = index end
		end
		return self.NeededBuffs[highest]
	end
end

-- check if person needs buff
function Buffzilla:CheckBuff(person,buff)
	if (not self.BuffCache[person][buff.spellname]) then
		table.insert(self.NeededBuffs, {
			person = person,
			spellname = buff.spellname,
			priority = buff.priority,
			inrange = IsSpellInRange(buff.spellname, person),
		})
	end
end

-- cache the current buffs for everyone in our party
function Buffzilla:BuildBuffCache()
	if (not self.PartyMembers) then self:CachePartyMembers() end

	self.BuffCache = {}
	for _,person in ipairs(self.PartyMembers.Everyone) do
		self.BuffCache[person] = {}

		local index = 0	
		while true do
			index = index + 1
			local buffname = UnitBuff(person, index)
			if (not buffname) then break end
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
	if (players) then
		for person = 1, players do
			local unitname, unitclass = UnitName("party" .. person), UnitClass("party" .. person)
			if (unitname and unitclass) then
				if (not self.PartyMembers[unitclass]) then self.PartyMembers[unitclass] = {} end
				table.insert(self.PartyMembers[unitclass], unitname)
				table.insert(self.PartyMembers.Everyone, unitname)
			end
		end
	end
end
