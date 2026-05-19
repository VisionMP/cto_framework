-- Payroll pickup stations
local paycheckStations = {
    {x = 441.2, y = -981.9, z = 30.7},   -- Mission Row PD
    {x = 1853.1, y = 3689.5, z = 34.2}   -- Sandy Shores PD
}

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        for _, station in ipairs(paycheckStations) do
            local dist = #(pos - vector3(station.x, station.y, station.z))

            if dist < 20.0 then
                sleep = 0

                -- Marker
                DrawMarker(
                    1,
                    station.x, station.y, station.z - 1.0,
                    0,0,0, 0,0,0,
                    1.5,1.5,1.0,
                    0, 150, 255, 150,
                    false, true, 2, false, nil, nil, false
                )

                if dist < 2.0 then
                    -- Prompt
                    BeginTextCommandDisplayHelp("STRING")
                    AddTextComponentSubstringPlayerName("Press ~INPUT_CONTEXT~ to collect paycheck")
                    EndTextCommandDisplayHelp(0, false, true, -1)

                    if IsControlJustPressed(0, 51) then
                        TriggerServerEvent("pd5m:collectPaycheckRequest")
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

-- Server confirms how much money is pending
RegisterNetEvent("pd5m:collectPaycheckConfirm")
AddEventHandler("pd5m:collectPaycheckConfirm", function(total)
    if total >= 1000 then
        -- Allowed to collect
        TriggerServerEvent("pd5m:collectPaycheck")
    else
        -- Not enough pending
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentSubstringPlayerName("You need at least $1000 pending to collect. Current: $"..total)
        EndTextCommandThefeedPostTicker(false, false)
    end
end)

function ShowMoneyNotification(amount, account)
    BeginTextCommandThefeedPost("STRING")

    if account == "cash" then
        AddTextComponentSubstringPlayerName("~g~+$"..amount.."~w~ CASH")
    else
        AddTextComponentSubstringPlayerName("~b~+$"..amount.."~w~ BANK")
    end

    EndTextCommandThefeedPostTicker(false, false)
end

RegisterNetEvent("pd5m:moneyNotify")
AddEventHandler("pd5m:moneyNotify", function(amount, account)
    ShowMoneyNotification(amount, account)
end)