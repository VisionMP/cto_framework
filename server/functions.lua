CTO = {}
CTO.Data = {}
CTO.Currency = {}
CTO.Functions = {}
CTO.Job = {}
CTO.Items = {}

function getDataObject()
    return CTO
end

-- Unified Identifier: steam first, fallback to license
CTO.GetIdentifier = function(src)
    local steam = CTO.GetPlayerIdentifierFromType("steam", src)
    if steam then return steam end

    local license = CTO.GetPlayerIdentifierFromType("license", src)
    if license then return license end

    return nil
end

CTO.GetPlayerIdentifierFromType = function(type, source)
    local identifierCount = GetNumPlayerIdentifiers(source)
    for count = 0, identifierCount - 1 do
        local identifier = GetPlayerIdentifier(source, count)
        if identifier and string.find(identifier, type) then
            return identifier
        end
    end
    return nil
end

CTO.GetData = function(player, key)
    player = tonumber(player)
    if not player or not CTO.Data[player] then return nil end
    return CTO.Data[player][key]
end

CTO.Job.Set = function(player, newJob)
    player = tonumber(player)
    local job = tostring(newJob)
    local id = CTO.GetIdentifier(player)

    exports.oxmysql:query(
        "UPDATE player_data SET job = ? WHERE license = ?",
        { job, id }
    )

    CTO.Currency.Update(player)
end

CTO.Currency.Update = function(player)
    player = tonumber(player)
    local id = CTO.GetIdentifier(player)

    exports.oxmysql:query(
        "SELECT name, job, cash, bank, model FROM player_data WHERE license = ?",
        { id },
        function(result)
            if result and result[1] then
                local row = result[1]

                CTO.Data[player] = {
                    name  = row.name,
                    job   = row.job,
                    cash  = row.cash,
                    bank  = row.bank,
                    model = row.model 
                }

                TriggerClientEvent("updateData", player,
                    row.name, row.job, row.cash, row.bank, row.model
                )
            end
        end
    )
end

CTO.Currency.Add = function(amount, player, to)
    amount = tonumber(amount)
    player = tonumber(player)
    local id = CTO.GetIdentifier(player)

    local field = (to == "bank") and "bank" or "cash"

    exports.oxmysql:query(
        "UPDATE player_data SET " .. field .. " = " .. field .. " + ? WHERE license = ?",
        { amount, id },
        function()
            CTO.Currency.Update(player)
        end
    )
end

CTO.Currency.Remove = function(amount, player, from)
    amount = tonumber(amount)
    player = tonumber(player)
    local id = CTO.GetIdentifier(player)

    local field = (from == "bank") and "bank" or "cash"

    exports.oxmysql:query(
        "UPDATE player_data SET " .. field .. " = " .. field .. " - ? WHERE license = ?",
        { amount, id },
        function()
            CTO.Currency.Update(player)
        end
    )
end

CTO.Currency.Withdraw = function(amount, player)
    amount = tonumber(amount)
    player = tonumber(player)

    if not CTO.Data[player] or not CTO.Data[player].bank then
        return false
    end

    if CTO.Data[player].bank >= amount then
        local id = CTO.GetIdentifier(player)

        exports.oxmysql:query(
            "UPDATE player_data SET bank = bank - ? WHERE license = ?",
            { amount, id }
        )

        exports.oxmysql:query(
            "UPDATE player_data SET cash = cash + ? WHERE license = ?",
            { amount, id }
        )

        CTO.Currency.Update(player)
        return true
    end

    return false
end

CTO.Currency.Deposit = function(amount, player)
    amount = tonumber(amount)
    player = tonumber(player)

    if not CTO.Data[player] or not CTO.Data[player].cash then
        return false
    end

    if CTO.Data[player].cash >= amount then
        local id = CTO.GetIdentifier(player)

        exports.oxmysql:query(
            "UPDATE player_data SET cash = cash - ? WHERE license = ?",
            { amount, id }
        )

        exports.oxmysql:query(
            "UPDATE player_data SET bank = bank + ? WHERE license = ?",
            { amount, id }
        )

        CTO.Currency.Update(player)
        return true
    end

    return false
end

CTO.Items.Load = function(player)
    local id = CTO.GetIdentifier(player)

    exports.oxmysql:query(
        "SELECT item, amount FROM player_items WHERE license = ?",
        { id },
        function(result)
            local inv = {}
            for _, row in ipairs(result) do
                inv[row.item] = row.amount
            end

            CTO.Data[player] = CTO.Data[player] or {}
            CTO.Data[player].items = inv

            TriggerClientEvent("updateInventory", player, inv)
        end
    )
end

CTO.Items.Add = function(player, item, amount)
    local id = CTO.GetIdentifier(player)

    exports.oxmysql:query(
        "INSERT INTO player_items (license, item, amount) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE amount = amount + ?",
        { id, item, amount, amount },
        function()
            CTO.Items.Load(player)
        end
    )
end

CTO.Items.Remove = function(player, item, amount)
    local id = CTO.GetIdentifier(player)

    exports.oxmysql:query(
        "UPDATE player_items SET amount = amount - ? WHERE license = ? AND item = ?",
        { amount, id, item },
        function()
            exports.oxmysql:query(
                "DELETE FROM player_items WHERE amount <= 0 AND license = ?",
                { id },
                function()
                    CTO.Items.Load(player)
                end
            )
        end
    )
end

CTO.Items.GetAll = function(player)
    return CTO.Data[player].items or {}
end

CTO.Items.Get = function(player, item)
    player = tonumber(player)
    if not player then return 0 end

    local inv = CTO.Data[player] and CTO.Data[player].items
    if not inv then return 0 end

    return inv[item] or 0
end

-- Model save/load now uses unified identifier
CTO.Functions.SaveModel = function(src, hash, cb)
    local id = CTO.GetIdentifier(src)
    if not id then
        if cb then cb(false) end
        return
    end

    exports.oxmysql:query(
        "UPDATE player_data SET model = ? WHERE license = ?",
        { tostring(hash), id },
        function()
            if cb then cb(true) end
        end
    )
end

CTO.Functions.LoadModel = function(src, cb)
    local id = CTO.GetIdentifier(src)
    if not id then return cb(nil) end

    exports.oxmysql:query(
        "SELECT model FROM player_data WHERE license = ?",
        { id },
        function(result)
            if result and result[1] and result[1].model then
                cb(tonumber(result[1].model))
            else
                cb(nil)
            end
        end
    )
end

CTO.Functions.DiscordSendMsg = function(name, message)
    if not message or message == "" then return end

    PerformHttpRequest(
        Server.Config.Webhook,
        function(err, text, headers) end,
        "POST",
        json.encode({ username = name, content = message }),
        { ["Content-Type"] = "application/json" }
    )
end

CTO.Functions.Notify = function(src, text)
    TriggerClientEvent("cto:nativeNotify", src, tostring(text))
end

RegisterNetEvent("cto:saveModel", function(hash)
    local src = source
    CTO.Functions.SaveModel(src, hash)
end)

RegisterNetEvent("cto:getModel", function()
    local src = source

    CTO.Functions.LoadModel(src, function(hash)
        if hash then
            TriggerClientEvent("cto:applyModel", src, hash)
        end
    end)
end)

AddEventHandler("playerDropped", function()
end)

RegisterNetEvent("getData")
AddEventHandler("getData", function()
    local src = source
    CTO.Currency.Update(src)
    CTO.Items.Load(src)
end)