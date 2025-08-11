if CLIENT then
	hook.Add('Think', 'mwLib.finishedLoading', function()
		hook.Remove('Think', 'mwLib.finishedLoading')

		netstream.Start('mwLib.finishedLoading')
		hook.Run('PlayerFinishedLoading')
	end)
end

if SERVER then
	local playersFinished = {}

	netstream.Hook('mwLib.finishedLoading', function(ply)
		if playersFinished[ply] then return end

		hook.Run('PlayerFinishedLoading', ply)
		playersFinished[ply] = true
	end)

	hook.Add('PlayerDisconnected', 'mwLib.finishedLoading', function(ply)
		playersFinished[ply] = nil
	end)

	-- simulate hook for bots (mainly for automated tests)
	hook.Add('PlayerInitialSpawn', 'mwLib.finishedLoading', function(ply)
		if ply:IsBot() then
			timer.Simple(1, function()
				hook.Run('PlayerFinishedLoading', ply)
				ply.FinishedLoading = true
			end)
		end
	end)
end
