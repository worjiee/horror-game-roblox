local Ui = {}

function Ui.create(player, config)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MinimalUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = player:WaitForChild("PlayerGui")

	local overlay = Instance.new("Frame")
	overlay.Name = "Overlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.Position = UDim2.new(0, 0, 0, 0)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.ZIndex = 3
	overlay.Visible = false
	overlay.Parent = screenGui

	local dispatchLabel = Instance.new("TextLabel")
	dispatchLabel.Name = "Dispatch"
	dispatchLabel.Size = UDim2.new(0, 520, 0, 60)
	dispatchLabel.Position = UDim2.new(0.5, -260, 0.8, -30)
	dispatchLabel.BackgroundTransparency = 0.4
	dispatchLabel.BackgroundColor3 = Color3.new(0, 0, 0)
	dispatchLabel.TextColor3 = Color3.new(1, 1, 1)
	dispatchLabel.TextXAlignment = Enum.TextXAlignment.Left
	dispatchLabel.Font = Enum.Font.Gotham
	dispatchLabel.TextSize = 18
	dispatchLabel.Text = ""
	dispatchLabel.ZIndex = 4
	dispatchLabel.Visible = false
	dispatchLabel.Parent = screenGui

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

	local cameraButtonContainer = Instance.new("Frame")
	cameraButtonContainer.Name = "CameraButtonContainer"
	cameraButtonContainer.Size = UDim2.new(1, -20, 1, -92)
	cameraButtonContainer.Position = UDim2.new(0, 10, 0, 52)
	cameraButtonContainer.BackgroundTransparency = 1
	cameraButtonContainer.ZIndex = 6
	cameraButtonContainer.Parent = cameraMenu

	local cameraButtonLayout = Instance.new("UIListLayout")
	cameraButtonLayout.Padding = UDim.new(0, 6)
	cameraButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
	cameraButtonLayout.Parent = cameraButtonContainer

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

	local cursorDot = Instance.new("Frame")
	cursorDot.Name = "CursorDot"
	cursorDot.Size = UDim2.new(0, 6, 0, 6)
	cursorDot.Position = UDim2.new(0.5, -3, 0.5, -3)
	cursorDot.BackgroundColor3 = Color3.new(1, 1, 1)
	cursorDot.BorderSizePixel = 0
	cursorDot.Visible = false
	cursorDot.ZIndex = 4
	cursorDot.Parent = screenGui

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

	local generatorLabel = Instance.new("TextLabel")
	generatorLabel.Name = "GeneratorLabel"
	generatorLabel.Size = UDim2.new(0, 220, 0, 30)
	generatorLabel.Position = UDim2.new(0, 16, 0, 94)
	generatorLabel.BackgroundTransparency = 0.4
	generatorLabel.BackgroundColor3 = Color3.new(0, 0, 0)
	generatorLabel.TextColor3 = Color3.new(1, 1, 1)
	generatorLabel.Font = Enum.Font.Gotham
	generatorLabel.TextSize = 16
	generatorLabel.Text = "Generator: --%"
	generatorLabel.ZIndex = 2
	generatorLabel.Parent = screenGui

	local cameraChecklistLabel = Instance.new("TextLabel")
	cameraChecklistLabel.Name = "CameraChecklist"
	cameraChecklistLabel.Size = UDim2.new(0, 240, 0, 70)
	cameraChecklistLabel.Position = UDim2.new(0, 16, 0, 128)
	cameraChecklistLabel.BackgroundTransparency = 0.4
	cameraChecklistLabel.BackgroundColor3 = Color3.new(0, 0, 0)
	cameraChecklistLabel.TextColor3 = Color3.new(1, 1, 1)
	cameraChecklistLabel.TextXAlignment = Enum.TextXAlignment.Left
	cameraChecklistLabel.TextYAlignment = Enum.TextYAlignment.Top
	cameraChecklistLabel.Font = Enum.Font.Gotham
	cameraChecklistLabel.TextSize = 14
	cameraChecklistLabel.Text = ""
	cameraChecklistLabel.Visible = false
	cameraChecklistLabel.ZIndex = 2
	cameraChecklistLabel.Parent = screenGui

	local ui = {
		screenGui = screenGui,
		overlay = overlay,
		dispatchLabel = dispatchLabel,
		cameraMenu = cameraMenu,
		cameraButtonContainer = cameraButtonContainer,
		cameraExitButton = cameraExitButton,
		cursorDot = cursorDot,
		vignette = vignette,
		taskLabel = taskLabel,
		batteryLabel = batteryLabel,
		statusLabel = statusLabel,
		generatorLabel = generatorLabel,
		cameraChecklistLabel = cameraChecklistLabel,
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

	function ui:setGeneratorFuel(fuel, maxFuel, working)
		local percent = 0
		if maxFuel and maxFuel > 0 then
			percent = math.floor((fuel / maxFuel) * 100 + 0.5)
		end
		local state = working and "" or " (offline)"
		self.generatorLabel.Text = string.format("Generator: %d%%%s", percent, state)
	end

	function ui:setCameraChecklist(text)
		self.cameraChecklistLabel.Text = text or ""
		self.cameraChecklistLabel.Visible = text ~= nil and text ~= ""
	end

	function ui:buildCameraButtons(cameraNames, onSelect)
		for _, child in ipairs(self.cameraButtonContainer:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		for index, name in ipairs(cameraNames) do
			local button = Instance.new("TextButton")
			button.Name = name .. "Button"
			button.Size = UDim2.new(1, 0, 0, 32)
			button.BackgroundColor3 = Color3.new(0.12, 0.12, 0.12)
			button.TextColor3 = Color3.new(1, 1, 1)
			button.Font = Enum.Font.Gotham
			button.TextSize = 16
			button.Text = name
			button.ZIndex = 6
			button.AutoButtonColor = true
			button.LayoutOrder = index
			button.Parent = self.cameraButtonContainer

			button.MouseButton1Click:Connect(function()
				onSelect(name)
			end)
			button.Activated:Connect(function()
				onSelect(name)
			end)
		end

		local count = #cameraNames
		local buttonHeight = 32
		local padding = 6
		local totalButtonsHeight = count * buttonHeight + math.max(count - 1, 0) * padding
		local baseHeight = 120
		local menuHeight = math.max(180, baseHeight + totalButtonsHeight)
		self.cameraMenu.Size = UDim2.new(0, 320, 0, menuHeight)
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

	function ui:showOverlay(alpha)
		self.overlay.Visible = true
		self.overlay.BackgroundTransparency = math.clamp(alpha or 0, 0, 1)
	end

	function ui:hideOverlay()
		self.overlay.Visible = false
	end

	function ui:showDispatch()
		self.dispatchLabel.Visible = true
	end

	function ui:hideDispatch()
		self.dispatchLabel.Visible = false
		self.dispatchLabel.Text = ""
	end

	function ui:setDispatch(text)
		self.dispatchLabel.Text = text
	end

	function ui:showCursorDot()
		self.cursorDot.Visible = true
	end

	function ui:hideCursorDot()
		self.cursorDot.Visible = false
	end

	function ui:isCameraMenuVisible()
		return self.cameraMenu.Visible
	end

	return ui
end

return Ui
