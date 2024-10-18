fx_version 'cerulean'
game 'gta5'
lua54 "yes"
name 'Blips Creator System'
author '1S - SCRIPTS'
version '2.37.2'


client_script 'client/*.lua'
server_script 'server/*.lua'

shared_scripts {'config.lua'}

shared_scripts {
  '@ox_lib/init.lua',
}
