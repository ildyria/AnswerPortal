function AnswerPortal_Load()
	ap_version = "0.1"
	DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal v"..ap_version.." by Ildyria loaded.", 0, 1, 0)
	if not ap then
		AnswerPortal_Reset()
	else
		if ap.self == nil then ap.self = false end
		if ap.debug == nil then ap.debug = false end
		if ap.append == nil then ap.append = "" end
		if ap.always == nil then ap.always = false end
		if ap.ignore == nil then ap.ignore = {} end
		if ap.debug == nil then AnswerPortal_Debug() end
		if ap.prefix == nil then ap.prefix = "(AnswerPortal) " end
		if ap.nospam == nil then ap.nospam = true end
		if ap.public == nil then ap.public = false end
	end
	linked = {}
end

function AnswerPortal_DebugChat(chat_msg)
	local f = LibConsoleFrame
	local COLOUR = {
	RED     = "|cffff0000",
	GREEN   = "|cff10ff10",
	BLUE    = "|cff0000ff",
	MAGENTA = "|cffff00ff",
	YELLOW  = "|cffffff00",
	ORANGE  = "|cffff9c00",
	CYAN    = "|cff00ffff",
	WHITE   = "|cffffffff",
	SILVER  = "|ca0a0a0a0",
	}
	if ap.debug then 
		f:AddMessage(COLOUR.CYAN .. "[" .. COLOUR.GREEN .. date("%H:%M:%S") .. COLOUR.CYAN .. "] ".. COLOUR.SILVER .."AnswerPortal DEBUG: "..chat_msg, 0, 1, 0);
	end
end

function AnswerPortal_RespondChat(chat_msg, chat_requestor)
	AnswerPortal_DebugChat("DEBUG: requestor: "..chat_requestor)
	AnswerPortal_DebugChat("DEBUG: chat msg: "..chat_msg)
	SendChatMessage(chat_msg, "WHISPER", nil, chat_requestor)
	return
end

function AnswerPortal_Reset()
	DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal v"..ap_version.." by Ildyria reseted.", 0, 1, 0)
	ap = {
		enabled = true,
		self = false,
		always = false,
		debug = false,
		ignore = {},
		prefix = "(AnswerPortal) ",
		nospam = true,
		append = "Pour 10 po tres certainement.",
	}
end

function AnswerPortal_Debug()
	AnswerPortal_DebugChat("------- DEBUG -------")
	AnswerPortal_DebugChat("value of self: " .. tostring(ap.self))
	AnswerPortal_DebugChat("value of nospam: " .. tostring(ap.nospam))
	AnswerPortal_DebugChat("prefix: " .. tostring( ap.prefix))
	AnswerPortal_DebugChat("message: " .. tostring( ap.append))
	for name,status in pairs(ap.ignore) do
		AnswerPortal_DebugChat("Ignore list entry: " .. tostring( name))
	end
end

function AnswerPortal_List()
	AnswerPortal_DebugChat("AnswerPortal DEBUG: Compiling monitored/ignored channel lists.")
	DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal v"..ap_version.." by Ildyria.", 0, 1, 0)
	DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal channel monitoring status:", 0, 1, 0)
	channels_monitored = ""
	channels_ignored = ""
	if ap.self then
		channels_monitored = channels_monitored .. "|cFFFFFFFFself|r "
	else
		channels_ignored = channels_ignored .. "|cFFFFFFFFself|r "
	end
	if not ap.always then
		channels_monitored = channels_monitored .. "|cFFFFFFFFafk/dnd_status|r "
	else
		channels_ignored = channels_ignored .. "|cFFFFFFFFafk/dns_status|r "
	end
	if channels_monitored == "" then
		channels_monitored = "|cFFFFFFFFNone|r"
	end
	if channels_ignored == "" then
		channels_ignored = "|cFFFFFFFFNone|r"
	end
	DEFAULT_CHAT_FRAME:AddMessage("  |cFF0000FFMonitoring|r: " .. channels_monitored, 0, 1, 0)
	DEFAULT_CHAT_FRAME:AddMessage("  |cFFFF0000Ignoring|r: " .. channels_ignored, 0, 1, 0)
	if ap.prefix ~= "" then
		DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFF00Prefix|r: " .."|cFFFFFFFF".. ap.prefix .. "|r", 0, 1, 0)
	end
	if ap.append ~= "" then
		DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFF00Message|r: " .."|cFFFFFFFF".. ap.append.."|r", 0, 1, 0)
	end
	if ap.nospam then
		DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFF00Anti-Spam|r: " .."|cFFFFFFFFOn|r", 0, 1, 0)
	else
		DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFF00Anti-Spam|r: " .."|cFFFFFFFFOff|r", 0, 1, 0)
	end
end

function AnswerPortal_GetCmd(msg)
 	if msg then
 		local a,b,c=strfind(msg, "(%S+)"); 
 		if a then
 			return c, strsub(msg, b+2)
 		else	
 			return ""
 		end
 	end
end

function AnswerPortal_GetArgument(msg)
 	if msg then
 		local a,b=strfind(msg, "=")
 		if a then
 			return strsub(msg,1,a-1), strsub(msg, b+1)
 		else	
 			return ""
 		end
 	end
end

function AnswerPortal_SlashCmdHandler(slashcmd)
	local maincmd, subcmd = AnswerPortal_GetCmd(slashcmd)
	cmd = strlower(maincmd)
	AnswerPortal_DebugChat("AnswerPortal DEBUG: Processing commands: ["..cmd.. "], ["..subcmd.."]")
	if InCombatLockdown() then
		DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal - Not operable during combat.", 0, 1, 0)
		return
	elseif (cmd == "enable" or cmd == "on") then
		if ap.enabled then
			DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal is already enabled.", 0, 1, 0)
		else
			DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal is now enabled.", 0, 1, 0)
			ap.enabled = true
		end
	elseif not ap.enabled then
		DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal is disabled, no other commands are possible.", 0, 1, 0)
		return
	elseif (cmd == "disable" or cmd == "off") then
		if not ap.enabled then
			DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal is already disabled.", 0, 1, 0)
		else
			DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal is now disabled.", 0, 1, 0)
			ap.enabled = false
		end
	elseif (cmd == "self" or cmd == "me") then
		if ap.self then
			DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal will now ignore your own chat.", 0, 1, 0)
			ap.self = false
		else
			DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal will now respond to your own chat.", 0, 1, 0)
			ap.self = true
		end
	elseif cmd == "nospam" then
		if ap.nospam then
			DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal now doesn't care about spamming, use at your own risk :)", 0, 1, 0)
			ap.nospam = false
		else
			DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal will now ban people for 1 minute to prevent spamming, and only send tells for Trade/Generap.", 0, 1, 0)
			ap.nospam = true
		end
	elseif cmd == "always" then
		if ap.always then
			DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal will now only work if you are not AFK/DND.", 0, 1, 0)
			ap.always = false
		else
			DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal will now continue to work even if you are AFK/DND.", 0, 1, 0)
			ap.always = true
		end
	elseif cmd == "list" then
		AnswerPortal_List()
	elseif (cmd == "reset" or cmd == "default") then
		AnswerPortal_Reset()
		DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal settings have been reset to defaults.", 0, 1, 0)
	elseif cmd == "prefix" then
		if (subcmd == "" or subcmd == nil) then
			DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal has cleared any prefix message.", 0, 1, 0)
			ap.prefix = "(AnswerPortal) "
			return
		end
		ap.prefix = subcmd
		DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal will now prefix your messages with: ".. ap.prefix, 0, 1, 0)
	elseif (cmd == "message" or cmd == "append") then
		if (subcmd == "" or subcmd == nil) then
			DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal has cleared any custom message.", 0, 1, 0)
			ap.append = "Pour 10 po tres certainement."
			return
		end
		ap.append = subcmd
		DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal will now append your custom message: ".. ap.append, 0, 1, 0)
	elseif cmd == "ignore" then
		if (subcmd == "" or subcmd == nil) then
			DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal Ignore list:", 0, 1, 0)
			for name,status in pairs(ap.ignore) do
				DEFAULT_CHAT_FRAME:AddMessage("    "..name, 0, 1, 0)
			end
			return
		end
		local name = strtrim(subcmd)
		name = string.lower(subcmd)
		name = string.gsub(name, "^%l", string.upper)
		if ap.ignore[name] == nil then
			DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal will now ignore '"..name.."'.", 0, 1, 0)
			ap.ignore[name] = true
		else
			DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal will stopping ignoring '"..name.."'.", 0, 1, 0)
			ap.ignore[name] = nil
		end
	elseif cmd == "debug" then
		if ap.debug then
			DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal will no longer show debugging messages.", 0, 1, 0)
			ap.debug = false
		else
			DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal will now show debugging messages. (libconsole requis et ouvert)", 0, 1, 0)
			ap.debug = true
			AnswerPortal_Debug()
		end
	else
		AnswerPortal_SlashCmdList()
	end
end

function AnswerPortal_SlashCmdList()
	if ap.enabled then
		DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal is |cFF0000FFenabled|r.  Supported commands:", 0, 1, 0)
	else
		DEFAULT_CHAT_FRAME:AddMessage("AnswerPortal is |cFFFF0000disabled|r.  Supported commands:", 0, 1, 0)
		DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFFFFenable|r - enable AnswerPortal", 0, 1, 0)
		return
	end
	DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFFFFdisable|r - disable AnswerPortal", 0, 1, 0)
	DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFFFFlist|r - list status of channel monitoring, linking, and other options.", 0, 1, 0)
	DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFFFFself|r - toggle responding to your own messages.", 0, 1, 0)
	DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFFFFprefix <message>|r - Prefix message to all wisp (Default: (AnswerPortal).", 0, 1, 0)
	DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFFFFmessage <message>|r - Append a custom message to all wisp.", 0, 1, 0)
	DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFFFFalways|r - toggle responding during AFK/DND.", 0, 1, 0)
	DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFFFFignore <name>|r - add/remove a name from the AnswerPortal ignore list.", 0, 1, 0)
	DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFFFFnospam|r - toggle  anti-spam (1 min ban to each person) or allowing people to trigger you endlessles (careful)", 0, 1, 0)
	DEFAULT_CHAT_FRAME:AddMessage("  |cFFFFFFFFreset|r - reset all settings to default.", 0, 1, 0)
end

SLASH_ANSWERPORTAL1 = "/AnswerPortal"
SLASH_ANSWERPORTAL2 = "/answerportal"
SLASH_ANSWERPORTAL3 = "/AP"
SLASH_ANSWERPORTAL4 = "/ap"
SLASH_ANSWERPORTAL5 = "/APT"
SLASH_ANSWERPORTAL6 = "/apt"
SlashCmdList["ANSWERPORTAL"] = AnswerPortal_SlashCmdHandler

function AnswerPortal_ClearRecent()
	local hour,min = GetGameTime()	-- Check if author has asked this minute
	for name,min_sent in pairs(linked) do
		if not min_sent == min then
			name = nil
		end
	end
end

function AnswerPortal(message, author, report_on_error)
	AnswerPortal_DebugChat("--------------------------------------")
	if (author == UnitName("player") and not ap.self) then
		AnswerPortal_DebugChat("AnswerPortal DEBUG: Ignoring messages from you by request.")
		return 
	end
	if UnitIsAFK("player") then
		if not ap.always then
			AnswerPortal_DebugChat("AnswerPortal DEBUG: You are AFK, clear your status to enable AnswerPortal.")
			return
		end
	end
	if UnitIsDND("player") then
		if not ap.always then
			AnswerPortal_DebugChat("AnswerPortal DEBUG: You are in DND, clear your status to enable AnswerPortal.")
			return
		end
	end
	AnswerPortal_DebugChat("AnswerPortal DEBUG: Checking for ignore match on: ["..author.."].")
	if ap.ignore[author] then
		AnswerPortal_DebugChat("AnswerPortal DEBUG: Ignoring "..author.." as per settings.")
		return
	end
	if ap.nospam then
		AnswerPortal_DebugChat("DEBUG: Anti-spam measures enabled, checking last request by "..author)
		local hour,min = GetGameTime()	-- Check if author has asked this minute
		if linked[author] == min then
			AnswerPortal_DebugChat("AnswerPortal DEBUG: ["..author.."] already responded to at minute ["..min.."].")
			return
		else
			AnswerPortal_DebugChat("AnswerPortal DEBUG: ["..author.."] not found.")
		end
	end
	msg = strlower(message)
	local match_trigger = false
	local match_request = false
	local req = {}
	triggers = {
			"need",
			"besoin",
			"seek",
			"svp",
			"stp",
			"fair",
			"faire",
			"pliz",
			"plz",
			"faire",
			"peux",
			"peu",
			"plait",
			"please",
			"portail",
			"portal",
			"tp",
		}
	for request in string.gmatch(msg, "%a+") do	--Check for request matches, store in req table
		for i,word in pairs(triggers) do
			if request == word then 
				match_trigger = true 
				AnswerPortal_DebugChat("AnswerPortal DEBUG: Match 1 found: ["..request.."]")
				break
			end
		end
	end
	triggers2 = {
			"^tp",
			"^portail",
			"^portal",
			"^sw",
			"^Hurlevent",
			"^hurlevent",
			"^if",
			"^exodar",
			"^teramor",
			"^darna",
			"^ogr",
			"^storm",
			"^dala",
			"^iron",
		}
	for request in string.gmatch(msg, "%a+") do	--Check for request matches, store in req table
		for i,word in pairs(triggers2) do
			if string.find(request,word) then 
				match_request = true 
				AnswerPortal_DebugChat("AnswerPortal DEBUG: Match 2 found: ["..word.."]")
				break
			end
		end
	end
	if not (match_trigger and match_request) then return end
	if (match_trigger and match_request) then 
		linked_someone = true
		AnswerPortal_RespondChat(ap.prefix .." ".. ap.append, author)
		AnswerPortal_DebugChat("DEBUG: Anti-spam measures enabled, recording time of request for "..author)
		AnswerPortal_ClearRecent()
		local hour,min = GetGameTime()	-- Record time that author requested link, for minor spam prevention
		AnswerPortal_DebugChat("AnswerPortal DEBUG: Recording current minute of ["..min.."] for sender: ["..author.."].")
		linked[author] = min
	end
end

function AnswerPortal_OnEvent(this, event, arg1, arg2, arg3, arg4, ...)
	if(event == "ADDON_LOADED" and arg1 == "AnswerPortal") then
		AnswerPortal_Load()
	elseif not ap.enabled then
		return
	elseif event == "CHAT_MSG_WHISPER" then
		AnswerPortal(arg1, arg2, true)
	end
end

APplayername, APrealm = UnitName("player")

local frame = CreateFrame("Frame", "AnswerPortalFrame")
frame:SetScript("OnEvent", AnswerPortal_OnEvent)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("CHAT_MSG_WHISPER")
