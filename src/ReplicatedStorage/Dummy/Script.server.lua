local humanoid = script.Parent.Humanoid
local Dummy = game:GetService("ReplicatedStorage"):WaitForChild("Dummy")

local buildRagdoll = require(game:GetService("ReplicatedStorage"):WaitForChild("buildRagdoll"))
buildRagdoll(humanoid)

function Clone(instance)
	local oldArchivable = instance.Archivable

	instance.Archivable = true
	local clone = instance:Clone()
	instance.Archivable = oldArchivable

	local random = Random.new()
	local hungaryLevel  = Instance.new("NumberValue")
	hungaryLevel.Parent = clone
	hungaryLevel.Value = random:NextNumber(1, 3)


	return clone
end

humanoid.Died:Connect(function()
	task.wait(3) -- Wait until it's time to respawn
	local clone = Clone(Dummy)
	local cloneHumanoid = clone:FindFirstChildOfClass("Humanoid")
	cloneHumanoid.Health = cloneHumanoid.MaxHealth

	--cloneHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	--cloneHumanoid.AutomaticScalingEnabled = false

	--script.Parent:ChangeState(Enum.HumanoidStateType.Physics)

	task.delay(5, function()
		script.Parent:Destroy()
	end)
end)