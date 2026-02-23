local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

function Remotes.getFolder()
	local folder = ReplicatedStorage:FindFirstChild("Remotes")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Remotes"
		folder.Parent = ReplicatedStorage
	end
	return folder
end

function Remotes.getRemote(folder, name)
	local remote = folder:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = folder
	end
	return remote
end

function Remotes.ensure(names)
	local folder = Remotes.getFolder()
	local remotes = {}
	for _, name in ipairs(names) do
		remotes[name] = Remotes.getRemote(folder, name)
	end
	return remotes
end

return Remotes
