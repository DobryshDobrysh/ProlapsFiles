-- TODO: implement config

-- mwLib.config = mwLib.config or {}
-- mwLib.config.storedOptions = mwLib.config.storedOptions or {}
-- mwLib.config.types = mwLib.config.types or {}

-- mwLib.include.prefixed('meta')
-- mwLib.include.prefixed('contract')
-- mwLib.include.client('vgui')

-- function mwLib.config.option(id, optionConfig)
-- 	local option
-- 	if mwLib.config.storedOptions[id] then
-- 		option = mwLib.config.storedOptions[id]
-- 	else
-- 		option = setmetatable({ id = id }, mwLib.meta.stored.configOption)
-- 		option:Load()
-- 	end

-- 	if optionConfig then table.Merge(option, optionConfig) end

-- 	mwLib.config.storedOptions[id] = option

-- 	return option
-- end

-- function mwLib.config.defineType(name, options)
-- 	local type
-- 	local changed = false
-- 	if mwLib.config.types[name] then
-- 		type = mwLib.config.types[name]

-- 		if options then
-- 			table.Merge(type, options)
-- 			changed = true
-- 		end
-- 	else
-- 		type = options
-- 		changed = true
-- 	end

-- 	if changed then
-- 		mwLib.config.types[name] = type
-- 	end

-- 	return type
-- end
