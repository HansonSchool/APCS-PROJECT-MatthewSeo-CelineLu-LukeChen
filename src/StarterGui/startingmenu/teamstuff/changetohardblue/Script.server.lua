function Click(mouse)
	--local respawnDelay = 5


	script.Parent.Parent.Parent.Parent.Parent.TeamColor = BrickColor.new("Dark blue")
	script.Parent.Parent.Parent.Parent.Parent.Character.HumanoidRootPart.CFrame = workspace.spawnstele["Hard Blue Team"].CFrame
	for i,v in pairs(script.Parent.Parent.Parent.Parent.Parent.Character:GetChildren()) do
		if v:IsA("Part") or v:IsA("MeshPart") then
			v.Color = Color3.new(0.425299, 0.732128, 0.888502)
		end
	end

	--game.Players.PlayerAdded:Connect(function(player)
	--	player:LoadCharacter() -- load the character for the first time
	--end)



end


script.Parent.MouseButton1Click:connect(Click)