local CutsceneConfig = {}

CutsceneConfig.Audio = {
	RadioClickId = "",
	DispatchVoiceIds = {
		Opening = {
			"rbxassetid://137948534626030", -- 1 Night shift crew, check in. You're early.
			"rbxassetid://73957051345235", -- 2 Orientation's short. Keep your radios open.
			"rbxassetid://74619711208376", -- 3 Power is unstable. We need Generator A online.
			"rbxassetid://72170376487720", -- 4 Security cameras are intermittent. Reset them when you're nearby.
			"rbxassetid://81550892495935", -- 5 Basement generator is last. Don't go down there alone.
			"rbxassetid://90746338070473", -- 6 If you see movement—don't stare. Just report.
			"rbxassetid://79761288976707", -- 7 You will hear things. Ignore them.
			"rbxassetid://118523593254374", -- 8 Orientation begins.
		},
		Basement = {
			"rbxassetid://72564686550603", -- 1 Basement power surging...
			"rbxassetid://128193671680673", -- 2 Keep moving. Do not stop.
			"", -- 3 ...
		},
		Ending = {
			"rbxassetid://79774072864255", -- 1 Orientation complete.
			"rbxassetid://91761032261547", -- 2 Containment Protocol: Phase One successful.
			"rbxassetid://139937107790218", -- 3 You were never alone.
			"rbxassetid://85273304476135", -- 4 Report to Sector 3 for Phase Two.
			"rbxassetid://113874559639328", -- 5 We are watching.
		},
	},
}

CutsceneConfig.Opening = {
	{ text = "...", duration = 0.5 },
	{ text = "Night shift crew, check in. You're early.", duration = 5, sound = true },
	{ text = "Orientation's short. Keep your radios open.", duration = 4, sound = true },
	{ text = "Power is unstable. We need Generator A online.", duration = 5, sound = true, glitch = true },
	{ text = "Security cameras are intermittent. Reset them when you're nearby.", duration = 5, sound = true },
	{ text = "Basement generator is last. Don't go down there alone.", duration = 6, sound = true, glitch = true },
	{ text = "If you see movement—don't stare. Just report.", duration = 6, sound = true },
	{ text = "You will hear things. Ignore them.", duration = 4, sound = true },
	{ text = "Orientation begins.", duration = 3, sound = true, glitch = true },
}

CutsceneConfig.Basement = {
	{ text = "Basement power surging...", duration = 3, sound = true },
	{ text = "Keep moving. Do not stop.", duration = 4, sound = true, glitch = true },
	{ text = "...", duration = 2 },
}

CutsceneConfig.Ending = {
	{ text = "Orientation complete.", duration = 4, sound = true },
	{ text = "Containment Protocol: Phase One successful.", duration = 5, sound = true },
	{ text = "You were never alone.", duration = 4, sound = true, glitch = true },
	{ text = "Report to Sector 3 for Phase Two.", duration = 5, sound = true },
	{ text = "We are watching.", duration = 4, sound = true },
}

return CutsceneConfig
