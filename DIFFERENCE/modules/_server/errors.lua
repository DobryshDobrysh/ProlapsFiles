if CFG.disabledModules.errors then return end

require 'luaerror'

luaerror.EnableRuntimeDetour(true)
luaerror.EnableCompiletimeDetour(true)
luaerror.EnableClientDetour(true)

local function formatError(fullerror, stack)
	return table.concat({ fullerror, unpack(mwLib.table.mapSequential(stack, function(e, i)
		return ('%s. %s:%s'):format(i, e.short_src, e.currentline)
	end)) }, '\n    ')
end

hook.Add('LuaError', 'mwLib.errors', function(isruntime, fullerror, sourcefile, sourceline, errorstr, stack)
	hook.Run('mwLib.error', formatError(fullerror, stack))
end)

hook.Add('ClientLuaError', 'mwLib.errors', function(player, fullerror, sourcefile, sourceline, errorstr, stack)
	hook.Run('mwLib.error', formatError(fullerror, stack), player)
end)

-- local errors = {}
-- if errors[msg] then
-- 	errors[msg].count = errors[msg].count + 1
-- 	errors[msg].last = os.time()
-- else
-- 	local txt, cl = msg:sub(2), false
-- 	if lastmsg:find('|STEAM_') then
-- 		txt = lastmsg .. txt
-- 		cl = true
-- 		for path in string.gmatch(txt, '%-%s.-%.lua') do
-- 			if not file.Exists(path:sub(3), 'GAME') then return end
-- 		end
-- 	end

-- 	errors[msg] = {
-- 		txt = txt,
-- 		client = cl,
-- 		count = 1,
-- 		last = os.time(),
-- 	}
-- end