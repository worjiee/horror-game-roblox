local SoundService = game:GetService("SoundService")

local AudioSystem = {}

local function getOrCreateSound(name, soundId, volume, looped)
	local sound = SoundService:FindFirstChild(name)
	if not sound then
		sound = Instance.new("Sound")
		sound.Name = name
		sound.Parent = SoundService
	end
	if soundId ~= "" then
		sound.SoundId = soundId
	end
	sound.Volume = volume
	sound.Looped = looped
	return sound
end

function AudioSystem.new(config, ui)
	local self = {}

	local ambientSound = getOrCreateSound("AmbientLoop", config.SoundIds.Ambient, config.SoundBaseVolumes.Ambient, true)
	local footstepsSound = getOrCreateSound("MonsterFootsteps", config.SoundIds.Footsteps, 0, true)
	local whispersSound = getOrCreateSound("Whispers", config.SoundIds.Whispers, 0, true)
	local breathingSound = getOrCreateSound("Breathing", config.SoundIds.Breathing, 0, true)
	local heartbeatSound = getOrCreateSound("Heartbeat", config.SoundIds.Heartbeat, 0, true)

	if ambientSound.SoundId ~= "" then
		ambientSound:Play()
	end
	if footstepsSound.SoundId ~= "" then
		footstepsSound:Play()
	end
	if whispersSound.SoundId ~= "" then
		whispersSound:Play()
	end
	if breathingSound.SoundId ~= "" then
		breathingSound:Play()
	end
	if heartbeatSound.SoundId ~= "" then
		heartbeatSound:Play()
	end

	function self:update(monsterActive, monsterPosition, player)
		if not monsterActive then
			footstepsSound.Volume = 0
			whispersSound.Volume = 0
			breathingSound.Volume = 0
			heartbeatSound.Volume = 0
			ui:setVignetteAlpha(0)
			return
		end

		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not root then
			return
		end

		local distance = (root.Position - monsterPosition).Magnitude
		local clamped = math.clamp((config.SoundMaxDistance - distance) / (config.SoundMaxDistance - config.SoundMinDistance), 0, 1)
		local intensity = clamped * clamped

		footstepsSound.Volume = config.SoundBaseVolumes.Footsteps * intensity
		whispersSound.Volume = config.SoundBaseVolumes.Whispers * intensity
		breathingSound.Volume = config.SoundBaseVolumes.Breathing * intensity
		heartbeatSound.Volume = config.SoundBaseVolumes.Heartbeat * intensity
		heartbeatSound.PlaybackSpeed = config.HeartbeatMinSpeed + (config.HeartbeatMaxSpeed - config.HeartbeatMinSpeed) * intensity

		ui:setVignetteAlpha(config.VignetteMaxAlpha * intensity)
	end

	return self
end

return AudioSystem
