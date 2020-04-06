local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}
ESX = nil
PlayerData = {}
local wantedTime = 0
local blip2 = nil
local wantedBlip = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData() == nil do
		Citizen.Wait(10)
	end
	PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(newData)
	PlayerData = newData
	Citizen.Wait(25000)
	ESX.TriggerServerCallback("esx-wanted:retrieveWantedTime", function(inWanted, newWantedTime)
		if inWanted then
			wantedTime = newWantedTime
			WantedLogin()
		end
	end)
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(response)
	PlayerData["job"] = response
end)

RegisterNetEvent("esx-wanted:gethead")
AddEventHandler("esx-wanted:gethead", function(tartgetPed)
	local mugshot, mugshotStr = ESX.Game.GetPedMugshot(PlayerPedId())
	ESX.ShowAdvancedNotification('WANTED', '<FONT FACE="Tahoma">TRUY NA', 'Thông báo truy nã đối tượng '..GetPlayerName(GetPlayerFromServerId(tartgetPed)), mugshotStr, 1)
	UnregisterPedheadshot(mugshot)
	exports['mugshotbk']:getMugshotUrl(PlayerPedId(), function ( url )
		print(url)
		TriggerServerEvent("esx-wanted:sendhead", url)
	end)
end)

RegisterNetEvent("esx-wanted:nhanhead")
AddEventHandler("esx-wanted:nhanhead", function(url)
	SendNUIMessage(
		{
			update = true,
			url = url,
		}
	)
end)

RegisterNetEvent("esx-wanted:openui")
AddEventHandler("esx-wanted:openui", function(ten, thoigian, id, lydo)	
	tg = tonumber(thoigian)
	if tg < 60 then
		h = 0
		m = thoigian
	else
		h = math.floor(thoigian / 60)
		m = thoigian - (h * 60)
	end
	SendNUIMessage(
		{
			display = true,
			ten = ten,
			thoigian = thoigian,
			id = id,
			lydo = lydo,
			h = h,
			m = thoigian,
		}
	)
	Citizen.Wait(60000)
	SendNUIMessage(
		{
			display = false,
		}
	)
end)

RegisterNetEvent("esx-wanted:hienblip")
AddEventHandler("esx-wanted:hienblip", function(target, blip, name)
	if wantedBlip[target] ~= nil then 
		RemoveBlip(wantedBlip[target])
		wantedBlip[target] = nil 
		wantedBlip[target] = AddBlipForCoord( blip.x, blip.y, blip.z)
		SetBlipSprite(wantedBlip[target], 458)
		SetBlipColour(wantedBlip[target], 1)
		SetBlipScale(wantedBlip[target], 0.8)
		SetBlipAsShortRange(wantedBlip[target], false)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(name)
		EndTextCommandSetBlipName(wantedBlip[target])
	else 
		wantedBlip[target] = AddBlipForCoord( blip.x, blip.y, blip.z)
		SetBlipSprite(wantedBlip[target], 458)
		SetBlipColour(wantedBlip[target], 1)
		SetBlipScale(wantedBlip[target], 0.8)
		SetBlipAsShortRange(wantedBlip[target], false)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(name)
		EndTextCommandSetBlipName(wantedBlip[target])
	end
end)

RegisterNetEvent("esx-wanted:openWantedMenu")
AddEventHandler("esx-wanted:openWantedMenu", function()
	OpenWantedMenu()
end)

RegisterNetEvent("esx-wanted:wantedPlayer")
AddEventHandler("esx-wanted:wantedPlayer", function(newWantedTime)
	wantedTime = newWantedTime
	InWanted()
	TriggerEvent("pNotify:SendNotification",{
					text = "<b style='color:#1E90FF'>Bạn đang bị truy nã trong thời gian :</b>".. wantedTime .. "Phút ",
					type = "warning",
					timeout = (6000),
					layout = "topcenter",
					queue = "global"
			})
end)

RegisterNetEvent("esx-wanted:unWantedPlayer")
AddEventHandler("esx-wanted:unWantedPlayer", function()
	wantedTime = 0

	UnWanted()
end)

function WantedLogin()
	InWanted()
	TriggerEvent("pNotify:SendNotification",{
					text = "<b style='color:#1E90FF'>Lần trước bạn bị truy nã xong quit nên giờ bạn vẫn đang bị truy nã</b>",
					type = "error",
					timeout = (6000),
					layout = "topcenter",
					queue = "global"
				})	
end

function UnWanted()
	TriggerServerEvent('esx-wanted:unWanted')
	TriggerEvent("pNotify:SendNotification",{
					text = "<b style='color:#1E90FF'>Bạn đã hết bị truy nã</b>",
					type = "error",
					timeout = (6000),
					layout = "topcenter",
					queue = "global"
				})
end

RegisterNetEvent('esx-wanted:unWanted')
AddEventHandler('esx-wanted:unWanted', function(target)
	if wantedBlip[target] ~= nil then 
		RemoveBlip(wantedBlip[target])
		wantedBlip[target] = nil 
	end
end)

function InWanted()
	Citizen.CreateThread(function()
		while wantedTime > 0  do
			TriggerEvent("pNotify:SendNotification",{
				text = "<b style='color:#1E90FF'>Bạn đang bị truy nã với thời gian</b>" .. wantedTime .. " phút ",
				type = "warning",
				timeout = (60000),
				layout = "topcenter",
				queue = "global"
			})
			local playerPed = PlayerPedId()
			local PedPosition = GetEntityCoords(playerPed)
			TriggerServerEvent("esx-wanted:vitri", PedPosition)
			Wait(15000)
			local PedPosition = GetEntityCoords(playerPed)
			TriggerServerEvent("esx-wanted:vitri", PedPosition)
			Wait(15000)
			local PedPosition = GetEntityCoords(playerPed)
			TriggerServerEvent("esx-wanted:vitri", PedPosition)
			Wait(15000)
			local PedPosition = GetEntityCoords(playerPed)
			TriggerServerEvent("esx-wanted:vitri", PedPosition)
			Wait(15000)
			local PedPosition = GetEntityCoords(playerPed)
			TriggerServerEvent("esx-wanted:vitri", PedPosition)
			wantedTime = wantedTime - 1
			if wantedTime == 0 then
				UnWanted()
				TriggerServerEvent("esx-wanted:updateWantedTime", 0)
			end
			
			TriggerServerEvent("esx-wanted:updateWantedTime", wantedTime)
		end		
	end)
end
RegisterCommand("wantedmenu", function(source, args)
	--OpenWantedMenu()
	if PlayerData.job.name == "police" then
		OpenWantedMenu()
	else
		ESX.ShowNotification("Bạn không phải là cảnh sát!")
	end
end)

function OpenWantedMenu()
	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'wanted_prison_menu',
		{
			title    = "Quản lý truy nã",
			align    = 'center',
			elements = {
				{ label = "Truy nã người chơi", value = "wanted_closest_player" },
				{ label = "Quản lý người chơi trong DS truy nã", value = "unwanted_player" }
			}
		}, 
	function(data, menu)

		local action = data.current.value

		if action == "wanted_closest_player" then

			menu.close()

			ESX.UI.Menu.Open(
          		'dialog', GetCurrentResourceName(), 'wanted_choose_id',
          		{
            		title = "ID người chơi"
          		},
          	function(data2, menu2)

            	local targetId = tonumber(data2.value)

            	if targetId == nil then
              		ESX.ShowNotification("Bạn chưa nhập id người cần truy nã")
            	else
              		menu2.close()
					ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'wanted_time', {
						title = "Thời gian truy nã"
					}, function(data3 , menu3)
						local time = tonumber(data3.value)
						if time == nil or time == 0 then 
							ESX.ShowNotification("Bạn chưa nhập thời gian truy nã")
						else 
							menu3.close()
							ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'wanted_reason', {
								title = 'Lý do truy nã'
							}, function(data4, menu4)
								local reason = data4.value
								TriggerServerEvent('esx-wanted:wantedPlayer', targetId, time, reason)
								menu4.close()
							end, function(data4, menu4)
								menu4.close()
							end)
						end 
					end, function(data3, menu3)
						menu3.close()
					end)
				end
          	end, function(data2, menu2)
				menu2.close()
			end)
		elseif action == "unwanted_player" then

			local elements = {}

			ESX.TriggerServerCallback("esx-wanted:retrieveWantededPlayers", function(playerArray)

				if #playerArray == 0 then
					ESX.ShowNotification("Không có ai trong danh sách truy nã")
					return
				end

				for i = 1, #playerArray, 1 do
					table.insert(elements, {label = "Truy Nã: " .. playerArray[i].name .. " | Thời Gian: " .. playerArray[i].wantedTime .. " Phút", value = playerArray[i].identifier })
				end

				ESX.UI.Menu.Open(
					'default', GetCurrentResourceName(), 'wanted_unwanted_menu',
					{
						title = "Danh sách truy nã",
						align = "center",
						elements = elements
					},
				function(data2, menu2)

					local action = data2.current.value

					TriggerServerEvent("esx-wanted:unWantedPlayer", action)

					menu2.close()

				end, function(data2, menu2)
					menu2.close()
				end)
			end)

		end

	end, function(data, menu)
		menu.close()
	end)	
end

