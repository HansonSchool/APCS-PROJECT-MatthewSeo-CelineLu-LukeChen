function Click(mouse)
	

	--game.Players.CharacterAutoLoads = false
	--local humanoid1 = game.Players.LocalPlayer.Character.Humanoid
	--humanoid1.Health = 0


	
	local Players = game:GetService("Players")
	local mouse = Players.LocalPlayer:GetMouse()
	mouse.Icon = 'rbxassetid://68308747'
	local Player = game.Players.LocalPlayer
	--Player.CameraMode = Enum.CameraMode.LockFirstPerson
end
script.Parent.MouseButton1Click:connect(Click)