----local Players = game:GetService("Players")
----local function onCharacterAdded(character)
----	print("hi")
----	print(character.Name .. " has spawned")
	
----end

----Players.PlayerAdded:Connect(onCharacterAdded())
--game.Players.PlayerAdded:connect(function(player)
--	player.CharacterAdded:Connect(function()
--		print("hi")
--		print(player.Name)
--		local humanoidrootpart = player.Character:FindFirstChild("HumanoidRootPart")
--		local forcefield = Instance.new("ForceField")
--		forcefield.Parent = humanoidrootpart
--		--forcefield.Visible = true
--		--forcefield.Parent = humanoid.Parent

--		print("added forcefield?")
--		player.Character:FindFirstChild("Humanoid").Died:Connect(function()
--			--player:LoadCharacter()
--			print("respawned")
--		end)
--	end)
	
	
--end)