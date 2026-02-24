local EventSystem = {}

function EventSystem.new(players, remotes, config)
	local self = {}
	local running = false

	local events = {
		{ name = "LightFlickerBurst", duration = 2.5, all = true },
		{ name = "FakeFootsteps", duration = 4, all = false },
		{ name = "WrongCameraFeed", duration = 5, all = false },
		{ name = "RadioInterference", duration = 6, all = true },
		{ name = "HallwayShadow", duration = 3, all = false },
	}

	local function pickPlayer()
		local list = players:GetPlayers()
		if #list == 0 then
			return nil
		end
		return list[math.random(1, #list)]
	end

	function self:start()
		if running then
			return
		end
		running = true
		task.spawn(function()
			while running do
				local waitTime = math.random(config.EventIntervalMin, config.EventIntervalMax)
				task.wait(waitTime)

				local event = events[math.random(1, #events)]
				if event.all then
					remotes.HorrorEvent:FireAllClients(event.name, event.duration)
				else
					local player = pickPlayer()
					if player then
						remotes.HorrorEvent:FireClient(player, event.name, event.duration)
					end
				end
			end
		end)
	end

	return self
end

return EventSystem
