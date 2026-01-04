fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Zeus'
description 'Editor de Handling com export em XML'
version '1.0'

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/script.js'
}

shared_scripts {
    '@ox_lib/init.lua',
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/server.lua'
}

dependency 'qb-core'