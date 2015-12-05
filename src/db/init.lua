local proxy = require 'utils/proxy'
local sql = require 'lsqlite3'
local scheme = require 'db/scheme'

local db
local M 

local ti, tc = table.insert, table.concat

local config = {
	storage = (package.data_path or '.')..'/data.sqlite3',
}


local function new(dbPath)
	local dbPath = dbPath or config.storage

	local obj = {}
	local closed = true
	local db

	local function sql_assert(expr, msg, ...)
		local code = db:errcode()
		if type(msg)=='string' then
			assert(code == sql.OK, msg)
		else
			assert(code == sql.OK, db:errmsg())
		end
		return expr, msg, ...
	end

	local function close()
		if not closed then
			assert(db, [[Database is not connected]])
			if db:isopen() then
				db:close()
			end
			closed = true
		end
	end

	local function open()
		if not closed then
			close()
		end

		if dbPath == true then
			db = assert(sql.open_memory(), ("Couldn't open database file in memory"))
		else
			db = assert(sql.open(dbPath), ("Couldn't open database file: %q"):format(dbPath))
		end
		closed = false
	end

	local function query(q, t)
		assert(type(q)=='string', [[Expected query string]])
		local out = {}

		if not t then
			for row in db:nrows(q) do
				ti(out, row)
			end
			if db:errcode() ~= sql.OK then
				error(db:errmsg())
			end
		elseif type(t)=='table' then
			local statement = sql_assert(db:prepare(q))

			if #t>0 then
				for i, ti in ipairs(t) do
					if i>1 then
						statement:reset()
					end
					statement:bind_values(t1)
					if statement:step() == sql.ROW then
						for row in statement:nrows() do
							ti(out, row)
						end
					end
				end
				statement:finalize()
			else
				statement:bind_names(t)
				if statement:step() == sql.ROW then
					for row in statement:nrows() do
						ti(out, row)
					end
				end
				statement:finalize()
			end
		end
		return db:errcode(), out
	end

	obj.errmsg = function()
		if not closed then
			return db:errmg()
		end
	end
	obj.close = close

	setmetatable(obj, {
		__call = function(_, q, t)
			return query(q, t)
		end,
		__gc = function()
			close()
		end,
	})

	table.proxy(obj)

	open()

	return obj
end

return {
	new = new,
	sql = sql,
}