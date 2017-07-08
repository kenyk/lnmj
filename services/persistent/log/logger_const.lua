local logger_const = {}

logger_const.log_level =
{
	debug = 1, 
	info  = 2,
	warn  = 3,
	err   = 4,
	fatal = 5,
}

logger_const.log_color = {
	[-1] = "\27[0m",							--reset
	[logger_const.log_level.info] = "\27[37m", 	--37m gray
	[logger_const.log_level.debug] = "\27[32m", --32m green
	[logger_const.log_level.warn] = "\27[36m", 	--36m cyan
	[logger_const.log_level.err] = "\27[31m", 	--31m red
	[logger_const.log_level.fatal] = "\27[34m", --34m blue
}

logger_const.log_lvlstr = 
{
	[logger_const.log_level.debug] = "debug",
	[logger_const.log_level.info] = "info", 
	[logger_const.log_level.warn] = "warn", 
	[logger_const.log_level.err] = "err",
	[logger_const.log_level.fatal] = "fatal",
}

logger_const.PTYPE = {
	LOG = 50,
}

return logger_const