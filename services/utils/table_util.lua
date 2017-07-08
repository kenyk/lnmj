--[[--

深度克隆一个值

~~~ lua

-- 下面的代码，t2 是 t1 的引用，修改 t2 的属性时，t1 的内容也会发生变化
local t1 = {a = 1, b = 2}
local t2 = t1
t2.b = 3    -- t1 = {a = 1, b = 3} <-- t1.b 发生变化

-- clone() 返回 t1 的副本，修改 t2 不会影响 t1
local t1 = {a = 1, b = 2}
local t2 = clone(t1)
t2.b = 3    -- t1 = {a = 1, b = 2} <-- t1.b 不受影响

~~~

@param mixed object 要克隆的值

@return mixed


]]
local syslog = require "syslog"

function table.printtable(t, prefix)
    if (#t == 0) then
        print('table is empty')
    end
    prefix = prefix or "";
    if #prefix<5 then
        print(prefix.."{")
        for k,v in pairs(t) do
            if type(v)=="table" then
                print(prefix.." "..tostring(k).." = ")
                if v~=t then
                    table.printtable(v, prefix.."   ")
                end
            elseif type(v)=="string" then
                print(prefix.." "..tostring(k).." = \""..v.."\"")
            elseif type(v)=="number" then
                print(prefix.." "..tostring(k).." = "..v)
            elseif type(v)=="userdata" then
                print(prefix.." "..tostring(k).." =  "..tostring(v))
            else
                print(prefix.." "..tostring(k).." = "..tostring(v))
            end
        end
        print(prefix.."}")
    end
end

function table.clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function table.get_readonly_table(t)
    local tt = {}
    local mt = {
        __index = t,
        __newindex = function (t, k, v)
            error("attempt to update a read-only table")
        end
    }
    setmetatable(tt, mt)
    return tt
end

function table.print_readonly_table(t)    
    table.printT(getmetatable(t).__index)
end

function table.pairs_readonly_table(t)
    local key = nil
    local function next_readonly(t)   
        local real_table = getmetatable(t).__index     
        local k, v = next(real_table, key)
        key = k
        if type(k) == "table" then 
            k = table.get_readonly_table(k)
        end
        if type(v) == "table" then 
            v = table.get_readonly_table(v)
        end
        return k, v
    end
    return next_readonly, t, nil;    
end

-- 只支持一层拷贝
function table.copy(t)
    local tt = {}
    for k, v in pairs(t) do
        tt[k] = v
    end
    return tt
end

--initialize table value all to zero
function table.zero(t)
    for k,v in pairs(t) do
        if type(v)~= "table" then 
            t[k] =0
        else
            table.zero(v)
        end
    end
    return t
end

function table.printR(root)
    local cache = { [root] = '.' }
    local function _dump(t, space, name)
        local temp = {}
        for k,v in pairs(t) do
            local key = tostring(k)
            if cache[v] then
                table.insert(temp, "+" .. key .. " {" .. cache[v] .. "}")
            elseif type(v) == "table" then
                local new_key = name .. "." ..key
                cache[v] = new_key
                table.insert(temp, "+" .. key .. _dump(v, space .. (next(t,k) and "|" or " ").. string.rep(" ",#key), new_key))
            else
                table.insert(temp, "+" .. key .. " [".. tostring(v) .. "]")
            end
        end
        return table.concat(temp, "\n"..space)
    end
     syslog.debug("\n".._dump(root, "",""))
end

-- cycle print all field in table
-- function table.printT2(ta)
--     s =""
--     local looped_table = {}
    
--     local function pt(key,t,ms)
--         print("{")
--         looped_table[t] = key
--         for k,v in pairs(t) do
--             if k then
--                 local ns=ms.."  "
--                 if type(v)~= "table" then                     
--                     if type(v) ~= "function" then
--                      if type(v) == "boolean" then   
--                          print(ms..k.." ", v)
--                      else                                             
--                          print(ms..k.."  "..v)
--                         end
--                     else
--                         print(ms..k.."  function()")
--                     end
--                 elseif not looped_table[v] then--avoid dead loop
--                         print(ms..k.." ")                        
--                         pt(k, v, ns)
--                         looped_table[v] = k
--                 else
--                     print(ms..k.." looped_table:"..tostring(looped_table[v]))
--                 end

--             end
--         end
--         print("}")
--     end
--     pt("self", ta, s)
-- end

function table.printT2(obj, depth)
    local  vis = {}
    depth = depth or 0
    local function pt(obj, depth)    
        if type(obj)~= "table" then
            print(obj)
            return 0
        else
            if vis[obj] then print(vis[obj]) return end
           -- vis[obj] = true
            local space = ""
            for i = 0, depth , 1 do space = space .. "    "end
            if depth == 0   then print("{") end
                for i, j in pairs(obj)
                do
                    if type(i) == "string"  then
                        io.write(space, i, " = ")
                    else
                        io.write(space,"[", i, "] = ")
                    end
                    if type(j) == "table"   then
                       io.write("{\n")
                       vis[obj] = i
                       pt(j, depth+1)
                       --table.printT(j, depth+1)
                       io.write(space, "}\n")
                    else
                        local tmp = tostring(j)
                        io.write(tmp, "\n")
                    end
                end
            if depth == 0   then print("}") end
        end
    end
    pt(obj, depth)
end

function table.printT(obj)
    if type(obj)~= "table" then
        print(obj)
        return 0
    end
    local looped_table = {}
    local function pt(key, obj, depth)
        local space = ""
        for i = 0, depth , 1 do space = space .. "    "end
        if depth == 0   then print("{") end
        looped_table[obj] = key
        for k, v in pairs(obj) do
            if type(k) == "string"  then
                io.write(space, k, " = ")
            else
                io.write(space,"[", k, "] = ")
            end
            if type(v) == "table"   then
                if looped_table[v] then
                   io.write(" looped_table: "..tostring(looped_table[v]).."\n")
                else
                    io.write("{\n")
                    pt(k, v, depth+1)
                    looped_table[v] = k
                    io.write(space, "}\n")
                end
            else
                local tmp = tostring(v)
                io.write(tmp, "\n")
            end
        end
        if depth == 0   then print("}") end
    end
    pt("self", obj, 0)
end

function table.printForMajiang(_chair_id, _cards)
	local cards = table.clone(_cards)
	table.sort(cards)
	local card_wan = _chair_id..":|"
	local card_tiao = ""
	local card_bing = ""
	local card_zi = ""
	
	for k,v in pairs(cards) do
		local card = ''
		if v < 20 then
			card = string.format("[%d 万] " ,v - 10)
			card_wan = card_wan..card
		elseif v < 30 then
			card = string.format("[%d 饼] " ,v - 20)
			card_tiao = card_tiao..card
		elseif v < 40 then
			card = string.format("[%d 条] " ,v - 30)
			card_bing = card_bing..card			
		elseif v == 41 then
			card = string.format("[东风] " )
			card_zi = card_zi..card	
		elseif v == 42 then
			card = string.format("[南风] " ,v - 20)
			card_zi = card_zi..card
		elseif v == 43 then
			card = string.format("[西风] " ,v - 20)
			card_zi = card_zi..card
		elseif v == 44 then
			card = string.format("[北风] " ,v - 20)
			card_zi = card_zi..card
		elseif v == 45 then
			card = string.format("[中] " ,v - 20)
			card_zi = card_zi..card
		elseif v == 46 then
			card = string.format("[發] " ,v - 20)
			card_zi = card_zi..card
		elseif v == 47 then
			card = string.format("[白板] " ,v - 20)
			card_zi = card_zi..card
		elseif v < 55 then
		end
	end
	-- print(card_wan..card_tiao..card_bing..card_zi)
    syslog.debug(card_wan..card_tiao..card_bing..card_zi)
end

PaohuziTable = {
"一","二","三","四","五","六","七","八","九","十","壹","贰","叁","肆","伍","陆","柒","捌","玖","拾",
}

function table.printForPaohuzi(_chair_id, _cards)
	local cards = table.clone(_cards)
	table.sort(cards)
	local card_wan = _chair_id..":|"	
    local card = _chair_id..":|"
	for k,v in pairs(cards) do
		
        if PaohuziTable[v] then
            card = card..PaohuziTable[v].." "
        else
            syslog.err("错误牌["..v.."]")
        end
	end
	-- print(card_wan..card_tiao..card_bing..card_zi)
    syslog.debug(card)
end

--[[--

计算表格包含的字段数量

Lua table 的 "#" 操作只对依次排序的数值下标数组有效，table.nums() 则计算 table 中所有不为 nil 的值的个数。

@param table t 要检查的表格

@return integer

]]
function table.nums(t)
    local count = 0
    if t and type(t) == 'table' then
        for k, v in pairs(t) do
            count = count + 1
        end
    end
    return count
end

--[[--

返回指定表格中的所有键

~~~ lua

local hashtable = {a = 1, b = 2, c = 3}
local keys = table.keys(hashtable)
-- keys = {"a", "b", "c"}

~~~

@param table hashtable 要检查的表格

@return table

]]
function table.keys(hashtable)
    local keys = {}
    for k, v in pairs(hashtable) do
        keys[#keys + 1] = k
    end
    return keys
end

--[[--

返回指定表格中的所有值

~~~ lua

local hashtable = {a = 1, b = 2, c = 3}
local values = table.values(hashtable)
-- values = {1, 2, 3}

~~~

@param table hashtable 要检查的表格

@return table

]]
function table.values(hashtable)
    local values = {}
    for k, v in pairs(hashtable) do
        values[#values + 1] = v
    end
    return values
end

--[[--

将来源表格中所有键及其值复制到目标表格对象中，如果存在同名键，则覆盖其值

~~~ lua

local dest = {a = 1, b = 2}
local src  = {c = 3, d = 4}
table.merge(dest, src)
-- dest = {a = 1, b = 2, c = 3, d = 4}

~~~

@param table dest 目标表格
@param table src 来源表格

]]
function table.merge(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

--[[--

在目标表格的指定位置插入来源表格，如果没有指定位置则连接两个表格

~~~ lua

local dest = {1, 2, 3}
local src  = {4, 5, 6}
table.insertto(dest, src)
-- dest = {1, 2, 3, 4, 5, 6}

dest = {1, 2, 3}
table.insertto(dest, src, 5)
-- dest = {1, 2, 3, nil, 4, 5, 6}

~~~

@param table dest 目标表格
@param table src 来源表格
@param [integer begin] 插入位置

]]
function table.insertto(dest, src, begin)
    begin = checkint(begin)
    if begin <= 0 then
        begin = #dest + 1
    end

    local len = #src
    for i = 0, len - 1 do
        dest[i + begin] = src[i + 1]
    end
end

--[[

从表格中查找指定值，返回其索引，如果没找到返回 false

~~~ lua

local array = {"a", "b", "c"}
print(table.indexof(array, "b")) -- 输出 2

~~~

@param table array 表格
@param mixed value 要查找的值
@param [integer begin] 起始索引值

@return integer

]]
function table.indexof(array, value, begin)
    for i = begin or 1, #array do
        if array[i] == value then return i end
    end
    return false
end

--[[--

从表格中查找指定值，返回其 key，如果没找到返回 nil

~~~ lua

local hashtable = {name = "dualface", comp = "chukong"}
print(table.keyof(hashtable, "chukong")) -- 输出 comp

~~~

@param table hashtable 表格
@param mixed value 要查找的值

@return string 该值对应的 key

]]
function table.keyof(hashtable, value)
    for k, v in pairs(hashtable) do
        if v == value then return k end
    end
    return nil
end

--[[--

从表格中删除指定值，返回删除的值的个数

~~~ lua

local array = {"a", "b", "c", "c"}
print(table.removebyvalue(array, "c", true)) -- 输出 2

~~~

@param table array 表格
@param mixed value 要删除的值
@param [boolean removeall] 是否删除所有相同的值

@return integer

]]
function table.removebyvalue(array, value, removeall)
    local c, i, max = 0, 1, #array
    while i <= max do
        if array[i] == value then
            table.remove(array, i)
            c = c + 1
            i = i - 1
            max = max - 1
            if not removeall then break end
        end
        i = i + 1
    end
    return c
end

--[[--

对表格中每一个值执行一次指定的函数，并用函数返回值更新表格内容

~~~ lua

local t = {name = "dualface", comp = "chukong"}
table.map(t, function(v, k)
    -- 在每一个值前后添加括号
    return "[" .. v .. "]"
end)

-- 输出修改后的表格内容
for k, v in pairs(t) do
    print(k, v)
end

-- 输出
-- name [dualface]
-- comp [chukong]

~~~

fn 参数指定的函数具有两个参数，并且返回一个值。原型如下：

~~~ lua

function map_function(value, key)
    return value
end

~~~

@param table t 表格
@param function fn 函数

]]
function table.map(t, fn)
    for k, v in pairs(t) do
        t[k] = fn(v, k)
    end
end

--[[--

对表格中每一个值执行一次指定的函数，但不改变表格内容

~~~ lua

local t = {name = "dualface", comp = "chukong"}
table.walk(t, function(v, k)
    -- 输出每一个值
    print(v)
end)

~~~

fn 参数指定的函数具有两个参数，没有返回值。原型如下：

~~~ lua

function map_function(value, key)

end

~~~

@param table t 表格
@param function fn 函数

]]
function table.walk(t, fn)
    for k,v in pairs(t) do
        fn(v, k)
    end
end

--[[--

对表格中每一个值执行一次指定的函数，如果该函数返回 false，则对应的值会从表格中删除

~~~ lua

local t = {name = "dualface", comp = "chukong"}
table.filter(t, function(v, k)
    return v ~= "dualface" -- 当值等于 dualface 时过滤掉该值
end)

-- 输出修改后的表格内容
for k, v in pairs(t) do
    print(k, v)
end

-- 输出
-- comp chukong

~~~

fn 参数指定的函数具有两个参数，并且返回一个 boolean 值。原型如下：

~~~ lua

function map_function(value, key)
    return true or false
end

~~~

@param table t 表格
@param function fn 函数

]]
function table.filter(t, fn)
    for k, v in pairs(t) do
        if not fn(v, k) then t[k] = nil end
    end
end

--[[--

遍历表格，确保其中的值唯一

~~~ lua

local t = {"a", "a", "b", "c"} -- 重复的 a 会被过滤掉
local n = table.unique(t)

for k, v in pairs(n) do
    print(v)
end

-- 输出
-- a
-- b
-- c

~~~

@param table t 表格

@return table 包含所有唯一值的新表格

]]
function table.unique(t)
    local check = {}
    local n = {}
    for k, v in pairs(t) do
        if not check[v] then
            n[k] = v
            check[v] = true
        end
    end
    return n
end

function table.make_key(t, key_name1, key_name2)
    local tt = {}
    if not key_name2 then
        for k, v in pairs(t) do
            tt[v[key_name1]] = v
        end
    else
        for k, v in pairs(t) do
            tt[v[key_name1]] = tt[v[key_name1]] or {}
            tt[v[key_name1]][v[key_name2]] = v
        end
    end
    return tt
end

function table.remake_key_value(t, key, value)
    local tt = {}
    for k, v in pairs(t) do
        local ttt = {}
        ttt[key] = k
        ttt[value] = v
        table.insert(tt, ttt)
    end
    return tt
end

function table.make_key_value(t, key, value)
    local tt = {}
    for k, v in pairs(t) do
        tt[v[key]] = v[value]
    end
    return tt
end