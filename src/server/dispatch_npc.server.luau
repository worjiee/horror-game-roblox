local TweenService = game:GetService("TweenService")

local npc = script.Parent
local head = npc:FindFirstChild("Head")
local torso = npc:FindFirstChild("Torso")
local humanoid = npc:FindFirstChildOfClass("Humanoid")

local function tweenPart(part, goal, time)
	if not part then
		return
	end
	local tween = TweenService:Create(part, TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), goal)
	tween:Play()
end

-- Subtle idle motion to imply typing/monitor focus.
if head then
	tweenPart(head, { CFrame = head.CFrame * CFrame.Angles(0, math.rad(6), 0) }, 2.5)
end

if torso then
	tweenPart(torso, { CFrame = torso.CFrame * CFrame.Angles(math.rad(2), 0, 0) }, 3)
end

if humanoid then
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.NameDisplayDistance = 0
	humanoid.DisplayName = ""
end

local monitor = npc.Parent:FindFirstChild("Monitor")
if monitor then
	local typingSound = Instance.new("Sound")
	typingSound.Name = "TypingLoop"
	typingSound.SoundId = ""
	typingSound.Volume = 0.25
	typingSound.Looped = true
	typingSound.Parent = monitor
	if typingSound.SoundId ~= "" then
		typingSound:Play()
	end
end
