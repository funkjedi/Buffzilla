
local L = LibStub('AceLocale-3.0'):NewLocale('Buffzilla', 'enUS', true)


-- keybindings frame
L['Cast any missing buffs'] = true


-- notifier options frame
L['Basic Settings'] = true
L['Notifier'] = true
L['Rules'] = true
L['Buffzilla provides a notifier that can be placed anywhere on the screen. It will notify you of any buffs that need to be refreshed.'] = true
L['Enable Notifier'] = true
L['Toggles the floating notifier'] = true
L['Lock Notifier'] = true
L['Locks the notifier, so it can\'t be moved accidentally'] = true
L['Notifier Scale'] = true
L['This setting allows you to change the scale of the notifier, making it larger or smaller'] = true
L['Notifier Opacity'] = true
L['This setting allows you to change the opacity of the notifier, making it transparent or opaque'] = true


--slash commands
L['^buff (%w+) with (.+)$'] = true
L['^buff (%w+) with (.+) priority (%d+)$'] = true
L['clear'] = true
L['options'] = true

--slash command tips
L['Commands:'] = true
L['buff - basic usage: /buffzilla buff Self with Arcane Intellect'] = true
L['buff - advanced usage: /buffzilla buff Self with Arcane Intellect priority 25'] = true
L['clear - Removes all buffs from the set'] = true
L['options - Open options window'] = true

--system messages
L['All buffs have been cleared.'] = true
L['Monitoring %s for %s at priority %s'] = true
L['%s was not found in your spellbook.'] = true
