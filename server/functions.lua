xPlayer = {}
xPlayer.Currency = {}
xPlayer.Functions = {}
xPlayer.Data = {}

function getDataObject()
    return xPlayer
end

xPlayer.GetPlayerIdentifierFromType = function(type, source)
    local identifierCount = GetNumPlayerIdentifiers(source)
    for count = 0, identifierCount do
        local identifier = GetPlayerIdentifier(source, count)
        if identifier and string.find(identifier, type) then
            return identifier
        end
    end
    return nil
end

xPlayer.Currency.Update = function(player)
    local player = tonumber(player)
    local license = xPlayer.GetPlayerIdentifierFromType("license", player)
    
    exports.oxmysql:query("SELECT cash, bank , xp , rank FROM player_data WHERE license = ?", {license}, function(result)
          if result then
            local cash = result[1].cash
            local bank = result[1].bank
            local xp = result[1].xp
            local rank = result[1].rank
            xPlayer.Data[player].cash = cash
            xPlayer.Data[player].bank = bank
            xPlayer.Data[player].xp = xp
            xPlayer.Data[player].rank = rank
            Citizen.Wait(500)
            TriggerClientEvent('UpdateMoney', player, cash, bank, rank, xp)   
        end
    end)
end

xPlayer.Currency.Add = function(amount, player, to)
    local amount = tonumber(amount)
    local player = tonumber(player)
    if to == "bank" then
        exports.oxmysql:query("UPDATE player_data SET bank = bank + ? WHERE license = ?", {amount, xPlayer.GetPlayerIdentifierFromType("license", player)})
        Citizen.Wait(500)       
    elseif to == "cash" then
        exports.oxmysql:query("UPDATE player_data SET cash = cash + ? WHERE license = ?", {amount, xPlayer.GetPlayerIdentifierFromType("license", player)})
        Citizen.Wait(500)       
    elseif to == "xp" then
        exports.oxmysql:query("UPDATE player_data SET xp = xp + ? WHERE license = ?", {amount, xPlayer.GetPlayerIdentifierFromType("license", player)})
        Citizen.Wait(500)       
    elseif to == "rank" then
        exports.oxmysql:query("UPDATE player_data SET rank = rank + ? WHERE license = ?", {amount, xPlayer.GetPlayerIdentifierFromType("license", player)})
        Citizen.Wait(500)       
    end
    xPlayer.Currency.Update(player)
    
end

xPlayer.Currency.Remove = function(amount, player, from)
    local amount = tonumber(amount)
    local player = tonumber(player)
    if from == "bank" then
        exports.oxmysql:query("UPDATE player_data SET bank = bank - ? WHERE license = ?", {amount, xPlayer.GetPlayerIdentifierFromType("license", player)})
        Citizen.Wait(500)        
    elseif from == "cash" then
        exports.oxmysql:query("UPDATE player_data SET cash = cash - ? WHERE license = ?", {amount, xPlayer.GetPlayerIdentifierFromType("license", player)})
        Citizen.Wait(500)        
    elseif to == "xp" then
        exports.oxmysql:query("UPDATE player_data SET xp = xp - ? WHERE license = ?", {amount, xPlayer.GetPlayerIdentifierFromType("license", player)})
        Citizen.Wait(500)       
    elseif to == "rank" then
        exports.oxmysql:query("UPDATE player_data SET rank = rank - ? WHERE license = ?", {amount, xPlayer.GetPlayerIdentifierFromType("license", player)})
        Citizen.Wait(500)        
    end
    xPlayer.Currency.Update(player)
end

xPlayer.Currency.Withdraw = function(amount, player)
    local amount = tonumber(amount)
    local player = tonumber(player)
    if xPlayer.Data[player].bank >= amount then
        exports.oxmysql:query("UPDATE player_data SET bank = bank - ? WHERE license = ?", {amount, xPlayer.GetPlayerIdentifierFromType("license", player)})
        exports.oxmysql:query("UPDATE player_data SET cash = cash + ? WHERE license = ?", {amount, xPlayer.GetPlayerIdentifierFromType("license", player)})
        Citizen.Wait(500)
        xPlayer.functions.update(player)
        return true
    end
    return false
end

xPlayer.Currency.Deposit = function(amount, player)
    local amount = tonumber(amount)
    local player = tonumber(player)
    if xPlayer.Data[player].cash >= amount then
        exports.oxmysql:query("UPDATE player_data SET cash = cash - ? WHERE license = ?", {amount, xPlayer.GetPlayerIdentifierFromType("license", player)})
        exports.oxmysql:query("UPDATE player_data SET bank = bank + ? WHERE license = ?", {amount, xPlayer.GetPlayerIdentifierFromType("license", player)})
        Citizen.Wait(500)
        xPlayer.Currency.Update(player)
        return true
    end
    return false
end

xPlayer.Currency.TransferBank = function(amount, player, target)
    local amount = tonumber(amount)
    local player = tonumber(player)
    local target = tonumber(target)
    if player == target then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            args = {"Error", "You can't send money to yourself."}
        })
        return false
    elseif GetPlayerPing(target) == 0 then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            args = {"Error", "That player does not exist."}
        })
        return false
    elseif amount <= 0 then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            args = {"Error", "You can't send that amount."}
        })
        return false
    elseif xPlayer.Data[player].bank < amount then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            args = {"Error", "You don't have enough money."}
        })
        return false
    else
        MySQL.query.await("UPDATE player_data SET bank = bank - ? WHERE license = ?", {amount, GetPlayerIdentifierFromType("license", player)})
        xPlayer.Currency.Update(player)
        MySQL.query.await("UPDATE player_data SET bank = bank + ? WHERE license = ?", {amount, GetPlayerIdentifierFromType("license", target)})
        xPlayer.Currency.Update(target)
        TriggerClientEvent("chat:addMessage", player, {
            color = {0, 255, 0},
            args = {"Success", "You paid " .. GetPlayerName(target) .. " $" .. amount .. "."}
        })
        TriggerClientEvent("chat:addMessage", targetId, {
            color = {0, 255, 0},
            args = {"Success", GetPlayerName(player) .. " sent you $" .. amount .. "."}
        })
        return true
    end
end

xPlayer.Functions.DiscordSendMsg = function(name, message)    
    if message == nil or message == '' then return FALSE end
    PerformHttpRequest('https://discord.com/api/webhooks/1331317019374780456/rojJClbugM-vZoINFiY6snLkwLnLi25l7wEel8H0RPwIk6TXzQBFvN9_GtjeZUlGC0fx', function(err, text, headers) end, 'POST', json.encode({username = name, content = message}), { ['Content-Type'] = 'application/json' })
end
