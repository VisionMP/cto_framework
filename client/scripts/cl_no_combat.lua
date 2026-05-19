CreateThread(function()
    while true do
        Wait(0)

        local ped = PlayerPedId()

        -- Only block melee when ON FOOT
        if not IsPedInAnyVehicle(ped, false) then

            -- B button (melee / shove)
           --DisableControlAction(0, 140, true) -- melee light
           --DisableControlAction(0, 141, true) -- melee heavy
           --DisableControlAction(0, 142, true) -- melee alternate
           --DisableControlAction(0, 37,  true) -- weapon wheel (prevents accidental shove)
            DisableControlAction(0, 347, true) -- B button (controller)

        end
    end
end)