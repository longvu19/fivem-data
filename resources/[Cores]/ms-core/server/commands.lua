MSCore.Commands = {}
MSCore.Commands.List = {}

MSCore.Commands.Add = function(name, help, arguments, argsrequired, callback, permission) -- [name] = command name (ex. /givemoney), [help] = help text, [arguments] = arguments that need to be passed (ex. {{name="id", help="ID of a player"}, {name="amount", help="amount of money"}}), [argsrequired] = set arguments required (true or false), [callback] = function(source, args) callback, [permission] = rank or job of a player
	MSCore.Commands.List[name:lower()] = {
		name = name:lower(),
		permission = permission ~= nil and permission:lower() or "user",
		help = help,
		arguments = arguments,
		argsrequired = argsrequired,
		callback = callback,
	}
end

MSCore.Commands.Refresh = function(source)
	local Player = MSCore.Functions.GetPlayer(tonumber(source))
	if Player ~= nil then
		for command, info in pairs(MSCore.Commands.List) do
			if MSCore.Functions.HasPermission(source, "god") or MSCore.Functions.HasPermission(source, MSCore.Commands.List[command].permission) then
				TriggerClientEvent('chat:addSuggestion', source, "/"..command, info.help, info.arguments)
			end
		end
	end
end

MSCore.Commands.Add("tp", "Dịch chuyển đến cạnh người chơi hoặc vị trí cụ thể", {{name="id/x", help="ID của người chơi hoặc vị trí X"}, {name="y", help="vị trí Y"}, {name="z", help="vị trí Z"}}, false, function(source, args)
    if (args[1] ~= nil and (args[2] == nil and args[3] == nil)) then
        -- tp to player
        local Player = MSCore.Functions.GetPlayer(tonumber(args[1]))
        if Player ~= nil then
            TriggerClientEvent('MSCore:Command:TeleportToPlayer', source, Player.PlayerData.source)
        else
            TriggerClientEvent('chatMessage', source, "Hệ thống", "error", "Người chơi không online")
        end
    else
        -- tp to location
        if args[1] ~= nil and args[2] ~= nil and args[3] ~= nil then
            local x = tonumber(args[1])
            local y = tonumber(args[2])
            local z = tonumber(args[3])
            TriggerClientEvent('MSCore:Command:TeleportToCoords', source, x, y, z)
        else
            TriggerClientEvent('chatMessage', source, "Hệ thống", "error", "Phải điền đầy đủ tham số (x, y, z)")
        end
    end
end, "admin") 

MSCore.Commands.Add("giveperms", "Cấp quyền cho người chơi (god/admin)", {{name="id", help="ID người chơi"}, {name="permission", help="Mức quyền hạn"}}, true, function(source, args)
	local Player = MSCore.Functions.GetPlayer(tonumber(args[1]))
	local permission = tostring(args[2]):lower()
	if Player ~= nil then
		MSCore.Functions.AddPermission(Player.PlayerData.source, permission)
	else
		TriggerClientEvent('chatMessage', source, "Hệ thống", "error", "Người chơi không online")	
	end
end, "god")

MSCore.Commands.Add("removeperms", "Xóa quyền của người chơi", {{name="id", help="ID người chơi"}}, true, function(source, args)
	local Player = MSCore.Functions.GetPlayer(tonumber(args[1]))
	if Player ~= nil then
		MSCore.Functions.RemovePermission(Player.PlayerData.source)
	else
		TriggerClientEvent('chatMessage', source, "Hệ thống", "error", "Người chơi không online")	
	end
end, "god")

MSCore.Commands.Add("car", "Tạo ra xe", {{name="model", help="Mẫu xe"}}, true, function(source, args)
	TriggerClientEvent('MSCore:Command:SpawnVehicle', source, args[1])
end, "admin")

MSCore.Commands.Add("debug", "Bật / tắt chế độ debug", {}, false, function(source, args)
	TriggerClientEvent('koil-debug:toggle', source)
end, "admin")

MSCore.Commands.Add("dv", "Xóa xe", {}, false, function(source, args)
	TriggerClientEvent('MSCore:Command:DeleteVehicle', source)
end, "admin")

MSCore.Commands.Add("tpm", "Dịch chuyển đến điểm đánh dấu", {}, false, function(source, args)
	TriggerClientEvent('MSCore:Command:GoToMarker', source)
end, "admin")

MSCore.Commands.Add("duatien", "Đưa tiền cho ai", {{name="id", help="ID người nhận"},{name="moneytype", help="Loại tiền (cash = tiền mặt, bank = tiền ngân hàng, crypto = tiền điện tử)"}, {name="amount", help="Số tiền"}}, true, function(source, args)
	local Player = MSCore.Functions.GetPlayer(tonumber(args[1]))
	if Player ~= nil then
		Player.Functions.AddMoney(tostring(args[2]), tonumber(args[3]))
	else
		TriggerClientEvent('chatMessage', source, "Hệ thống", "error", "Người chơi không online")
	end
end, "admin")

MSCore.Commands.Add("setmoney", "Set tiền cho người chơi", {{name="id", help="ID người chơi"},{name="moneytype", help="Loại tiền (cash = tiền mặt, bank = tiền ngân hàng, crypto = tiền điện tử)"}, {name="amount", help="Số tiền"}}, true, function(source, args)
	local Player = MSCore.Functions.GetPlayer(tonumber(args[1]))
	print(Player)
	if Player ~= nil then
		Player.Functions.SetMoney(tostring(args[2]), tonumber(args[3]))
	else
		TriggerClientEvent('chatMessage', source, "Hệ thống", "error", "Người chơi không online")
	end
end, "admin")

MSCore.Commands.Add("setjob", "Gán việc làm cho người chơi", {{name="id", help="ID"}, {name="job", help="Tên việc làm"}}, true, function(source, args)
	local Player = MSCore.Functions.GetPlayer(tonumber(args[1]))
	if Player ~= nil then
		Player.Functions.SetJob(tostring(args[2]))
	else
		TriggerClientEvent('chatMessage', source, "Hệ thống", "error", "Người chơi không online")
	end
end, "admin")

MSCore.Commands.Add("work", "Xem việc làm của mình", {}, false, function(source, args)
	local Player = MSCore.Functions.GetPlayer(source)
	TriggerClientEvent('chatMessage', source, "Hệ thống", "warning", "Work: "..Player.PlayerData.job.label)
end)

MSCore.Commands.Add("setgang", "Mời người chơi vào gang", {{name="id", help="ID"}, {name="job", help="Tên gang"}}, true, function(source, args)
	local Player = MSCore.Functions.GetPlayer(tonumber(args[1]))
	if Player ~= nil then
		Player.Functions.SetGang(tostring(args[2]))
	else
		TriggerClientEvent('chatMessage', source, "Hệ thống", "error", "Người chơi không online")
	end
end, "admin")

MSCore.Commands.Add("gang", "Xem tên gang của mình", {}, false, function(source, args)
	local Player = MSCore.Functions.GetPlayer(source)

	if Player.PlayerData.gang.name ~= "geen" then
		TriggerClientEvent('chatMessage', source, "Hệ thống", "warning", "Gang: "..Player.PlayerData.gang.label)
	else
		TriggerClientEvent('MSCore:Notify', source, "Bạn đang không ở trong gang", "error")
	end
end)

MSCore.Commands.Add("testnotify", "test notify", {{name="text", help="Tekst enzo"}}, true, function(source, args)
	TriggerClientEvent('MSCore:Notify', source, table.concat(args, " "), "success")
end, "god")

MSCore.Commands.Add("clearinv", "Dọn túi đồ người chơi", {{name="id", help="ID người chơi"}}, false, function(source, args)
	local playerId = args[1] ~= nil and args[1] or source 
	local Player = MSCore.Functions.GetPlayer(tonumber(playerId))
	if Player ~= nil then
		Player.Functions.ClearInventory()
	else
		TriggerClientEvent('chatMessage', source, "Hệ thống", "error", "Người chơi không online")
	end
end, "admin")

MSCore.Commands.Add("ooc", "Message Out Of Character", {}, false, function(source, args)
	local message = table.concat(args, " ")
	TriggerClientEvent("MSCore:Client:LocalOutOfCharacter", -1, source, GetPlayerName(source), message)
	local Players = MSCore.Functions.GetPlayers()
	local Player = MSCore.Functions.GetPlayer(source)

	for k, v in pairs(MSCore.Functions.GetPlayers()) do
		if MSCore.Functions.HasPermission(v, "admin") then
			if MSCore.Functions.IsOptin(v) then
				TriggerClientEvent('chatMessage', v, "OOC " .. GetPlayerName(source), "normal", message)
				TriggerEvent("ms-log:server:CreateLog", "ooc", "OOC", "white", "**"..GetPlayerName(source).."** (CitizenID: "..Player.PlayerData.citizenid.." | ID: "..source..") **Message:** " ..message, false)
			end
		end
	end
end)