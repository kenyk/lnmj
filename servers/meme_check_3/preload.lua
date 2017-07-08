-- This file will execute before every lua service start
-- See config

package.path = "lualib/?.lua;"
package.path = package.path.."../services/common/?.lua;../servers/?.lua;"
package.path = package.path.."../services/game_kind/0_3/gameserver/?.lua;"
package.path = package.path.."../services/game_kind/0_3/?.lua;"
package.path = package.path.."../services/game_kind/0_3/logic/?.lua;"
package.path = package.path.."../services/game_kind/0_3/logic/agent/?.lua;"
package.path = package.path.."../services/game_kind/0_3/logic/majiang/?.lua;"
package.path = package.path.."../services/game_kind/0_3/logic/room/?.lua;"
package.path = package.path.."../services/persistent/cachedb/?.lua;"
package.path = package.path.."../services/persistent/log/?.lua;"
package.path = package.path.."../services/utils/?.lua;"


--print("PRELOAD", ...)

