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
			for _, name in ipairs({ "Rig" }) do
				local found = root:FindFirstChild(name, true)
				if found then
					return found
				end
			end
			return nil
		end

		local facility = Workspace:FindFirstChild("Facility")
		return findRig(facility) or findRig(Workspace)
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

		if not targetPart:FindFirstChild("RigScaryBackdrop") then
			local billboard = Instance.new("BillboardGui")
			billboard.Name = "RigScaryBackdrop"
			billboard.Size = UDim2.new(18, 0, 10, 0)
			billboard.StudsOffset = Vector3.new(0, 2, -6)
			billboard.AlwaysOnTop = false
			billboard.MaxDistance = 0
			billboard.Parent = targetPart

			local frame = Instance.new("Frame")
			frame.BackgroundColor3 = Color3.new(0, 0, 0)
			frame.BackgroundTransparency = 0
			frame.BorderSizePixel = 0
			frame.Size = UDim2.new(1, 0, 1, 0)
			frame.Parent = billboard
		end

		if not rig:FindFirstChild("RigScaryBgPart") then
			local bgPart = Instance.new("Part")
			bgPart.Name = "RigScaryBgPart"
			bgPart.Anchored = true
			bgPart.CanCollide = false
			bgPart.Transparency = 1
			bgPart.Size = Vector3.new(60, 35, 1)
			bgPart.CFrame = CFrame.lookAt(
				targetPart.Position - targetPart.CFrame.LookVector * 8,
				targetPart.Position
			)
			bgPart.Parent = rig

			local surface = Instance.new("SurfaceGui")
			surface.Name = "RigScaryBgSurface"
			surface.Face = Enum.NormalId.Front
			surface.AlwaysOnTop = false
			surface.Parent = bgPart

			local panel = Instance.new("Frame")
			panel.BackgroundColor3 = Color3.new(0, 0, 0)
			panel.BackgroundTransparency = 0
			panel.BorderSizePixel = 0
			panel.Size = UDim2.new(1, 0, 1, 0)
			panel.Parent = surface
		end

		if not targetPart:FindFirstChild("RigScarySurface") then
			local surface = Instance.new("SurfaceGui")
			surface.Name = "RigScarySurface"
			surface.Face = Enum.NormalId.Front
			surface.AlwaysOnTop = false
			surface.Parent = targetPart

			local panel = Instance.new("Frame")
			panel.BackgroundColor3 = Color3.new(0, 0, 0)
			panel.BackgroundTransparency = 0.2
			panel.BorderSizePixel = 0
			panel.Size = UDim2.new(1, 0, 1, 0)
			panel.Parent = surface
		end

		if not targetPart:FindFirstChild("RigScaryFog") then
			local fog = Instance.new("ParticleEmitter")
			fog.Name = "RigScaryFog"
			fog.Texture = "rbxassetid://258128463"
			fog.Color = ColorSequence.new(Color3.fromRGB(10, 10, 10))
			fog.LightEmission = 0
			fog.Rate = 6
			fog.Lifetime = NumberRange.new(2, 4)
			fog.Speed = NumberRange.new(0.5, 1.5)
			fog.SpreadAngle = Vector2.new(20, 20)
			fog.RotSpeed = NumberRange.new(-30, 30)
			fog.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 2),
			})
			fog.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.6),
				NumberSequenceKeypoint.new(1, 1),
			})
			fog.Parent = targetPart
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
			local rigPart = resolveDispatchRigPart()
			if not rigPart then
				return
			end
			originalCameraType = Camera.CameraType
			originalCameraSubject = Camera.CameraSubject
			originalCameraCFrame = Camera.CFrame
			Camera.CameraType = Enum.CameraType.Scriptable
			local offset = rigPart.CFrame.LookVector * 2
			local position = rigPart.Position + offset
			Camera.CFrame = CFrame.lookAt(position, rigPart.Position)
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
