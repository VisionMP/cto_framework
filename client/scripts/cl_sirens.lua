local silentMode = false

RegisterCommand("silent", function()
    silentMode = not silentMode
    print("Silent Sirens:", silentMode and "ON" or "OFF")

    -- Send state to server
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)

    if veh ~= 0 then
        TriggerServerEvent("framework:silentSync", VehToNet(veh), silentMode)
    end
end)

-- Apply silent mode when server tells us
RegisterNetEvent("framework:applySilent")
AddEventHandler("framework:applySilent", function(netVeh, state)
    local veh = NetToVeh(netVeh)
    if DoesEntityExist(veh) then
        SetVehicleHasMutedSirens(veh, state)
    end
end)

-- Your original loop (kept intact)
CreateThread(function()
    while true do
        if silentMode then
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)

            if veh ~= 0 and IsVehicleSirenOn(veh) then
                SetVehicleHasMutedSirens(veh, true)
            end
        end

        Wait(0)
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        -- Controller B button
       if IsControlJustPressed(0, 177) then
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)

          if veh ~= 0 and IsVehicleSirenOn(veh) then
           silentMode = not silentMode
           print("Silent Sirens:", silentMode and "ON" or "OFF")
           TriggerServerEvent("framework:silentSync", VehToNet(veh), silentMode)
          end
       end
    end
end)
