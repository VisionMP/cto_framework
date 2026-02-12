# cto_framework
Light framework for FiveM

- CTO Object — Main framework container holding: CTO.Data, CTO.Currency, CTO.Functions, CTO.Job, CTO.Items.
- local CTO = exports[cto_framework]:getDataObject() — Returns the full CTO object.
- CTO.GetPlayerIdentifierFromType(type, source) — Loops all identifiers for a player and returns the first one matching the given type (e.g., "steam").
- CTO.GetData(player, key) — Returns a specific stored value from CTO.Data[player][key] or nil if missing.
- CTO.Job.Set(player, newJob) — Converts job to string, updates the database, then refreshes all player data using CTO.Currency.Update.
- CTO.Currency.Update(player) — Loads the player's full row from player_data (name, job, cash, bank, model), stores it in CTO.Data[player], and sends updateData to the client.
- CTO.Currency.Add(amount, player, to) — Adds money to either "cash" or "bank" in the database, then refreshes player data.
- CTO.Currency.Remove(amount, player, from) — Removes money from "cash" or "bank" in the database, then refreshes player data.
- CTO.Currency.Withdraw(amount, player) — Moves money from bank → cash if the player has enough bank balance; updates data and returns true or false.
- CTO.Currency.Deposit(amount, player) — Moves money from cash → bank if the player has enough cash; updates data and returns true or false.
- CTO.Items.Load(player) — Loads all items from player_items for the player's license, stores them in CTO.Data[player].items, and sends updateInventory to the client.
- CTO.Items.Add(player, item, amount) — Inserts or increases an item using ON DUPLICATE KEY UPDATE, then reloads the inventory.
- CTO.Items.Remove(player, item, amount) — Decreases an item amount, deletes rows with amount <= 0, then reloads the inventory.
- CTO.Items.GetAll(player) — Returns the entire inventory table stored in CTO.Data[player].items.
- CTO.Items.Get(player, item) — Returns the amount of a specific item or 0 if missing.
- CTO.Functions.SaveModel(src, hash, cb) — Saves the player's ped model hash to the database and triggers callback with success/failure.
- CTO.Functions.LoadModel(src, cb) — Loads the player's saved model hash from the database and returns it via callback.
- CTO.Functions.DiscordSendMsg(name, message) — Sends a message to the configured Discord webhook using PerformHttpRequest.
- CTO.Functions.Notify(src, text) — Sends a native notification to the client using cto:nativeNotify.
