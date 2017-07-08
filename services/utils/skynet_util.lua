local skynet = require "skynet"

local util = {}

function util.lua_docmd(cmdhandler, session, cmd, ...)
	local handler_type = type(cmdhandler)
	if handler_type == "table" then
		local f = cmdhandler[cmd]
		if not f then
			return error(string.format("Unknown command %s", tostring(cmd)))
		end
		if session == 0 then
			return f(...)
		else
			return skynet.ret(skynet.pack(f(...)))
		end
	elseif handler_type == "function" then
		if session == 0 then
			return cmdhandler(cmd, ...)
		else
			return skynet.ret(skynet.pack(cmdhandler(cmd, ...)))
		end
	else
		skynet.error("service command handler type error, type:"..tostring(handler_type))
		return false, "handler type error"
	end
end

return util
