local GameConfig = {}

GameConfig.Tasks = {
	{ id = "restore_power", text = "Restore power in the generator room" },
	{ id = "check_cameras", text = "Check the security cameras" },
	{ id = "reset_generators", text = "Reset backup generators" },
}

GameConfig.FlashlightMax = 100
GameConfig.FlashlightDrainRate = 6

GameConfig.PromptHoldDuration = 1

GameConfig.FlickerIntervalMin = 6
GameConfig.FlickerIntervalMax = 14
GameConfig.FlickerDepthMin = 0.2
GameConfig.FlickerDepthMax = 0.5
GameConfig.FlickerDurationMin = 0.08
GameConfig.FlickerDurationMax = 0.2

GameConfig.SoundIds = {
	Ambient = "",
	Footsteps = "rbxassetid://6506537704",
	Whispers = "rbxassetid://1228230799",
	Breathing = "rbxassetid://180315285",
	Heartbeat = "rbxassetid://1844272296",
}

GameConfig.SoundBaseVolumes = {
	Ambient = 0.18,
	Footsteps = 0.35,
	Whispers = 0.25,
	Breathing = 0.3,
	Heartbeat = 0.4,
}

GameConfig.SoundMinDistance = 6
GameConfig.SoundMaxDistance = 50

GameConfig.HeartbeatMinSpeed = 0.9
GameConfig.HeartbeatMaxSpeed = 1.4

GameConfig.VignetteImageId = ""
GameConfig.VignetteMaxAlpha = 0.6

GameConfig.CameraViewMusicId = ""

GameConfig.GeneratorMaxFuel = 100
GameConfig.GeneratorDrainSeconds = 120
GameConfig.GeneratorUseDistance = 8

GameConfig.GasCanMinFuel = 20
GameConfig.GasCanMaxFuel = 60
GameConfig.GasCanSpawnCount = 4
GameConfig.GasCanToolName = "Gas Can"
GameConfig.GasCanSpawnName = "GasCanSpawn"

GameConfig.CameraNames = {
	"CameraA",
	"CameraB",
	"CameraC",
	"CameraD",
	"CameraE",	
}

GameConfig.EventIntervalMin = 60
GameConfig.EventIntervalMax = 120
GameConfig.EventSounds = {
	Footsteps = "",
	Radio = "",
	Shadow = "",
}

GameConfig.MonsterMoveInterval = 6
GameConfig.MonsterActivationChance = 0.05
GameConfig.MonsterDeactivationChance = 0.03
GameConfig.MonsterKillDistance = 6
GameConfig.LookDotThreshold = 0.85

GameConfig.MonsterPatrolPoints = {
	Vector3.new(-24, 4, 12),
	Vector3.new(18, 4, -8),
	Vector3.new(4, 4, 22),
	Vector3.new(-12, 4, -20),
}

return GameConfig
