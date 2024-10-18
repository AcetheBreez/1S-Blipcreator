local Framework = nil


if Config.Framework == 'esx' then
    TriggerEvent('esx:getSharedObject', function(obj) Framework = obj end)
elseif Config.Framework == 'qbcore' then
    Framework = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'qbox' then
    Framework = exports['qbox-core']:GetCoreObject()
end


local function getPlayer(source)
    if Config.Framework == 'esx' then
        return Framework.GetPlayerFromId(source)
    elseif Config.Framework == 'qbcore' then
        return Framework.Functions.GetPlayer(source)
    elseif Config.Framework == 'qbox' then
        return Framework.GetPlayer(source)
    end
end


RegisterNetEvent('1S-Blips:adminCheck', function()
    local src = source
    local isAdmin = IsPlayerAceAllowed(src, 'admin') or IsPlayerAceAllowed(src, 'god')

    -- Send back the result to the client
    TriggerClientEvent('1S-Blips:adminCheckResult', src, isAdmin)
end)



RegisterNetEvent('1S-Blips:createBlip', function(blipName, blipSprite, blipColor, coords)
    local src = source
    local xPlayer = getPlayer(src)

    if not xPlayer then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Failed to find player.', type = 'error'})
        return
    end

    exports.oxmysql:insert('INSERT INTO blips (name, sprite, color, x, y, z) VALUES (?, ?, ?, ?, ?, ?)', {
        blipName, blipSprite, blipColor, coords.x, coords.y, coords.z
    }, function(insertId)
        TriggerClientEvent('1S-Blips:createBlipOnClient', -1, insertId, blipName, blipSprite, blipColor, coords)
    end)
end)

RegisterNetEvent('1S-Blips:deleteBlip', function(blipId)
    local src = source
    local xPlayer = getPlayer(src)

    if not xPlayer then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Failed to find player.', type = 'error'})
        return
    end

    if type(blipId) ~= "number" then
        TriggerClientEvent('ox_lib:notify', src, {description = 'Invalid Blip ID.', type = 'error'})
        return
    end

    exports.oxmysql:query('DELETE FROM blips WHERE id = ?', {blipId}, function(result)
        if type(result) == "table" and result.affectedRows then
            local affectedRows = result.affectedRows
            if affectedRows > 0 then
                TriggerClientEvent('1S-Blips:removeBlipOnClient', -1, blipId)
            end
        end
    end)
end)

RegisterNetEvent('1S-Blips:loadBlips', function()
    local src = source

    exports.oxmysql:query('SELECT * FROM blips', {}, function(result)
        if type(result) == "table" then
            TriggerClientEvent('1S-Blips:showBlipMenu', src, result)
            
            for _, blip in ipairs(result) do
                if blip.id and blip.name and blip.sprite and blip.color and blip.x and blip.y and blip.z then
                    TriggerClientEvent('1S-Blips:createBlipOnClient', -1, blip.id, blip.name, blip.sprite, blip.color, vector3(blip.x, blip.y, blip.z))
                end
            end
        else
            TriggerClientEvent('ox_lib:notify', src, {description = 'Failed to load blips.', type = 'error'})
        end
    end)
end)

RegisterNetEvent('1S-Blips:fetchBlipList', function()
    local src = source

    exports.oxmysql:query('SELECT id, name FROM blips', {}, function(result)
        if type(result) == "table" then
            TriggerClientEvent('1S-Blips:showBlipList', src, result)
        else
            TriggerClientEvent('ox_lib:notify', src, {description = 'Failed to fetch blip list.', type = 'error'})
        end
    end)
end)
