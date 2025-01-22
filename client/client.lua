local cash = ""
local bank = ""
local rank = ""
local xp = ""

-- For Exporting --
function getMoney()
    return {["cash"] = cash, ["bank"] = bank, ["rank"] = rank, ["xp"] = xp}
end

-- Update Money on Clientside --
RegisterNetEvent('UpdateMoney')
AddEventHandler('UpdateMoney', function(updatedCash, updatedBank , updatedRank, updatedXp)
   cash, bank, rank, xp = updatedCash, updatedBank, updatedRank, UpdatedXp
end)

-- When spawn player ped --
AddEventHandler('playerSpawned', function()
   --TriggerServerEvent('Server:SpawnPlayer')
   --print("Server Event: Server:SpawnPlayer")      
   TriggerServerEvent('GetMoney')
end)

-- Text for HUD --
function text(text, x, y, scale)
   SetTextFont(7)
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
       text("CASH", 0.885, 0.035, 0.35)
       text("BANK", 0.885, 0.075, 0.35)        
       text("RANK", 0.885, 0.115, 0.35)               
       text("~g~$~w~ ".. cash, 0.91, 0.03, 0.50)
       text("~b~$~w~ ".. bank, 0.91, 0.07, 0.50)
       text(" ~y~".. rank, 0.91, 0.109, 0.50)      
       if IsPauseMenuActive() then
           BeginScaleformMovieMethodOnFrontendHeader("SET_HEADING_DETAILS")
           ScaleformMovieMethodAddParamPlayerNameString(GetPlayerName(PlayerId()))
           PushScaleformMovieFunctionParameterString("Cash: $" .. cash)
           PushScaleformMovieFunctionParameterString("Bank: $" .. bank)
           EndScaleformMovieMethod()
       end
   end
end)