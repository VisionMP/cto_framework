RegisterCommand("addMoney", function(source, args, raw)
    local player = source
    local amount = args[1]
    local to = args[2]
    xPlayer.Currency.Add(amount, source, to)
    print('Added:'..amount)
    xPlayer.Functions.DiscordSendMsg(GetPlayerName(player), 'Cash Commmand - Cash Added:'..amount)
end)

RegisterCommand("removeMoney", function(source, args, raw)
    local player = source
    local amount = args[1]
    local to = args[2]
    xPlayer.Currency.Remove(amount, source, to)
    print('Removed:'..amount)
    xPlayer.Functions.DiscordSendMsg(GetPlayerName(player), 'Cash Commmand - Cash Removed:'..amount)
end)