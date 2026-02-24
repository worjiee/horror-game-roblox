local CutsceneSystem = {}

local CutsceneConfig = require(game:GetService("ReplicatedStorage").Shared.CutsceneConfig)

local function glitchText(text)
	return text
end

function CutsceneSystem.new(ui, lighting, player, services)
	local self = {}
	local playing = false
	local ContextActionService = services.ContextActionService
	local SoundService = services.SoundService
	local Workspace = services.Workspace
	local Camera = services.Camera or (Workspace and Workspace.CurrentCamera)
	local TweenService = services.TweenService or game:GetService("TweenService")
	local movementBlocked = false
	local originalWalkSpeed = nil
	local originalJumpPower = nil
	local originalAutoRotate = nil
	local originalCameraType = nil
	local originalCameraSubject = nil
	local originalCameraCFrame = nil
	local activeTalkTween = nil
	local activeTalkNeck = nil
	local activeTalkC0 = nil
	local activeOverlayTween = nil

	local radioClick = Instance.new("Sound")
	radioClick.Name = "RadioClick"
	radioClick.SoundId = CutsceneConfig.Audio.RadioClickId or ""
	radioClick.Volume = 0.4
	radioClick.Parent = SoundService

	local glitchSound = Instance.new("Sound")
	glitchSound.Name = "GlitchSound"
	glitchSound.SoundId = CutsceneConfig.Audio.GlitchId or ""
	glitchSound.Volume = 0.5
	glitchSound.Parent = SoundService

	local function resolveDispatchRig()
		if not Workspace then
			return nil
		end

		local function findRig(root)
			if not root then
				return nil
			end
			return root:FindFirstChild("Rig", true)
		end

		local mapModel = Workspace:FindFirstChild("Game Map") or Workspace:FindFirstChild("Facility")
		return findRig(mapModel) or findRig(Workspace)
	end

	local function resolveDispatchEmitter()
		local rig = resolveDispatchRig()
		if not rig then
			return SoundService
		end
		if rig:IsA("Model") then
			return rig:FindFirstChild("Head")
				or rig.PrimaryPart
				or rig:FindFirstChild("HumanoidRootPart")
				or SoundService
		end
		return rig
	end

	local function resolveDispatchRigPart()
		local rig = resolveDispatchRig()
		if not rig then
			return nil
		end
		if rig:IsA("Model") then
			local part = rig:FindFirstChild("Head")
				or rig.PrimaryPart
				or rig:FindFirstChild("HumanoidRootPart")
			if part and part:IsA("BasePart") then
				return part
			end
			return nil
		end
		if rig:IsA("BasePart") then
			return rig
		end
		return nil
	end

	local function resolveDispatchRigModel()
		local rig = resolveDispatchRig()
		if rig and rig:IsA("Model") then
			return rig
		end
		return nil
	end


	local function setupRigBackdrop()
		local rig = resolveDispatchRigModel()
		if not rig then
			return
		end
		local head = rig:FindFirstChild("Head")
		local targetPart = head or rig.PrimaryPart or rig:FindFirstChild("HumanoidRootPart")
		if not targetPart or not targetPart:IsA("BasePart") then
			return
		end

		local existingBackdrop = targetPart:FindFirstChild("RigScaryBackdrop")
		if existingBackdrop then
			existingBackdrop:Destroy()
		end
		local existingSurface = targetPart:FindFirstChild("RigScarySurface")
		if existingSurface then
			existingSurface:Destroy()
		end
		local existingFog = targetPart:FindFirstChild("RigScaryFog")
		if existingFog then
			existingFog:Destroy()
		end
		local existingBgPart = rig:FindFirstChild("RigScaryBgPart")
		if existingBgPart then
			existingBgPart:Destroy()
		end
	end

	local function stopTalking()
		if activeTalkTween then
			activeTalkTween:Cancel()
			activeTalkTween = nil
		end
		if activeTalkNeck and activeTalkC0 then
			activeTalkNeck.C0 = activeTalkC0
		end
		activeTalkNeck = nil
		activeTalkC0 = nil
	end

	local function startTalking(duration)
		stopTalking()
		local rig = resolveDispatchRigModel()
		if not rig then
			return
		end
		local head = rig:FindFirstChild("Head")
		if not head then
			return
		end
		local neck = head:FindFirstChild("Neck") or head.Parent:FindFirstChild("Neck") or rig:FindFirstChild("Neck", true)
		if not neck or not neck:IsA("Motor6D") then
			return
		end
		activeTalkNeck = neck
		activeTalkC0 = neck.C0
		local target = activeTalkC0 * CFrame.Angles(math.rad(-6), 0, 0)
		activeTalkTween = TweenService:Create(neck, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
			C0 = target,
		})
		activeTalkTween:Play()
		task.delay(duration, stopTalking)
	end

	local dispatchVoice = Instance.new("Sound")
	dispatchVoice.Name = "DispatchVoice"
	dispatchVoice.Volume = 1
	dispatchVoice.Parent = resolveDispatchEmitter()
	setupRigBackdrop()

	local function normalizeId(id)
		if not id or id == "" then
			return ""
		end
		if string.find(id, "rbxassetid://", 1, true) then
			return id
		end
		return "rbxassetid://" .. id
	end

	local function playVoice(voiceId)
		local normalized = normalizeId(voiceId)
		if normalized == "" then
			return 0
		end
		dispatchVoice:Stop()
		dispatchVoice.SoundId = normalized
		dispatchVoice.TimePosition = 0
		dispatchVoice:Play()
		if dispatchVoice.IsLoaded then
			return dispatchVoice.TimeLength
		end
		local startedAt = os.clock()
		while not dispatchVoice.IsLoaded and os.clock() - startedAt < 2 do
			task.wait()
		end
		return dispatchVoice.TimeLength
	end

	local function setMovementBlocked(blocked)
		if blocked == movementBlocked then
			return
		end
		movementBlocked = blocked

		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			if blocked then
				originalWalkSpeed = humanoid.WalkSpeed
				originalJumpPower = humanoid.JumpPower
				originalAutoRotate = humanoid.AutoRotate
				humanoid.WalkSpeed = 0
				humanoid.JumpPower = 0
				humanoid.AutoRotate = false
			else
				humanoid.WalkSpeed = originalWalkSpeed or 16
				humanoid.JumpPower = originalJumpPower or 50
				humanoid.AutoRotate = originalAutoRotate ~= nil and originalAutoRotate or true
			end
		end

		if blocked then
			ContextActionService:BindActionAtPriority(
				"BlockMovementCutscene",
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
			ContextActionService:UnbindAction("BlockMovementCutscene")
		end
	end

	local function setCutsceneCamera(enabled)
		if not Camera then
			return
		end
		if enabled then
			local function waitForRigPart(timeoutSeconds)
				local startedAt = os.clock()
				while os.clock() - startedAt < timeoutSeconds do
					local rig = resolveDispatchRigModel()
					local rigPart = rig and (rig:FindFirstChild("HumanoidRootPart") or rig.PrimaryPart or rig:FindFirstChild("Head"))
					if rigPart and rigPart:IsA("BasePart") then
						return rigPart
					end
					task.wait()
				end
				return nil
			end

			local rigPart = waitForRigPart(2)
			if not rigPart then
				return
			end
			originalCameraType = Camera.CameraType
			originalCameraSubject = Camera.CameraSubject
			originalCameraCFrame = Camera.CFrame
			Camera.CameraType = Enum.CameraType.Scriptable
			local rig = rigPart.Parent
			local head = rig and rig:FindFirstChild("Head")
			local anchor = (head and head:IsA("BasePart")) and head or (rig and rig.PrimaryPart) or rigPart
			if not anchor or not anchor:IsA("BasePart") then
				return
			end
			local offset = anchor.CFrame.LookVector * 2.2 + Vector3.new(0, 0.35, 0)
			local position = anchor.Position + offset
			Camera.CFrame = CFrame.lookAt(position, anchor.Position + Vector3.new(0, 0.15, 0))
		else
			if originalCameraType then
				Camera.CameraType = originalCameraType
			else
				Camera.CameraType = Enum.CameraType.Custom
			end
			if originalCameraSubject and originalCameraSubject.Parent then
				Camera.CameraSubject = originalCameraSubject
			else
				local character = player.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					Camera.CameraSubject = humanoid
				end
			end
			if originalCameraCFrame then
				Camera.CFrame = originalCameraCFrame
			end
			originalCameraType = nil
			originalCameraSubject = nil
			originalCameraCFrame = nil
		end
	end

	local function playSteps(steps, voiceIds)
		playing = true
		ui:showDispatch()
		setMovementBlocked(true)
		setCutsceneCamera(true)

		local voiceIndex = 0
		for _, step in ipairs(steps) do
			if step.brightness then
				lighting.Brightness = step.brightness
			end
			local text = step.glitch and glitchText(step.text) or step.text
			ui:setDispatch(text)
			if step.sound then
				radioClick:Stop()
				radioClick:Play()
			end
			if step.glitch and glitchSound.SoundId ~= "" then
				glitchSound:Stop()
				glitchSound:Play()
			end
			local voiceLength = 0
			if step.sound and voiceIds then
				voiceIndex += 1
				voiceLength = playVoice(voiceIds[voiceIndex])
			end
			local waitTime = step.duration or 0
			if step.sound and voiceLength > 0 then
				waitTime = math.max(step.duration or 0, voiceLength)
			end
			if step.sound and waitTime > 0 then
				startTalking(waitTime)
			end
			task.wait(waitTime)
		end

		ui:hideDispatch()
		if activeOverlayTween then
			activeOverlayTween:Cancel()
			activeOverlayTween = nil
		end
		ui:showOverlay(0)
		activeOverlayTween = TweenService:Create(ui.overlay, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1,
		})
		activeOverlayTween:Play()
		activeOverlayTween.Completed:Connect(function()
			ui:hideOverlay()
		end)
		stopTalking()
		setCutsceneCamera(false)
		setMovementBlocked(false)
		playing = false
	end

	function self:isActive()
		return playing
	end

	function self:playOpening()
		playSteps(CutsceneConfig.Opening, CutsceneConfig.Audio.DispatchVoiceIds.Opening)
	end

	function self:playBasementClimax()
		playSteps(CutsceneConfig.Basement, CutsceneConfig.Audio.DispatchVoiceIds.Basement)
	end

	function self:playEnding()
		playSteps(CutsceneConfig.Ending, CutsceneConfig.Audio.DispatchVoiceIds.Ending)
	end

	return self
end

return CutsceneSystem
