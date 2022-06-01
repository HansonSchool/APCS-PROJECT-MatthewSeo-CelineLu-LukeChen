

--local replicatedStorage = game:GetService("ReplicatedStorage")
--local respawnEvent = replicatedStorage:WaitForChild("Respawn_Plr")
local button = script.Parent
button.MouseButton1Click:Connect(function()
	--respawnEvent:FireServer()
	script.Parent.Visible = false
	script.Parent.Parent.changetohardblue.Visible = true
	print("hi")
end)

