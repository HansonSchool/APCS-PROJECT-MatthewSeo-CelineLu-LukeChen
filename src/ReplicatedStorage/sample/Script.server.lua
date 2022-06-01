local humanoid = script.Parent.Humanoid

local buildRagdoll = require(game:GetService("ReplicatedStorage"):WaitForChild("buildRagdoll"))
buildRagdoll(humanoid)

local animation = script:WaitForChild('Animation')
local humanoid = script.Parent:WaitForChild('Humanoid')
local dance = humanoid:LoadAnimation(animation)
dance:Play()

humanoid.Died:Connect(function()
	dance:Stop()
	task.wait(3) -- Wait until it's time to respawn

	task.delay(3, function()
		script.Parent:Destroy()
	end)
end)