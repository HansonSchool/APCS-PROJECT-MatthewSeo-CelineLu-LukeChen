local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local Animate 
local Humanoid = player.Character:FindFirstChild('Humanoid')

mouse.KeyDown:Connect(function(Key) 
	if Key == "c" then
		print("crouching")
		local Animation = Instance.new("Animation", player.Character)
		Animation.AnimationId = "rbxassetid://6191406943"
		Animate = Humanoid:LoadAnimation(Animation)
		Humanoid.WalkSpeed = 10
		Animate:Play()
	end  
end)

mouse.KeyUp:Connect(function(Key)
	if Key == "c" then
		Humanoid.WalkSpeed = 16
		Animate:Stop()
	end
end)
