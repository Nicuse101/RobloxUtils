if not writefile or not isfile or not makefolder then return end

local path, content = ...

local function splitPath(path)
	local parts = {}
	for part in string.gmatch(path, "[^/\]+") do
		table.insert(parts, part)
	end
	return parts
end

local parts = splitPath(path)
local currentPath = ""

for i = 1, #parts - 1 do  -- exclude last part (file)
	currentPath = currentPath == "" and parts[i] or (currentPath .. "/" .. parts[i])
	if not isfolder(currentPath) then
		makefolder(currentPath)
	end
end

writefile(path, content)