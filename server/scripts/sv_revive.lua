------------------------------------------------------------
-- CTO Revive ANY AI (Server)
------------------------------------------------------------

RegisterNetEvent("cto_revive_any:revivePed")
AddEventHandler("cto_revive_any:revivePed", function(netId)
    TriggerClientEvent("cto_revive_any:reviveClient", -1, netId)
end)