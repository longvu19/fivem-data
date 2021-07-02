MSCore = {}
MSCore.PlayerData = {}
MSCore.Config = MSConfig
MSCore.Shared = MShared
MSCore.ServerCallbacks = {}
MSCore.quicksandId = nil

isLoggedIn = false

function GetCoreObject()
	return MSCore
end

RegisterNetEvent('MSCore:GetObject')
AddEventHandler('MSCore:GetObject', function(cb)
	cb(GetCoreObject())
end)

RegisterNetEvent('MSCore:Client:OnPlayerLoaded')
AddEventHandler('MSCore:Client:OnPlayerLoaded', function()
	ShutdownLoadingScreenNui()
	isLoggedIn = true
end)

RegisterNetEvent('MSCore:Client:OnPlayerUnload')
AddEventHandler('MSCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)

Citizen.CreateThread(function()
    RegisterFontFile('quicksand') -- the name of your .gfx, without .gfx
    MSCore.quicksandId = RegisterFontId('Quicksand') -- the name from the .xml
end)