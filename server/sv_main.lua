---------------------------------------------------------------------------
-- Framework support: ESX, QBCore or standalone (ACE permissions only)
---------------------------------------------------------------------------
local frameworkName, ESX, QBCore

-- Detected on first use, so start order in server.cfg does not matter.
local function detectFramework()
    if frameworkName then return frameworkName end

    local wanted = Config.Framework
    if wanted == 'auto' then
        if GetResourceState('es_extended') == 'started' then
            wanted = 'esx'
        elseif GetResourceState('qb-core') == 'started' then
            wanted = 'qbcore'
        else
            wanted = 'standalone'
        end
    end

    if wanted == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
    elseif wanted == 'qbcore' then
        QBCore = exports['qb-core']:GetCoreObject()
    end

    frameworkName = wanted
    print(('[lc-commlist] Framework: %s'):format(wanted))
    return wanted
end

local function isAdmin(source)
    if source == 0 then return true end -- server console

    if Config.AllowAce and IsPlayerAceAllowed(source, Config.AcePermission) then
        return true
    end

    local framework = detectFramework()
    if framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return false end
        local group = xPlayer.getGroup()
        for _, allowed in ipairs(Config.ESXAdminGroups) do
            if group == allowed then return true end
        end
    elseif framework == 'qbcore' then
        for _, permission in ipairs(Config.QBCoreAdminPermissions) do
            if QBCore.Functions.HasPermission(source, permission) then return true end
        end
    end

    return false
end

-- Chat message to a player (or the server console when source is 0)
local function reply(source, kind, text)
    if source == 0 then
        print(('[lc-commlist] %s: %s'):format(kind, text))
        return
    end
    TriggerClientEvent('chat:addMessage', source, {
        args = { kind, text }
    })
end

---------------------------------------------------------------------------
-- Database
---------------------------------------------------------------------------
if Config.AutoCreateTables then
    MySQL.ready(function()
        MySQL.Async.execute([[
            CREATE TABLE IF NOT EXISTS `commands` (
                `id` INT AUTO_INCREMENT PRIMARY KEY,
                `command` VARCHAR(255) NOT NULL,
                `commandText` VARCHAR(255) DEFAULT 'No description provided'
            )
        ]], {}, function() end)
        MySQL.Async.execute([[
            CREATE TABLE IF NOT EXISTS `keybinds` (
                `id` INT AUTO_INCREMENT PRIMARY KEY,
                `keybind` VARCHAR(255) NOT NULL,
                `keybindText` VARCHAR(255) DEFAULT 'No keybind description provided'
            )
        ]], {}, function() end)
    end)
end

local function getCommands(cb)
    MySQL.Async.fetchAll("SELECT * FROM commands", {}, function(result)
        if not result or #result == 0 then
            print("No commands found or error fetching commands!")
        end
        cb(result)
    end)
end

local function getKeybinds(cb)
    MySQL.Async.fetchAll("SELECT * FROM keybinds", {}, function(result)
        if not result or #result == 0 then
            print("No keybinds found or error fetching keybinds!")
        end
        cb(result)
    end)
end

-- Loads both tables and keeps only usable rows (blank command/keybind rows are skipped).
local function getValidLists(cb)
    getCommands(function(commands)
        getKeybinds(function(keybinds)
            local validCommands = {}
            for _, cmd in ipairs(commands) do
                if cmd.command and cmd.command ~= "" then
                    table.insert(validCommands, cmd)
                else
                    print("Invalid command skipped: ", json.encode(cmd))  -- Debugging invalid command
                end
            end

            local validKeybinds = {}
            for _, bind in ipairs(keybinds) do
                if bind.keybind and bind.keybind ~= "" then
                    table.insert(validKeybinds, bind)
                else
                    print("Invalid keybind skipped: ", json.encode(bind))  -- Debugging invalid keybind
                end
            end

            cb(validCommands, validKeybinds)
        end)
    end)
end

-- After an admin adds an entry, update the window for every player who has it open right now.
-- Players with the window closed simply see the new entry the next time they open it.
local function refreshOpenWindows()
    getValidLists(function(validCommands, validKeybinds)
        TriggerClientEvent('Lcboss77:refreshIfOpen', -1, validCommands, validKeybinds)
    end)
end

---------------------------------------------------------------------------
-- Commands
---------------------------------------------------------------------------
RegisterCommand("addcommand", function(source, args)
    if not isAdmin(source) then
        reply(source, "Error", "You do not have permission to use this command.")
        return
    end

    local newCommand = args[1]
    local newCommandText = table.concat(args, " ", 2)
    if newCommandText == "" then
        newCommandText = 'No description provided'
    end

    if not newCommand then
        reply(source, "Error", "Command text cannot be empty!")
        return
    end

    MySQL.Async.execute("INSERT INTO commands (command, commandText) VALUES (@command, @commandText)", {
        ['@command'] = newCommand,
        ['@commandText'] = newCommandText
    }, function(rowsChanged)
        if rowsChanged > 0 then
            reply(source, "Success", "Command added successfully!")
            refreshOpenWindows()
        else
            reply(source, "Error", "Failed to add command!")
        end
    end)
end, false)

RegisterCommand("addkeybind", function(source, args)
    if not isAdmin(source) then
        reply(source, "Error", "You do not have permission to use this command.")
        return
    end

    local newKeybind = args[1]
    local newKeybindText = table.concat(args, " ", 2)
    if newKeybindText == "" then
        newKeybindText = 'No keybind description provided'
    end

    if not newKeybind then
        reply(source, "Error", "Keybind cannot be empty!")
        return
    end

    print("Adding keybind:", newKeybind, newKeybindText)

    MySQL.Async.execute("INSERT INTO keybinds (keybind, keybindText) VALUES (@keybind, @keybindText)", {
        ['@keybind'] = newKeybind,
        ['@keybindText'] = newKeybindText
    }, function(rowsChanged)
        print("Rows Changed:", rowsChanged)

        if rowsChanged > 0 then
            reply(source, "Success", "Keybind added successfully!")
            refreshOpenWindows()
        else
            reply(source, "Error", "Failed to add keybind!")
        end
    end)
end, false)

RegisterNetEvent('Lcboss77:requestCommands')
AddEventHandler('Lcboss77:requestCommands', function()
    local _source = source
    if _source then
        getValidLists(function(validCommands, validKeybinds)
            if #validCommands > 0 or #validKeybinds > 0 then
                TriggerClientEvent('Lcboss77:showUpdatedCommands', _source, validCommands, validKeybinds)
            else
                print("Error: No valid commands or keybinds available to send.")
                TriggerClientEvent('Lcboss77:showUpdatedCommands', _source, {}, {})  -- Send empty data to client
            end
        end)
    end
end)
