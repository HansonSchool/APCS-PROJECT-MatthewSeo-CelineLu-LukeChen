local collectionService = game:GetService("CollectionService")
local players = game:GetService("Players")
local runService = game:GetService("RunService")

local TAG_NAME = "Ragdoll"
local RAGDOLL_STATES = {
	[Enum.HumanoidStateType.Dead] = true,
	[Enum.HumanoidStateType.Physics] = true,
	[Enum.HumanoidStateType.FallingDown] = true,
}

local connections = {}

function setRagdollEnabled(humanoid, isEnabled)
	local ragdollConstraints = humanoid.Parent:WaitForChild("RagdollConstraints")
	
	for _,constraint in pairs(ragdollConstraints:GetChildren()) do
		if constraint:IsA("Constraint") then
			wait()
			local rigidJoint = constraint.RigidJoint.Value
			local expectedValue = (not isEnabled) and constraint.Attachment1.Parent or nil
			
			if rigidJoint.Part1 ~= expectedValue then
				rigidJoint.Part1 = expectedValue 
			end
		end
	end
end

function hasRagdollOwnership(humanoid)
	if runService:IsServer() then
		
		return true
	end

	local player = players:GetPlayerFromCharacter(humanoid.Parent)
	return player == players.LocalPlayer
end

function ragdollAdded(humanoid)
	connections[humanoid] = humanoid.StateChanged:Connect(function(oldState, newState)
		if hasRagdollOwnership(humanoid) then
			if RAGDOLL_STATES[newState] then
				setRagdollEnabled(humanoid, true)
			else
				setRagdollEnabled(humanoid, false)
			end
		end
	end)
end

function ragdollRemoved(humanoid)
	connections[humanoid]:Disconnect()
	connections[humanoid] = nil
end

collectionService:GetInstanceAddedSignal(TAG_NAME):Connect(ragdollAdded)
collectionService:GetInstanceRemovedSignal(TAG_NAME):Connect(ragdollRemoved)
for _,humanoid in pairs(collectionService:GetTagged(TAG_NAME)) do
	ragdollAdded(humanoid)
end

return nil