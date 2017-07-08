local skynet = require "skynet"
require "skynet.manager"
local mysql = require "mysql"
local syslog = require "syslog"
local futil = require "futil"

local mysql_host 	 = assert(skynet.getenv("mysql_host"))
local mysql_port	 = assert(tonumber(skynet.getenv("mysql_port")))
local mysql_database = assert(skynet.getenv("mysql_database"))
local mysql_user 	 = assert(skynet.getenv("mysql_user"))
local mysql_password = assert(skynet.getenv("mysql_password"))

local db

local cache_conf = require "cache_conf"

local command = {}



local mysqlconf={}
local mysqlhandle
local sqlStat = {
	total = {
		cnt = 0,
		time = 0.0,
		avg = 0.0,
	},
	sqls = {},
}

local function dbgInfo()
	local function fmtStat(oneStat)
		local s = string.format("{cnt = %d, time = %.3f, avg = %.3f}",
			oneStat.cnt, oneStat.time, oneStat.avg)
		return s
	end
	local statMsg = "notice: time is in seconds\n"
	statMsg = statMsg.."total : "..fmtStat(sqlStat.total).."\n"
	for k, v in pairs(sqlStat.sqls) do
		statMsg = statMsg..k.." : "..fmtStat(v).."\n"
	end
	return statMsg
end

local function isConnErr(errmsg)
	if not errmsg then
		return false
	end
	if type(errmsg) == 'string' and string.find(errmsg, "Connect to") then
		return true
	end
	return false
end


local function dosqlStat(sql, startTime, endTime)
	local costTime = endTime - startTime

	sqlStat.total.cnt = sqlStat.total.cnt + 1
	sqlStat.total.time = sqlStat.total.time + costTime
	sqlStat.total.avg = sqlStat.total.time / sqlStat.total.cnt
--[[ -- 只统计总的执行时间，暂时省略每个请求执行时间
	if not sqlStat.sqls[sql] then
		sqlStat.sqls[sql] = {}
		sqlStat.sqls[sql].cnt = 0
		sqlStat.sqls[sql].time = 0.0
		sqlStat.sqls[sql].avg = 0.0
	end

	local theSql = sqlStat.sqls[sql]
	theSql.cnt = theSql.cnt + 1
	theSql.time = theSql.time + costTime
	theSql.avg = theSql.time / theSql.cnt
	]]
end


local function makeConn()
	local conf = {
		host            = mysql_host,
		port            = mysql_port,
		database        = mysql_database,
		user            = mysql_user,
		password        = mysql_password,
		max_packet_size = 1024 * 1024,
	}
	local conn = mysql.connect(conf)
	if not conn then
		syslog.err("failed to connect")
	else
		syslog.noticef("mysql_service makeConn success, database = %s" ,conf.database)
	end
	return conn
end

-- 处理mysql转义字符  
--local mysqlEscapeMode = "[%z\'\"\\\26\b\n\r\t]";  
local mysqlEscapeMode = "[%z\'\"\\]";  
local mysqlEscapeReplace = {  
    --['\0']='\\0',  
    ['\''] = '\\\'',  
    ['\"'] = '\\\"',  
    ['\\'] = '\\\\',  
   -- ['\26'] = '\\z',  
   -- ['\b'] = '\\b',  
   -- ['\n'] = '\\n',  
  --  ['\r'] = '\\r',  
   -- ['\t'] = '\\t',  
  
    };  
  
local function mysqlEscapeString(s)  
    return string.gsub(s, mysqlEscapeMode, mysqlEscapeReplace);  
end  
sql = [[ insert db_stat.room_result_log (room_id, end_time, game_num, owner, chair_1_uid, chair_1_name, chair_1_point, chair_2_uid, chair_2_name, chair_2_point, chair_3_uid, chair_3_name, chair_3_point, chair_4_uid, chair_4_name, chair_4_point)
			 values('778459', '1495124116', 8, 2030992,2030992, '-       ...', -12, 2030004, 'Jiushi_壬', -2, 2035676, '熊', -13, 2035856, 'J .'', 27)
			]]
test = "J .'"
--print(mysqlEscapeString(test))



local function request_sql(db_name, cache_name, args)
	assert(args == nil or type(args) == "table","query cache err, args must be table")
	local dbcache = cache_conf[db_name]
	assert(dbcache,"query db cache conf not exists "..db_name)
	local cacheconf = dbcache[cache_name]
	assert(cacheconf,"query cache conf not exists "..cache_name)
	for k, v in pairs(args) do
		if type(v) == "string" then
			args[k] = mysqlEscapeString(v)
		end
	end           
	--pattern
	local pattern = cacheconf.pattern or "$([%w_]+)"

	local qysql = args and string.gsub(cacheconf.sql,pattern,args)
	
	
	--local format = string.format("insert into tb_role_logs set role_id = %u,operater_type = %u, operater_extra_1 = %u,operater_extra_2 = %u,operater_extra_3 = %u,operater_extra_4 = %u,time = %u",role_id,t,extra_1,extra_2,extra_3,extra_4,os.time())
	return qysql
end



local function mysql_err(res, sql)
    if res.badresult == true then
        syslog.errf("mysql_service do_sql error, res = %s, sql = [[%s]]", futil.toStr(res), sql)
        return true
    end

    return false
end


local function do_sql(sql)
	if not mysqlhandle then
		mysqlhandle = makeConn()
		if not mysqlhandle then
			syslog.errf("mysql_service cannot make conn to database:%s",mysql_database)
		end
	end

	local sTime = skynet.time()
    local result = mysqlhandle:query(sql)
    --判断是否执行sql出错
    if mysql_err(result,sql) then
        result = nil
    end

	dosqlStat(sql, sTime, skynet.time())
end

function command.LOG(db_name, cache_name, args)
	--syslog.debug("log :%s , %s ", db_name, cache_name)

	local ok ,sql = pcall(request_sql,db_name, cache_name, args)
	if not ok then
		syslog.errf("request_sql sql err :%s", sql)
		return
	end
	local ok1, err = pcall(do_sql, sql)
	if not ok1 then
		syslog.errf("mysql_service err: %s", err)
		if isConnErr(err) then
			syslog.errf("mysql_service conn err, reconnect, err = %s", err)
			mysqlhandle = makeConn()
		end
		syslog.errf("mysql_service query sql error: %s",sql) 
	end
	return
end


skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[string.upper(cmd)]
		if f then
            if session ~= 0 then
                skynet.ret(skynet.pack(f(...)))
            else
                f(...)
            end
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)

	mysqlhandle = makeConn()

	skynet.info_func(dbgInfo)

	skynet.register ".MYSQL"   -- main mysql db
end)





