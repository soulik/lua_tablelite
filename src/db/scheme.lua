local sql = require 'lsqlite3'

--[[

schemeName:
	tableName:
		name, type, maxLength, key, refTable, refColumn, default, autoincrement

--]]
local ti, tc = table.insert, table.concat

local function new(schemas)
	assert(type(schemas)=='table')
	local obj = {}

	obj.prepare = function()
		local schemeQuery = {}
		for schemaName, scheme in pairs(schemas) do
			assert(type(schemaName)=='string' and type(scheme)=='table')

			for tableName, tableDef in pairs(scheme) do
				assert(type(tableName)=='string' and type(tableDef)=='table')

				local tableQuery, columnQuery = {}, {}
				ti(tableQuery, ([[CREATE TABLE IF NOT EXISTS %s.%s (]]):format(schemaName, tableName))

				for _, column in ipairs(tableDef) do
					assert(type(column.name)=='string' and type(column.type)=='string')

					local columnKey = ""
					local columnType = column.type:upper()
					local columnDefault = ""

					if type(column.maxLength)=='number' then
						columnType = columnType..('(%d)'):format(tonumber(column.maxLength))
					end
					if type(column.key)=='string' then
						if column.key == 'primary' then
							columnKey = ' PRIMARY KEY'
							
							if type(column.conflict)=='string' then
								columnKey = columnKey..' '..conflict
							end
							if column.autoincrement then
								columnKey = columnKey..' AUTOINCREMENT'
							end
						elseif column.key == 'unique' then
							columnKey = ' UNIQUE'
						elseif column.key == 'foreign' and type(column.refTable)=='string' then
							local refColumn = ""
							if type(column.refColumn)=='string' then
								refColumn = ("(%s)"):format(column.refColumn)
							end
							columnKey = (' REFERENCES %s%s'):format(column.refTable, refColumn)
						end
					end
					if column.default then
						columnDefault = (' DEFAULT %s'):format(tostring(column.default))
					end
					ti(columnQuery, ([[%s %s%s%s]]):format(column.name, columnType, columnKey, columnDefault))
				end

				if type(tableDef.primaryKey)=='table' then
					local columns = {}
					for _, columnName in ipairs(tableDef.primaryKey) do
						ti(columns, columnName)
					end
					ti(columnQuery, ("PRIMARY KEY (%s)"):format(tc(columns, ',')))
				end

				if type(tableDef.constraints)=='table' then
					local constraints = {}
					for _, constraint in ipairs(tableDef.constraints) do
						ti(constraints, constraint)
					end
					ti(columnQuery, tc(constraints, ','))
				end

				ti(tableQuery, tc(columnQuery, ','))
				ti(tableQuery, ");\n")

				if type(tableDef.indices)=='table' then
					local indices = {}

					for indexName, indexDef in pairs(tableDef.indices) do
						assert(type(indexDef.table)=='string')
						assert(type(indexDef.columns)=='table')

						local uniqueIndex = ""
						local indexWhere = ""

						if indexDef.unique then
							uniqueIndex = " UNIQUE"
						end
						local columns = {}
						for _, column in ipairs(indexDef.columns) do
							table.insert(columns, column)
						end
						if type(indexDef.where)=='string' then
							indexWhere = (" WHERE %s"):format(indexDef.where)
						end
						ti(indices, ("CREATE%s INDEX IF NOT EXISTS %s.%s_%s ON %s(%s)%s"):format(uniqueIndex, schemaName, tableName, indexName, indexDef.table, tc(columns, ','), indexWhere))
					end
					if #indices>0 then
						ti(indices, '');
						ti(tableQuery, tc(indices, ";\n"))
					end
				end

				ti(schemeQuery, tc(tableQuery))
			end
		end
		return tc(schemeQuery)
	end

	obj.apply = function(db)
		local s = obj.prepare()
		--print(s)
		db(s)
	end

	return obj
end

return {
	new = new,
}