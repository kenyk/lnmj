require "table_util"
local random_util = {}

function random_util.randomseed()
	math.randomseed(os.time())
end

function random_util.random_get_elements_in_array(array, get_count)
	if type(array) ~= 'table' or get_count > #array then
		return nil
	end

	if get_count == #array then
		return array
	end

	local tmp_array = table.copy(array)

	-- random_util.randomseed()

	local result  = {}
	for i = 1, get_count do
		local index = math.random(#tmp_array)
		table.insert(result, tmp_array[index])
		table.remove(tmp_array, index)
	end
	return result
end

function random_util.random(m, n)
	random_util.randomseed()
	return math.random(m, n)
end

return random_util