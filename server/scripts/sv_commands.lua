RegisterCommand("additem", function(source, args)
    local player = source
    if player == 0 then return end -- console block

    local item = tostring(args[1])
    local amount = tonumber(args[2]) or 1

    if not item then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255,0,0},
            args = {"Error", "Usage: /additem [item] [amount]"}
        })
        return
    end

    CTO.Items.Add(player, item, amount)

    TriggerClientEvent("chat:addMessage", player, {
        color = {0,255,0},
        args = {"Items", "Added "..amount.."x "..item}
    })
end)

RegisterCommand("checkitems", function(source)
    local player = source
    if player == 0 then return end

    local inv = CTO.Data[player].items or {}

    local msg = "===== Inventory =====\n"

    for item, amount in pairs(inv) do
        msg = msg .. item .. ": " .. amount .. "\n"
    end

    TriggerClientEvent("chat:addMessage", player, {
        color = {0,150,255},
        args = {"Inventory", msg}
    })
end)