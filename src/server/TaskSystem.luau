local TaskSystem = {}

function TaskSystem.new(config, workspace, remotes)
	local self = {}
	local tasks = config.Tasks
	local currentTaskIndex = 1
	local cameraPromptDebounce = {}

	local taskPromptBindings = {
		restore_power = { partName = "Generator", actionText = "Restore Power" },
		check_cameras = { partName = "CameraTerminal", actionText = "Check Cameras" },
		reset_generators = { partName = "BackupGenerator", actionText = "Reset Generator" },
	}

	local function getCurrentTask()
		return tasks[currentTaskIndex]
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
		self:broadcastTask()
		return true
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
