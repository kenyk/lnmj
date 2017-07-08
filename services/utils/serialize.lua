
local serialize={}

function serialize.encode(seritable)
	local seri = {}
	for k,v in pairs(seritable) do
		--key
		local keystr = type(k)=="string" and "["..string.format("%q",k).."]"  or "["..tostring(k).."]"
		--val
		local vtype = type(v)
		if vtype == "string" then
			table.insert(seri,keystr.."="..string.format("%q",v))
		end
		if vtype == "number" or vtype == "nil" or vtype == "boolean" then
			table.insert(seri,keystr.."="..tostring(v))
		end
		if vtype == "table" then
			table.insert(seri,keystr.."="..serialize.encode(v))
		end
		--function set nil
	end
	seristr="{"..table.concat(seri,",").."}"
	return seristr
end

function serialize.decode(seristr)
	local f = load("return "..seristr)
	if f then
		return f()
	end
end

return serialize

