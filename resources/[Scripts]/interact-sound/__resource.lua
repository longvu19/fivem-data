-- Manifest Version
resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

-- Client Scripts
client_script 'client/main.lua'

-- Server Scripts
server_script 'server/main.lua'

-- NUI Default Page
ui_page('client/html/index.html')

-- Files needed for NUI
files {
    'client/html/index.html',
    'client/html/sounds/*.ogg',
}
