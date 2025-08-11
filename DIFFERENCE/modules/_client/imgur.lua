local original = 'https://i.imgur.com/'

local server

function mwLib.imgurLoaded()
	return server ~= nil
end

function mwLib.imgurImage(name)
	if not mwLib.imgurLoaded() then
		ErrorNoHalt('Tried to load imgur image before server determined')
	end
	return (server or original) .. name
end

mwLib.loadingMat = Material("icon16/arrow_rotate_clockwise.png")
local imgCache = {}

local function fileNameFromURL(url)
	return 'imgscreen/' ..
		string.StripExtension(url):gsub('https?://', ''):gsub('[\\/:*?"<>|%.]', '_') ..
		'.' .. string.GetExtensionFromFilename(url)
end

local function matNameFromURL(url)
	return '../data/' .. fileNameFromURL(url)
end

function mwLib.getURLMaterial(url, callback, forceReload)
	local mat = imgCache[url]
	if not mat then
		imgCache[url] = mwLib.loadingMat
		mat = mwLib.loadingMat

		http.Fetch(url, function(content)
			file.Write(fileNameFromURL(url), content)

			local matName = matNameFromURL(url)
			RunConsoleCommand('mat_reloadmaterial', string.StripExtension(matName))
			imgCache[url] = Material(matName)

			if isfunction(callback) then callback(imgCache[url]) end
		end)
	else
		if forceReload then
			RunConsoleCommand('mat_reloadmaterial', string.StripExtension(matNameFromURL(url)))
		end
		if isfunction(callback) then callback(mat) end
	end
	return mat
end

function mwLib.getImgurMaterial(url, callback, forceReload)
	return mwLib.getURLMaterial(mwLib.imgurImage(url), callback, forceReload)
end

local function clearCache()

	file.CreateDir('imgscreen')
	local fls = file.Find('imgscreen/*', 'DATA')
	for _, fl in ipairs(fls) do
		file.Delete('imgscreen/' .. fl)
	end

end
hook.Add('Shutdown', 'imgscreen.clearCache', clearCache)
hook.Add('PlayerFinishedLoading', 'imgscreen.clearCache', clearCache)

hook.Add('Think', 'mwLib-imgur.init', function()
	hook.Remove('Think', 'mwLib-imgur.init')
	vgui.GetControlTable('DImage').SetURL = function(self, url)
		mwLib.getURLMaterial(url, function(mat)
			if not IsValid(self) then return end
			self:SetMaterial(mat)
		end)
	end
end)
