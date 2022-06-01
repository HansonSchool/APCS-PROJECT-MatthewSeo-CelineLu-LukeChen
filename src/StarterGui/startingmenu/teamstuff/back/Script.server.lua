function Click(mouse)
	script.Parent.Parent.Parent.Parent.Parent.Character.HumanoidRootPart.CFrame = workspace.spawnstele["SpawnLocation"].CFrame
	for i,v in pairs(script.Parent.Parent.Parent.Parent.Parent.Character:GetChildren()) do
		if v:IsA("Part") or v:IsA("MeshPart") then
			v.Color = Color3.new(1, 0.999969, 0.999985)
		end
	end

end

script.Parent.MouseButton1Click:connect(Click)