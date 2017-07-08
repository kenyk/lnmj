
local config = {
		mysql ={   -- mysql
					host="10.17.174.171",
					port=3306,
					database="db_stat",
					user="linweixiong",
					password="qipai123987",
					max_packet_size = 1024 * 1024
		      },
		redis1 = {  -- redis
			        host = "127.0.0.1",
			        port = 6379,
			        db   = 0,
  	    		},
		redis2 = { -- redis
			        host = "127.0.0.1",
			        port = 6379,
			        db   = 2,
  	             },
  

	}

return config



