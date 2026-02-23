local Flashlight = {}

function Flashlight.new(camera, ui, config)
	local self = {}
	local battery = config.FlashlightMax
	local flashlightOn = false

	local light = Instance.new("PointLight")
	light.Name = "Flashlight"
	light.Range = 22
	light.Brightness = 2
	light.Enabled = false
	light.Parent = camera

	function self:isOn()
		return flashlightOn
	end

	function self:toggle()
		flashlightOn = not flashlightOn and battery > 0
		light.Enabled = flashlightOn
		ui:setStatus(flashlightOn and "Flashlight on" or "")
		return flashlightOn
	end

	function self:update(dt)
		if flashlightOn then
			battery -= config.FlashlightDrainRate * dt
			if battery <= 0 then
				battery = 0
				flashlightOn = false
				light.Enabled = false
				ui:setStatus("")
			end
		end

		local percent = math.floor((battery / config.FlashlightMax) * 100)
		ui:setBattery(percent)
	end

	return self
end

return Flashlight
