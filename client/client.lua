local name = ""
local job = ""
local cash = ""
local bank = ""
local model = ""          -- model NAME from SQL
local inventory = {}

-- For Exporting --
function getData()
    return {
        ["name"] = name,
        ["job"] = job,
        ["cash"] = cash,
        ["bank"] = bank,
        ["model"] = model
    }
end

function GetInventory()
    return inventory
end

-- Update Data on Clientside --
RegisterNetEvent("updateData")
AddEventHandler("updateData", function(_name, _job, _cash, _bank, _model)
    name, job, cash, bank, model = _name, _job, _cash, _bank, _model
end)

RegisterNetEvent("updateInventory")
AddEventHandler("updateInventory", function(inv)
    inventory = inv
end)

------------------------------------------------------------
-- APPLY MODEL
------------------------------------------------------------
RegisterNetEvent("cto:applyModel")
AddEventHandler("cto:applyModel", function(hash)
    if not hash then return end

    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(0) end

    SetPlayerModel(PlayerId(), hash)
    SetModelAsNoLongerNeeded(hash)
end)

------------------------------------------------------------
-- AUTOSAVE MODEL (EVERY 5 MINUTES)
------------------------------------------------------------
CreateThread(function()
    while true do
        Wait(60000 * 5)
        TriggerServerEvent("cto:saveModel", GetEntityModel(PlayerPedId()))
    end
end)

------------------------------------------------------------
-- MANUAL SAVE
------------------------------------------------------------
RegisterCommand("savemodel", function()
    TriggerServerEvent("cto:saveModel", GetEntityModel(PlayerPedId()))
end)

------------------------------------------------------------
-- When spawn player ped --
------------------------------------------------------------
AddEventHandler("playerSpawned", function()
    TriggerServerEvent("getData")
    Citizen.Wait(1000)
    TriggerServerEvent("cto:getModel")   
end)

------------------------------------------------------------
-- Text for HUD --
------------------------------------------------------------
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

------------------------------------------------------------
-- Text Based HUD Display --
------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        text("CASH", 0.885, 0.035, 0.35)
        text("BANK", 0.885, 0.075, 0.35)
        text("~y~JOB~w~", 0.885, 0.115, 0.35)

        text("~g~$~w~ ".. cash, 0.91, 0.03, 0.50)
        text("~b~$~w~ ".. bank, 0.91, 0.07, 0.50)
        text(" ".. job, 0.91, 0.11, 0.50)

        if IsPauseMenuActive() then
            BeginScaleformMovieMethodOnFrontendHeader("SET_HEADING_DETAILS")
            ScaleformMovieMethodAddParamPlayerNameString(GetPlayerName(PlayerId()))
            PushScaleformMovieFunctionParameterString("Cash: $" .. cash)
            PushScaleformMovieFunctionParameterString("Bank: $" .. bank)
            EndScaleformMovieMethod()
        end
    end
end)

local notifyText = nil
local notifyTimer = 0
local notifyDuration = 3500 -- ms

RegisterNetEvent("cto:nativeNotify", function(msg)
    notifyText = msg
    notifyTimer = GetGameTimer()
end)

CreateThread(function()
    while true do
        Wait(0)

        if notifyText then
            local now = GetGameTimer()
            local alpha = 255

            -- fade out
            if now - notifyTimer > notifyDuration - 500 then
                alpha = math.floor(255 - ((now - (notifyTimer + notifyDuration - 500)) / 500) * 255)
            end

            -- background box (same style as your menu)
            DrawRect(0.15, 0.12, 0.22, 0.045, 0, 0, 0, alpha * 0.65)

            -- text
            SetTextFont(0)
            SetTextScale(0.35, 0.35)
            SetTextColour(255, 255, 255, alpha)
            SetTextDropshadow(1, 0, 0, 0, 255)
            SetTextCentre(false)
            SetTextEntry("STRING")
            AddTextComponentString(notifyText)
            DrawText(0.05, 0.10)

            if now - notifyTimer > notifyDuration then
                notifyText = nil
            end
        end
    end
end)