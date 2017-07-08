require "lfs"
local file_util = {}

function file_util.get_file_recursively(root)
	local paths = {}
	function recursive(root_path)
		for entry in lfs.dir(root_path) do
			if entry ~= '.' and entry ~= ".." then
				local path = root_path..'/'..entry
				local attr = lfs.attributes(path)
				assert(type(attr) == 'table')

				if attr.mode == 'directory' then
					recursive(path)
				else
					table.insert(paths, path)
				end
			end
		end
	end
	recursive(root)
	return paths
end

function file_util.get_sub_dir_recursively(root)
	local paths = {}
	function recursive(root_path)
		for entry in lfs.dir(root_path) do
			if entry ~= '.' and entry ~= ".." then
				local path = root_path..'/'..entry
				local attr = lfs.attributes(path)
				if attr then
					assert(type(attr) == 'table')

					if attr.mode == 'directory' then
						table.insert(paths, path)
						recursive(path)							
					end
				end
			end
		end
	end
	recursive(root)
	return paths
end

function file_util.each_sub_dir(root)
	local key = nil
	local paths = file_util.get_sub_dir_recursively(root)
	if not paths then
		return nil
	end
	local function next_dir(dirs)    
        local k, v = next(dirs, key)
        key = k        
        return v
    end
    
    return next_dir, paths;    
end

function file_util.get_preload_paths_in_root_path(root)
	local path = ''
	for dir in file_util.each_sub_dir(root) do		
		path = path .. dir .. "/?.lua;"		
	end
	return path
end

return file_util