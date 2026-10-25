local isUIOpen = false

RegisterNetEvent('Lcboss77:showUpdatedCommands')
AddEventHandler('Lcboss77:showUpdatedCommands', function(commands, keybinds)
    isUIOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "showCommands",
        commands = commands,
        keybinds = keybinds
    })
end)

-- An admin just added an entry: update the window only if this player has it open.
RegisterNetEvent('Lcboss77:refreshIfOpen')
AddEventHandler('Lcboss77:refreshIfOpen', function(commands, keybinds)
    if not isUIOpen then return end
    SendNUIMessage({
        type = "showCommands",
        commands = commands,
        keybinds = keybinds
    })
end)

RegisterCommand("commands", function()
    TriggerServerEvent('Lcboss77:requestCommands')
end, false)

RegisterNUICallback("closeUI", function(data, cb)
    isUIOpen = false
    SetNuiFocus(false, false)
    cb("ok")
end)
