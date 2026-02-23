local LightingFlicker = {}

function LightingFlicker.new(config, lighting)
	local self = {}
	local nextFlickerTime = os.clock() + math.random() * (config.FlickerIntervalMax - config.FlickerIntervalMin) + config.FlickerIntervalMin
	local flickerEndTime = 0
	local baseBrightness = lighting.Brightness

	function self:update()
		local now = os.clock()
		if now >= nextFlickerTime then
			local depth = math.random() * (config.FlickerDepthMax - config.FlickerDepthMin) + config.FlickerDepthMin
			local duration = math.random() * (config.FlickerDurationMax - config.FlickerDurationMin) + config.FlickerDurationMin
			flickerEndTime = now + duration
			lighting.Brightness = math.max(baseBrightness - depth, 0)
			nextFlickerTime = now + math.random() * (config.FlickerIntervalMax - config.FlickerIntervalMin) + config.FlickerIntervalMin
		elseif flickerEndTime > 0 and now >= flickerEndTime then
			lighting.Brightness = baseBrightness
			flickerEndTime = 0
		end
	end

	return self
end

return LightingFlicker
