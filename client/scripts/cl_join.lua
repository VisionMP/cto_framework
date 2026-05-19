-- client.lua
AddEventHandler('playerSpawned', function()
    -- Teleport instantly
   TriggerServerEvent('teleportOnJoin:request')

    -- Wait for model to fully load before giving weapons
    Wait(3000) -- 1.5 seconds is usually enough, adjust if needed

    TriggerServerEvent('giveLoadoutOnJoin:request')
end)