--Localization.enUS.lua

-- BINDINGS
BINDING_HEADER_BUFFZILLA = "Buffzilla"
BINDING_NAME_BUFFZILLACASTBUTTON = "Cast buff";


BuffzillaLocals = {
	["Buffzilla"] = "Buffzilla",
	["Buffzilla is a simple buff assistant"] = "Buffzilla is a simple buff assistant",
	
	["Buff Sets"] = "Buff Sets",
	["Buffzilla allows you to created multiple preset buff configurations known as Buff Sets."] = "Buffzilla allows you to created multiple preset buff configurations known as Buff Sets.",
	
	["Notifier"] = "Notifier",
	["Buffzilla provides a notifier that can be placed anywhere on the screen. It will notify you of any buffs that need to be refreshed."] = "Buffzilla provides a notifier that can be placed anywhere on the screen. It will notify you of any buffs that need to be refreshed.",
	
	["Enable notifier"] = "Enable",
	["Toggles the floating notifier"] = "Toggles the floating notifier",
	
	["Lock notifier"] = "Lock",
	["Locks the notifier, so it can't be moved accidentally"] = "Locks the notifier, so it can't be moved accidentally",
	
	["Notifier display"] = "Notifier display",
	["These options let you customize the size and opacity of the notifier, making it larger or partially transparent."] = "These options let you customize the size and opacity of the notifier, making it larger or partially transparent.",
	
	["Scale"] = "Scale",
	["This setting allows you to change the scale of the notifier, making it larger or smaller"] = "This setting allows you to change the scale of the notifier, making it larger or smaller",

	["Alpha"] = "Alpha",
	["This setting allows you to change the opacity of the notifier, making it transparent or opaque"] = "This setting allows you to change the opacity of the notifier, making it transparent or opaque",

	["Reset Position"] = "Reset Position",
	["Resets the position of the notifier if its been dragged off screen"] = "Resets the position of the notifier if its been dragged off screen",

	["Profile Options"] = "Profile Options",
	["Buffzilla profiles allow you to share settings between characters"] = "Buffzilla profiles allow you to share settings between characters",
}

setmetatable(BuffzillaLocals, {__index=function(t,k) rawset(t, k, k); return k; end})
