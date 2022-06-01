local ReplicatedStorage    = game:GetService("ReplicatedStorage")
local Players 			   = game:GetService("Players")
local RunService		   = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character 
local Humanoid = Character:WaitForChild("Humanoid")

local enumBinds = {
	[1] = "One",
	[2] = "Two",
	[3] = "Three",
}

ReplicatedStorage:WaitForChild("modules")
ReplicatedStorage:WaitForChild("weaponRemotes")
ReplicatedStorage.modules:WaitForChild("Velocity")
ReplicatedStorage.weaponRemotes:WaitForChild("fire")

local RagdollHandler = require(ReplicatedStorage:WaitForChild("RagdollHandler"))

local weaponHandler = require(ReplicatedStorage.modules.Framework)

local velocity = require(ReplicatedStorage.modules.Velocity):Init(true)
local InputService = velocity:GetService("InputService")

local weps, ammoData = ReplicatedStorage.weaponRemotes.new:InvokeServer()
local weapon = weaponHandler.New(weps)

weapon.ammoData = ammoData


local viewmodels = workspace.Camera:GetChildren()
for _, v in pairs(viewmodels) do
	local viewmodel = v and v.Name == "viewmodel"
	if viewmodel then
		viewmodel:Destroy()
	end
end

for i, v in pairs(weps) do
	local working

	local function equip()
		if working then
			return
		end

		working = true

		if weapon.curWeapon ~= v then
			if weapon.equipped then
				weapon:Remove()
			end
			weapon:Equip(v)
		else
			task.spawn(function()
				weapon:Remove()
			end)
			weapon.curWeapon = nil
		end

		working = false
	end

	InputService.BindOnBegan(nil, enumBinds[i], equip, "Equip : " .. i)
end

local function update(dt)
	weapon:Update(dt)
end
	
InputService.BindOnBegan("MouseButton1", nil, function()
	weapon:Fire(true)
end, "Fire")

InputService.BindOnEnded("MouseButton1", nil, function()
	weapon:Fire(false)
end, "FireEnd")

InputService.BindOnBegan("MouseButton2", nil, function()
	weapon:Aim(true)
end, "Aim")
InputService.BindOnEnded("MouseButton2", nil, function()
	weapon:Aim(false)
end, "AimEnd")

--InputService.BindOnBegan(nil, "R", function()
--	weapon:Reload()
--end, "Reload")

Humanoid.Died:Connect(function()
	weapon:Remove()
	weapon.disabled = true
	
	Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
end)


local fallpos = Vector3.new()
local re = ReplicatedStorage.poop

re.OnClientEvent:Connect(function()
	weapon:Reload()
end)

--function statechange(old,new)
--	if new==Enum.HumanoidStateType.Freefall then
--		fallpos = Character:WaitForChild("HumanoidRootPart").Position
--	elseif new == Enum.HumanoidStateType.Landed then
--		local fallv = math.abs(Character:WaitForChild("HumanoidRootPart").Velocity.Y)
--		if fallv>90 then
--			local damage = math.abs(Character:WaitForChild("HumanoidRootPart").Velocity.Y/50) ^ 4
--			re:FireServer(Humanoid)
--		end
--	end
--end

--Humanoid.StateChanged:Connect(statechange)
RunService.RenderStepped:Connect(update)
