------------------------------------------------------------
-- CTO Revive ANY AI (Client)
------------------------------------------------------------

-- Find closest non-player ped
local function GetClosestAIPed()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    local handle, ped = FindFirstPed()
    local success
    local closestPed = nil
    local closestDist = 999.0

    repeat
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
            local dist = #(GetEntityCoords(ped) - playerCoords)
            if dist < closestDist then
                closestDist = dist
                closestPed = ped
            end
        end
        success, ped = FindNextPed(handle)
    until not success

    EndFindPed(handle)
    return closestPed
end

-- Command: revive closest AI
RegisterCommand("reviveai", function()
    local ped = GetClosestAIPed()

    if not ped then
        TriggerEvent("chat:addMessage", {
            color = {255, 0, 0},
            args = {"CTO", "No AI ped nearby to revive."}
        })
        return
    end

    TriggerServerEvent("cto_revive_any:revivePed", NetworkGetNetworkIdFromEntity(ped))
end)

-- Receive revive from server
RegisterNetEvent("cto_revive_any:reviveClient")
AddEventHandler("cto_revive_any:reviveClient", function(netId)
    local ped = NetToPed(netId)
    if not DoesEntityExist(ped) then return end

    ResurrectPed(ped)
    ClearPedTasksImmediately(ped)
    SetEntityHealth(ped, 150)

    TriggerEvent("chat:addMessage", {
        color = {0, 255, 0},
        args = {"CTO", "AI revived."}
    })
end)