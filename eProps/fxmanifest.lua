fx_version 'adamant'
game 'gta5'
lua54 'yes'
author 'Enøs Edit By ImSama'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    "config.lua",
}

client_scripts {
    --------------------------
    "src/RMenu.lua",
    "src/menu/RageUI.lua",
    "src/menu/Menu.lua",
    "src/menu/MenuController.lua",
    "src/components/*.lua",
    "src/menu/elements/*.lua",
    "src/menu/items/*.lua",
    "src/menu/panels/*.lua",
    "src/menu/panels/*.lua",
    "src/menu/windows/*.lua",
    --------------------------
    "client.lua",
}

exports {
    'PropsMenu',
}