-- RunConsoleCommand('sv_downloadurl', 'https://dl.pastera.com/content/')

hook.Add('InitPostEntity', 'mwLib.content', function()

	if file.Exists('ClockworkLite/framework/config/content.lua', 'LUA') then
		mwLib.server('ClockworkLite/framework/config/content')
	end

end)
