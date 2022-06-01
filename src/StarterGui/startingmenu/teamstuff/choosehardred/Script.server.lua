function Click(mouse)
	--local respawnDelay = 5


	script.Parent.Parent.Parent.Parent.Parent.TeamColor = BrickColor.new("Really red")
	script.Parent.Parent.Parent.Parent.Parent.Character.HumanoidRootPart.CFrame = workspace.spawnstele["Hard Red Team"].CFrame
	for i,v in pairs(script.Parent.Parent.Parent.Parent.Parent.Character:GetChildren()) do
		if v:IsA("Part") or v:IsA("MeshPart") then
			v.Color = Color3.new(0.877211, 0.262501, 0.314794)
		end
	end

	--game.Players.PlayerAdded:Connect(function(player)
	--	player:LoadCharacter() -- load the character for the first time
	--end)



end


script.Parent.MouseButton1Click:connect(Click)