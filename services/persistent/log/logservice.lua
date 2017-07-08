local skynet = require "skynet"
local const = require "logger_const"
require "skynet.manager"

local command = {}
local logfile = nil
local openTime = nil
local logNameTag = nil
local logFilePath = nil
local logLevel = const.log_level.debug
local defaultLogFileSize = 1024*1024*1024
local maxLogFileSize = tonumber(skynet.getenv("MaxLogFileSize") or defaultLogFileSize)
print("maxLogFileSize = ", maxLogFileSize)

local logPath = skynet.getenv("logpath") or "../../../log"
local logfilename = skynet.getenv("logfilename") or skynet.getenv("harbor") or "unknownsvr"

local function openLog(tag)
	openTime = os.time()
	logNameTag = tag or logfilename
	logFilePath = string.format("%s/%s.log", logPath, logNameTag)
	print("log file path is:"..logFilePath)
	logfile = io.open(logFilePath, "a+")
	assert(logfile ~= nil)
end

local function closeLog()
	if logfile ~= nil then
		io.close(logfile)
	end
end

local function getFileSize()
	if not logfile then
		return 0
	end
	local s = logfile:seek()
	return s
end

local function isFileExists(filePath)
	local aFile = io.open(filePath, "r")
	if aFile then
		aFile:close()
		return true
	end
	return false
end

local function rollLog(savePath)
	if not savePath then
		skynet.error("rollLog nil arg")
		return
	end
	if isFileExists(savePath) then
		skynet.error("rollLog, file already exists: ", savePath)
		return
	end

	--close the opened file
	io.close(logfile)
	logfile = nil

	--rename the file
	local rst, errMsg = os.rename(logFilePath, savePath)
	if not rst then
		skynet.error(string.format("rollLog fail, rename error: %s, %s => %s", 
			errMsg, logFilePath, savePath))
		return
	end

	--reopen the file
	logfile = io.open(logFilePath, "a+")
	if not logfile then
		skynet.error(string.format("rollLog fail, reopen fail: %s", logFilePath))
	end
	assert(logfile ~= nil)	
end

local function chooseSavePath(savePath, dateStr)
	local ret = nil 
	local pathFound = false

	for i = 1, 1000000 do
		ret = string.format("%s.%d", savePath, dateStr, i)
		if not isFileExists(ret) then
			pathFound = true
			break
		end
	end	

	if pathFound then
		return ret
	end

	return nil
end

local function checkForRename()
	curTime = os.time()
	local curDate = os.date("*t", curTime)
	local openDate = os.date("*t", openTime)

	--diff day, should roll the log
	if curDate.day ~= openDate.day then
		local dateStr = os.date("%Y%m%d", openTime)
		local savePath = string.format("%s.%s", logFilePath, dateStr)
		if isFileExists(savePath) then
			savePath = chooseSavePath(savePath, dateStr)
		end

		if savePath then
			rollLog(savePath)
		end
		openTime = curTime
	end

	--over the max size, should roll the log
	local fileSize = getFileSize()
	if fileSize >= maxLogFileSize then
		local dateStr = os.date("%Y%m%d", curTime)
		local savePath = chooseSavePath(logNameTag, dateStr)

		if savePath then
			rollLog(savePath)
		end
	end
end

local function setLogLevel(level)
	local before = logLevel
	if const.log_level[level] ~= nil then
		logLevel = const.log_level[level]
	else
		skynet.error("logservice error: loglevel no valid config, logLevel = "..logLevel)
	end	

	return {before = const.log_lvlstr[before], after = const.log_lvlstr[logLevel]}
end

function command.log(source, level, msg)

	if level < logLevel then
		return
	end

	checkForRename()

	if logfile ~= nil then
		local tmpMsg = string.format("[:%08x]%s", source, msg)
		local cMsg = string.format("%s[:%08x]%s%s", const.log_color[level], source, msg, const.log_color[-1])
		
		--write to console
		io.write(cMsg)
		io.flush()

		--write to file
		logfile:write(tmpMsg)
		logfile:flush()
	else
		skynet.error("logservice: log file name not set, msg = "..msg)
	end
end

function command.set_log_file(source, tag)
	assert(logfile == nil)
	openLog(tag)
	return {true}
end

function command.set_log_level(source, level)
	return setLogLevel(level)
end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...) 
		local f = command[string.lower(cmd)]
		if f ~= nil then
			local ret = f(address, ...)
			if ret ~= nil then
				skynet.ret(skynet.pack(ret))
			end
		else
			skynet.error(".LOGSERVICE unknown cmd: "..cmd)
		end
	end)	

	local level = skynet.getenv("loglevel")
	if level then 
		setLogLevel(level) 
    else
        setLogLevel(const.log_level.info)
	end

	skynet.register(".LOGSERVICE")
end)
