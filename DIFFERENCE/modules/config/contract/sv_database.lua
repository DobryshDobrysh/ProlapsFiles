hook.Add('mwLib.db.init', 'mwLib.config', function()
	mwLib.db:RunQuery([[
		CREATE TABLE IF NOT EXISTS mwLib_config (
			id VARCHAR(255) NOT NULL,
			value TEXT,
				PRIMARY KEY (id)
		) ENGINE=INNODB CHARACTER SET utf8 COLLATE utf8_general_ci
	]])
end)

function mwLib.config.getDatabaseValue(id, callback)
	mwLib.db:PrepareQuery('select from mwLib_config where id = ?', { id }, function(q, st, rows)
		callback(rows[1] and rows[1].value or nil)
	end)
end

function mwLib.config.setDatabaseValue(id, value, callback)
	mwLib.db:PrepareQuery('update mwLib_config set value = ? where id = ?', { value, id }, callback and function(q, st)
		callback(st and q:affectedRows() > 0)
	end)
end
