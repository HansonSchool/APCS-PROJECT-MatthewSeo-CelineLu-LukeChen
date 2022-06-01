local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local remotes = ReplicatedStorage:WaitForChild("weaponRemotes")
local weapons = ReplicatedStorage:WaitForChild("weapons")
local randomRemote = ReplicatedStorage:WaitForChild("RemoteEvent")
local Teams = game:GetService("Teams")

local RoundSystem = require(ServerStorage:WaitForChild("Modules"):WaitForChild("RoundSystem"))
_G.players = {}

local defaultWeapons = {
	[1] = "Vandal",
	--[2] = "shotgun",
}

local magazineCount = 5


Players.PlayerAdded:Connect(function(player)
	local values = {
		{ name = "gun", value = nil, type = "ObjectValue" },
	}

	for _, v in pairs(values) do
		local value = Instance.new(v.type)
		value.Name = v.name
		value.Value = v.value
		value.Parent = player
	end
end)

remotes:WaitForChild("new").OnServerInvoke = function(player)
	if not player.Character then
		return
	end

	_G.players[player.UserId] = {}
	local weaponTable = _G.players[player.UserId]

	weaponTable.magData = {}
	weaponTable.weapons = {}
	weaponTable.loadedAnimations = {}

	for index, weaponName in pairs(defaultWeapons) do
		local weapon = weapons[weaponName]:Clone()
		local weaponSettings = require(weapon.settings)

		weaponTable.weapons[weaponName] = { weapon = weapon, settings = weaponSettings }

		weaponTable.magData[index] = {
			current = weaponSettings.firing.magCapacity,
			spare = weaponSettings.firing.magCapacity * magazineCount,
		}
		
		weapon.Name = "FakeWeapon"
		weapon.Parent = player.Character
		weapon.Body.backweld.Part0 = player.Character.UpperTorso
	end

	return defaultWeapons, weaponTable.magData
end

remotes:WaitForChild("equip").OnServerInvoke = function(player, wepName)
	if _G.players[player.UserId].currentWeapon then
		return
	end
	if not _G.players[player.UserId].weapons then
		return
	end
	if not _G.players[player.UserId].weapons[wepName] then
		return
	end
	if not player.Character then
		return
	end
	local weaponTable = _G.players[player.UserId]

	weaponTable.currentWeapon = weaponTable.weapons[wepName]
	player.gun.Value = weaponTable.currentWeapon.weapon

	weaponTable.currentWeapon.Parent = player.Character	
	weaponTable.currentWeapon.weapon.Body.backweld.Part0 = nil

	weaponTable.currentWeapon.weapon.Body.weaponHold.Part0 = player.Character["RightHand"]
	weaponTable.loadedAnimations.idle = player.Character.Humanoid:LoadAnimation(
		weaponTable.currentWeapon.settings.animations.player.idle
	)
	weaponTable.loadedAnimations.idle:Play()
	return true
end

remotes:WaitForChild("aim").OnServerEvent:Connect(function(player, toaim)
	if not _G.players[player.UserId].currentWeapon then
		return
	end
	if not player.Character then
		return
	end
	local weaponTable = _G.players[player.UserId]

	weaponTable.aiming = toaim

	if not weaponTable.loadedAnimations.aim then
		weaponTable.loadedAnimations.aim = player.Character.Humanoid:LoadAnimation(
			weaponTable.currentWeapon.settings.animations.player.aim
		)
	end

	if toaim then
		weaponTable.loadedAnimations.aim:Play()
	else
		weaponTable.loadedAnimations.aim:Stop()
	end
end)

remotes:WaitForChild("unequip").OnServerInvoke = function(player)
	if not _G.players[player.UserId].currentWeapon then
		return
	end
	if not player.Character then
		return
	end
	local weaponTable = _G.players[player.UserId]

	weaponTable.loadedAnimations.idle:Stop()
	weaponTable.loadedAnimations = {}

	if weaponTable.currentWeapon.weapon.Body:FindFirstChild("weaponHold") then
		weaponTable.currentWeapon.Parent = player.Character
		weaponTable.currentWeapon.weapon.Body.backweld.Part0 = player.Character.UpperTorso

		weaponTable.currentWeapon.weapon.Body.weaponHold.Part0 = nil
	end

	weaponTable.currentWeapon = nil
	player.gun.Value = nil
	return true
end

remotes:WaitForChild("fire").OnServerEvent:Connect(function(player, origin, direction, projectileType)
	local weaponTable = _G.players[player.UserId]
	if not weaponTable.currentWeapon then
		return
	end
	if not player.Character then
		return
	end
	
	_G.players[player.UserId].projectile = projectileType

	remotes.fire:FireAllClients(player, origin, direction, projectileType)

	if weaponTable.aiming then
		if not weaponTable.loadedAnimations.aimFire then
			weaponTable.loadedAnimations.aimFire = player.Character.Humanoid:LoadAnimation(
				weaponTable.currentWeapon.settings.animations.player.aimFire
			)
		end

		weaponTable.loadedAnimations.aimFire:Play()
	else
		if not weaponTable.loadedAnimations.idleFire then
			weaponTable.loadedAnimations.idleFire = player.Character.Humanoid:LoadAnimation(
				weaponTable.currentWeapon.settings.animations.player.idleFire
			)
		end

		weaponTable.loadedAnimations.idleFire:Play()
	end
end)

local function handlekill(victim, killer)
	print(victim.Parent.Name.."has been satisfied by "..killer.Name.." and is no longer hungary")
end

local function addPoints(player, hitPart, headShot, projectileType)
	if hitPart == nil or hitPart.Parent == nil or hitPart.Parent.Humanoid.Health <= 0 then return end
	local bonus = require(game.ReplicatedStorage.itemData)[projectileType].Bonus
	if player.Team == Teams["Team Red"] then
		if headShot then
			ReplicatedStorage.ServerValues.RedScore.Value += hitPart.Parent.hungryLevel.Value * 2 + bonus
		else
			ReplicatedStorage.ServerValues.RedScore.Value += hitPart.Parent.hungryLevel.Value + bonus
		end
	elseif player.Team == Teams["Team Blue"] then
		if headShot then
			ReplicatedStorage.ServerValues.BlueScore.Value += hitPart.Parent.hungryLevel.Value * 2 + bonus
		else
			ReplicatedStorage.ServerValues.BlueScore.Value += hitPart.Parent.hungryLevel.Value + bonus
		end 
	end
end

remotes:WaitForChild("hit").OnServerEvent:Connect(function(player, humanoid, headshot, hitPart)
	--local shooter = game:GetService("Players").LocalPLayer
	if not _G.players[player.UserId].currentWeapon then
		return
	end
	if not player.Character then
		return
	end

	if humanoid.Parent.Name == "Dummy" or humanoid.Parent.Name == "Low" or humanoid.Parent.Name == "Medium" or humanoid.Parent.Name == "High" or Players:GetPlayerFromCharacter(humanoid.Parent).Team ~= player.Team then
		if humanoid.health <= 0 then
			--local victimplayer = game.Players:GetPlayerFromCharacter(humanoid.Parent)
			handlekill(humanoid, player)
		end
		
		--local Tagged = Instance.new("ObjectValue")
		--Tagged.Name = "creator"
		--Tagged.Value = player
		--Tagged.Parent = hitPart.Parent.Humanoid
		
		--creator tag works for now ig, will change later maybe idk
		local projectileType = _G.players[player.UserId].projectile

		if headshot then
			humanoid:TakeDamage(_G.players[player.UserId].currentWeapon.settings.firing.headshot)
			addPoints(player, hitPart, headshot, projectileType)
		else
			humanoid:TakeDamage(_G.players[player.UserId].currentWeapon.settings.firing.damage)
			addPoints(player, hitPart, headshot, projectileType)
		end
	end
end)

randomRemote.OnServerEvent:Connect(function(player, name, spawnpos, health)
	player.Character.HumanoidRootPart.CFrame = spawnpos
end)


--Matthew 1
while true do
	local Map, Gamemode = RoundSystem.GetMatch()

	print("Map"..Map.."|| Mode"..Gamemode)

	local status, error = pcall(function()
		RoundSystem.StartMatch(Map, Gamemode)
	end)

	if error then
		print(error)
	end

	wait(1)
end


