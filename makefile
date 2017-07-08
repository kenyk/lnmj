PLAT ?= linux
CC ?= gcc
TARGETS =  skynet lua-cjson lfs
SKYNET_PATH = skynet
SKYNET_LUA_PATH = $(SKYNET_PATH)/3rd/lua
SKYNET_CSERVICE_PATH = $(SKYNET_PATH)/cservice
SKYNET_LUA_CLIB_PATH = $(SKYNET_PATH)/luaclib
LUA_CJSON_PATH = 3rd/lua-cjson
LFS_PATH = 3rd/lfs
SHARED = -fPIC -shared

all : \
	$(foreach v, $(TARGETS), $(v)) \
	$(foreach v, $(CSERVICE), $(SKYNET_CSERVICE_PATH)/$(v).so) \
	$(foreach v, $(LUA_CLIB), $(SKYNET_LUA_CLIB_PATH)/$(v).so)

skynet :
	$(MAKE) -C $(SKYNET_PATH) $(PLAT) CC=$(CC)

lua-cjson :
	$(MAKE) -C $(LUA_CJSON_PATH) LUA_INCLUDE_DIR=../../$(SKYNET_LUA_PATH) CC=$(CC) CJSON_LDFLAGS="$(SHARED)"
	cp $(LUA_CJSON_PATH)/cjson.so $(SKYNET_LUA_CLIB_PATH)/cjson.so

lfs :
	$(MAKE) -C $(LFS_PATH) LUA_INC=../../$(SKYNET_LUA_PATH) LUA_LIBDIR=LUA_INC=../../$(SKYNET_LUA_PATH) LIB_OPTION="$(SHARED)"
	cp $(LFS_PATH)/src/lfs.so $(SKYNET_LUA_CLIB_PATH)/lfs.so
