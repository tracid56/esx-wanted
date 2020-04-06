ESX                = nil
truyna			={}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent("esx-wanted:sendhead")
AddEventHandler("esx-wanted:sendhead", function(url)
	TriggerClientEvent("esx-wanted:nhanhead", -1, url)
end)

RegisterServerEvent("esx-wanted:vitri")
AddEventHandler("esx-wanted:vitri", function(coords)
	local xPlayer = ESX.GetPlayerFromId(source)
	local name = xPlayer.getName()
	TriggerClientEvent("esx-wanted:hienblip", -1, source, coords, name)
end)

RegisterCommand("wanted", function(src, args, raw)

	local xPlayer = ESX.GetPlayerFromId(src)
	

	if xPlayer["job"]["name"] == "police" then

		local wantedPlayer = args[1]
		local wantedTime = tonumber(args[2])
		local wantedReason = args[3]

		if GetPlayerName(wantedPlayer) ~= nil then

			if wantedTime ~= nil then
				TriggerClientEvent('mythic_notify:client:SendAlert', wantedPlayer, { type = 'inform', text = "server gethead"})
				TriggerClientEvent('mythic_notify:client:SendAlert', -1, { type = 'inform', text = "server gethead toan server"})
				TriggerClientEvent("esx-wanted:gethead", wantedPlayer, wantedPlayer)
				WantedPlayer(wantedPlayer, wantedTime, wantedReason)

				TriggerClientEvent("esx:showNotification", src, GetPlayerName(wantedPlayer) .. " bi truy na trong " .. wantedTime .. " phut!")
				
				if args[3] ~= nil then
					GetWantedPlayerName(wantedPlayer, function(Firstname, Lastname)
						TriggerClientEvent('chat:addMessage', -1, { args = { "WANTED",  Firstname .. " " .. Lastname .. " đang bị truy nã với lý do: " .. args[3] }, color = { 249, 166, 0 } })
					end)
				end
			else
				TriggerClientEvent("esx:showNotification", src, "Thoi gian khong hop le!")
			end
		else
			TriggerClientEvent("esx:showNotification", src, "ID nay khong online!")
		end
	else
		TriggerClientEvent("esx:showNotification", src, "Ban khong co quyen truy na!")
	end
end)

RegisterCommand("unwanted", function(src, args)

	local xPlayer = ESX.GetPlayerFromId(src)

	if xPlayer["job"]["name"] == "police" then

		local wantedPlayer = args[1]

		if GetPlayerName(wantedPlayer) ~= nil then
			UnWanted(wantedPlayer)
		else
			TriggerClientEvent("esx:showNotification", src, "ID nay khong online!")
		end
	else
		TriggerClientEvent("esx:showNotification", src, "Ban khong co quyen truy na!")
	end
end)

RegisterServerEvent("esx-wanted:wantedPlayer")
AddEventHandler("esx-wanted:wantedPlayer", function(targetSrc, wantedTime, wantedReason)
	local src = source
	local targetSrc = tonumber(targetSrc)
	TriggerClientEvent("esx-wanted:gethead", targetSrc, targetSrc)	
	WantedPlayer(targetSrc, wantedTime, wantedReason)
end)

RegisterServerEvent("esx-wanted:unWantedPlayer")
AddEventHandler("esx-wanted:unWantedPlayer", function(targetIdentifier)
	local src = source
	local xPlayer = ESX.GetPlayerFromIdentifier(targetIdentifier)

	if xPlayer ~= nil then
		UnWanted(xPlayer.source)
	else
		MySQL.Async.execute(
			"UPDATE users SET wanted = @newWantedTime WHERE identifier = @identifier",
			{
				['@identifier'] = targetIdentifier,
				['@newWantedTime'] = 0
			}
		)
	end

	TriggerClientEvent("esx:showNotification", src, xPlayer.name .. " Unwanted!")
end)

RegisterServerEvent("esx-wanted:updateWantedTime")
AddEventHandler("esx-wanted:updateWantedTime", function(newWantedTime)
	local src = source

	EditwantedTime(src, newWantedTime)
end)

RegisterServerEvent("esx-wanted:unWanted")
AddEventHandler("esx-wanted:unWanted", function()
	TriggerClientEvent('esx-wanted:unWanted', -1, source)
end)

function WantedPlayer(wantedPlayer, wantedTime, wantedReason)
	print(wantedPlayer)
	local targetPlayer = ESX.GetPlayerFromId(wantedPlayer)
	local name = targetPlayer.getName()
	local Reason = wantedReason
	if Reason == nil or Reason == "" then
		Reason = 'Không rõ'
	end
	TriggerClientEvent("esx-wanted:wantedPlayer", wantedPlayer, wantedTime)
	TriggerClientEvent("esx-wanted:openui", -1, name, wantedTime, wantedPlayer, Reason)

	EditwantedTime(wantedPlayer, wantedTime)
end

function UnWanted(wantedPlayer)
	TriggerClientEvent("esx-wanted:unWantedPlayer", wantedPlayer)
	EditwantedTime(wantedPlayer, 0)
end

function EditwantedTime(source, wantedTime)

	local src = source

	local xPlayer = ESX.GetPlayerFromId(src)
	local Identifier = xPlayer.identifier

	MySQL.Async.execute(
       "UPDATE users SET wanted = @newWantedTime WHERE identifier = @identifier",
        {
			['@identifier'] = Identifier,
			['@newWantedTime'] = tonumber(wantedTime)
		}
	)
end

function GetWantedPlayerName(playerId, data)
	local Identifier = ESX.GetPlayerFromId(playerId).identifier

	MySQL.Async.fetchAll("SELECT firstname, lastname FROM users WHERE identifier = @identifier", { ["@identifier"] = Identifier }, function(result)

		data(result[1].firstname, result[1].lastname)

	end)
end

ESX.RegisterServerCallback("esx-wanted:retrieveWantededPlayers", function(source, cb)
	
	local wantededPersons = {}

	MySQL.Async.fetchAll("SELECT firstname, lastname, wanted, identifier FROM users WHERE wanted > @wanted", { ["@wanted"] = 0 }, function(result)

		for i = 1, #result, 1 do
			table.insert(wantededPersons, { name = result[i].firstname .. " " .. result[i].lastname, wantedTime = result[i].wanted, identifier = result[i].identifier })
		end

		cb(wantededPersons)
	end)
end)

ESX.RegisterServerCallback("esx-wanted:retrieveWantedTime", function(source, cb)

	local src = source

	local xPlayer = ESX.GetPlayerFromId(src)
	local Identifier = xPlayer.identifier


	MySQL.Async.fetchAll("SELECT wanted FROM users WHERE identifier = @identifier", { ["@identifier"] = Identifier }, function(result)

		local WantedTime = tonumber(result[1].wanted)

		if WantedTime ~= nil and WantedTime > 0 then

			cb(true, WantedTime)
		else
			cb(false, 0)
		end

	end)
end)