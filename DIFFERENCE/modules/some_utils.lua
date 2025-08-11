if not hook.Exist then
	local Hooks = hook.GetTable()
	function hook.Exist(event_name, name)
		return Hooks[event_name] and Hooks[event_name][name]
	end
end

-- Первый вызов происходит на следующий тик после создания. Выход может быть в том же тике.
function hook.Deferred(hookName, callsPerSecond, func, callback)
	local tickInterval = engine.TickInterval()
	local callsPerTick = math.ceil(callsPerSecond * tickInterval)
	local workInterval = callsPerTick / callsPerSecond
	local nextWork = CurTime()
	hook.Add(
		"Tick",
		hookName,
		function()
			if nextWork > CurTime() then
				return
			end
			nextWork = nextWork + workInterval

			for _ = 1, callsPerTick do
				local result, message = pcall(func)
				if result then
					if message == true then
						hook.Remove("Tick", hookName)
						if callback then
							callback()
						end
						return
					end
				else
					hook.Remove("Tick", hookName)
					ErrorNoHalt("hook.Deferred '", hookName, "' failed:\n\t", message, "\n")
					return
				end
			end
		end
	)
end

-- ====================================================================================================

function ColorToChar(color)
	return string.char(color.r, color.g, color.b, color.a)
end

function CharToColor(char)
	return Color(string.byte(char, 1, 4))
end

-- ====================================================================================================

local CMOVEDATA = FindMetaTable("CMoveData")

function CMOVEDATA:RemoveKey(key)
	local keys = self:GetButtons()
	keys = bit.band(keys, bit.bnot(key))
	self:SetButtons(keys)
end

-- ====================================================================================================

if CLIENT then
	local traceOut = {}
	local traceData = {collisiongroup = COLLISION_GROUP_WORLD, output = traceOut}

	function util.IsInWorld(pos)
		traceData.start = pos
		traceData.endpos = pos
		util.TraceLine(traceData)
		return not traceOut.HitWorld
	end
end

-- По настоящему загружает модель с диска. Если данных о коллизии нет, то модели нет или это не физический проп.
function util.GetPropSkinCount(model)
	if not model:match("^models/[%w_/%-]+%.mdl$") then
		return
	end
	local info = util.GetModelInfo(model)
	return info and info.KeyValues and info.SkinCount
end

---@class Entity
---@class Vector
---@class Angle

-- Возвращает матрицу кости головы, иначе матрицу "глаз" энтити.
-- Однако для локального игрока EyePos это позиция камеры, а для невидимого GetPos.
function util.GetHeadMatrix(ent, skipFallback)
	if ent.GetRagdollEntity then
		ent = ent:GetRagdollEntity() or ent
	end

	local headBone = "ValveBiped.Bip01_Head1"
	local model = ent:GetModel()
	if string.find(model, "vortigaunt") then
		headBone = "ValveBiped.Head"
	elseif model == "models/pb2uniq/creampie.mdl" then
		headBone = "Bip01 Head"
	end

	local boneIdx = ent:LookupBone(headBone)
	if boneIdx then
		local matrix = ent:GetBoneMatrix(boneIdx)
		if matrix then
			return matrix
		end
	end

	if skipFallback then
		return
	end
	local matrix = Matrix()
	matrix:SetTranslation(ent:EyePos())
	matrix:SetAngles(ent:EyeAngles())
	return matrix
end

---@param ent Entity
---@param skipFallback boolean
---@return Vector|nil, Angle|nil
---@overload fun(ent: Entity): Vector, Angle
function util.GetHeadPosAng(ent, skipFallback)
	local matrix = util.GetHeadMatrix(ent, true)
	if matrix then
		return matrix:GetTranslation(), matrix:GetAngles()
	end

	if skipFallback then
		return
	end
	return ent:EyePos(), ent:EyeAngles()
end

-- Возвращает матрицу глаз модели, иначе матрицу кости головы.
function util.GetEyeMatrix(ent, skipFallback)
	local pos, ang = util.GetEyePosAng(ent, true)
	if pos then
		local matrix = Matrix()
		matrix:SetTranslation(pos)
		matrix:SetAngles(ang)
		return matrix
	end

	if skipFallback then
		return
	end
	return util.GetHeadMatrix(ent)
end

---@param ent Entity
---@param skipFallback boolean
---@return Vector|nil, Angle|nil
---@overload fun(ent: Entity): Vector, Angle
function util.GetEyePosAng(ent, skipFallback)
	if ent.GetRagdollEntity then
		ent = ent:GetRagdollEntity() or ent
	end

	local attIdx = ent:LookupAttachment("eyes")
	if attIdx > 0 then
		local att = ent:GetAttachment(attIdx)
		if att then
			return att.Pos, att.Ang
		end
	end

	if skipFallback then
		return
	end
	return util.GetHeadPosAng(ent)
end

-- ====================================================================================================

function util.Steam32FromID(sid)
	local mod, id = string.match(sid, "^([01]):(%d+)$", 9)
	local sid32 = tonumber(id) * 2 + tonumber(mod)
	return sid32
end

function util.SteamIDFrom32(sid32)
	local id = math.floor(sid32 / 2)
	local mod = sid32 % 2
	local sid = "STEAM_0:" .. mod .. ":" .. id
	return sid
end

function util.Steam32From64(sid64)
	local sid = util.SteamIDFrom64(sid64)
	return util.Steam32FromID(sid)
end

-- unit-test
do
	local sid = "STEAM_0:1:2147483647"
	local sid32 = 4294967295
	assert(sid32 == util.Steam32FromID(sid) and sid == util.SteamIDFrom32(sid32), "SteamID/SteamID32 unit-test failed!")
end

-- ====================================================================================================

-- function string.FindNoCase(source, target)
-- 	return source:utf8lower():find(target:utf8lower(), 1, true)
-- end

-- -- unit-test
-- do
-- 	assert(string.FindNoCase("[Source", "[sour"), "FindNoCase unit-test failed!")
-- 	assert(string.FindNoCase("[Источник", "[исто"), "FindNoCase unit-test failed!")
-- end

-- ====================================================================================================

-- `assert` с форматированием. По сравнению с `assert` не вычисляет строку, если нет ошибки.
-- Однако нужно быть осторожным, чтобы не ошибиться с количеством аргументов в шаблоне.
---@diagnostic disable-next-line: lowercase-global
function assertf(expression, template, ...)
	if not expression then
		return error(template:format(...))
	end
	return expression
end

-- ====================================================================================================

-- Удаление элемента во время итерации, для этого `func` должен вернуть `true`.
-- Элемент просто удаляется из таблицы по ключу. Для сдвига последовательной таблицы нужно использовать **Stack**.
-- В реальности удаление не во время цикла, потому что по умолчанию модификация таблицы во время итерации портит цикл.
---@param tbl table
---@param func fun(k, v): boolean
function table.RemoveInPlace(tbl, func)
	local removedKeys = Stack()
	for k, v in pairs(tbl) do
		if func(k, v) then
			removedKeys:Push(k)
		end
	end

	for _, k in ipairs(removedKeys) do
		tbl[k] = nil
	end
end
