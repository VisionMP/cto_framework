-- teleportOnJoin.lua
local spawnCoords = vector3(-1628.45, -1017.28, 13.15)
local spawnHeading = 308.08

-- Server-side hook
RegisterNetEvent('teleportOnJoin:request')
AddEventHandler('teleportOnJoin:request', function()
    local src = source
    local ped = GetPlayerPed(src)
    if ped then
        SetEntityCoords(ped, spawnCoords.x, spawnCoords.y, spawnCoords.z, false, false, false, true)
        SetEntityHeading(ped, spawnHeading)
    end
end)