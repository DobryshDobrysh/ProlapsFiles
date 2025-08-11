require('mysqloo')

function mwLib.reconnectDB()

	mwLib.warning('DB: Connecting...')

	local config = CFG.db
	local db = mysqloo.CreateDatabase(config.host, config.user, config.pass, config.main, config.port, config.socket)
	function db:onConnected()
		mwLib.complete('DB: Connected.')
		mwLib.db = db
		-- mwLib.db:RunQuery('SET NAMES utf8')

		timer.Create('mwLib.db.heartbeat', 30, 0, function()
			local status = mwLib.db:status()
			if status ~= mysqloo.DATABASE_CONNECTED and status ~= mysqloo.DATABASE_CONNECTED then
				mwLib.reconnectDB()
				timer.Remove('mwLib.db.heartbeat')
			end
		end)
		hook.Run('mwLib.db.init', db)
	end

	function db:onConnectionFailed(data)
		mwLib.error('DB: Connection failed: '..data)

		mwLib.warning('DB: Reconnecting in 30 seconds...')
		timer.Simple(30, mwLib.reconnectDB)

		timer.Remove('mwLib.db.heartbeat')
	end

end
mwLib.reconnectDB()

hook.Add('mwLib.db.init', 'mwLib.db.tick', function()

	mwLib.db:RunQuery([[
		CREATE TABLE IF NOT EXISTS ]] .. CFG.db.main .. [[.mwLib_queue (
		serverID VARCHAR(30) NOT NULL,
		event VARCHAR(30) NOT NULL,
		data TEXT
	) ENGINE=INNODB CHARACTER SET utf8 COLLATE utf8_general_ci
	]])

end)

--
-- DB SOCKET (kinda)
--

function mwLib.sendCmd(serverID, event, data)

	mwLib.db:PrepareQuery('insert into ' .. CFG.db.main .. '.mwLib_queue(serverID, event, data) values(?, ?, ?)', { serverID, event, util.TableToJSON(data or {}) })

end

local servers = CFG.serversList or {'cdev3', 'pastera'}
function mwLib.sendCmdToOthers(event, data)
	for _,serverID in ipairs(servers) do
		if serverID ~= CFG.serverID then
			mwLib.sendCmd(serverID, event, data)
		end
	end
end

if CFG.dbTick then
	timer.Create('mwLib.db.tick', CFG.dbTickTime, 0, function()
		if not mwLib.db or mwLib.db:status() ~= mysqloo.DATABASE_CONNECTED then return end
		mwLib.db:PrepareQuery('select event, data from ' .. CFG.db.main .. '.mwLib_queue where serverID = ?', { CFG.serverID }, function(q, st, res)
			if st and istable(res) then
				if #res > 0 then
					for i, v in ipairs(res) do
						if v.event then
							hook.Run('mwLib.event:' .. v.event, isstring(v.data) and util.JSONToTable(v.data) or {})
							if CFG.dev then
								mwLib.dmsg('DB hook: ' .. v.event)
							end
						end
					end
					mwLib.db:PrepareQuery('delete from ' .. CFG.db.main .. '.mwLib_queue where serverID = ?', { CFG.serverID })
				end
			else
				ErrorNoHalt('DB ERROR: ' .. res)
			end
		end)
	end)
end
