local sentence = {
	[1] = "I am hungry!",
	[2] = "I am very hungry, give me FOOD now!",
	[3] = "I am SUPER hungry, I NEED FOOD NOW!!!"
}

local function generateStat(new, level)
	local Color 
	if level == 1 then
		--GREEN COLOR
		Color = Color3.new(0.380392, 0.847059, 0.298039) 
	elseif level == 2 then
		--YELLOW COLOR
		Color = Color3.new(1, 0.894118, 0.0941176)
	elseif level == 3 then
		--RED COLOR
		Color = Color3.new(0.847059, 0.384314, 0.152941)
	end
	
	for i,v in pairs(new:GetChildren()) do
		if v:IsA("Part") or v:IsA("MeshPart") then
			v.Color = Color
		end
	end
	
	coroutine.wrap(function()
		while true do
			wait(10)
			if new:FindFirstChild("Head") then
				game:GetService("Chat"):Chat(new.Head, sentence[level])
			end
		end
	end)()
end


while true do
	wait(5)

	if #workspace.people:GetChildren() <= 5 then
		local new = game.ReplicatedStorage["sample"]:Clone()
		new.Parent = workspace.people
		new.PrimaryPart = new.HumanoidRootPart
		
		new:MoveTo(Vector3.new(math.random(-800.847, -745.344), 4, math.random(-450.622, -398.281)))

		local random = Random.new()
		local hungryLevel  = Instance.new("NumberValue")
		hungryLevel.Parent = new
		hungryLevel.Name = "hungryLevel"
		hungryLevel.Value = random:NextInteger(1, 10)
		
		if hungryLevel.Value <= 7 then
			new.Name = "Low"
			generateStat(new, 1)
		elseif hungryLevel.Value <= 9 then
			new.Name = "Medium"
			generateStat(new, 2)
		else
			new.Name = "High"
			generateStat(new, 3)
		end

		--local origin = new.HumanoidRootPart.Position
		--local ray = Ray.new(origin, new.HumanoidRootPart.CFrame.UpVector * -100)
		--local hit, pos, norm = game.Workspace:FindPartOnRay(ray)
		--new:SetPrimaryPartCFrame(CFrame.new(pos, pos + norm) * CFrame.fromEulerAngles(0, -90, 0))
	end	
end


