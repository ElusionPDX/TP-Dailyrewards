fx_version 'adamant'
game 'gta5'

author 'Nosmakos'
description 'Titans Productions Dailyrewards (QB)'
version '1.0.0'

server_scripts {
	"@mysql-async/lib/MySQL.lua",
    'config.lua',
    'server/*.lua'
}

client_scripts {
    'config.lua',
    'client/*.lua'
}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/js/script.js',
	'html/css/*.css',
	'html/font/Prototype.ttf',
    'html/img/background.jpg',
    'html/img/items/*.png',
}

