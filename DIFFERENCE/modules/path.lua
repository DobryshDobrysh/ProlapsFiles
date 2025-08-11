mwLib.path = mwLib.path or {}

function mwLib.path.current(level)
	assert(isnumber(level) or level == nil, 'level must be a number or nil')

	local path = debug.getinfo(2 + (level or 0), 'S').short_src:Split('/')

	return '/' .. table.concat({ unpack(path, 4, #path - 1) }, '/')
end

function mwLib.path.resolve(path, level)
	assert(isstring(path), 'path must be a string')
	assert(isnumber(level) or level == nil, 'level must be a number or nil')

	path = mwLib.path.normalize(path)

	if string.StartWith(path, '/') then
		return path
	end

	return mwLib.path.join(mwLib.path.current(1 + (level or 0)), path)
end

function mwLib.path.normalize(path)
	assert(isstring(path), 'path must be a string')

	if path == '.' then
		path = ''
	elseif string.StartWith(path, './') then
		path = string.sub(path, 3)
	end

	local result = {}

	for element in string.gmatch(path, '[^/\\]+') do
		if element == '..' and #result ~= 0 then
			table.remove(result)
		elseif element ~= '' then
			table.insert(result, element)
		end
	end

	return (string.StartWith(path, '/') and '/' or '') .. table.concat(result, '/')
end

function mwLib.path.trim(path)
	assert(isstring(path), 'path must be a string')

	return string.Trim(path, '/')
end

function mwLib.path.join(...)
	local elements = { ... }
	local result = ''

	for _, element in ipairs(elements) do
		result = result .. mwLib.path.normalize(element) .. '/'
	end

	return mwLib.path.normalize(result)
end
