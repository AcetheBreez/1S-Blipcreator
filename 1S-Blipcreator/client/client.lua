local activeBlips = {}
local Framework = nil

Citizen.CreateThread(function()
    if Config.Framework == 'esx' then
        while Framework == nil do
            TriggerEvent('esx:getSharedObject', function(obj) Framework = obj end)
            Citizen.Wait(0)
        end
    elseif Config.Framework == 'qbcore' then
        Framework = exports['qb-core']:GetCoreObject()
    elseif Config.Framework == 'qbox' then
        Framework = exports['qbox-core']:GetCoreObject()
    end
end)

RegisterCommand('blipscreator', function()
    TriggerServerEvent('1S-Blips:adminCheck')
end, false)

RegisterNetEvent('1S-Blips:adminCheckResult', function(isAdmin)
    if not isAdmin then
        lib.notify({title = 'Access Denied', description = 'You do not have permission to use this command.', type = 'error'})
        return
    end

    local input = lib.inputDialog('Blip Options', {
        {type = 'select', label = 'Blip System', options = {
            {label = 'Create A Blip', value = 'create'},
            {label = 'Delete A Blip', value = 'delete'}
        }}
    })

    if input then
        if input[1] == 'create' then
            local createInput = lib.inputDialog('Create Blip', {
                {type = 'input', label = 'Blip Name', description = 'Enter the blip name. It will show on the map!', required = true},
                {type = 'number', label = 'Blip Sprite', description = 'Enter the blip sprite number ('..Config.BlipOptions.sprite.min..' - '..Config.BlipOptions.sprite.max..')', icon = 'hashtag'},
                {type = 'number', label = 'Blip Color', description = 'Enter the blip color number ('..Config.BlipOptions.color.min..' - '..Config.BlipOptions.color.max..')', icon = 'palette'}
            })

            if createInput then
                local playerPed = PlayerPedId()
                local coords = GetEntityCoords(playerPed)
                TriggerServerEvent('1S-Blips:createBlip', createInput[1], tonumber(createInput[2]), tonumber(createInput[3]), coords)
                lib.notify({title = 'Blip Created', description = 'Your blip "' .. createInput[1] .. '" has been added to the map.', type = 'success'})
            else
                lib.notify({title = 'Error', description = 'Input was cancelled or invalid.', type = 'error'})
            end
        elseif input[1] == 'delete' then
            TriggerServerEvent('1S-Blips:fetchBlipList')
        end
    else
        lib.notify({title = 'Error', description = 'Input was cancelled or invalid.', type = 'error'})
    end
end)

RegisterNetEvent('1S-Blips:showBlipList', function(blips)
    local blipOptions = {}
    if type(blips) == 'table' then
        for _, blip in ipairs(blips) do
            if type(blip) == 'table' and blip.id and blip.name then
                table.insert(blipOptions, {label = blip.name .. " (ID: " .. tostring(blip.id) .. ")", value = blip.id})
            end
        end
        local deleteInput = lib.inputDialog('Delete Blip', {
            {type = 'select', label = 'Select Blip to Delete', description = 'Choose a blip to delete', options = blipOptions}
        })

        if deleteInput then
            local blipId = tonumber(deleteInput[1])
            if blipId then
                TriggerServerEvent('1S-Blips:deleteBlip', blipId)
                lib.notify({title = 'Blip Deleted', description = 'Blip ID ' .. blipId .. ' has been removed.', type = 'success'})
            else
                lib.notify({title = 'Error', description = 'Invalid Blip ID.', type = 'error'})
            end
        else
            lib.notify({title = 'Error', description = 'Input was cancelled or invalid.', type = 'error'})
        end
    else
        lib.notify({title = 'Error', description = 'Failed to fetch blip list.', type = 'error'})
    end
end)

RegisterNetEvent('1S-Blips:createBlipOnClient', function(blipId, blipName, blipSprite, blipColor, coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, blipSprite)
    SetBlipColour(blip, blipColor)
    SetBlipScale(blip, 1.0)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(blipName)
    EndTextCommandSetBlipName(blip)
    activeBlips[blipId] = blip
end)

RegisterNetEvent('1S-Blips:removeBlipOnClient', function(blipId)
    local blip = activeBlips[blipId]
    if blip then
        RemoveBlip(blip)
        activeBlips[blipId] = nil
        lib.notify({title = 'Blip Removed', description = 'Blip ID ' .. blipId .. ' has been deleted from the map.', type = 'success'})
    end
end)

AddEventHandler('playerSpawned', function()
    TriggerServerEvent('1S-Blips:loadBlips')
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        TriggerServerEvent('1S-Blips:loadBlips')
    end
end)
