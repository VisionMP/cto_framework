RegisterServerEvent('getData')
AddEventHandler('getData', function()
    local player = source
    local id = CTO.GetIdentifier(player)
    if not id then return end

    local name = ""
    local job = ""
    local cash = ""
    local bank = ""
    local model = ""

    exports.oxmysql:query(
        "SELECT name, job, cash, bank, model FROM player_data WHERE license = ?",
        { id },
        function(result)

            -- No row exists - create one
            if not result or not result[1] then
                exports.oxmysql:query(
                    "INSERT INTO player_data (license, name, job, cash, bank, model) VALUES (?, ?, ?, ?, ?, ?)",
                    {
                        id,
                        GetPlayerName(player),
                        "Police Officer",
                        Server.Config.NewPlayerCash,
                        Server.Config.NewPlayerBank,
                        "s_m_y_cop_01"
                    },
                    function()
                        CTO.Currency.Update(player)
                        CTO.Items.Load(player)
                        CTO.Functions.Notify(player, "Welcome to Rooster Cruiser World")
                    end
                )
                return
            end

            -- Row exists - load it
            local row = result[1]

            CTO.Data[player] = {
                name  = row.name,
                job   = row.job,
                cash  = row.cash,
                bank  = row.bank,
                model = row.model
            }

            -- Sync to client
            TriggerClientEvent('updateData', player,
                row.name, row.job, row.cash, row.bank, row.model
            )

            CTO.Currency.Update(player)
            CTO.Items.Load(player)
            CTO.Functions.Notify(player, "Welcome to Rooster Cruiser World")
        end
    )
end)