
local L = BuffzillaLocals
function Buffzilla:InitializeConfig()
	self.cmd = self:InitializeSlashCommand(L["Buffzilla commands"], "BUFFZILLA", "buffzilla")

	self.cmd:RegisterSlashHandler(
		L["buff - advanced usage: /buffzilla buff Self with Arcane Intellect priority 25"], 
		L["^buff (%w+) with (.+) priority (%d+)$"], 
		function(target, spellname, priority)
			if Buffzilla:AddBuff(target, spellname, tonumber(priority)) then
				Buffzilla:PrintF(L["Monitoring %s for %s at priority %s"], spellname, target, priority)
			else
				Buffzilla:PrintF(L["%s was not found in your spellbook."], spellname)
			end
		end)

	self.cmd:RegisterSlashHandler(
		L["buff - basic usage: /buffzilla buff Self with Arcane Intellect"], 
		L["^buff (%w+) with (.+)$"],
		function(target, spellname)
			if Buffzilla:AddBuff(target, spellname) then
				Buffzilla:PrintF(L["Monitoring %s for %s at priority %s"], spellname, target, 10)
			else
				Buffzilla:PrintF(L["%s was not found in your spellbook."], spellname)
			end
		end)

	self.cmd:RegisterSlashHandler(L["clear - Removes all buffs from the set."], L["clear"], function()
		self:Print(L["All buffs have been cleared."])
		Buffzilla:ClearBuffs()
	end)

	self.cmd:RegisterSlashHandler(L["options - Open the Notifer options window."], L["options"], function()
		InterfaceOptionsFrame_OpenToCategory("Buffzilla")
	end)
end
