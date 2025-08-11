mwLib.registerTests({
	name = 'Basic database usage',
	run = function(finish)
		mwLib.func.chain({
			function(done)
				mwLib.db:RunQuery('drop table if exists tester')
				mwLib.db:RunQuery('create table if not exists tester(id varchar(32))', done)
			end,
			function(done, q, st, data)
				mwLib.db:PrepareQuery('insert into tester(id) values(?)', {'it works'}, done)
			end,
			function(done)
				mwLib.db:RunQuery('select * from tester', done)
			end,
			function(done, q, st, data)
				finish(data[1].id ~= 'it works' and 'Data mismatch')
			end,
		})
	end,
}, 'mwLib')
