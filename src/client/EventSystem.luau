local EventSystem = {}

function EventSystem.new(ui, lighting, soundService, config, cameraSystem)
	local self = {}
	local baseBrightness = lighting.Brightness

	local function playSound(id, volume)
		if id == "" then
			return
		end
		local sound = Instance.new("Sound")
		sound.SoundId = id
		sound.Volume = volume or 0.5
		sound.Parent = soundService
		sound:Play()
		sound.Ended:Connect(function()
			sound:Destroy()
		end)
	end

	function self:trigger(eventType, duration)
		if eventType == "LightFlickerBurst" then
			local endTime = os.clock() + duration
			while os.clock() < endTime do
				lighting.Brightness = math.max(baseBrightness - 0.6, 0)
				task.wait(0.08)
				lighting.Brightness = baseBrightness
				task.wait(0.1)
			end
		elseif eventType == "FakeFootsteps" then
			playSound(config.EventSounds.Footsteps, 0.5)
		elseif eventType == "WrongCameraFeed" then
			if cameraSystem:isInSecurityView() then
				ui:setStatus("Camera feed corrupted...")
				task.wait(duration)
				ui:setStatus("")
			end
		elseif eventType == "RadioInterference" then
			ui:showDispatch()
			ui:setDispatch("[static] ...repeat... [static]")
			playSound(config.EventSounds.Radio, 0.4)
			task.wait(duration)
			ui:hideDispatch()
		elseif eventType == "HallwayShadow" then
			ui:setStatus("You saw something move...")
			playSound(config.EventSounds.Shadow, 0.4)
			task.wait(duration)
			ui:setStatus("")
		end
	end

	return self
end

return EventSystem
