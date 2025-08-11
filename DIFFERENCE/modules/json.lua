local json = {}
_G.json = json

json.pendingEnts = {}
function json.queueEntsFlush() end

hook.Add('Think', 'mwLib.json.init', function()
	hook.Remove('Think', 'mwLib.json.init')

	json.queueEntsFlush = mwLib.func.debounce(function()
		table.Empty(json.pendingEnts)
	end, 300)
end)

local type = type
local pairs = pairs
local tonumber = tonumber
local function insert(tbl, val)
	tbl[#tbl + 1] = val
end
local isSequential = table.IsSequential
local isColor = IsColor
local isValid = IsValid

do
	local encode = {}


	encode['table'] = function(tbl, output)

		-- starts with a sequential type
		if isSequential(tbl) then
			insert(output, '[')

			for i = 1, #tbl do
				local v = tbl[i]
				local _ = isColor(v) and encode.Color(v, output) or encode[type(v)](v, output)
				insert(output, ',')
			end

			local last = #output
			output[last + (output[last] ~= ',' and 1 or 0)] = ']' -- replace last comma with ] or just append it
		else

			insert(output, '{')
			for k, v in pairs(tbl) do
				local tk = type(k)
				if tk ~= 'string' then
					error('unserializable key ' .. tostring(k) .. ' (type = ' .. tk .. ')')
				end
				encode.string(k, output)
				insert(output, ':')

				local _ = isColor(v) and encode.Color(v, output) or encode[type(v)](v, output)

				insert(output, ',')
			end

			local last = #output
			output[last + (output[last] ~= ',' and 1 or 0)] = '}' -- replace last comma with } or just append it
		end

		return true
	end
	--	ENCODE STRING
	local gsub = string.gsub
	encode['string'] = function(str, output)
		insert(output, '"')
		insert(output, gsub(gsub(str, '\\', '\\\\'), '"', '\\"'))
		insert(output, '"')
		return true
	end
	--	ENCODE NUMBER
	encode['number'] = function(num, output)
		insert(output, num)
		return true
	end
	--	ENCODE BOOLEAN
	encode['boolean'] = function(val, output)
		insert(output, val and 'true' or 'false')
		return true
	end
	--	ENCODE VECTOR
	encode['Vector'] = function(val, output)
		insert(output, '"')
		insert(output, '$$v$$')
		insert(output, val.x)
		insert(output, ',')
		insert(output, val.y)
		insert(output, ',')
		insert(output, val.z)
		insert(output, '"')
		return true
	end
	--	ENCODE COLOR
	encode['Color'] = function(val, output)
		insert(output, '"')
		insert(output, '$$c$$')
		insert(output, val.r)
		insert(output, ',')
		insert(output, val.g)
		insert(output, ',')
		insert(output, val.b)
		if val.a ~= 255 then
			insert(output, ',')
			insert(output, val.a)
		end
		insert(output, '"')
		return true
	end
	--	ENCODE ANGLE
	encode['Angle'] = function(val, output)
		insert(output, '"')
		insert(output, '$$a$$')
		insert(output, val.p)
		insert(output, ',')
		insert(output, val.y)
		insert(output, ',')
		insert(output, val.r)
		insert(output, '"')
		return true
	end
	encode['Entity'] = function(val, output)
		insert(output, '"')
		insert(output, '$$e$$')
		insert(output, isValid(val) and val:EntIndex() or '#')
		insert(output, '"')
		return true
	end
	encode['Player'] = function(val, output)
		insert(output, '"')
		insert(output, '$$p$$')
		insert(output, val:SteamID())
		insert(output, '"')
		return true
	end
	encode['Vehicle'] = encode['Entity']
	encode['Weapon'] = encode['Entity']
	encode['NPC'] = encode['Entity']
	encode['NextBot'] = encode['Entity']
	encode['PhysObj'] = encode['Entity']

	do
		local concat = table.concat
		function json.encode(tbl)
			assert(istable(tbl), 'Table excepted for encode.')

			local output = {}
			encode['table'](tbl, output, {})
			return concat(output)

		end
	end
end

do
	local tonumber = tonumber
	local find, sub, Explode = string.find, string.sub, string.Explode
	local Vector, Angle, Entity = Vector, Angle, Entity
	local getBySteamID = player.GetBySteamID

	local decode = {}

	-- keep track of encoding table stack to restore null refs
	local curStack = {}

	-- sequential table
	decode['['] = function(index, str) -- index is at [
		index = index + 1
		local cur = {}

		local k = 1
		local v, tv
		while true do
			tv = sub(str, index, index)
			if tv == '' or tv == ']' then
				return index, cur
			end
			if tv == ',' then
				index = index + 1
				continue
			end

			curStack[#curStack + 1] = { cur, k }
			index, v = decode[tv](index, str)
			curStack[#curStack] = nil
			index = index + 1 -- , or ]

			cur[k] = v

			k = k + 1
		end

		return index, cur
	end

	-- dictionary table
	decode['{'] = function(index, str) -- index is at {
		index = index + 1
		local cur = {}

		local k, v, tk, tv
		while true do
			tk = sub(str, index, index)
			if tk == '' or tk == '}' then
				return index + 1, cur
			end
			if tk == ',' then
				index = index + 1
				continue
			end

			index, k = decode[tk](index, str)

			index = index + 2 -- skip :

			tv = sub(str, index, index)
			index, v = decode[tv](index, str)
			index = index + 1 -- , or }

			cur[k] = v
		end

		return index, cur
	end

	-- string
	local startWith = string.StartWith
	decode['"'] = function(index, str) -- index is '"' pos
		index = index + 1
		local finish = find(str, '[^\\]"', index)
		local res = sub(str, index, finish)
		finish = finish + 1

		if startWith(res, '$$') then
			local cmd = sub(res, 1, 5)
			if decode[cmd] then
				finish, res = decode[cmd](index + 5, str)
			end
		end

		return finish, res
	end

	-- number
	decode['0'] = function(index, str)
		local finish = find(str, '[,}%]]', index)
		local num = tonumber(sub(str, index, finish - 1))
		index = finish
		return index - 1, num
	end
	decode['1'] = decode['0']
	decode['2'] = decode['0']
	decode['3'] = decode['0']
	decode['4'] = decode['0']
	decode['5'] = decode['0']
	decode['6'] = decode['0']
	decode['7'] = decode['0']
	decode['8'] = decode['0']
	decode['9'] = decode['0']
	decode['-'] = decode['0']

	-- boolean
	decode['t'] = function(index)
		return index + 4, true
	end
	decode['f'] = function(index)
		return index + 5, false
	end

	-- Vector
	decode['$$v$$'] = function(index, str) -- index is last $ sign
		local finish = find(str, '[^\\]"', index)
		local vecStr = sub(str, index, finish)
		index = finish + 1 -- update the index.
		local segs = Explode(',', vecStr, false)
		return index, Vector(tonumber(segs[1]), tonumber(segs[2]), tonumber(segs[3]))
	end
	-- Color
	decode['$$c$$'] = function(index, str)
		local finish = find(str, '[^\\]"', index)
		local colStr = sub(str, index, finish)
		index = finish + 1 -- update the index.
		local segs = Explode(',', colStr, false)
		return index, Color(tonumber(segs[1]), tonumber(segs[2]), tonumber(segs[3]), tonumber(segs[4] or '255'))
	end
	-- Angle
	decode['$$a$$'] = function(index, str)
		local finish = find(str, '[^\\]"', index)
		local angStr = sub(str, index, finish)
		index = finish + 1 -- update the index.
		local segs = Explode(',', angStr, false)
		return index, Angle(tonumber(segs[1]), tonumber(segs[2]), tonumber(segs[3]))
	end
	-- Entity
	decode['$$e$$'] = function(index, str)
		if str[index] == '#' then
			index = index + 1
			return index, NULL
		else
			local finish = find(str, '[^\\]"', index)
			local num = tonumber(sub(str, index, finish))
			index = finish + 1 -- update the index.

			local ent = Entity(num)
			if not IsValid(ent) and curStack[#curStack] then
				json.pendingEnts[num] = curStack[#curStack]
				json.queueEntsFlush()
			end

			return index, ent
		end
	end
	-- Player
	decode['$$p$$'] = function(index, str)
		local finish = find(str, '[^\\]"', index)
		local steamID = sub(str, index, finish)
		index = finish + 1 -- update the index.

		return finish, getBySteamID(steamID) or steamID
	end

	function json.decode(data)
		assert(isstring(data), 'String excepted for decode.')

		local _, res = decode[sub(data, 1, 1)](1, data, {})
		return res
	end
end

local function entCreated(ent)
	local id = ent:EntIndex()
	local link = json.pendingEnts[id]
	if link then
		local tbl, key = unpack(link)
		tbl[key] = ent
		json.pendingEnts[id] = nil
		hook.Run('json.entityCreated', ent, tbl, key)
	end
end
hook.Add('OnEntityCreated', 'mwLib.json', entCreated)
hook.Add('NetworkEntityCreated', 'mwLib.json', entCreated)

hook.Add('EntityRemoved', 'mwLib.json', function(ent)
	local id = ent:EntIndex()
	json.pendingEnts[id] = nil
end)
