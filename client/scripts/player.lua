Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        SetPlayerHealthRechargeLimit(PlayerId(),0.0)
    end
 end)