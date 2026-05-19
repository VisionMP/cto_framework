-- giveLoadoutOnJoin.lua

local loadout = {
    { weapon = `WEAPON_STUNGUN`, ammo = 1 },
    { weapon = `WEAPON_PISTOL`, ammo = 60 },
    { weapon = `WEAPON_SHOTGUN`, ammo = 30 }
}

RegisterNetEvent('giveLoadoutOnJoin:request')
AddEventHandler('giveLoadoutOnJoin:request', function()
    local src = source
    local ped = GetPlayerPed(src)

    if not ped then return end

    for _, item in ipairs(loadout) do
        GiveWeaponToPed(ped, item.weapon, item.ammo, false, true)
    end

    -- Add flashlight to pistol
    GiveWeaponComponentToPed(ped, `WEAPON_PISTOL`, `COMPONENT_AT_PI_FLSH`)
end)