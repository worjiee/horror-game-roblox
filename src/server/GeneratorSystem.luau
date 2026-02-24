local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local GeneratorSystem = {}

local function getMapModel(workspace)
	return workspace:FindFirstChild("Game Map") or workspace:FindFirstChild("Facility")
end

local function clamp(value, minValue, maxValue)
	return math.max(minValue, math.min(maxValue, value))
end

local function resolveToolHandle(tool)
	if not tool then
		return nil
	end
	local handle = tool:FindFirstChild("Handle")	
	if handle and handle:IsA("BasePart") then
		return handle
	end
	for _, child in ipairs(tool:GetDescendants()) do
		if child:IsA("BasePart") then
			return child
		end
	end
	return nil
end

local function attachGasUi(tool, amount)
	local handle = resolveToolHandle(tool)
	if not handle then
		return
	end
	local existing = handle:FindFirstChild("GasAmountGui")
	if existing then
		existing:Destroy()
	end
	local gui = Instance.new("BillboardGui")
	gui.Name = "GasAmountGui"
	gui.Size = UDim2.new(0, 120, 0, 40)
	gui.StudsOffset = Vector3.new(0, 2, 0)
	gui.AlwaysOnTop = true
	gui.Parent = handle

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 0.35
	label.BackgroundColor3 = Color3.new(0, 0, 0)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Text = string.format("Gas: %d%%", amount)
	label.Parent = gui
end

function GeneratorSystem.new(config, workspace, remotes)
	local self = {}
	local mapModel = nil
	local generatorPart = nil
	local fuel = config.GeneratorMaxFuel or 100
	local maxFuel = config.GeneratorMaxFuel or 100
	local drainSeconds = config.GeneratorDrainSeconds or 120
	local drainRate = maxFuel / math.max(drainSeconds, 1)
	local lastBroadcast = 0

	local function setGeneratorAttributes()
		if not generatorPart then
			return
		end
		generatorPart:SetAttribute("GeneratorFuel", fuel)
		generatorPart:SetAttribute("GeneratorMaxFuel", maxFuel)
		generatorPart:SetAttribute("GeneratorWorking", fuel > 0)
	end

	local function broadcastState()
		remotes.GeneratorState:FireAllClients(fuel, maxFuel, fuel > 0)
		lastBroadcast = os.clock()
	end

	local function addFuel(amount)
		if amount <= 0 then
			return 0
		end
		local before = fuel
		fuel = clamp(fuel + amount, 0, maxFuel)
		setGeneratorAttributes()
		broadcastState()
		return fuel - before
	end

	local function spawnGasCanAt(spawnPart, value)
		if not spawnPart then
			return
		end
		local template = mapModel and mapModel:FindFirstChild(config.GasCanToolName or "Gas Can", true)
		if not (template and template:IsA("Tool")) then
			warn("Gas Can tool not found in Game Map")
			return
		end
		if template.Parent ~= ServerStorage then
			template.Parent = ServerStorage
		end

		local tool = template:Clone()
		tool:SetAttribute("GasAmount", value)
		local handle = resolveToolHandle(tool)
		if handle then
			handle.CFrame = spawnPart.CFrame
		end
		tool.Parent = workspace
		attachGasUi(tool, value)

		tool.Activated:Connect(function()
			local character = tool.Parent
			local player = character and Players:GetPlayerFromCharacter(character)
			if not player then
				return
			end
			if not generatorPart then
				return
			end
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if not root then
				return
			end
			if (root.Position - generatorPart.Position).Magnitude > (config.GeneratorUseDistance or 8) then
				return
			end

			local gasAmount = tool:GetAttribute("GasAmount") or 0
			if gasAmount <= 0 then
				tool:Destroy()
				return
			end
			local needed = maxFuel - fuel
			if needed <= 0 then
				return
			end
			local used = math.min(gasAmount, needed)
			addFuel(used)
			gasAmount -= used
			tool:SetAttribute("GasAmount", gasAmount)
			attachGasUi(tool, gasAmount)
			if gasAmount <= 0 then
				tool:Destroy()
			end
		end)
	end

	function self:initialize()
		mapModel = getMapModel(workspace)
		generatorPart = mapModel and mapModel:FindFirstChild("Generator") or nil
		setGeneratorAttributes()
		broadcastState()

		if not mapModel then
			warn("Game Map not found; gas cans not spawned")
			return
		end

		local spawnName = config.GasCanSpawnName or "GasCanSpawn"
		local spawnParts = {}
		for _, child in ipairs(mapModel:GetDescendants()) do
			if child:IsA("BasePart") and (child.Name == spawnName or string.sub(child.Name, 1, #spawnName) == spawnName) then
				table.insert(spawnParts, child)
			end
		end

		local spawnCount = math.min(#spawnParts, config.GasCanSpawnCount or 4)
		for i = #spawnParts, 2, -1 do
			local j = math.random(1, i)
			spawnParts[i], spawnParts[j] = spawnParts[j], spawnParts[i]
		end

		for index = 1, spawnCount do
			local value = math.random(config.GasCanMinFuel or 20, config.GasCanMaxFuel or 60)
			spawnGasCanAt(spawnParts[index], value)
		end
	end

	function self:update(dt)
		if fuel > 0 then
			fuel = clamp(fuel - drainRate * dt, 0, maxFuel)
			setGeneratorAttributes()
		end
		if os.clock() - lastBroadcast >= 0.5 then
			broadcastState()
		end
	end

	function self:sendStateTo(player)
		remotes.GeneratorState:FireClient(player, fuel, maxFuel, fuel > 0)
	end

	return self
end

return GeneratorSystem
