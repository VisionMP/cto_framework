--AddEventHandler("playerConnecting", OnPlayerConnecting)
function OnPlayerConnecting(name, setKickReason, deferrals)
    local player = source   
    local license = xPlayer.GetPlayerIdentifierFromType("license", player)
    deferrals.defer()      
    -- mandatory wait!    
    --deferrals.update(string.format("Hello %s. Fetching Database.", name))
    --Wait(5000)   
    
        deferrals.update(string.format("%s: Cash $" .. cash .. " Bank $ ".. bank, name))
        xPlayer.Functions.DiscordSendMsg(name,"Cash: "..xPlayer.Data[player].cash)
        Wait(10000)  
        deferrals.done()      
end

AddEventHandler('playerActivated', function()
    xPlayer.Functions.DiscordSendMsg('SYSTEM', GetPlayerName(source) .. ' joined.')
  end)
  
  AddEventHandler('playerDropped', function(reason)
    xPlayer.Functions.DiscordSendMsg('SYSTEM', GetPlayerName(source) .. ' left (' .. reason .. ')')
  end)

RegisterNetEvent('GetMoney')
AddEventHandler('GetMoney', function()
    local player = source
    local license = xPlayer.GetPlayerIdentifierFromType("license", player)
    local cash = nil
    local bank = nil
   
    exports.oxmysql:query("SELECT cash, bank FROM player_data WHERE license = ?", {license}, function(result)
        if result then
            if not result[1] then
                exports.oxmysql:query("INSERT INTO player_data (license, cash, bank, xp, rank) VALUES (?, ?, ?, ?, ?)", {license, Server.Config.NewPlayerCash, Server.Config.NewPlayerBank, Server.Config.NewPlayerXp, Server.Config.NewPlayerRank})
                Citizen.Wait(500) 
                
                local cash = result[1].cash
                local bank = result[1].bank  
            end           
            xPlayer.Data[player] = {["cash"] = cash, ["bank"] = bank}
            xPlayer.Currency.Update(player)
            TriggerClientEvent('UpdateMoney', source, cash, bank)
        end
    end)
end)




