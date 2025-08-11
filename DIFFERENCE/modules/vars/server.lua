local pending = {}

netstream.Hook('mwLib.getVars', function(ply, vars)
	local callback = pending[ply]
	if not callback then return end

	callback(vars)
	pending[ply] = nil
end)

local ply = FindMetaTable 'Player'

function ply:GetClientVar(vars, callback)
	if self:IsBot() then
		callback({})
		return
	end

	pending[self] = callback
	netstream.Start(self, 'mwLib.getVars', vars)
end

function ply:SetClientVar(var, val)
	netstream.Start(self, 'mwLib.setVar', var, val)
end
