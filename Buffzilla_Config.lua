local L = BuffzillaLocals


local function createconfig()
	local options = {}

	options.type = "group"
	options.name = "Buffzilla"


	local function get(info)
		local section,option = string.split(".", info.arg)
		local value = Buffzilla.db.profile[section][option]

		if type(value) == "table" then
			return unpack(value)
		else
			return value
		end
	end

	local function set(info, arg1, arg2, arg3, arg4)
		local section,option = string.split(".", info.arg)

		if arg2 then
			local entry = Buffzilla.db.profile[section][option]
			entry[1] = arg1
			entry[2] = arg2
			entry[3] = arg3
			entry[4] = arg4
		else
			Buffzilla.db.profile[section][option] = arg1
		end

		if section == "notifier" then
			Buffzilla:ShowHideNotifier()
		end
	end
	

	options.args = {}
	options.args.notifier = {
		type = "group",
		order = 1, 
		name = L["Notifier"],
		desc = L["Buffzilla provides a notifier that can be placed anywhere on the screen. It will notify you of any buffs that need to be refreshed."],
		get = get,
		set = set,
		args = {
			help = {
				order = 1,
				type = "description",
				name = L["Buffzilla provides a notifier that can be placed anywhere on the screen. It will notify you of any buffs that need to be refreshed."],
			},
			spacer = {
				order = 2,
				type = "description",
				name = " ",
			},
			enable = {
				order = 3,
				type = "toggle",
				name = L["Enable"],
				desc = L["Toggles the floating notifier"],
				width = "double",
				arg = "notifier.enable",
			},
			lock = {
				order = 4,
				type = "toggle",
				name = L["Lock"],
				desc = L["Locks the notifier, so it can't be moved accidentally"],
				arg = "notifier.lock",
			},
			spacer2 = {
				order = 5,
				type = "description",
				name = " ",
			},
			display = {
				type = "group",
				name = L["Notifier display"],
				order = 6,
				inline = true,
				args = {
					help = {
						type = "description",
						order = 1,
						name = L["These options let you customize the size and opacity of the notifier, making it larger or partially transparent."],
					},
					spacer = {
						order = 2,
						type = "description",
						name = " ",
					},
					scale = {
						type = "range",
						order = 2,
						name = L["Scale"],
						desc = L["This setting allows you to change the scale of the notifier, making it larger or smaller"],
						min = 0.35, max = 1.45, step = 0.05,
						arg = "notifier.scale",
					},
					spacer2 = {
						order = 3,
						type = "description",
						name = " ",
					},
					alpha = {
						type = "range",
						order = 4,
						name = L["Alpha"],
						desc = L["This setting allows you to change the opacity of the notifier, making it transparent or opaque"],
						min = 0, max = 1, step = 0.05,
						arg = "notifier.alpha",
					},
					spacer3 = {
						order = 5,
						type = "description",
						name = " ",
					},
					reset_position = {
						order = 6,
						type = "execute",
						name = L["Reset Position"],
						desc = L["Resets the position of the notifier if its been dragged off screen"],
						func = function()
							BuffzillaNotifier:ClearAllPoints()
							BuffzillaNotifier:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
						end,
					},
				}
			},
		},   
	} -- End notifier options

	options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(Buffzilla.db)
	options.args.profile.name = L["Profile Options"]
	options.args.profile.desc = L["Buffzilla profiles allow you to share settings between characters"]
	options.args.profile.order = 2
	
	return options
end





SLASH_BUFFZILLA1 = "/buffzilla"
SlashCmdList["BUFFZILLA"] = function(msg)
	local _, _, target, spellname, priority = string.find(msg,'^buff (%w+) with (.+) priority (%d+)$');
	if (target and spellname and priority) then
		table.insert(Buffzilla.db.profile.buffset, {target = target, spellname = spellname, priority = tonumber(priority)})
		Buffzilla:UpdateNotifier()
		return
	end

	local _, _, target, spellname = string.find(msg,'^buff (%w+) with (.+)$');
	if (target and spellname) then
		table.insert(Buffzilla.db.profile.buffset, {target = target, spellname = spellname,	priority = 10})
		Buffzilla:UpdateNotifier()
		return
	end

	Buffzilla:Print("Unknown command")
end


local config = LibStub("AceConfig-3.0")
local dialog = LibStub("AceConfigDialog-3.0")
local hijack = CreateFrame("Frame", nil, InterfaceOptionsFrame)
hijack:SetScript("OnShow", function()
	hijack:Hide()

	local options = createconfig()
	config:RegisterOptionsTable("Buffzilla-Bliz", {
		name = L["Buffzilla"],
		type = "group",
		args = {
			help = {
				type = "description",
				name = L["Buffzilla is a simple buff assistant"],
			},
		},
	})

	dialog:SetDefaultSize("Buffzilla-Bliz", 600, 400)
	dialog:AddToBlizOptions("Buffzilla-Bliz", "Buffzilla")
	config:RegisterOptionsTable("Buffzilla-Notifier", options.args.notifier)
	config:RegisterOptionsTable("Buffzilla-Profiles", options.args.profile)
	dialog:AddToBlizOptions("Buffzilla-Notifier", options.args.notifier.name, "Buffzilla")	
	dialog:AddToBlizOptions("Buffzilla-Profiles", options.args.profile.name, "Buffzilla")
end)




function Buffzilla:Print(format,...)
	if (not format) then 
		message("Buffzilla:Print() tried to print nil message.")
		return
	end

	if (DEFAULT_CHAT_FRAME) then
		format = string.gsub(format,"(%%%w)","|cffFF6600%1|cff0099FF")
		if (...) then format = string.format(format, ...) end
		DEFAULT_CHAT_FRAME:AddMessage("|cff0033ffBuffzilla: |cff0099FF" .. format)
	end
end
