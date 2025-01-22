AddEventHandler('playerDropped', function(reason)
    xPlayer.Functions.DiscordSendMsg('Chill Theft Auto', GetPlayerName(source) .. ' left (' .. reason .. ')')
end)

local function OnPlayerConnecting(name, setKickReason, deferrals)
  local player = source
  xPlayer.Functions.DiscordSendMsg('Chill Theft Auto', name .. ' connecting...')
end

AddEventHandler("playerConnecting", OnPlayerConnecting)

