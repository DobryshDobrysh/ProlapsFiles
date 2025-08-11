mwLib.vars = mwLib.vars or {}

local fname = 'mwLib_vars.dat'
local function load()
	local txt = file.Read(fname, 'DATA') or '[}'
	mwLib.vars = pon.decode(txt) or {}
end
pcall(load)

local function save()
	file.Write(fname, pon.encode(mwLib.vars))
end
local saveDebounced = mwLib.func.debounce(save, 1)

function mwLib.vars.set(var, val, saveNow)

	if not istable(val) and mwLib.vars[var] == val then return end
	mwLib.vars[var] = val
	if saveNow then
		save()
	else
		saveDebounced()
	end

	hook.Run('mwLib.setVar', var, val)

end

function mwLib.vars.init(var, val)

	if mwLib.vars[var] ~= nil then return end
	mwLib.vars.set(var, val)

end

function mwLib.vars.get(var)

	return mwLib.vars[var]

end
