local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPack = game:GetService("StarterPack")
local StarterPlayer = game:GetService("StarterPlayer")

local buildRagdoll = require(ReplicatedStorage:WaitForChild("buildRagdoll"))
local RagdollHandler = require(ReplicatedStorage:WaitForChild("RagdollHandler"))

local RagdollEvent = ReplicatedStorage.Ragdoll

function Clone(instance)
	local oldArchivable = instance.Archivable

	instance.Archivable = true
	local clone = instance:Clone()
	instance.Archivable = oldArchivable

	return clone
end

function characterAdded(player, character)
	--player.CharacterAppearanceLoaded:wait()
	
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	buildRagdoll(humanoid)
end

function characterRemoving(player, character)
	--RagdollEvent:FireClient()
	--works without event for now
	
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
		return
	end

	local clone = Clone(character)
	local cloneHumanoid = clone:FindFirstChildOfClass("Humanoid")

	cloneHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	cloneHumanoid.AutomaticScalingEnabled = false

	local animate = character:FindFirstChild("Animate")
	local sound = character:FindFirstChild("Sound")
	local health = character:FindFirstChild("Health")
	local fakeWeapon = clone:FindFirstChild("FakeWeapon")

	if animate then
		animate:Destroy()
	end
	if sound then
		sound:Destroy()
	end
	if health then
		health:Destroy()
	end
	if fakeWeapon then
		fakeWeapon:Destroy() -- will be gun dropping later
	end

	clone.Parent = workspace

	cloneHumanoid:ChangeState(Enum.HumanoidStateType.Physics)
	
	task.delay(5, function()
		clone:Destroy()
	end)
end

function playerAdded(player)
	player.CharacterAdded:Connect(function(character)
		characterAdded(player, character)
	end)

	player.CharacterRemoving:Connect(function(character)
		characterRemoving(player, character)
	end)

	if player.Character then
		characterAdded(player, player.Character)
	end
end

Players.PlayerAdded:Connect(playerAdded)

for _,player in pairs(Players:GetPlayers()) do
	playerAdded(player)
end
