RegisterServerEvent('vs_savename')
AddEventHandler('vs_savename', function()   
   MySQL.Sync.execute('UPDATE player_data SET `name` = @name WHERE license = @id', {['@name'] = GetPlayerName(source), ['@id'] = GetPlayerIdentifier(source, 0)})
   --local updateHealth = MySQL.Sync.execute('UPDATE money SET `name` = @name WHERE license = @id', {['@name'] = name, ['@id'] = GetPlayerIdentifier(source, 0)})     
end)

