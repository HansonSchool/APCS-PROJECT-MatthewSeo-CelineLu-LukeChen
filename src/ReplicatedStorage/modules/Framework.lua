local FrameWork = {}
local fpsMT = { __index = FrameWork }

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

ReplicatedStorage:WaitForChild("modules")
ReplicatedStorage.modules:WaitForChild("fastCastHandler")
ReplicatedStorage.modules:WaitForChild("spring")

local fastcastHandler = require(ReplicatedStorage.modules.fastCastHandler)
local spring = require(ReplicatedStorage.modules.spring)
local Hud = require(ReplicatedStorage.modules.HudHandler)

local curr_projectile = "Hotdog"

local function getBobbing(addition, speed, modifier)
	return math.sin(tick() * addition * speed) * modifier
end
--[[
local function gunbob(a,r)
	local a,r=a or 1,r or 1
	local d,s,v=char.distance*6.28318*3/4,char.speed,-char.velocity
	local w=v3(r*sin(d/4-1)/256+r*(sin(d/64)-r*v.z/4)/512,r*cos(d/128)/128-r*cos(d/8)/256,r*sin(d/8)/128+r*v.x/1024)*s/20*6.28318
	return cf(r*cos(d/8-1)*s/196,1.25*a*sin(d/4)*s/512,0)*cframe.fromaxisangle(w)
end
]]
function FrameWork.New(weapons)
	local self = {}

	self.loadedAnimations = {}
	self.springs = {}
	self.lerpValues = {}
	self.ammo = {} 

	self.lerpValues.aim = Instance.new("NumberValue")
	self.lerpValues.equip = Instance.new("NumberValue")
	self.lerpValues.equip.Value = 1

	self.springs.walkCycle = spring.create()
	self.springs.sway = spring.create()
	self.springs.fire = spring.create()

	self.canFire = true

	return setmetatable(self, fpsMT)
end

function FrameWork:Equip(wepName)
	if self.disabled then
		return
	end
	if self.equipped then
		self:Remove()
	end
	if self.reloading then
		return
	end
	local weapon = ReplicatedStorage.weapons:FindFirstChild(wepName) 
	if not weapon then
		return
	end
	weapon = weapon:Clone()

	self.viewmodel = ReplicatedStorage.viewmodel:Clone()
	for _, v in pairs(weapon:GetChildren()) do
		v.Parent = self.viewmodel
		if v:IsA("BasePart") then
			v.CanCollide = false
			v.CastShadow = false
		end
	end

	self.camera = workspace.CurrentCamera
	self.character = Players.LocalPlayer.Character

	self.viewmodel.HumanoidRoot.CFrame = CFrame.new(0, -100, 0)

	self.viewmodel.HumanoidRoot.WeaponMain.Part1 = self.viewmodel.WeaponMain
	--self.viewmodel.left.leftHand.Part0 = self.viewmodel.WeaponMain
	--self.viewmodel.RightArm.WeaponMain.Part1 = self.viewmodel.WeaponMain

	self.viewmodel.Parent = workspace.Camera

	self.settings = require(self.viewmodel.settings)
	self.loadedAnimations.idle = self.viewmodel.AnimationController:LoadAnimation(
		self.settings.animations.viewmodel.idle
	)
	self.loadedAnimations.reload = self.viewmodel.AnimationController:LoadAnimation(
		self.settings.animations.viewmodel.reload
	)
	self.loadedAnimations.fire = self.viewmodel.AnimationController:LoadAnimation(
		self.settings.animations.viewmodel.fire
	)
	self.loadedAnimations.idle:Play()

	self.wepName = wepName
	self.ammo[wepName] = self.ammo[wepName] or (self.settings.firing.magCapacity + 1)
	
	Hud:updateAmmo(self.ammo[self.wepName], 120)

	local tweeningInformation = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	TweenService:Create(self.lerpValues.equip, tweeningInformation, { Value = 0 }):Play()

	--[[
		Real life example:
			
		self.loadedAnimations.idle = self.viewmodel.AnimationController:LoadAnimation(self.settings.anims.viewmodel.idle)
		self.loadedAnimations.idle:Play()
	
		self.tweenLerp("equip","In")
		self.playSound("draw")
		
	--]]

	task.spawn(function()
		local pass = ReplicatedStorage.weaponRemotes.equip:InvokeServer(wepName)
		if not pass then
			self:Remove()
		end
	end)
	

	self.curWeapon = wepName
	self.equipped = true
end

function FrameWork:Remove()
	if self.reloading then
		return
	end
	if self.firing then
		self:Fire(false)
	end
	if self.aiming then
		self:Fire(false)
	end

	local tweeningInformation = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	TweenService:Create(self.lerpValues.equip, tweeningInformation, { Value = 1 }):Play()

	self.equipped = false
	self.disabled = true
	self.curWeapon = nil

	task.spawn(function()
		ReplicatedStorage.weaponRemotes.unequip:InvokeServer()
	end)

	task.wait(0.6)
	if self.viewmodel then
		self.viewmodel:Destroy()
		self.viewmodel = nil
	end
	self.disabled = false
end

function FrameWork:Reload()
	if self.disabled then
		return
	end
	if not self.equipped then
		return
	end
	if self.firing then
		self:Fire(false)
	end
	if self.aiming then
		self:Aim(false)
	end
	if self.reloading then
		return
	end

	self.reloading = true
	self.ammo[self.wepName] = 0
	self.loadedAnimations.reload:Play()

	if not self.equipped then
		return
	end
	task.wait(self.loadedAnimations.reload.Length)

	self.ammo[self.wepName] = self.settings.firing.magCapacity
	Hud:updateAmmo(self.ammo[self.wepName], 120)
	
	self.reloading = false
end

function FrameWork:Fire(tofire)
	if self.reloading then
		return
	end
	if self.disabled then
		return
	end
	if not self.equipped then
		return
	end
	if tofire and self.ammo[self.wepName] <= 0 then
		--self:Reload()
		return
	end
	if self.firing and tofire then
		return
	end
	if not self.canFire and tofire then
		return
	end

	self.firing = tofire
	if not tofire then
		return
	end

	local function Fire()
		if self.ammo[self.wepName] <= 0 then
			return
		end

		local sound = self.viewmodel.Body.pewpew:Clone()
		sound.Parent = self.viewmodel.Body
		sound:Play()

		Debris:AddItem(sound, 5)
		self.loadedAnimations.fire:Play()
		self.ammo[self.wepName] = self.ammo[self.wepName] - 1
		Hud:updateAmmo(self.ammo[self.wepName], 120)
		
		self.springs.fire:shove(Vector3.new(0.012, 0, 0) * self.deltaTime * 60)
		--the vector.new(thisnumber , 0, 0) changes how much u wanna go up; the delta time too
		task.delay(0.05, function()
			self.springs.fire:shove(Vector3.new(-0.01, 0, 0) * self.deltaTime * 60)
		end)

		for _, v in pairs(self.viewmodel.Body.barrel:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(v.Rate)
			end
		end
		local origin = self.viewmodel.Body.barrel.WorldPosition
		local direction = self.viewmodel.Body.barrel.WorldCFrame

		--if self.settings.Type == "Shotgun" then
		--	for i = 1, 15 do
		--		fastcastHandler:Fire(origin, direction, self.settings)
		--	end
		--else
		--	fastcastHandler:Fire(origin, direction, self.settings)
		--end
		
		for i = 1, (self.settings.Type == "Shotgun" and 15 or 1) do
			fastcastHandler:Fire(origin, direction, self.settings, curr_projectile)
		end

		task.wait(60 / self.settings.firing.rpm)
	end

	repeat
		self.canFire = false
		Fire()
		self.canFire = true
	until self.ammo[self.wepName] <= 0 or not self.firing

	if self.ammo[self.wepName] <= 0 then
		self.firing = false
	end
end

function FrameWork:Aim(toaim)
	if self.disabled then
		return
	end
	if not self.equipped then
		return
	end

	self.aiming = toaim
	UserInputService.MouseIconEnabled = not toaim --do this wherever you want
	ReplicatedStorage.weaponRemotes.aim:FireServer(toaim)

	if toaim then
		local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		TweenService:Create(self.lerpValues.aim, tweeningInformation, { Value = 1 }):Play()
	else
		local tweeningInformation = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		TweenService:Create(self.lerpValues.aim, tweeningInformation, { Value = 0 }):Play()
	end
end

function FrameWork:Update(deltaTime)
	self.deltaTime = deltaTime

	if self.viewmodel then
		local animatorCFrameDifference = self.lastBodyRelativity
			or CFrame.new() * self.viewmodel.camera.CFrame:ToObjectSpace(self.viewmodel.HumanoidRoot.CFrame):Inverse()
		local x, y, z = animatorCFrameDifference:ToOrientation()
		workspace.Camera.CFrame = workspace.Camera.CFrame * CFrame.Angles(x, y, z)
		self.lastBodyRelativity = self.viewmodel.camera.CFrame:ToObjectSpace(self.viewmodel.HumanoidRoot.CFrame)

		local velocity = self.character.HumanoidRootPart.Velocity

		local idleOffset = self.viewmodel.offsets.idle.Value
		local aimOffset = idleOffset:lerp(self.viewmodel.offsets.aim.Value, self.lerpValues.aim.Value)
		local equipOffset = aimOffset:lerp(self.viewmodel.offsets.equip.Value, self.lerpValues.equip.Value)

		local finalOffset = equipOffset

		local mouseDelta = UserInputService:GetMouseDelta()
		if self.aiming then
			mouseDelta *= 0.1
		end
		self.springs.sway:shove(Vector3.new(mouseDelta.X / 1000, mouseDelta.Y / 1000)) --not sure if this needs deltaTime filtering

		local speed = 1

		local modifier = 0.1

		if self.aiming then
			modifier = 0.01
		end

		local movementSway = Vector3.new(
			getBobbing(10, speed, modifier),
			getBobbing(5, speed, modifier),
			getBobbing(5, speed, modifier)
		)

		self.springs.walkCycle:shove((movementSway / 500) * deltaTime * 60 * velocity.Magnitude)

		local sway = self.springs.sway:update(deltaTime)
		local walkCycle = self.springs.walkCycle:update(deltaTime)
		local recoil = self.springs.fire:update(deltaTime)

		self.camera.CFrame = self.camera.CFrame * CFrame.Angles(recoil.x, recoil.y, recoil.z)
		self.viewmodel.HumanoidRoot.CFrame = self.camera.CFrame:ToWorldSpace(finalOffset)
		self.viewmodel.HumanoidRoot.CFrame = self.viewmodel.HumanoidRoot.CFrame:ToWorldSpace(
			CFrame.new(walkCycle.x / 4, walkCycle.y / 2, 0)
		)
		self.viewmodel.HumanoidRoot.CFrame = self.viewmodel.HumanoidRoot.CFrame * CFrame.Angles(0, -sway.x, sway.y)
		self.viewmodel.HumanoidRoot.CFrame = self.viewmodel.HumanoidRoot.CFrame
			* CFrame.Angles(0, walkCycle.y / 2, walkCycle.x / 5)
	end
end

local function onRequest(toChange, newValue)
	curr_projectile = newValue
end


ReplicatedStorage.Event.Event:Connect(onRequest)

return FrameWork
