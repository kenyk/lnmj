

local skynet = require "skynet"
require "skynet.manager"
local redis  = require "redis"
local syslog = require "syslog"

local config = require "config.dbase"

local db

local krole_id  = "lroleId_guid"

local kmail_id  = "lmailId_guid"

local kgroup_id = "lgroupId_guid"

local command = {}



function command.REQUEST(...)
	syslog.debug("redis command request ", db:dbsize())
	return {{prop_id = 31001,prop_num = 100},{prop_id = 31002,prop_num = 100},{prop_id = 31003,prop_num = 100},{},{a = 1}}
end

function command.CREATEROLEID()
	local id = db:llen(krole_id)
	syslog.debug("redis 1 CREATEROLEID ",id)
	id = 1073741824 + id
	db:rpush(krole_id,id)

	return id
end

function command.CREATEMAILID()
	local id = db:llen(kmail_id)
	id = 100000000 + id
	db:rpush(kmail_id,id)
	return id
end

function command.CREATEGROUP()
	local id = db:llen(kgroup_id)
	id = 300000000 + id
	db:rpush(kgroup_id,id)
	return id
end



function command.HSET(key,field,value)
    local r = db:hset(key,field,value)
	return r
end

function command.HMSET(key,fv)
    local r = db:hmset(key,table.unpack(fv))
	return r	
end

function command.EXPIRE(key, timeout)
	timeout = timeout or 3600
	local r = db:expire(key,timeout)
	return r
end

function command.HGET(key,field)
    local r = db:hget(key,field)
	return r
end

function command.HKEYS(key)
    local r = db:hkeys(key)
	return r
end

function command.HDEL(key,field)
    local r = db:hdel(key,table.unpack(field))
	return r
end

function command.HMGET(key,field)
    local r = db:hmget(key,table.unpack(field))
	return r
end


function command.HGETALL(key)
    local r = db:hgetall(key)
	return r
end


function command.ZRANK(key,field)
    local r = db:zrank(key,field)
	return r
end

function command.ZREVRANK(key,field)
    local r = db:zrevrank(key,field)
	return r
end


function command.ZRANGE(key,low,high)
    local r = db:zrange(key,low,high,"WITHSCORES")
	return r
end


function command.ZREVRANGE(key,low,high)
    local r = db:zrevrange(key,low,high,"WITHSCORES")
	return r
end

function command.ZINCRBY(key,add,field)
    local r = db:zincrby(key,add,field)
	return r
end

function command.ZADD(key,add,field)
    local r = db:zadd(key,add,field)
	return r
end

function command.ZCARD(key)
    local r = db:zcard(key)
	return r
end

function command.SADD(key, field)
    local r = db:sadd(key, field)
	return r
end

function command.SREM(key, field)
    local r = db:srem(key, field)
	return r
end

function command.ZSCORE(key,field)
    local r = db:zscore(key,field)
	return r
end

function command.ZRANGEBYSCORE(key,low,high)
    local r = db:zrangebyscore(key,low,high)
	return r
end


function command.LPUSH(key,field)
    local r = db:lpush(key,field)
	return r
end


function command.LRANGE(key,low,high)
    local r = db:lrange(key,low,high)
	return r
end


function command.RPOP(key)
    local r = db:rpop(key)
	return r
end
function command.LPOP(key)
    local r = db:lpop(key)
	return r
end

function command.LREM(key,field)
    local r = db:lrem(key,0,field)
	return r
end

function command.LLEN(key)
    local r = db:llen(key)
	return r
end

function command.DEL(key)
	local r = db:del(key)
end


function __init__()
    db = redis.connect {
        host = config.redis1.host,
        port = config.redis1.port,
        db   = config.redis1.db,
    }
    syslog.debug("redistest launched")
end



skynet.start(function()
	__init__()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[string.upper(cmd)]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			error(string.format("Unknown command %s", tostring(cmd)))
		end
	end)
	skynet.register ".DBREDIS"
end)

