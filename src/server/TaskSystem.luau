local TaskSystem = {}

function TaskSystem.new(config, workspace, remotes)
	local self = {}
	local tasks = config.Tasks
	local currentTaskIndex = 1
	local cameraPromptDebounce = {}
	local requiredCameraNames = config.CameraNames or { "CameraA", "CameraB" }
	local cameraViewsByPlayer = {}

	local taskPromptBindings = {
		restore_power = { partName = "Generator", actionText = "Restore Power" },
		check_cameras = { partName = "CameraTerminal", actionText = "Check Cameras" },
		reset_generators = { partName = "BackupGenerator", actionText = "Reset Generator" },
	}

	local function getCurrentTask()
		return tasks[currentTaskIndex]
	end

	local function clearCameraViews()
		cameraViewsByPlayer = {}
	end

	local function getCameraViewState(player)
		local state = cameraViewsByPlayer[player]
		if not state then
			state = {}
			cameraViewsByPlayer[player] = state
		end
		return state
	end

	local function hasViewedAllCameras(player)
		local state = cameraViewsByPlayer[player]
		if not state then
			return false
		end
		for _, name in ipairs(requiredCameraNames) do
			if not state[name] then
				return false
			end
		end
		return true
	end

	local function getFacilityPart(partName)
		local facility = workspace:FindFirstChild("Facility")
		if not facility then
			return nil
		end
		return facility:FindFirstChild(partName)
	end

	function self:broadcastTask()
		local currentTask = getCurrentTask()
		if currentTask then
			remotes.TaskUpdate:FireAllClients(currentTaskIndex, #tasks, currentTask.id, currentTask.text)
		else
			remotes.TaskUpdate:FireAllClients(#tasks, #tasks, "complete", "All tasks complete")
		end
	end

	function self:completeTask(taskId)
		local currentTask = getCurrentTask()
		if not currentTask or taskId ~= currentTask.id then
			return false
		end

		currentTaskIndex += 1
		if getCurrentTask() and getCurrentTask().id == "check_cameras" then
			clearCameraViews()
		end
		self:broadcastTask()
		if taskId == "reset_generators" then
			remotes.BasementClimax:FireAllClients()
			task.delay(6, function()
				remotes.Ending:FireAllClients()
			end)
		end
		return true
	end

	function self:recordCameraViewed(player, cameraName)
		if not cameraName or cameraName == "" then
			return
		end
		local state = getCameraViewState(player)
		state[cameraName] = true
		local currentTask = getCurrentTask()
		if currentTask and currentTask.id == "check_cameras" and hasViewedAllCameras(player) then
			self:completeTask("check_cameras")
		end
	end

	function self:ensurePromptForTask(taskId)
		local binding = taskPromptBindings[taskId]
		if not binding then
			return
		end

		local part = getFacilityPart(binding.partName)
		if not part then
			warn("Missing facility part for task:", taskId, binding.partName)
			return
		end

		local prompt = part:FindFirstChild("TaskPrompt")
		if not prompt then
			prompt = Instance.new("ProximityPrompt")
			prompt.Name = "TaskPrompt"
			prompt.Parent = part
		end
		prompt.ActionText = binding.actionText
		prompt.ObjectText = "Task"
		prompt.HoldDuration = config.PromptHoldDuration
		prompt.RequiresLineOfSight = false
		prompt.MaxActivationDistance = 10
		prompt.Enabled = true
		prompt:SetAttribute("TaskId", taskId)

		prompt.Triggered:Connect(function(player)
			if taskId == "check_cameras" then
				remotes.CameraMenu:FireClient(player)
				if hasViewedAllCameras(player) then
					self:completeTask(taskId)
				end
				return
			end
			self:completeTask(taskId)
		end)
	end

	function self:ensureCameraPrompt()
		local terminal = getFacilityPart("CameraTerminal")
		if not terminal then
			warn("Missing CameraTerminal for camera prompt")
			return
		end

		local prompt = terminal:FindFirstChild("CameraUsePrompt")
		if not prompt then
			prompt = Instance.new("ProximityPrompt")
			prompt.Name = "CameraUsePrompt"
			prompt.Parent = terminal
		end
		prompt.ActionText = "Use Cameras"
		prompt.ObjectText = "Security Terminal"
		prompt.HoldDuration = 0.4
		prompt.RequiresLineOfSight = false
		prompt.MaxActivationDistance = 10
		prompt.Enabled = true

		prompt.Triggered:Connect(function(player)
			local now = os.clock()
			local lastTime = cameraPromptDebounce[player]
			if lastTime and now - lastTime < 0.5 then
				return
			end
			cameraPromptDebounce[player] = now
			remotes.CameraMenu:FireClient(player)
			local currentTask = getCurrentTask()
			if currentTask and currentTask.id == "check_cameras" and hasViewedAllCameras(player) then
				self:completeTask("check_cameras")
			end
		end)
	end

	function self:handleTaskComplete(taskId)
		self:completeTask(taskId)
	end

	function self:initialize()
		self:broadcastTask()
		task.spawn(function()
			local facility = workspace:WaitForChild("Facility", 30)
			if not facility then
				warn("Facility not found; task prompts not initialized")
				return
			end

			for _, task in ipairs(tasks) do
				self:ensurePromptForTask(task.id)
			end
			self:ensureCameraPrompt()
		end)
	end

	return self
end

return TaskSystem
