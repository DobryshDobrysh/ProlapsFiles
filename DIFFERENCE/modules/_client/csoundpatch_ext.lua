local CSOUNDPATCH = FindMetaTable("CSoundPatch")

local CSOUNDPATCH_EXT = {}
for k, v in pairs(CSOUNDPATCH) do
	if isfunction(v) then
		CSOUNDPATCH_EXT[k] = function(self, ...)
			return v(self.userdata, ...)
		end
	end
end
CSOUNDPATCH_EXT.__index = CSOUNDPATCH_EXT
CSOUNDPATCH_EXT.__gc = nil

function CSOUNDPATCH_EXT:Play()
	self.faded = false
	self.userdata:Play()
end

function CSOUNDPATCH_EXT:PlayEx(volume, pitch)
	self.faded = false
	self.userdata:PlayEx(volume, pitch)
end

-- Если вызывать FadeOut каждый кадр, то звук в реальности не остановится. Громкость будет 0, а IsPlaying вернет true.
-- Если вызвать один раз, то остановится. Считаю это ошибкой.
function CSOUNDPATCH_EXT:FadeOut(seconds)
	if not self.faded then
		self.faded = true
		self.userdata:FadeOut(seconds)
	end
end

-- Звук в процессе затухания. Если звук не воспроизводится, то и не затухает.
function CSOUNDPATCH_EXT:IsFading()
	return self.userdata:IsPlaying() and self.faded
end

function CreateSoundExt(ent, sound, filter)
	local self = {
		userdata = CreateSound(ent, sound, filter),
		faded = false
	}
	return setmetatable(self, CSOUNDPATCH_EXT)
end
