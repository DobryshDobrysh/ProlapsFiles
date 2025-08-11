local distanceThreshold = 512

local function updateEntityVisibility()
    local players = player.GetAll()

    for _, entity in ipairs(ents.GetAll()) do
        if IsValid(entity) then
            local class = entity:GetClass()

            if class ~= "player" and not entity:IsWeapon() and not entity:IsVehicle() and not string.find(class, "viewmodel") then
                local shouldShow = false

                for _, ply in ipairs(players) do
                    if IsValid(ply) and ply:Alive() then
                        if ply:GetPos():DistToSqr(entity:GetPos()) <= distanceThreshold^2 then
                            shouldShow = true
                            break
                        end
                    end
                end

                entity:SetNoDraw(not shouldShow)
                entity:SetCollisionGroup(shouldShow and COLLISION_GROUP_NONE or COLLISION_GROUP_WORLD)
            end
        end
    end
end

timer.Create("UpdateEntityVisibility", 0, 0, updateEntityVisibility)
