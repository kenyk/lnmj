local skynet = require "skynet"
local syslog = require "syslog"
local game_config = require "config.game"



skynet.start(function()
	--local console = skynet.newservice("console")
	
	skynet.newservice("logservice")
	skynet.call(".LOGSERVICE", "lua", "set_log_file")
	
	skynet.uniqueservice("cross_center")
	
	local gamed = skynet.newservice ("gamed", 1)
	skynet.call (gamed, "lua", "open",game_config)

	skynet.newservice("debug_console",8000)
	
	skynet.newservice("webserver")

	syslog.debug("cross_center manage_room  webserver  start")
	

	
	skynet.exit()
end)
