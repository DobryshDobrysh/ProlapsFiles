mwLib.meta = mwLib.meta or {}
mwLib.meta.stored = mwLib.meta.stored or {}

function mwLib.meta.getOrCreate(id)
	if mwLib.meta.stored[id] then
		return mwLib.meta.stored[id]
	end

	local meta = {}
	meta.__index = meta
	mwLib.meta.stored[id] = meta

	return meta
end
