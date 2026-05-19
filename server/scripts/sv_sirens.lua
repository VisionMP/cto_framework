RegisterNetEvent("framework:silentSync")
AddEventHandler("framework:silentSync", function(netVeh, state)
    TriggerClientEvent("framework:applySilent", -1, netVeh, state)
end)