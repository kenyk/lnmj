local futil = {}

function futil.split(s, sep)
	--print("spe2:",spe, s)
	local sep = sep or " "
	local fields = {}
	local pattern = string.format("([^%s]+)", sep)
	string.gsub(s, pattern, function(c) fields[#fields+1]=c end)
	return fields
end


function futil.toStr(t)
	if type(t) == 'table' then
		local s = "{"
		for k, v in pairs(t) do
			local temp = string.format("%s:%s,", tostring(k), futil.toStr(v))
			s = s .. temp
		end
		s = s .. "}"
		return s
	else
		return tostring(t)
	end
end


return futil