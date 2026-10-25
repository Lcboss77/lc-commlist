fx_version 'cerulean'

game 'gta5'

name 'lc-commlist'
author 'Lcboss77'
description 'In-game list of every command and keybind on your server. ESX, QBCore and standalone.'
version '1.1.0'

client_scripts {
    'config.lua',
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config.lua',
    'server/*.lua'
}

ui_page "html/index.html"

files {
    'html/*.html',
    'html/*.js',
    'html/*.css',
    'html/*.png',
    'html/*.jpg'
}
