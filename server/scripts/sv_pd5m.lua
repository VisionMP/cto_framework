-- PD5M Payroll System
-- Arrest logging + paycheck collection
-- Uses CTO Framework + oxmysql

-- Arrest Event: log pending paycheck
RegisterNetEvent("pd5m:payForAIArrest")
AddEventHandler("pd5m:payForAIArrest", function(data)
    local officer = source
    if not officer then return end

    -- Suspect + officer data
    local name    = data.name or "Unknown"
    local gender  = data.gender or "Unknown"
    local dob     = data.dob or "Unknown"
    local id      = data.id or "N/A"
    local wanted  = data.wanted or false
    local offense = data.offense or "None"
    local reason  = data.reason or "No reason provided"

    -- Pay calculation
    local amount = math.random(100, 175)
    if wanted then
        amount = amount + math.random(100, 250)
    end

    local officerName = GetPlayerName(officer)

    -- Grab Steam ID
    local identifiers = GetPlayerIdentifiers(officer)
    local steamId = "unknown"
    for _, v in ipairs(identifiers) do
        if v:sub(1, 6) == "steam:" then
            steamId = v
            break
        end
    end

    -- Save paycheck entry to DB
    exports.oxmysql:insert(
        "INSERT INTO pending_paychecks (identifier, amount, reason) VALUES (?, ?, ?)",
        {steamId, amount, reason}
    )

    -- Notify officer
    TriggerClientEvent("chat:addMessage", officer, {
        args = {"[PD5M]", ("Arrest logged: %s. Paycheck pending: $%s"):format(name, amount)}
    })

    -- Discord embed log
    local CTO = exports['cto_framework']:getDataObject(officer)
    if CTO then
        local msg = ("Officer: %s | Steam: %s | Suspect: %s | DOB: %s | Gender: %s | ID: %s | Wanted: %s | Offense: %s | Reason: %s | Pending Pay: $%s")
        :format(officerName, steamId, name, dob, gender, id, tostring(wanted), offense, reason, amount)

        CTO.Functions.DiscordSendMsg("AI Arrest Logged", msg)
    end
end)

-- Paycheck Collection Request
RegisterNetEvent("pd5m:collectPaycheckRequest")
AddEventHandler("pd5m:collectPaycheckRequest", function()
    local src = source

    local identifiers = GetPlayerIdentifiers(src)
    local steamId = "unknown"
    for _, v in ipairs(identifiers) do
        if v:sub(1, 6) == "steam:" then
            steamId = v
            break
        end
    end

    exports.oxmysql:query(
        "SELECT SUM(amount) as total FROM pending_paychecks WHERE identifier = ?",
        {steamId},
        function(result)
            local total = tonumber(result and result[1] and result[1].total) or 0
            TriggerClientEvent("pd5m:collectPaycheckConfirm", src, total)
        end
    )
end)

-- Paycheck Collection Event
RegisterNetEvent("pd5m:collectPaycheck")
AddEventHandler("pd5m:collectPaycheck", function()
    local src = source
    local officerName = GetPlayerName(src)

    local identifiers = GetPlayerIdentifiers(src)
    local steamId = "unknown"
    for _, v in ipairs(identifiers) do
        if v:sub(1, 6) == "steam:" then
            steamId = v
            break
        end
    end

    exports.oxmysql:query(
        "SELECT SUM(amount) as total FROM pending_paychecks WHERE identifier = ?",
        {steamId},
        function(result)
            local total = tonumber(result and result[1] and result[1].total) or 0

            if total < 1000 then
                TriggerClientEvent("chat:addMessage", src, {
                    color = {255,0,0},
                    args = {"Payroll", "You need at least $1000 to collect a paycheck. Current: $" .. total}
                })
                return
            end
         
            exports.oxmysql:execute(
                "DELETE FROM pending_paychecks WHERE identifier = ?",
                {steamId}
            )

            local xPlayer = exports['cto_framework']:getDataObject(src)
            if xPlayer then
                xPlayer.Currency.Add(total, src, "bank")
                TriggerClientEvent("pd5m:moneyNotify", src, total, "bank")
                xPlayer.Functions.DiscordSendMsg("Paycheck Collection", {
                    embeds = {{
                        title = "Paycheck Collected",
                        color = 3066993,
                        fields = {
                            {name = "Officer", value = officerName, inline = true},
                            {name = "Steam ID", value = steamId, inline = true},
                            {name = "Amount Collected", value = "$"..total, inline = true}
                        },
                        footer = {text = "PD5M Payroll System"}
                    }}
                })
            end

            TriggerClientEvent("chat:addMessage", src, {
                color = {0,255,0},
                args = {"Payroll", "Collected paycheck: $" .. total}
            })
        end
    )
end)

RegisterNetEvent("pd5m:syncsv:SetPlayerAsCop")
AddEventHandler("pd5m:syncsv:SetPlayerAsCop", function(isCop)
    local src = source

    if isCop then
        -- Mark player as police in PD5M AI system
        CopPlayers[src] = true
        print("[PD5M] Player " .. src .. " marked as COP")
    else
        CopPlayers[src] = nil
        print("[PD5M] Player " .. src .. " marked as CIVILIAN")
    end

    -- Sync to all clients
    TriggerClientEvent("pd5m:synccl:UpdateCopStatus", -1, src, isCop)
end)