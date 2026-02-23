local MonsterSystem = {}

function MonsterSystem.new(config, workspace, players, monsterStateRemote)
	local self = {}
	local monster = nil
	local lastMoveTime = 0
	local monsterActive = false
	local lastStateBroadcast = 0

	local function getOrCreateMonster()
		local existing = workspace:FindFirstChild("Monster")
		if existing then
			return existing
		end

		local part = Instance.new("Part")
		part.Name = "Monster"
		part.Size = Vector3.new(2, 6, 2)
		part.Anchored = true
		part.Color = Color3.new(0.05, 0.05, 0.05)
		part.Position = Vector3.new(0, 4, -30)
		part.Parent = workspace
		return part
	end

	local function pickPatrolPoint()
		if #config.MonsterPatrolPoints == 0 then
			return Vector3.new(math.random(-40, 40), 4, math.random(-40, 40))
		end
		return config.MonsterPatrolPoints[math.random(1, #config.MonsterPatrolPoints)]
	end

	local function anyPlayerLooking()
		for _, player in ipairs(players:GetPlayers()) do
			if player:GetAttribute("IsLookingAtMonster") then
				return true
			end
		end
		return false
	end

	function self:update(dt)
		if not monster then
			monster = getOrCreateMonster()
		end

		if not monsterActive then
			if math.random() < config.MonsterActivationChance * dt then
				monsterActive = true
			end
		else
			if math.random() < config.MonsterDeactivationChance * dt then
				monsterActive = false
			end
		end

		if monsterActive and os.clock() - lastMoveTime >= config.MonsterMoveInterval then
			if not anyPlayerLooking() then
				monster.Position = pickPatrolPoint()
				lastMoveTime = os.clock()
			end
		end

		for _, player in ipairs(players:GetPlayers()) do
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if humanoid and root and not player:GetAttribute("IsHidden") then
				if (root.Position - monster.Position).Magnitude <= config.MonsterKillDistance then
					humanoid.Health = 0
				end
			end
		end

		if os.clock() - lastStateBroadcast >= 1 then
			monsterStateRemote:FireAllClients(monsterActive, monster.Position)
			lastStateBroadcast = os.clock()
		end
	end

	return self
end

return MonsterSystem
