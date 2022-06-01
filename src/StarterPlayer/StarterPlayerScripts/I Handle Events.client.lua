local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local fireremote = ReplicatedStorage:WaitForChild("weaponRemotes"):WaitForChild("fire")

local fastcastHandler = require(ReplicatedStorage:WaitForChild("modules"):WaitForChild("fastCastHandler"))

fireremote.OnClientEvent:Connect(function(player, origin, direction, projectileType)
	if player ~= Players.LocalPlayer then

		local gun = player.gun.Value
		local properties = gun.settings

		local sound = gun.receiver.pewpew:Clone()
		sound.Parent = gun.receiver
		sound:Play()

		for _, v in pairs(gun.receiver.barrel:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(v.Rate)
			end
		end

		fastcastHandler:fire(origin, direction, properties, projectileType ,true)
	end
end)

