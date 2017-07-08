local skynet = require "skynet"
local syslog = require "syslog"
local game_config = require "config.game"



skynet.start(function()
	--local console = skynet.newservice("console")
	skynet.newservice("logservice")
	skynet.call(".LOGSERVICE", "lua", "set_log_file")

	local gamed = skynet.newservice ("gamed", 1)
	skynet.call (gamed, "lua", "open", game_config)

	skynet.newservice("debug_console",8000)
	
	syslog.debug("Server start")
	
	skynet.exit()
end)
