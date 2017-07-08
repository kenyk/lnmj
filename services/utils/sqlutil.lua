local logger = require "logger"
local futil = require "futil"
local mysql = require "mysql"

local sqlutil = {}

--return true if res contain error
function sqlutil.mysql_err(res, sql)
    if not res then
    	logger.err(string.format("sql error, res nil, sql = [[%s]]", sql))
        return true 
    end

    --badresult判断暂时失效,请不要继续使用这个函数
    if res.badresult == true then
        logger.err(string.format("sql error, res = %s, sql = [[%s]]", futil.toStr(res), sql))
        return true
    end

    return false
end

function sqlutil.quote_sql_str(str)
	return mysql.quote_sql_str(str)
end

return sqlutil
