local FastCastHandler = {}

--// SERVICES
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players 			= game:GetService("Players")
local Debris 			= game:GetService("Debris")

--// MODULES
local Utilities = require(game.ReplicatedStorage:WaitForChild("modules").Utilities)
local Thread = Utilities.Thread
local FastCast = require(ReplicatedStorage:WaitForChild("modules").FastCastRedux)
local BulletHole = require(ReplicatedStorage:WaitForChild("modules").BulletHole)
local ScreenCulling = Utilities.ScreenCulling

--// VARIABLES
local random = Random.new()

local Storage = workspace:WaitForChild("WorkSpace")
local Camera = workspace.CurrentCamera	
local ChargeLevel = 0

local mainCaster = FastCast.new()

local bullets = {}
local customList = {}

--// PROPERTIES
local OptimalEffects = true
local ScreenCullingEnabled = true
local ScreenCullingRadius = 16

local function AddressTableValue(v1, v2)
	if v1 ~= nil then
		return ((ChargeLevel == 1 and v1.Level1) or (ChargeLevel == 2 and v1.Level2) or (ChargeLevel == 3 and v1.Level3) or v2)
	else
		return v2
	end
end

local function CalculateSpread(Direction)
	local DirectionCFrame = CFrame.new(Vector3.new(), Direction.LookVector)
	local SpreadDirection = CFrame.fromOrientation(0, 0, math.random(0, math.pi * 2))
	local SpreadAngle = CFrame.fromOrientation(math.rad(math.random(1, 5)), 0, 0)
	local NewDirection = (DirectionCFrame * SpreadDirection * SpreadAngle).LookVector

	return NewDirection
end

local function CanRayPenetrate(origin, direction, hitPart, hitPoint, normal, material, segmentVelocity, hitData)
	if hitPart ~= nil and hitPart.Parent ~= nil then
		if hitPart.Name == "Glass" then
			BulletHole.HitEffect(customList,Storage, hitPoint, hitPart, normal, material)
			return "penetratedObject"
		--elseif material == Enum.Material.CorrodedMetal or material == Enum.Material.Metal or material == Enum.Material.DiamondPlate then
			--return "POOP ON U"
		else
			local Distance = (hitPoint - origin).Magnitude
			local Target = hitPart:FindFirstAncestorOfClass("Model")
			local TargetHumanoid = Target and Target:FindFirstChildOfClass("Humanoid")
			local TargetTorso = Target and (Target:FindFirstChild("HumanoidRootPart") or Target:FindFirstChild("Head"))
			
			BulletHole.HitEffect(customList,Storage,hitPoint, hitPart, normal, material)
			
			if TargetHumanoid and TargetHumanoid.Health > 0 and TargetTorso then
				local headshot = hitPart.Name == "Head" or hitPart:FindFirstChild("HatAttachment")

				ReplicatedStorage.weaponRemotes.hit:FireServer(TargetHumanoid, headshot)
				return "penetratedHumanoid" -- Penetrate Humanoid
			else
				return "penetratedObject" -- Penetrate Object
			end
		end
	end
end

local function CanRayPenetrateHumanoid(origin, direction, hitPart, hitPoint, normal, material, segmentVelocity, penetrationAmount, hitData)
	if hitPart ~= nil and hitPart.Parent ~= nil then
		if (hitPart.Transparency > 0.75
			or hitPart.Name == "Handle"
			or hitPart.Name == "Effect"
			or hitPart.Name == "Bullet"
			or hitPart.Name == "Laser"
			or string.lower(hitPart.Name) == "water"
			or (hitPart.Parent:FindFirstChild("Humanoid") and hitPart.Parent.Humanoid.Health == 0)) then
			return true
			
		else
			local Distance = (hitPoint - origin).Magnitude
			local Target = hitPart:FindFirstAncestorOfClass("Model")
			local TargetHumanoid = Target and Target:FindFirstChildOfClass("Humanoid")
			local TargetTorso = Target and (Target:FindFirstChild("HumanoidRootPart") or Target:FindFirstChild("Head"))
			
			if TargetHumanoid and TargetHumanoid.Health > 0 and TargetTorso then
				if penetrationAmount > 0 then
					BulletHole.HitEffect(customList,Storage,hitPoint, hitPart, normal, material)
					
					if TargetHumanoid.Health > 0 then
						--local headshot = hitPart.Name == "Head" or hitPart:FindFirstChild("HatAttachment")

						ReplicatedStorage.weaponRemotes.hit:FireServer(TargetHumanoid, false)
					end
				end
			--[[else
				if penetrationAmount <= 0 then
			   		-- hit effects
				end]]
				
				return true
			end
		end
	end
	return false
end

-- the _ here is castOrigin, but can be ignored i think
function rayUpdated(_, segmentOrigin, segmentDirection, length, segmentVelocity, Bullet, bulletData, whizData, hitData)
	local BulletLength = Bullet.Size.Z / 2
	Bullet.CFrame = CFrame.new(segmentOrigin, segmentOrigin + segmentDirection)
		* CFrame.new(0, 0, -(length - BulletLength))
end

function OnRayExited(origin, direction, hitPart, hitPoint, normal, material, segmentVelocity, hitData)
	if hitPart ~= nil and hitPart.Parent ~= nil then
		BulletHole.HitEffect(customList,Storage,hitPoint, hitPart, normal, material)
		if hitPart.Name == "Glass" then
			return
		else
			local TargetHumanoid = hitPart.Parent and hitPart.Parent:FindFirstChildOfClass("Humanoid")
			local TargetTorso = hitPart.Parent and (hitPart.Parent:FindFirstChild("HumanoidRootPart") or hitPart.Parent:FindFirstChild("Head"))

			BulletHole.HitEffect(customList,Storage,hitPoint, hitPart, normal, material)
		end
	end
end

function OnRayHit(origin, direction, hitPart, hitPoint, normal, material, segmentVelocity, Bullet, hitData)
	--local ShowEffects = ScreenCullingEnabled and (ScreenCulling(hitPoint, ScreenCullingRadius) and (hitPoint - Camera.CFrame.p).Magnitude <= 400) or (hitPoint - Camera.CFrame.p).Magnitude <= 400
	Bullet:Destroy()
	if not hitPart then
		return
	end
	--Debris:AddItem(Bullet, 5) -- 10
	if hitPart ~= nil and hitPart.Parent ~= nil then
		BulletHole.HitEffect(customList,Storage,hitPoint, hitPart, normal, material)

		if hitPart.Parent and hitPart.Parent:FindFirstChildOfClass("Humanoid") then
			local humanoid = hitPart.Parent:FindFirstChildOfClass("Humanoid")
			local headshot = hitPart.Name == "Head" or hitPart:FindFirstChild("HatAttachment")

			ReplicatedStorage.weaponRemotes.hit:FireServer(humanoid, headshot, hitPart)
		else
			--hit effects on wall 
		end
	end
end

function FastCastHandler:Fire(origin: Vector3, direction: CFrame, properties, projectileType, isReplicated, repCharacter)
	local rawOrigin = origin
	local rawDirection = direction

	if type(properties) ~= "table" then
		properties = require(properties)
	end

	local directionalCFrame = CFrame.new(Vector3.new(), direction.LookVector)
	direction = (
		directionalCFrame
			* CFrame.fromOrientation(0, 0, random:NextNumber(0, math.pi * 2))
			* CFrame.fromOrientation(0, 0, 0)
	).LookVector

	--local bullet = ReplicatedStorage.bullet:Clone()
	local bullet = ReplicatedStorage.Foods[projectileType]:Clone()
	bullet.CFrame = CFrame.new(origin, origin + direction)
	bullet.Orientation = Vector3.new(0,90,0)
	bullet.Parent = workspace.fastCast
	bullet.Size = Vector3.new(0.05, 0.05, properties.firing.velocity / 200)

	local id = math.random(-100000, 100000)
	local idValue = Instance.new("NumberValue")
	idValue.Name = "id"
	idValue.Value = id
	idValue.Parent = bullet

	bullets[id] = {
		properties = properties,
		replicated = isReplicated,
	}

	if not isReplicated then
		ReplicatedStorage.weaponRemotes.fire:FireServer(rawOrigin, rawDirection, projectileType)
	end

	customList[#customList + 1] = repCharacter
	customList[#customList + 1] = workspace.Camera
	customList[#customList + 1] = Players.LocalPlayer.Character
	customList[#customList + 1] = bullet

	if properties.Type == "Shotgun" then
		mainCaster:FireWithBlacklist(
			origin,
			properties.firing.range * CalculateSpread(rawDirection),
			properties.firing.velocity,
			customList,
			bullet,
			true,
			Vector3.new(0, ReplicatedStorage.bulletGravity.Value, 0),
			{properties.CanSpinPart, properties.SpinX, properties.SpinY, properties.SpinZ},
			{properties.WhizSoundEnabled, properties.WhizSoundID, properties.WhizSoundPitchMin, properties.WhizSoundPitchMax, properties.WhizDistance, properties.WhizSoundVolume},
			nil,
			{penetrationType = properties.PenetrationType, penetrationDepth = properties.PenetrationDepth, canPenetrateFunction = CanRayPenetrate, penetrationAmount = properties.PenetrationAmount, canPenetrateHumanoidFunction = CanRayPenetrateHumanoid}
		)
	elseif properties.Type == "Rifle" then
		mainCaster:FireWithBlacklist(
			origin,
			direction * properties.firing.range,
			properties.firing.velocity,
			customList,
			bullet,
			true,
			Vector3.new(0, ReplicatedStorage.bulletGravity.Value, 0),
			{properties.CanSpinPart, properties.SpinX, properties.SpinY, properties.SpinZ},
			{properties.WhizSoundEnabled, properties.WhizSoundID, properties.WhizSoundPitchMin, properties.WhizSoundPitchMax, properties.WhizDistance, properties.WhizSoundVolume},
			nil,
			{penetrationType = properties.PenetrationType, penetrationDepth = properties.PenetrationDepth, canPenetrateFunction = CanRayPenetrate, penetrationAmount = properties.PenetrationAmount, canPenetrateHumanoidFunction = CanRayPenetrateHumanoid}
		)
	end
end
	
mainCaster.RayHit:Connect(OnRayHit)
mainCaster.RayExited:Connect(OnRayExited)
mainCaster.LengthChanged:Connect(rayUpdated)	

return FastCastHandler
