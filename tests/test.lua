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
local code = d([[
CREATE VIEW IF NOT EXISTS main.config_view(id, parent, name, value, version, modTime) AS
	SELECT * FROM
		(
			SELECT id, parent, name, value, version, modTime FROM main.config
			GROUP BY parent, name
			ORDER BY version DESC
		)
	ORDER BY parent ASC, name ASC;
]])

local code = d([[
CREATE TRIGGER IF NOT EXISTS main.config_t1 BEFORE INSERT ON config FOR EACH ROW
WHEN EXISTS (
	SELECT parent, name FROM main.config
	WHERE
		parent=COALESCE(NEW.parent, 0) AND
		name=NEW.name AND
		version = (SELECT MAX(version) FROM main.config WHERE parent=COALESCE(NEW.parent, 0) AND name=NEW.name GROUP BY parent, name) AND
		value != NEW.value
	ORDER BY id ASC, version DESC LIMIT 1
)
BEGIN
	INSERT INTO config (parent, name, version, value)
		SELECT parent, name, (version+1), NEW.value FROM config WHERE parent=COALESCE(NEW.parent, 0) AND name=NEW.name ORDER BY version DESC LIMIT 1;
END
]])

local code = d('INSERT INTO config (name, value) VALUES (:name, :value)', {name='name 1', value='Abcdef 1'})

--local code, items = d('SELECT * FROM config WHERE name="name 2";', {name='name 2', value='Abcdef4'})
local code, items = d('SELECT * FROM config_view;')

for _, item in ipairs(items) do
	local t = {}
	for k,v in pairs(item) do
		table.insert(t, ('%q = %q'):format(k, v))
	end
	print(table.concat(t, ','))
end
