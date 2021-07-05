MSCore = nil

TriggerEvent('MSCore:GetObject', function(obj) MSCore = obj end)

MSCore.Commands.Add("cash", "Xem tiền mặt", {}, false, function(source, args)
	TriggerClientEvent('hud:client:ShowMoney', source, "cash")
end)

MSCore.Commands.Add("bank", "Xem tiền trong tài khoản", {}, false, function(source, args)
	TriggerClientEvent('hud:client:ShowMoney', source, "bank")
end)