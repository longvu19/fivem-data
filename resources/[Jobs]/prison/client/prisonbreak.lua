prisonBreak = false
currentGate = 0

local requiredItemsShowed = false
local requiredItems = {}
local inRange = false
local securityLockdown = false

local Gates = {
    [1] = {
        gatekey = 38,
        coords = {x = 1845.99, y = 2604.7, z = 45.58, h = 94.5},  
        hit = false,
    },
    [2] = {
        gatekey = 39,
        coords = {x = 1819.47, y = 2604.67, z = 45.56, h = 98.5},
        hit = false,
    },
    [3] = {
        gatekey = 40,
        coords = {x = 1804.74, y = 2616.311, z = 45.61, h = 335.5},
        hit = false,
    }
}

Citizen.CreateThread(function()
    Citizen.Wait(500)
    requiredItems = {
        [1] = {name = MSCore.Shared.Items["electronickit"]["name"], image = MSCore.Shared.Items["electronickit"]["image"]},
        [2] = {name = MSCore.Shared.Items["gatecrack"]["name"], image = MSCore.Shared.Items["gatecrack"]["image"]},
    }
    while true do 
        Citizen.Wait(5)
        inRange = false
        currentGate = 0
        if isLoggedIn and MSCore ~= nil then
            if PlayerJob.name ~= "police" then
                local pos = GetEntityCoords(GetPlayerPed(-1))
                for k, v in pairs(Gates) do
                    local dist = GetDistanceBetweenCoords(pos, Gates[k].coords.x, Gates[k].coords.y, Gates[k].coords.z, true)
                    if (dist < 1.5) then
                        currentGate = k
                        inRange = true
                        if securityLockdown then
                            MSCore.Functions.DrawText3D(Gates[k].coords.x, Gates[k].coords.y, Gates[k].coords.z, "~r~HỆ THỐNG KHÓA")
                        elseif Gates[k].hit then
                            MSCore.Functions.DrawText3D(Gates[k].coords.x, Gates[k].coords.y, Gates[k].coords.z, "XÂM NHẬP HỆ THỐNG")
                        elseif not requiredItemsShowed then
                            requiredItemsShowed = true
                            TriggerEvent('inventory:client:requiredItems', requiredItems, true)
                        end
                    end
                end

                if not inRange then
                    if requiredItemsShowed then
                        requiredItemsShowed = false
                        TriggerEvent('inventory:client:requiredItems', requiredItems, false)
                    end
                    Citizen.Wait(1000)
                end
            else
                Citizen.Wait(1000)
            end
        else
            Citizen.Wait(5000)
        end
    end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(7)
		local pos = GetEntityCoords(GetPlayerPed(-1), true)
		if (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Config.Locations["middle"].coords.x, Config.Locations["middle"].coords.y, Config.Locations["middle"].coords.z, false) > 200.0 and inJail) then
			inJail = false
            jailTime = 0
            RemoveBlip(currentBlip)
            RemoveBlip(CellsBlip)
            CellsBlip = nil
            RemoveBlip(TimeBlip)
            TimeBlip = nil
            RemoveBlip(ShopBlip)
            ShopBlip = nil
            TriggerServerEvent("prison:server:SecurityLockdown")
            TriggerEvent('prison:client:PrisonBreakAlert')
            MSCore.Functions.Notify("Bạn đã vượt ngục", "error")
		end
	end
end)

RegisterNetEvent('electronickit:UseElectronickit')
AddEventHandler('electronickit:UseElectronickit', function()
    if currentGate ~= 0 and not securityLockdown and not Gates[currentGate].hit then 
        MSCore.Functions.TriggerCallback('MSCore:HasItem', function(result)
            if result then 
                TriggerEvent('inventory:client:requiredItems', requiredItems, false)
                MSCore.Functions.Progressbar("hack_gate", "Đang kết nối với dụng cụ điện..", math.random(5000, 10000), false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {
                    animDict = "anim@gangops@facility@servers@",
                    anim = "hotwire",
                    flags = 16,
                }, {}, {}, function() -- Done
                    StopAnimTask(GetPlayerPed(-1), "anim@gangops@facility@servers@", "hotwire", 1.0)
                    TriggerEvent("mhacking:show")
                    TriggerEvent("mhacking:start", math.random(5, 9), math.random(10, 18), OnHackDone)
                end, function() -- Cancel
                    StopAnimTask(GetPlayerPed(-1), "anim@gangops@facility@servers@", "hotwire", 1.0)
                    MSCore.Functions.Notify("Hủy..", "error")
                end)
            else
                MSCore.Functions.Notify("Thiếu đồ nghề..", "error")
            end
        end, "gatecrack")
    end
end)

RegisterNetEvent('prison:client:SetLockDown')
AddEventHandler('prison:client:SetLockDown', function(isLockdown)
    securityLockdown = isLockdown
    if securityLockDown and inJail then
        TriggerEvent("chatMessage", "QUẢN TÙ", "error", "Mức bảo mật được nâng lên tối đa!")
    end
end)

RegisterNetEvent('prison:client:PrisonBreakAlert')
AddEventHandler('prison:client:PrisonBreakAlert', function()
    -- TriggerEvent("chatMessage", "ALERT", "error", "Attentie alle eenheden! Poging tot uitbraak in de gevangenis!")
    TriggerEvent('ms-policealerts:client:AddPoliceAlert', {
        timeOut = 10000,
        alertTitle = "Vượt ngục",
        details = {
            [1] = {
                icon = '<i class="fas fa-lock"></i>',
                detail = "Nhà tù Boilingbroke Penitentiary",
            },
            [2] = {
                icon = '<i class="fas fa-globe-europe"></i>',
                detail = "Đường 68",
            },
        },
        callSign = MSCore.Functions.GetPlayerData().metadata["callsign"],
    })

    local BreakBlip = AddBlipForCoord(Config.Locations["middle"].coords.x, Config.Locations["middle"].coords.y, Config.Locations["middle"].coords.z)
    TriggerServerEvent('prison:server:JailAlarm')
	SetBlipSprite(BreakBlip , 161)
	SetBlipScale(BreakBlip , 3.0)
	SetBlipColour(BreakBlip, 3)
	PulseBlip(BreakBlip)
    PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
    Citizen.Wait(100)
    PlaySoundFrontend( -1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1 )
    Citizen.Wait(100)
    PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
    Citizen.Wait(100)
    PlaySoundFrontend( -1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1 )
    Citizen.Wait((1000 * 60 * 5))   
    RemoveBlip(BreakBlip)
end)

RegisterNetEvent('prison:client:SetGateHit')
AddEventHandler('prison:client:SetGateHit', function(key, isHit)
    Gates[key].hit = isHit
end)

function OnHackDone(success, timeremaining)
    if success then
        TriggerServerEvent("prison:server:SetGateHit", currentGate)
		TriggerServerEvent('ms-doorlock:server:updateState', Gates[currentGate].gatekey, false)
		TriggerEvent('mhacking:hide')
    else
        TriggerServerEvent("prison:server:SecurityLockdown")
		TriggerEvent('mhacking:hide')
	end
end