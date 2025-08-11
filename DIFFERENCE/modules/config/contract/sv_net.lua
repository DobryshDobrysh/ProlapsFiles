netstream.Listen('mwLib.config.get', function(reply, ply, id)
	local option = mwLib.config.storedOptions[id]
	if not option or not option:CanRead(ply) then
		return reply()
	end

	reply(option:Get())
end)

netstream.Listen('mwLib.config.set', function(reply, ply, id, value)
	local option = mwLib.config.storedOptions[id]
	if not option or not option:CanWrite(ply) then
		return reply(false)
	end

	option:Set(value)

	reply(true)
end)
