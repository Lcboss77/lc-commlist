Config = {}

-- Which framework to use for the admin check.
--   'auto'       -> detects es_extended (ESX) or qb-core (QBCore), otherwise standalone
--   'esx'        -> force ESX
--   'qbcore'     -> force QBCore (also works with Qbox through its qb-core bridge)
--   'standalone' -> no framework, admins are decided by ACE permissions only
-- Tip: with 'auto', start lc-commlist AFTER your framework in server.cfg.
Config.Framework = 'auto'

-- ESX: players in these groups can use /addcommand and /addkeybind
Config.ESXAdminGroups = { 'admin', 'superadmin' }

-- QBCore: players with any of these permissions can use /addcommand and /addkeybind
Config.QBCoreAdminPermissions = { 'admin', 'god' }

-- ACE permission (works in every mode, and is the only check in standalone mode).
-- Give it to your admins in server.cfg, for example:
--   add_ace group.admin lc-commlist.admin allow
--   add_principal identifier.license:YOUR_LICENSE group.admin
Config.AllowAce = true
Config.AcePermission = 'lc-commlist.admin'

-- Create the `commands` and `keybinds` tables automatically when the resource starts.
-- (You can still import commands.sql by hand and set this to false.)
Config.AutoCreateTables = true
