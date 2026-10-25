# lc-commlist

In-game window that lists every command and keybind on your server, read live from your database.

Works with **ESX**, **QBCore** (and Qbox through its qb-core bridge) and **standalone** servers.

Live demo: https://lcboss77.github.io/lc-commlist-demo/

## Commands

| Command | Who | What it does |
|---|---|---|
| `/commands` | everyone | Opens the list (Commands and Keybinds tabs) |
| `/addcommand <command> <description...>` | admins | Adds a command to the list |
| `/addkeybind <key> <description...>` | admins | Adds a keybind to the list |

When an admin adds an entry, any player who has the window open sees it appear at once.

## Install

1. Put the `lc-commlist` folder in your resources.
2. Make sure **oxmysql** is installed and running.
3. Add to `server.cfg`, **after** your framework and oxmysql:
   ```
   ensure oxmysql
   ensure es_extended   # or qb-core, or neither for standalone
   ensure lc-commlist
   ```
4. The `commands` and `keybinds` tables are created automatically on first start.
   (Prefer to do it by hand? Import `commands.sql` and set `Config.AutoCreateTables = false`.)

## Who counts as an admin

Set in `config.lua`:

| Mode | Admin check |
|---|---|
| ESX | player group is in `Config.ESXAdminGroups` (default: `admin`, `superadmin`) |
| QBCore | player has a permission in `Config.QBCoreAdminPermissions` (default: `admin`, `god`) |
| Standalone | ACE permission `lc-commlist.admin` |
| Any mode | the server console, and anyone with the ACE permission (can be turned off with `Config.AllowAce = false`) |

Give the ACE permission in `server.cfg`:
```
add_ace group.admin lc-commlist.admin allow
add_principal identifier.license:YOUR_LICENSE group.admin
```

`Config.Framework = 'auto'` detects ESX or QBCore for you. Force one with `'esx'`, `'qbcore'` or `'standalone'`.

## Requirements
- oxmysql
- ESX or QBCore (optional: standalone works without either)

## Support
Questions, bugs or ideas: join the Discord, https://discord.gg/vea5eC334Z

## Performance
No loops or threads. The script does nothing until a player runs `/commands` (or an admin adds an entry), so it should use no resource time while idle.

## License
See `LICENSE`: free to use on your own server, no reselling or redistributing.

By Lcboss77.
