QBCore = exports['qb-core']:GetCoreObject()




local Weeks = {
	['1']  = "WEEK_1", ['2']  = "WEEK_1", ['3']  = "WEEK_1", ['4']  = "WEEK_1", ['5']  = "WEEK_1", ['6']  = "WEEK_1", ['7']  = "WEEK_1", 
	['8']  = "WEEK_2", ['9']  = "WEEK_2", ['10'] = "WEEK_2", ['11'] = "WEEK_2", ['12'] = "WEEK_2", ['13'] = "WEEK_2", ['14'] = "WEEK_2", 
	['15'] = "WEEK_3", ['16'] = "WEEK_3", ['17'] = "WEEK_3", ['18'] = "WEEK_3", ['19'] = "WEEK_3", ['20'] = "WEEK_3", ['21'] = "WEEK_3", 
	['22'] = "WEEK_4", ['23'] = "WEEK_4", ['24'] = "WEEK_4", ['25'] = "WEEK_4", ['26'] = "WEEK_4", ['27'] = "WEEK_4", ['28'] = "WEEK_4", 
}

local WeekDays = {
	['WEEK_1']  = {check = 7, start = 0}, ['WEEK_2']  = {check = 14, start = 7}, ['WEEK_3'] = {check = 21, start = 14}, ['WEEK_4'] = {check = 28, start = 21},
}

local isAllowedToClose = false

local guiEnabled, isDead = false, false
local myIdentity = {}

local uiType = 'enable_dailyrewards'

cachedData = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
	Citizen.SetTimeout(100, function()
		Wait(7000)
		TriggerServerEvent('tp-dailyrewards:loadPlayerInformation')
	end)
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		SetNuiFocus(false,false)
    end
end)

AddEventHandler('hospital:server:SetDeathStatus', function(data)
	isDead = true

	if guiEnabled then
		EnableGui(false, uiType)
	end
end)

AddEventHandler('playerSpawned', function(spawn)
	isDead = false
end)

function EnableGui(state, ui)
	SetNuiFocus(state, state)
	guiEnabled = state

	SendNUIMessage({
		type = ui,
		enable = state
	})
end

RegisterNUICallback('closeNUI', function()
	EnableGui(false, uiType)
end)

function closeUI()
	EnableGui(false, uiType)
end


RegisterNetEvent("tp-dailyrewards:refreshData")
AddEventHandler("tp-dailyrewards:refreshData", function()
	SendNUIMessage({
		action = 'refreshData',
	})	
end)


RegisterNetEvent('tp-dailyrewards:openDailyRewards')
AddEventHandler('tp-dailyrewards:openDailyRewards', function()
TriggerServerEvent('tp-dailyrewards:loadPlayerInformation')
Wait(2000)
	if not isDead then

		QBCore.Functions.TriggerCallback('tp-dailyrewards:fetchUserInformation', function(cb) 

			local week = Weeks[tostring(cb.day)]
			local weekDays = WeekDays[ week ]
	
			SendNUIMessage({
				action = 'mainData',
				daysCheck = weekDays.check,
				daysStart = weekDays.start,
				currentWeek =  week
			})	

			uiType = "enable_loading"

			EnableGui(true, uiType)

			Wait(200)

			for k,v in pairs(Config.DailyRewards[ week ]) do


				if cb.received == 0 and v.day == cb.day then
					SendNUIMessage({
						action = 'addDays',
						day_detail = v.dayReward,
						status = 'canClaim'
					})
				elseif (v.day < cb.day) or (cb.received == 1 and v.day == cb.day) then
					SendNUIMessage({
						action = 'addDays',
						day_detail = v.dayReward,
						status = 'claimed'
					})					
				else
	
					SendNUIMessage({
						action = 'addDays',
						day_detail = v.dayReward,
						status = 'waiting',
					})
				end
			end
	
	
			SendNUIMessage({
				action        = 'addPlayerDetails',
				current_day   = cb.current_day,
				day           = cb.day,
				received_hour = cb.received_hour
			})
			
			uiType = "enable_dailyrewards"
			
			EnableGui(true, uiType)

		end)
			 
	end
end)

RegisterNUICallback('claimRewards', function (data)
	TriggerServerEvent('tp-dailyrewards:claimReward', Weeks[ tostring(data.day) ], data.day)
end)


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if guiEnabled then


			DisableControlAction(0, 1,   true) -- LookLeftRight
			DisableControlAction(0, 2,   true) -- LookUpDown
			DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
			DisableControlAction(0, 142, true) -- MeleeAttackAlternate
			DisableControlAction(0, 30,  true) -- MoveLeftRight
			DisableControlAction(0, 31,  true) -- MoveUpDown
			DisableControlAction(0, 21,  true) -- disable sprint
			DisableControlAction(0, 24,  true) -- disable attack
			DisableControlAction(0, 25,  true) -- disable aim
			DisableControlAction(0, 47,  true) -- disable weapon
			DisableControlAction(0, 58,  true) -- disable weapon
			DisableControlAction(0, 263, true) -- disable melee
			DisableControlAction(0, 264, true) -- disable melee
			DisableControlAction(0, 257, true) -- disable melee
			DisableControlAction(0, 140, true) -- disable melee
			DisableControlAction(0, 141, true) -- disable melee
			DisableControlAction(0, 143, true) -- disable melee
			DisableControlAction(0, 75,  true) -- disable exit vehicle
			DisableControlAction(27, 75, true) -- disable exit vehicle
		else
			Citizen.Wait(1000)
		end
	end
end)
	exports['qb-target']:RemoveZone("rewardsguy")
	local pos = Config.rewards
	print(pos)
	exports['qb-target']:AddBoxZone("rewardsguy", vector3(pos.x, pos.y, pos.z), 0.5, 0.5, {
      name = "rewardsguy", 
      heading = 100, 
      debugPoly = false, 
      minZ = pos.z -0.1, 
      maxZ = pos.z +1.5, 
    }, {
      options = { 
        {
          type = "client",
          event = "tp-dailyrewards:openDailyRewards", 
          icon = "fa-solid fa-gift", 
          label = "Claim Rewards", 
        },
      },
      distance = 2.5,
    })