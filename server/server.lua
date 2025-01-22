RegisterNetEvent('GetMoney')
AddEventHandler('GetMoney', function()
    local player = source
    local license = xPlayer.GetPlayerIdentifierFromType("license", player)
    local cash = nil
    local bank = nil
    local rank = nil
    local xp = nil
   
    exports.oxmysql:query("SELECT cash, bank FROM player_data WHERE license = ?", {license}, function(result)
        if result then
            if not result[1] then
                exports.oxmysql:query("INSERT INTO player_data (license, cash, bank, xp, rank) VALUES (?, ?, ?, ?, ?)", {license, Server.Config.NewPlayerCash, Server.Config.NewPlayerBank, Server.Config.NewPlayerXp, Server.Config.NewPlayerRank})
                Citizen.Wait(500) 
                
                local cash = result[1].cash
                local bank = result[1].bank  
                local rank = result[1].rank                
                local xp = result[1].xp
            end           
            xPlayer.Data[player] = {["cash"] = cash, ["bank"] = bank, ["rank"] = rank, ["xp"] = xp}
            xPlayer.Currency.Update(player)
            TriggerClientEvent('UpdateMoney', source, cash, bank, rank, xp)
        end
    end)
end)