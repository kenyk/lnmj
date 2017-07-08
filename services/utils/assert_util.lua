local skynet = require "skynet"

local assert_util = {}

function assert_util.assert(cond, msg)
	if not cond then
		local tmp = "assert failed";
		if msg then
			tmp = tmp..", "..msg
		end
		skynet.error(msg)

	end
end

function assert_util.assert_stack_trace(cond, msg)
	if not cond then
		local tmp = "assert failed";
		if msg then
			tmp = tmp..", "..msg
		end
		skynet.error(msg)
		skynet.error(debug.traceback())
	end
end

return assert_util