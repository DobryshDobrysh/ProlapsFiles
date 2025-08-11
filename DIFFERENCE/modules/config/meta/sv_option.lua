local Option = mwLib.meta.getOrCreate('configOption')

function Option:Load(callback)
	mwLib.config.getDatabaseValue(self.id, function(value)
		self:Set(value)

		if callback then
			callback(value)
		end
	end)
end

function Option:Save(callback)
	mwLib.config.setDatabaseValue(self.id, self.value, function()
		self:Emit('changed', self.value)

		if callback then
			callback(success)
		end
	end)
end
