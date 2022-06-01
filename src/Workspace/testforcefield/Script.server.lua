

function onTouch(part)
	local player = game.Players:GetPlayerFromCharacter(part.Parent)
	player.Character.Humanoid:TakeDamage(100)
end
script.Parent.Touched:Connect(onTouch)