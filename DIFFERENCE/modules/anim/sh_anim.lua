function mwLib.manipulateBones(ply, tbl, time)

	if not IsValid(ply) then return end

	local old = {}
	local tgt = {}

	if not tbl then
		for i = 0, ply:GetBoneCount() - 1 do
			old[i] = ply:GetManipulateBoneAngles(i) or angle_zero
			tgt[i] = angle_zero
		end
	end

	for bone, ang in pairs(tbl or {}) do
		local boneID = ply:LookupBone(bone)
		if boneID then
			old[boneID] = ply:GetManipulateBoneAngles(boneID) or angle_zero
			tgt[boneID] = ang
		end
	end

	for boneID, ang in pairs(tgt) do
		if old[boneID] == ang then
			old[boneID] = nil
			tgt[boneID] = nil
		end
	end

	running[#running + 1] = {
		ply = ply,
		old = old,
		tgt = tgt,
		start = CurTime(),
		finish = CurTime() + (time or 0),
	}

end