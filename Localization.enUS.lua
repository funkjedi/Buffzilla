--Localization.enUS.lua

-- BINDINGS
BINDING_HEADER_BUFFZILLA = "Buffzilla"
BINDING_NAME_BUFFZILLACASTBUTTON = "Cast buff";


BuffzillaLocals = {
	["Buffzilla"] = "Buffzilla",
	["Buffzilla commands"] = "Buffzilla commands",

	["^buff (%w+) with (.+)$"] = "^buff (%w+) with (.+)$",
	["buff - basic usage: /buffzilla buff Self with Arcane Intellect"] = "buff - basic usage: /buffzilla buff Self with Arcane Intellect",

	["^buff (%w+) with (.+) priority (%d+)$"] = "^buff (%w+) with (.+) priority (%d+)$",
	["buff - advanced usage: /buffzilla buff Self with Arcane Intellect priority 25"] = "buff - advanced usage: /buffzilla buff Self with Arcane Intellect priority 25",

	["Monitoring %s for %s at priority %s"] = "Monitoring %s for %s at priority %s",
	["%s was not found in your spellbook."] = "%s was not found in your spellbook.",

	["clear"] = "clear",
	["clear - Removes all buffs from the set."] = "clear - Removes all buffs from the set.",
	["All buffs have been cleared."] = "All buffs have been cleared.",

	["options"] = "options",
	["options - Open the Notifer options window."] = "options - Open the Notifer options window.",

	["Buffzilla - Notifier"] = "Buffzilla - Notifier",
	["Buffzilla provides a notifier that can be placed anywhere on the screen. It will notify you of any buffs that need to be refreshed."] = "Buffzilla provides a notifier that can be placed anywhere on the screen. It will notify you of any buffs that need to be refreshed.",

	["Enable Notifier"] = "Enable Notifier",
	["Toggles the floating notifier"] = "Toggles the floating notifier",

	["Lock Notifier"] = "Lock Notifier",
	["Locks the notifier, so it can't be moved accidentally"] = "Locks the notifier, so it can't be moved accidentally",

	["Notifier Scale"] = "Notifier Scale",
	["This setting allows you to change the scale of the notifier, making it larger or smaller"] = "This setting allows you to change the scale of the notifier, making it larger or smaller",

	["Notifier Opacity"] = "Notifier Opacity",
	["This setting allows you to change the opacity of the notifier, making it transparent or opaque"] = "This setting allows you to change the opacity of the notifier, making it transparent or opaque",
}

setmetatable(BuffzillaLocals, {__index=function(t,k) rawset(t, k, k); return k; end})
