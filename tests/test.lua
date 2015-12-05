package.data_path = 'data'
local db = require 'db'
local scheme = require 'db/scheme'

local s1 = scheme.new {
	['main'] = {
		['config'] = {
			{name = 'id', type='INTEGER', key='primary', autoincrement=true},
			{name = 'name', type='TEXT', maxLength = 30},
			{name = 'version', type='INTEGER', default=0},
			{name = 'modTime', type='INTEGER', default='CURRENT_TIMESTAMP'},
			{name = 'parent', type='INTEGER', default=0, key='foreign', refTable='config', refColumn='id'},
			{name = 'value', type='TEXT'},
			constraints = {
				'UNIQUE (parent, id, version) ON CONFLICT FAIL',
				'UNIQUE (parent, name, version) ON CONFLICT FAIL',
			},
		},
	},
}

local d = db.new()
s1.apply(d)

local code = d('INSERT INTO config (name, value) VALUES (:name, :value)', {name='name 2', value='Abcdef4'})
--[[
WITH old_config(id, parent, version) AS (SELECT id, parent, version FROM config WHERE name=:name AND parent=0)
VALUES (old_config.id, old_config.parent, :name, :value, old_config.version+1)
--]]
if code == db.sql.CONSTRAINT then
	local code = d([[
INSERT INTO config (id, parent, name, value, version)
SELECT id, parent, (version+1), name, :value FROM config WHERE name=:name AND parent=0;
]], {name='name 2', value='Abcdef4'})
	print(code)
end

print(code)

--local code, items = d('SELECT * FROM config WHERE name="name 2";', {name='name 2', value='Abcdef4'})
local code, items = d('SELECT * FROM config;')
print(code)
--local code, items = d('SELECT id, parent, version FROM config WHERE name="name 2" AND parent=0')

for _, item in ipairs(items) do
	local t = {}
	for k,v in pairs(item) do
		table.insert(t, ('%q = %q'):format(k, v))
	end
	print(table.concat(t, ','))
end
