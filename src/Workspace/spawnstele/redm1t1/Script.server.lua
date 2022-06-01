local DBAlowed = BrickColor.new("Really red")


function onTouch(part)
	local player = game.Players:GetPlayerFromCharacter(part.Parent)
	if player then
		if player.TeamColor == DBAlowed then
			--part.Parent:MoveTo(script.Parent.Parent.BlueTeamSpawn.Position) idk i changed the way of teleporting
			part.Parent.HumanoidRootPart.Position = workspace.spawnstele.redm1t2.Position
			local forcefield = part.Parent.HumanoidRootPart:WaitForChild("ForceField")
			wait(1)

			forcefield:Destroy()
			print("forcefield destroyed")
			--script.Parent.Parent.t2Tele2.Script.Disabled = true 
			--wait(2)
			--script.Parent.Parent.t2Tele2.Script.Disabled = false
		end
	end
end
script.Parent.Touched:Connect(onTouch)
