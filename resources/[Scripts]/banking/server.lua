MSCore = nil
TriggerEvent('MSCore:GetObject', function(obj) MSCore = obj end)

-- Code

local BankStatus = {}

RegisterServerEvent('ms-banking:server:SetBankClosed')
AddEventHandler('ms-banking:server:SetBankClosed', function(BankId, bool)
  print(BankId)
  BankStatus[BankId] = bool
  TriggerClientEvent('ms-banking:client:SetBankClosed', -1, BankId, bool)
end)

RegisterServerEvent('bank:withdraw')
AddEventHandler('bank:withdraw', function(amount)
    local src = source
    local ply = MSCore.Functions.GetPlayer(src)
    local bankamount = ply.PlayerData.money["bank"]
    local amount = tonumber(amount)
    if bankamount >= amount and amount > 0 then
      ply.Functions.RemoveMoney('bank', amount, "Rút tiền từ ngân hàng")
      TriggerEvent("ms-log:server:CreateLog", "banking", "Rút tiền", "red", "**"..GetPlayerName(src) .. "** Đã rút $"..amount.." từ tài khoản ngân hàng")
      ply.Functions.AddMoney('cash', amount, "Rút tiền từ ngân hàng")
    else
      TriggerClientEvent('MSCore:Notify', src, 'Bạn không đủ tiền trong tài khoản :(', 'error')
    end
end)

RegisterServerEvent('bank:deposit')
AddEventHandler('bank:deposit', function(amount)
    local src = source
    local ply = MSCore.Functions.GetPlayer(src)
    local cashamount = ply.PlayerData.money["cash"]
    local amount = tonumber(amount)
    if cashamount >= amount and amount > 0 then
      ply.Functions.RemoveMoney('cash', amount, "Nộp tiền vào ngân hàng")
      TriggerEvent("ms-log:server:CreateLog", "banking", "Nộp tiền", "green", "**"..GetPlayerName(src) .. "** Đã nộp $"..amount.." vào tài khoản ngân hàng")
      ply.Functions.AddMoney('bank', amount, "Nộp tiền vào ngân hàng")
    else
      TriggerClientEvent('MSCore:Notify', src, 'Bạn không đủ tiền mặt :(', 'error')
    end
end)

MSCore.Commands.Add("duatien", "Đưa tiền cho người khác", {{name="id", help="ID người chơi"},{name="amount", help="Số tiền"}}, true, function(source, args)
  local Player = MSCore.Functions.GetPlayer(source)
  local TargetId = tonumber(args[1])
  local Target = MSCore.Functions.GetPlayer(TargetId)
  local amount = tonumber(args[2])
  
  if Target ~= nil then
    if amount ~= nil then
      if amount > 0 then
        if Player.PlayerData.money.cash >= amount and amount > 0 then
          if TargetId ~= source then
            TriggerClientEvent('banking:client:CheckDistance', source, TargetId, amount)
          else
            TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Bạn không thể đưa tiền cho chính mình")     
          end
        else
          TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Bạn không đủ tiền")
        end
      else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Số tiền phải lớn hơn 0")
      end
    else
      TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Nhập số tiền")
    end
  else
    TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Người chơi không trực tuyến")
  end    
end)

RegisterServerEvent('banking:server:giveCash')
AddEventHandler('banking:server:giveCash', function(trgtId, amount)
  local src = source
  local Player = MSCore.Functions.GetPlayer(src)
  local Target = MSCore.Functions.GetPlayer(trgtId)

  print(src)
  print(trgtId)

  if src ~= trgtId then
    Player.Functions.RemoveMoney('cash', amount, "Đã đưa tiền cho "..Player.PlayerData.citizenid)
    Target.Functions.AddMoney('cash', amount, "Đã nhận tiền từ "..Target.PlayerData.citizenid)

    TriggerEvent("ms-log:server:CreateLog", "banking", "Đưa tiền", "blue", "**"..GetPlayerName(src) .. "** đã đưa $"..amount.." cho **" .. GetPlayerName(trgtId) .. "**")
    
    TriggerClientEvent('MSCore:Notify', trgtId, "Bạn đã nhận $"..amount.." từ "..Player.PlayerData.charinfo.firstname.."!", 'success')
    TriggerClientEvent('MSCore:Notify', src, "Bạn đã đưa $"..amount.." cho "..Target.PlayerData.charinfo.firstname.."!", 'success')
  else
    TriggerEvent("ms-anticheat:server:banPlayer", "Cheating")
    TriggerEvent("ms-log:server:CreateLog", "anticheat", "Người chơi bị ban", "red", "** @everyone " ..GetPlayerName(player).. "** đã cố ý đưa **"..amount.." cho chính mình")  
  end
end)
