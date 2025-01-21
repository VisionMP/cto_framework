local cash = ""
local bank = ""

-- For Exporting --
function getMoney()
    return {["cash"] = cash, ["bank"] = bank}
end

-- Trigger the server event "getMoney" when the resource starts.
AddEventHandler("onResourceStart", function(resourceName)
   if (GetCurrentResourceName() ~= resourceName) then
      return
   end
   Citizen.Wait(1000)
   --TriggerServerEvent('GetMoney')
end)  

-- Update Money on Clientside --
RegisterNetEvent('UpdateMoney')
AddEventHandler('UpdateMoney', function(updatedCash, updatedBank)
   cash, bank = updatedCash, updatedBank
end)

-- When spawn player ped --
AddEventHandler('playerSpawned', function()
   --TriggerServerEvent('Server:SpawnPlayer')
   --print("Server Event: Server:SpawnPlayer")      
   TriggerServerEvent('GetMoney')
end)

-- Text for HUD --
function text(text, x, y, scale)
   SetTextFont(1)
   SetTextProportional(0)
   SetTextScale(scale, scale)
   SetTextEdge(1, 0, 0, 0, 255)
   SetTextDropShadow(0, 0, 0, 0,255)
   SetTextOutline()
   SetTextJustification(1)
   SetTextEntry("STRING")
   AddTextComponentString(text)
   DrawText(x, y)
end

-- Text Based HUD Display--
Citizen.CreateThread(function()
   while true do
       Citizen.Wait(0)
       text("💵", 0.885, 0.03, 0.30)
       text("💳", 0.885, 0.07, 0.30)        
      -- text("🧑‍✈️", 0.885, 0.108, 0.30)
       text("~g~$~w~ ".. cash, 0.91, 0.03, 0.50)
       text("~b~$~w~ ".. bank, 0.91, 0.07, 0.50)
       --text("~y~$~w~ "..  rank, 0.91, 0.109, 0.50)
       if IsPauseMenuActive() then
           BeginScaleformMovieMethodOnFrontendHeader("SET_HEADING_DETAILS")
           ScaleformMovieMethodAddParamPlayerNameString(GetPlayerName(PlayerId()))
           PushScaleformMovieFunctionParameterString("Cash: $" .. cash)
           PushScaleformMovieFunctionParameterString("Bank: $" .. bank)
           EndScaleformMovieMethod()
       end
   end
end)