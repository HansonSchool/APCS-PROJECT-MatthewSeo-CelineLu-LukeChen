local function onPlayerJoin(player)

local leaderstats = Instance.new("Folder")

leaderstats.Name = 'leaderstats'

leaderstats.Parent = player



local kills = Instance.new("IntValue")

kills.Value = 0

kills.Name = 'Hits'

kills.Parent = leaderstats



--	local deaths = Instance.new('IntValue')

--	deaths.Value = 0

--	deaths.Name = 'Outs'

--	deaths.Parent = leaderstats



--	--local killer = Instance.new('StringValue')

--	--killer.Name = 'Killer'

--	--killer.Parent = player
--	player.CharacterAdded:connect(function(char)
--		local humanoid
--		repeat 
--			humanoid = char:FindFirstChild("Humanoid")
			
--		until humanoid
--		humanoid.Died:connect(function()
--			local tag = humanoid:FindFirstChild("creator")
--			if tag then
--				local killer = tag.Value
--				if killer then
--					killer.leaderstats.Kills.Value = killer.leaderstats.Kills.Value + 1
--				end
--			end
--		end)
--	end)


end



--game.Players.PlayerAdded:Connect(onPlayerJoin)



----Death Tracker



--game:GetService('Players').PlayerAdded:Connect(function(player)

--	player.CharacterAdded:Connect(function(character)

--		character:WaitForChild("Humanoid").Died:Connect(function()
--			--if player.TeamColor ~= BrickColor.new("Institutional white") then
--			--	player.leaderstats.Deaths.Value = player.leaderstats.Deaths.Value + 1
--			--end
--			player.leaderstats.Deaths.Value = player.leaderstats.Deaths.Value + 1

--			--local killerTag = game.Players:FindFirstChild(player.Killer.Value)

--			--if killerTag then

--			--	killerTag.leaderstats.Kills.Value = killerTag.leaderstats.Kills.Value + 1

--			--end

--		end)

--	end)

--end)