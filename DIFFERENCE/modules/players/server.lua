hook.Add("PlayerSpawn", "mwLib.setupCollision", function(ply)
    ply:SetNoCollideWithTeammates(true)
end)