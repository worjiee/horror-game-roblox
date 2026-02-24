local CameraSystem = {}

function CameraSystem.new(deps)
	local self = {}
	local player = deps.player
	local camera = deps.camera
	local ui = deps.ui
	local config = deps.config
	local UserInputService = deps.services.UserInputService
	local ContextActionService = deps.services.ContextActionService
	local ProximityPromptService = deps.services.ProximityPromptService
	local Workspace = deps.services.Workspace
	local SoundService = deps.services.SoundService
	local onCameraViewed = deps.onCameraViewed
	local statusFallback = deps.statusFallback

	local cameraParts = {}
	local cameraByName = {}
	local cameraIndex = 1
	local inSecurityView = false
	local cameraMenuOpen = false
	local originalCameraType = nil
	local originalCameraSubject = nil
	local originalCameraCFrame = nil
	local originalMouseBehavior = nil
	local originalMouseIcon = nil
	local originalWalkSpeed = nil
	local originalJumpPower = nil
	local originalAutoRotate = nil
	local cameraYaw = 0
	local cameraPitch = 0
	local cameraPitchLimit = math.rad(40)
	local cameraYawLimit = math.rad(60)
	local cameraSensitivity = 0.0025
	local checklistEnabled = false
	local viewedCameras = {}

	local function getCameraNames()
		return config.CameraNames or { "CameraA", "CameraB" }
	end

	local function updateChecklist()
		if not ui or not checklistEnabled then
			if ui then
				ui:setCameraChecklist("")
			end
			return
		end
		local lines = { "Cameras checked:" }
		for _, name in ipairs(getCameraNames()) do
			local checked = viewedCameras[name]
			local mark = checked and "x" or " "
			table.insert(lines, string.format("[%s] %s", mark, name))
		end
		ui:setCameraChecklist(table.concat(lines, "\n"))
	end

	local function reportCameraViewed(name)
		if onCameraViewed and name and name ~= "" then
			onCameraViewed(name)
		end
		if name and name ~= "" then
			viewedCameras[name] = true
			updateChecklist()
		end
	end

	local cameraSelectSound = Instance.new("Sound")
	cameraSelectSound.Name = "CameraSelectSound"
	cameraSelectSound.SoundId = "rbxassetid://1673280232"
	cameraSelectSound.Volume = 0.6
	cameraSelectSound.Looped = false
	cameraSelectSound.Parent = SoundService

	local cameraViewMusic = Instance.new("Sound")
	cameraViewMusic.Name = "CameraViewMusic"
	cameraViewMusic.SoundId = config.CameraViewMusicId or ""
	cameraViewMusic.Volume = 0.35
	cameraViewMusic.Looped = true
	cameraViewMusic.Parent = SoundService

	local cameraExitSound = Instance.new("Sound")
	cameraExitSound.Name = "CameraExitSound"
	cameraExitSound.SoundId = "rbxassetid://1673280232"
	cameraExitSound.Volume = 0.45
	cameraExitSound.Parent = SoundService

	local function applyMouseForMenu()
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
		ui:hideCursorDot()
	end

	local function applyMouseForLook()
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = false
		ui:showCursorDot()
	end

	local function restoreMovement()
		ContextActionService:UnbindAction("BlockMovement")

		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = originalWalkSpeed or 16
			humanoid.JumpPower = originalJumpPower or 50
			if originalAutoRotate ~= nil then
				humanoid.AutoRotate = originalAutoRotate
			else
				humanoid.AutoRotate = true
			end
		end

		originalWalkSpeed = nil
		originalJumpPower = nil
		originalAutoRotate = nil
	end

	local function setMovementBlocked(blocked)
		if blocked then
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				if not originalWalkSpeed then
					originalWalkSpeed = humanoid.WalkSpeed or 16
				end
				if not originalJumpPower then
					originalJumpPower = humanoid.JumpPower or 50
				end
				if originalAutoRotate == nil then
					originalAutoRotate = humanoid.AutoRotate
				end
				humanoid.WalkSpeed = 0
				humanoid.JumpPower = 0
				humanoid.AutoRotate = false
			end

			ContextActionService:UnbindAction("BlockMovement")
			ContextActionService:BindActionAtPriority(
				"BlockMovement",
				function()
					return Enum.ContextActionResult.Sink
				end,
				false,
				2000,
				Enum.PlayerActions.CharacterForward,
				Enum.PlayerActions.CharacterBackward,
				Enum.PlayerActions.CharacterLeft,
				Enum.PlayerActions.CharacterRight,
				Enum.PlayerActions.CharacterJump
			)
		else
			restoreMovement()
		end
	end

	local function updateSecurityCamera()
		local target = cameraParts[cameraIndex]
		if target then
			local base = target.CFrame
			local rotation = CFrame.Angles(cameraPitch, cameraYaw, 0)
			camera.CFrame = base * rotation
		end
	end

	local function refreshCameraParts()
		cameraParts = {}
		cameraByName = {}
		local facility = Workspace:FindFirstChild("Facility")
		if not facility then
			return
		end

		local candidateNames = getCameraNames()
		for index, name in ipairs(candidateNames) do
			local part = facility:FindFirstChild(name)
			if part then
				table.insert(cameraParts, part)
				cameraByName[name] = index
			end
		end
	end

	local function openCameraMenu()
		refreshCameraParts()
		if #cameraParts == 0 then
			ui:setStatus("No security cameras found")
			return
		end

		if not originalMouseBehavior then
			originalMouseBehavior = UserInputService.MouseBehavior
		end
		if originalMouseIcon == nil then
			originalMouseIcon = UserInputService.MouseIconEnabled
		end

		applyMouseForMenu()
		setMovementBlocked(true)

		ui:showCameraMenu()
		cameraMenuOpen = true
		ui:setStatus("Select a camera")
		updateChecklist()
	end

	local function closeCameraMenu()
		ui:hideCameraMenu()
		cameraMenuOpen = false
		if inSecurityView then
			applyMouseForLook()
			setMovementBlocked(true)
		else
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = false
			ui:showCursorDot()
			setMovementBlocked(false)
		end
		updateChecklist()

		if statusFallback then
			ui:setStatus(statusFallback())
		end
	end

	local function enterSecurityView(openMenu)
		if #cameraParts == 0 or inSecurityView then
			return
		end

		inSecurityView = true
		originalCameraType = camera.CameraType
		originalCameraSubject = camera.CameraSubject
		originalCameraCFrame = camera.CFrame
		cameraYaw = 0
		cameraPitch = 0

		if not originalMouseBehavior then
			originalMouseBehavior = UserInputService.MouseBehavior
		end
		if originalMouseIcon == nil then
			originalMouseIcon = UserInputService.MouseIconEnabled
		end
		applyMouseForLook()

		setMovementBlocked(true)
		ProximityPromptService.Enabled = false

		camera.CameraType = Enum.CameraType.Scriptable
		updateSecurityCamera()
		if cameraViewMusic.SoundId ~= "" and not cameraViewMusic.IsPlaying then
			cameraViewMusic:Play()
		end
		ui:setStatus("Security view (Tab: menu, Q: exit)")
		if openMenu ~= false then
			openCameraMenu()
		else
			cameraMenuOpen = false
			ui:hideCameraMenu()
		end
		updateChecklist()
	end

	local function exitSecurityView()
		if not inSecurityView then
			return
		end

		inSecurityView = false
		camera.CameraType = originalCameraType or Enum.CameraType.Custom
		if originalCameraSubject then
			camera.CameraSubject = originalCameraSubject
		end
		if originalCameraCFrame then
			camera.CFrame = originalCameraCFrame
		end

		setMovementBlocked(false)
		ProximityPromptService.Enabled = true
		cameraViewMusic:Stop()
		closeCameraMenu()
		ui:hideCursorDot()
		UserInputService.MouseIconEnabled = false
	end

	local function cycleSecurityCamera()
		if #cameraParts == 0 then
			return
		end

		cameraIndex += 1
		if cameraIndex > #cameraParts then
			cameraIndex = 1
		end
		cameraYaw = 0
		cameraPitch = 0
		updateSecurityCamera()
		local target = cameraParts[cameraIndex]
		if target then
			reportCameraViewed(target.Name)
		end
	end

	local function selectCameraByName(name)
		local index = cameraByName[name]
		if not index then
			return
		end

		cameraSelectSound:Stop()
		cameraSelectSound.TimePosition = 0
		cameraSelectSound:Play()

		cameraIndex = index
		reportCameraViewed(name)
		if not inSecurityView then
			enterSecurityView(false)
		else
			updateSecurityCamera()
		end
		cameraMenuOpen = false
		ui:hideCameraMenu()
		applyMouseForLook()
		setMovementBlocked(true)
		ProximityPromptService.Enabled = false
		ui:setStatus("Security view (Tab: menu, Q: exit)")
	end

	function self:handleInput(input, processed)
		if input.KeyCode == Enum.KeyCode.Tab and inSecurityView then
			if cameraMenuOpen then
				closeCameraMenu()
			else
				openCameraMenu()
			end
			return true
		end

		if processed then
			return false
		end

		if input.KeyCode == Enum.KeyCode.Q then
			exitSecurityView()
			return true
		end

		if input.KeyCode == Enum.KeyCode.R and inSecurityView then
			cycleSecurityCamera()
			return true
		end

		return false
	end

	function self:update()
		if cameraMenuOpen then
			applyMouseForMenu()
			return
		end

		if inSecurityView then
			applyMouseForLook()
			local delta = UserInputService:GetMouseDelta()
			cameraYaw = math.clamp(cameraYaw - delta.X * cameraSensitivity, -cameraYawLimit, cameraYawLimit)
			cameraPitch = math.clamp(cameraPitch - delta.Y * cameraSensitivity, -cameraPitchLimit, cameraPitchLimit)
			updateSecurityCamera()
		else
			UserInputService.MouseIconEnabled = false
			ui:showCursorDot()
		end
	end

	function self:onMenuRemote()
		if inSecurityView then
			exitSecurityView()
		else
			openCameraMenu()
		end
	end

	function self:isMenuOpen()
		return cameraMenuOpen
	end

	function self:isInSecurityView()
		return inSecurityView
	end

	function self:initialize()
		refreshCameraParts()
		UserInputService.MouseIconEnabled = false
		ui:showCursorDot()
		updateChecklist()

		ui:buildCameraButtons(getCameraNames(), function(name)
			selectCameraByName(name)
		end)

		ui.cameraExitButton.MouseButton1Click:Connect(function()
			cameraExitSound:Stop()
			cameraExitSound:Play()
			closeCameraMenu()
			if inSecurityView then
				exitSecurityView()
			end
		end)
		ui.cameraExitButton.Activated:Connect(function()
			cameraExitSound:Stop()
			cameraExitSound:Play()
			closeCameraMenu()
			if inSecurityView then
				exitSecurityView()
			end
		end)

		player.CharacterAdded:Connect(function()
			exitSecurityView()
		end)
	end

	function self:setChecklistEnabled(enabled)
		checklistEnabled = enabled == true
		if not checklistEnabled then
			viewedCameras = {}
		end
		updateChecklist()
	end

	return self
end

return CameraSystem
