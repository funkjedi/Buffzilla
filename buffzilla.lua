Buffzilla = DongleStub('Dongle-1.2'):New('Buffzilla')
local L = LibStub('AceLocale-3.0'):GetLocale('Buffzilla')

function Buffzilla:Initialize(event, addon)
    self.db = self:InitializeDB('BuffzillaDB', {
        char = { buffset = {}, bufflog = {}, notifier = { enabled = true, locked = false, scale = 1.0, alpha = 1.0 } },
    })

    self:CreateNotifier()
    self:CreateInterfaceOptions()

    self:RegisterEvent('UPDATE_BINDINGS')

    -- expired anything that hasn't been seen in a week
    local timestamp = time()
    for key, encountered in pairs(self.db.char.bufflog) do
        if timestamp - encountered > 604800 then
            self.db.char.bufflog[key] = nil
        end
    end

    self:ScheduleRepeatingTimer('BUFFZILLA_BUFF_CHECK', function()
        Buffzilla:UpdateNotifier()
    end, 0.5);
end

-- keybinding text
BINDING_HEADER_BUFFZILLA = L['BUFFZILLA']
BINDING_NAME_BUFFZILLACASTBUTTON = L['KEYBINDING_DESC']

function Buffzilla:UPDATE_BINDINGS()
    if not InCombatLockdown() then
        ClearOverrideBindings(self.notifier)

        -- override the bindings for our secure button
        local key1, key2 = GetBindingKey('BUFFZILLACASTBUTTON')

        if key1 then
            SetOverrideBindingClick(self.notifier, false, key1, 'BuffzillaNotifier')
        end

        if key2 then
            SetOverrideBindingClick(self.notifier, false, key2, 'BuffzillaNotifier')
        end
    end
end

function Buffzilla:GetHighestPriorityBuff()
    local buffs = {} -- cache current buffs in a lookup table
    self.buffdebug = buffs

    for index = 1, 40 do
        local aura = C_UnitAuras.GetAuraDataByIndex('player', index, 'HELPFUL')

        if not aura then
            break
        end

        if not issecretvalue(aura.spellId) then
            buffs[aura.name] = {
                name = aura.name,
                expirationTime = aura.expirationTime,
                spellId = aura.spellId,
                unitCaster = aura.sourceUnit,
            }

            -- track when we last saw this buff
            self.db.char.bufflog[aura.name] = time()
        end
    end

    local _, mainHandExpiration, _, mainHandEnchantID, _, offHandExpiration, _, offHandEnchantID = GetWeaponEnchantInfo()

    if mainHandEnchantID == 5401 then
        local spell = C_Spell.GetSpellInfo('Windfury Weapon')

        buffs[spell.name] = { name = spell.name, expirationTime = mainHandExpiration, spellId = spell.spellID, unitCaster = 'player' }
    end

    if offHandEnchantID == 5400 then
        local spell = C_Spell.GetSpellInfo('Flametongue Weapon')

        buffs[spell.name] = { name = spell.name, expirationTime = offHandExpiration, spellId = spell.spellID, unitCaster = 'player' }
    end

    -- find any missing buffs
    local missingBuffs = {}

    for _, buffset in ipairs(self.db.char.buffset) do
        local spellname = false

        if type(buffset.spellname) == 'table' then
            -- multiple spells can be specified in a table
            -- spell priority is determine by the current or last cast
            -- then defaulting to the first buff in the list if none is found
            for _, spell in ipairs(buffset.spellname) do
                if buffs[spell] then
                    spellname = spell
                    break
                end

                if spellname then
                    local a, b = self.db.char.bufflog[spellname], self.db.char.bufflog[spell]
                    if a and b and a < b then
                        spellname = spell
                    end
                else
                    if self.db.char.bufflog[spell] then
                        spellname = spell
                    end
                end
            end

            if not spellname then
                spellname = buffset.spellname[1]
            end
        else
            spellname = buffset.spellname
        end

        -- if we know the buff and we're missing it add it to our list
        if spellname and C_Spell.GetSpellInfo(spellname) and not buffs[spellname] then
            local cooldown = 0
            local oncooldown = false
            local spellCooldown = C_Spell.GetSpellCooldown(spellname)

            if spellCooldown then
                local duration = spellCooldown.duration

                if duration and not issecretvalue(duration) and duration > 0 then
                    cooldown = duration
                    oncooldown = true
                end
            end

            table.insert(missingBuffs, {
                person = UnitName('player'),
                spellname = spellname,
                priority = buffset.priority,
                oncooldown = oncooldown,
                cooldown = cooldown,
            })
        end
    end

    -- return the highest priority missing buff
    if #missingBuffs > 0 then
        local highest = 1

        for index, buff in ipairs(missingBuffs) do
            if not buff.oncooldown and buff.priority < missingBuffs[highest].priority then
                highest = index
            end
        end

        return missingBuffs[highest]
    end
end

function Buffzilla:AddRule(spellstring)
    local spells = {}
    local spell_found = true

    string.gsub(spellstring, '%s*([^,]*[^, ])%s*,?%s*', function(spellname)
        local spellid = select(3, string.find(spellname, '|c%x+|Hspell:(.+)|h%[.*%]'))
        local spellInfo = C_Spell.GetSpellInfo(spellid or spellname)
        if spellInfo then
            table.insert(spells, spellInfo.name)
        else
            spell_found = false
        end
    end)

    if spell_found then
        table.insert(self.db.char.buffset, { spellname = #spells > 1 and spells or spells[1], priority = #self.db.char.buffset + 1 })
        return true
    end
end

function Buffzilla:ClearRules()
    wipe(self.db.char.buffset)
end
