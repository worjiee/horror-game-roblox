local Ui = {}

function Ui.create(player, config)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MinimalUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = player:WaitForChild("PlayerGui")

	local debugLabel = Instance.new("TextLabel")
	debugLabel.Name = "UiDebug"
	debugLabel.Size = UDim2.new(0, 200, 0, 20)
	debugLabel.Position = UDim2.new(0, 16, 1, -28)
	debugLabel.BackgroundTransparency = 0.4
	debugLabel.BackgroundColor3 = Color3.new(0, 0, 0)
	debugLabel.TextColor3 = Color3.new(1, 1, 1)
	debugLabel.Font = Enum.Font.Gotham
	debugLabel.TextSize = 12
	debugLabel.Text = "UI loaded"
	debugLabel.ZIndex = 2
	debugLabel.Parent = screenGui

	local cameraMenu = Instance.new("Frame")
	cameraMenu.Name = "CameraMenu"
	cameraMenu.Size = UDim2.new(0, 320, 0, 180)
	cameraMenu.Position = UDim2.new(0.5, -160, 0.5, -90)
	cameraMenu.BackgroundColor3 = Color3.new(0, 0, 0)
	cameraMenu.BackgroundTransparency = 0.2
	cameraMenu.BorderSizePixel = 0
	cameraMenu.Active = true
	cameraMenu.Visible = false
	cameraMenu.ZIndex = 5
	cameraMenu.Parent = screenGui

	local cameraMenuTitle = Instance.new("TextLabel")
	cameraMenuTitle.Name = "Title"
	cameraMenuTitle.Size = UDim2.new(1, -20, 0, 30)
	cameraMenuTitle.Position = UDim2.new(0, 10, 0, 10)
	cameraMenuTitle.BackgroundTransparency = 1
	cameraMenuTitle.TextColor3 = Color3.new(1, 1, 1)
	cameraMenuTitle.TextXAlignment = Enum.TextXAlignment.Left
	cameraMenuTitle.Font = Enum.Font.Gotham
	cameraMenuTitle.TextSize = 18
	cameraMenuTitle.Text = "Security Cameras"
	cameraMenuTitle.ZIndex = 6
	cameraMenuTitle.Parent = cameraMenu

	local cameraAButton = Instance.new("TextButton")
	cameraAButton.Name = "CameraAButton"
	cameraAButton.Size = UDim2.new(1, -20, 0, 36)
	cameraAButton.Position = UDim2.new(0, 10, 0, 52)
	cameraAButton.BackgroundColor3 = Color3.new(0.12, 0.12, 0.12)
	cameraAButton.TextColor3 = Color3.new(1, 1, 1)
	cameraAButton.Font = Enum.Font.Gotham
	cameraAButton.TextSize = 16
	cameraAButton.Text = "Camera A"
	cameraAButton.ZIndex = 6
	cameraAButton.AutoButtonColor = true
	cameraAButton.Parent = cameraMenu

	local cameraBButton = Instance.new("TextButton")
	cameraBButton.Name = "CameraBButton"
	cameraBButton.Size = UDim2.new(1, -20, 0, 36)
	cameraBButton.Position = UDim2.new(0, 10, 0, 94)
	cameraBButton.BackgroundColor3 = Color3.new(0.12, 0.12, 0.12)
	cameraBButton.TextColor3 = Color3.new(1, 1, 1)
	cameraBButton.Font = Enum.Font.Gotham
	cameraBButton.TextSize = 16
	cameraBButton.Text = "Camera B"
	cameraBButton.ZIndex = 6
	cameraBButton.AutoButtonColor = true
	cameraBButton.Parent = cameraMenu

	local cameraExitButton = Instance.new("TextButton")
	cameraExitButton.Name = "ExitButton"
	cameraExitButton.Size = UDim2.new(1, -20, 0, 30)
	cameraExitButton.Position = UDim2.new(0, 10, 1, -40)
	cameraExitButton.BackgroundColor3 = Color3.new(0.18, 0.1, 0.1)
	cameraExitButton.TextColor3 = Color3.new(1, 1, 1)
	cameraExitButton.Font = Enum.Font.Gotham
	cameraExitButton.TextSize = 14
	cameraExitButton.Text = "Exit"
	cameraExitButton.ZIndex = 6
	cameraExitButton.AutoButtonColor = true
	cameraExitButton.Parent = cameraMenu

	local vignette = Instance.new("ImageLabel")
	vignette.Name = "Vignette"
	vignette.Size = UDim2.new(1, 0, 1, 0)
	vignette.Position = UDim2.new(0, 0, 0, 0)
	vignette.BackgroundTransparency = 1
	vignette.Image = config.VignetteImageId
	vignette.ImageColor3 = Color3.new(0, 0, 0)
	vignette.ImageTransparency = 1
	vignette.ScaleType = Enum.ScaleType.Stretch
	vignette.ZIndex = 1
	vignette.Visible = config.VignetteImageId ~= ""
	vignette.Parent = screenGui

	local taskLabel = Instance.new("TextLabel")
	taskLabel.Name = "TaskLabel"
	taskLabel.Size = UDim2.new(0, 320, 0, 40)
	taskLabel.Position = UDim2.new(0, 16, 0, 16)
	taskLabel.BackgroundTransparency = 0.4
	taskLabel.BackgroundColor3 = Color3.new(0, 0, 0)
	taskLabel.TextColor3 = Color3.new(1, 1, 1)
	taskLabel.TextXAlignment = Enum.TextXAlignment.Left
	taskLabel.Font = Enum.Font.Gotham
	taskLabel.TextSize = 16
	taskLabel.Text = "Tasks loading..."
	taskLabel.ZIndex = 2
	taskLabel.Parent = screenGui

	local batteryLabel = Instance.new("TextLabel")
	batteryLabel.Name = "BatteryLabel"
	batteryLabel.Size = UDim2.new(0, 160, 0, 30)
	batteryLabel.Position = UDim2.new(1, -176, 0, 16)
	batteryLabel.BackgroundTransparency = 0.4
	batteryLabel.BackgroundColor3 = Color3.new(0, 0, 0)
	batteryLabel.TextColor3 = Color3.new(1, 1, 1)
	batteryLabel.Font = Enum.Font.Gotham
	batteryLabel.TextSize = 16
	batteryLabel.Text = "Light: 100%"
	batteryLabel.ZIndex = 2
	batteryLabel.Parent = screenGui

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(0, 220, 0, 30)
	statusLabel.Position = UDim2.new(0, 16, 0, 60)
	statusLabel.BackgroundTransparency = 0.4
	statusLabel.BackgroundColor3 = Color3.new(0, 0, 0)
	statusLabel.TextColor3 = Color3.new(1, 1, 1)
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextSize = 16
	statusLabel.Text = ""
	statusLabel.ZIndex = 2
	statusLabel.Parent = screenGui

	local ui = {
		screenGui = screenGui,
		debugLabel = debugLabel,
		cameraMenu = cameraMenu,
		cameraAButton = cameraAButton,
		cameraBButton = cameraBButton,
		cameraExitButton = cameraExitButton,
		vignette = vignette,
		taskLabel = taskLabel,
		batteryLabel = batteryLabel,
		statusLabel = statusLabel,
	}

	function ui:setTask(text)
		self.taskLabel.Text = text
	end

	function ui:setBattery(percent)
		self.batteryLabel.Text = string.format("Light: %d%%", percent)
	end

	function ui:setStatus(text)
		self.statusLabel.Text = text
	end

	function ui:setVignetteAlpha(alpha)
		if not self.vignette.Visible then
			return
		end
		self.vignette.ImageTransparency = math.clamp(1 - alpha, 0, 1)
	end

	function ui:showCameraMenu()
		self.cameraMenu.Visible = true
	end

	function ui:hideCameraMenu()
		self.cameraMenu.Visible = false
	end

	function ui:isCameraMenuVisible()
		return self.cameraMenu.Visible
	end

	return ui
end

return Ui
