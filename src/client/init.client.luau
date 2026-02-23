local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local Ui = require(script:WaitForChild("Ui"))
local Flashlight = require(script:WaitForChild("Flashlight"))
local AudioSystem = require(script:WaitForChild("AudioSystem"))
local LightingFlicker = require(script:WaitForChild("LightingFlicker"))
local CameraSystem = require(script:WaitForChild("CameraSystem"))

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local Config = require(ReplicatedStorage.Shared.GameConfig)
local ui = Ui.create(player, Config)
local flashlight = Flashlight.new(camera, ui, Config)
local audio = AudioSystem.new(Config, ui)
local flicker = LightingFlicker.new(Config, Lighting)

ui.screenGui.Enabled = true
ProximityPromptService.Enabled = true

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local taskUpdateRemote = remotes:WaitForChild("TaskUpdate")
local hideRequestRemote = remotes:WaitForChild("HideRequest")
local lookReportRemote = remotes:WaitForChild("LookReport")
local monsterStateRemote = remotes:WaitForChild("MonsterState")
local cameraMenuRemote = remotes:WaitForChild("CameraMenu")

local cameraSystem = CameraSystem.new({
	player = player,
	camera = camera,
	ui = ui,
	config = Config,
	services = {
		UserInputService = UserInputService,
		ContextActionService = ContextActionService,
		ProximityPromptService = ProximityPromptService,
		Workspace = Workspace,
	},
	statusFallback = function()
		return flashlight:isOn() and "Flashlight on" or ""
	end,
})
cameraSystem:initialize()

local currentTaskId = ""
local lastLookReport = 0
local isHidden = false
local monsterPosition = Vector3.new()
local monsterActive = false

local function toggleHide()
	isHidden = not isHidden
	hideRequestRemote:FireServer(isHidden)
	if isHidden then
		ui:setStatus("Hidden")
	else
		ui:setStatus(flashlight:isOn() and "Flashlight on" or "")
	end
end

taskUpdateRemote.OnClientEvent:Connect(function(index, total, taskId, text)
	currentTaskId = taskId
	ui:setTask(string.format("Task %d/%d: %s", index, total, text))
end)

monsterStateRemote.OnClientEvent:Connect(function(active, position)
	monsterActive = active
	monsterPosition = position
end)

cameraMenuRemote.OnClientEvent:Connect(function()
	cameraSystem:onMenuRemote()
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if cameraSystem:handleInput(input, processed) then
		return
	end

	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.F then
		flashlight:toggle()
	elseif input.KeyCode == Enum.KeyCode.H then
		toggleHide()
	end
end)

RunService.RenderStepped:Connect(function(dt)
	cameraSystem:update()
	flashlight:update(dt)
	audio:update(monsterActive, monsterPosition, player)
	flicker:update()

	if os.clock() - lastLookReport >= 0.2 then
		local isLooking = false
		if monsterActive then
			local toMonster = (monsterPosition - camera.CFrame.Position)
			if toMonster.Magnitude > 0 then
				local direction = toMonster.Unit
				local dot = camera.CFrame.LookVector:Dot(direction)
				isLooking = dot >= Config.LookDotThreshold
			end
		end
		lookReportRemote:FireServer(isLooking)
		lastLookReport = os.clock()
	end
end)

flashlight:update(0)
