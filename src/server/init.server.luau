local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.GameConfig)

local Remotes = require(script:WaitForChild("Remotes"))
local TaskSystem = require(script:WaitForChild("TaskSystem"))
local MonsterSystem = require(script:WaitForChild("MonsterSystem"))
local EventSystem = require(script:WaitForChild("EventSystem"))

local remotes = Remotes.ensure({
	"TaskUpdate",
	"TaskComplete",
	"HideRequest",
	"LookReport",
	"MonsterState",
	"CameraMenu",
	"CameraViewed",
	"Cutscene",
	"HorrorEvent",
	"BasementClimax",
	"Ending",
})

local taskSystem = TaskSystem.new(Config, Workspace, remotes)
local monsterSystem = MonsterSystem.new(Config, Workspace, Players, remotes.MonsterState)
local eventSystem = EventSystem.new(Players, remotes, Config)

Players.PlayerAdded:Connect(function(player)
	player:SetAttribute("IsHidden", false)
	player:SetAttribute("IsLookingAtMonster", false)
	player.CharacterAdded:Connect(function()
		player:SetAttribute("IsHidden", false)
	end)
	task.wait(1)
	taskSystem:broadcastTask()
	remotes.Cutscene:FireClient(player, "Opening")
end)

remotes.TaskComplete.OnServerEvent:Connect(function(player, taskId)
	taskSystem:handleTaskComplete(taskId)
end)

remotes.HideRequest.OnServerEvent:Connect(function(player, hideState)
	player:SetAttribute("IsHidden", hideState == true)
end)

remotes.LookReport.OnServerEvent:Connect(function(player, isLooking)
	player:SetAttribute("IsLookingAtMonster", isLooking == true)
end)

remotes.CameraViewed.OnServerEvent:Connect(function(player, cameraName)
	taskSystem:recordCameraViewed(player, cameraName)
end)

RunService.Heartbeat:Connect(function(dt)
	monsterSystem:update(dt)
end)

taskSystem:initialize()
eventSystem:start()
