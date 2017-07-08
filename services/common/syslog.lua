local skynet = require "skynet"

local config = require "config.system"
local const = require "logger_const"

local loglevel = assert(skynet.getenv("loglevel"))

local syslog = {
	prefix = {
		"D|",
		"I|",
		"N|",
		"W|",
		"E|",
	},
}

local level
function syslog.level (lv)
	level = lv
end

local function logErrhandle()
	skynet.error(debug.traceback())
end

local function write (priority, fmt, ...)
	if priority >= level then
		if type(fmt) ~= 'string' then
			return
		end

	--	local ok, content = xpcall(string.format, logErrhandle, fmt, ...)
	--	if not ok then
	--		skynet.error("log fail: ", fmt, ...)
	--		return
	--	end
	
			--send to log service
		local nowStr = os.date("%Y-%m-%d %H:%M:%S", os.time())
		local msg = string.format("[%s %5s] %s\r\n", nowStr, const.log_lvlstr[priority], fmt)
		skynet.send(".LOGSERVICE", "lua", "log", priority, msg)


		--skynet.error (syslog.prefix[priority] .." ["..os.date("%H:%M:%S", os.time()).."] ".. fmt, ...)
	end
end

local function writef (priority, fmt, ...)
	if priority >= level then
		if type(fmt) ~= 'string' then
			return
		end

		local ok, content = xpcall(string.format, logErrhandle, fmt, ...)
		if not ok then
			skynet.error("log fail: ", fmt, ...)
			return
		end
	
			--send to log service
		local nowStr = os.date("%Y-%m-%d %H:%M:%S", os.time())
		local msg = string.format("[%s %5s] %s\r\n", nowStr, const.log_lvlstr[priority], content)
		skynet.send(".LOGSERVICE", "lua", "log", priority, msg)
		--skynet.error (syslog.prefix[priority] .. string.format (...))
	end
end

function syslog.debug (...)
	write (1, ...)
end

function syslog.debugf (...)
	writef (1, ...)
end

function syslog.info (...)
	write (2, ...)
end

function syslog.infof (...)
	writef (2, ...)
end

function syslog.notice (...)
	write (2, ...)
end

function syslog.noticef (...)
	writef (2, ...)
end

function syslog.warning (...)
	write (3, ...)
end

function syslog.warningf (...)
	writef (3, ...)
end

function syslog.err (...)
	write (4, ...)
end

function syslog.errf (...)
	writef (4, ...)
end

function syslog.fatal (...)
	write (5, ...)
end

function syslog.fatalf (...)
	writef (5, ...)
end

local function setLogLevel(level)
	if const.log_level[level] ~= nil then
		return const.log_level[level]
	end	
end



syslog.level (setLogLevel (loglevel) or 3)

return syslog
