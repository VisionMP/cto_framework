author "Vision"
description "Chill Theft Auto Framework"
version "1.0.0"

fx_version "cerulean"
game "gta5"
lua54 "yes"

client_scripts { 
    "config/client_config.lua",   
    "client/client.lua",
    "client/functions.lua",  
    "client/scripts/*.lua"  
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "config/server_config.lua",     
    "server/server.lua",
    "server/functions.lua",
    "server/scripts/*.lua"
}

export "getMoney"
server_export "getDataObject"
dependency "oxmysql"
