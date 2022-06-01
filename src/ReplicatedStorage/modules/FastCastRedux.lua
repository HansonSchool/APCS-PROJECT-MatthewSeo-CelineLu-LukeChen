--[[
	FastCast Ver. 10.0.2
	Written by Eti the Spirit (18406183)
	
		The latest patch notes can be located here (and do note, the version at the top of this script might be outdated. I have a thing for forgetting to change it):
		>	https://github.com/XanTheDragon/FastCastAPIDocs/wiki/Changelist
		
		*** If anything is broken, please don't hesitate to message me! ***
		
		YOU CAN FIND IMPORTANT USAGE INFORMATION HERE: https://github.com/XanTheDragon/FastCastAPIDocs/wiki
		YOU CAN FIND IMPORTANT USAGE INFORMATION HERE: https://github.com/XanTheDragon/FastCastAPIDocs/wiki
		YOU CAN FIND IMPORTANT USAGE INFORMATION HERE: https://github.com/XanTheDragon/FastCastAPIDocs/wiki
		
		YOU SHOULD ONLY CREATE ONE CASTER PER GUN.
		YOU SHOULD >>>NEVER<<< CREATE A NEW CASTER EVERY TIME THE GUN NEEDS TO BE FIRED.
		
		A caster (created with FastCast.new()) represents a "gun".
		When you consider a gun, you think of stats like accuracy, bullet speed, etc. This is the info a caster stores. 
	
	--
	
	This is a library used to create hitscan-based guns that simulate projectile physics.
	
	This means:
		- You don't have to worry about bullet lag / jittering
		- You don't have to worry about keeping bullets at a low speed due to physics being finnicky between clients
		- You don't have to worry about misfires in bullet's Touched event (e.g. where it may going so fast that it doesn't register)
		
	Hitscan-based guns are commonly seen in the form of laser beams, among other things. Hitscan simply raycasts out to a target
	and says whether it hit or not.
	
	Unfortunately, while reliable in terms of saying if something got hit or not, this method alone cannot be used if you wish
	to implement bullet travel time into a weapon. As a result of that, I made this library - an excellent remedy to this dilemma.
	
	FastCast is intended to be require()'d once in a script, as you can create as many casters as you need with FastCast.new()
	This is generally handy since you can store settings and information in these casters, and even send them out to other scripts via events
	for use.
	
	Remember -- A "Caster" represents an entire gun (or whatever is launching your projectiles), *NOT* the individual bullets.
	Make the caster once, then use the caster to fire your bullets. Do not make a caster for each bullet.
--]]

local FastCast = {}
FastCast.DebugLogging = false
FastCast.VisualizeCasts = false
FastCast.RayExit = true
FastCast.__index = FastCast

-----------------------------------------------------------
----------------------- STATIC DATA -----------------------
-----------------------------------------------------------
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("modules")

local Utilities = require(Modules.Utilities)
local Signal = Utilities.Signal
local table = Utilities.Table
local Thread = Utilities.Thread

local TargetEvent
if RunService:IsClient() then
	TargetEvent = RunService.RenderStepped
else
	TargetEvent = RunService.Heartbeat
end

local Projectiles = {}
local RemoveList = {}

-- Format params: methodName, ctorName
local ERR_NOT_INSTANCE = "Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"

-- Format params: paramName, expectedType, actualType
local ERR_INVALID_TYPE = "Invalid type for parameter '%s' (Expected %s, got %s)"

-- The name of the folder containing the 3D GUI elements for visualizing casts.
local FC_VIS_OBJ_NAME = "FastCastVisualizationObjects"

-----------------------------------------------------------
------------------------ UTILITIES ------------------------
-----------------------------------------------------------

-- Alias function to automatically error out for invalid types.
local function MandateType(value, type, paramName, nullable)
	if nullable and value == nil then return end
	assert(typeof(value) == type, ERR_INVALID_TYPE:format(paramName or "ERR_NO_PARAM_NAME", type, typeof(value)))
end

-- Looks for a folder within Workspace.Terrain that contains elements to visualize casts.
local function GetFastCastVisualizationContainer()
	local fcVisualizationObjects = Workspace.Terrain:FindFirstChild(FC_VIS_OBJ_NAME)
	if fcVisualizationObjects ~= nil then
		return fcVisualizationObjects
	end

	fcVisualizationObjects = Instance.new("Folder")
	fcVisualizationObjects.Name = FC_VIS_OBJ_NAME
	fcVisualizationObjects.Archivable = false -- TODO: Keep this as-is? You can't copy/paste it if this is false. I have it false so that it doesn't linger in studio if you save with the debug data in there.
	fcVisualizationObjects.Parent = Workspace.Terrain
	return fcVisualizationObjects
end

-----------------------------------------------------------
------------------------ DEBUGGING ------------------------
-----------------------------------------------------------

-- Print that runs only if debug mode is active.
local function PrintDebug(message)
	if FastCast.DebugLogging == true then
		print(message)
	end
end

-- Visualizes a ray. This will not run if FastCast.VisualizeCasts is false.
function DbgVisualizeSegment(castStartCFrame, castLength)
	if FastCast.VisualizeCasts ~= true then return end
	local adornment = Instance.new("ConeHandleAdornment")
	adornment.Adornee = Workspace.Terrain
	adornment.CFrame = castStartCFrame
	adornment.Height = castLength
	adornment.Color3 = Color3.new()
	adornment.Radius = 0.25
	adornment.Transparency = 0.5
	adornment.Parent = GetFastCastVisualizationContainer()
	return adornment
end

-- Visualizes an impact. This will not run if FastCast.VisualizeCasts is false.
function DbgVisualizeHit(atCF, color)
	if FastCast.VisualizeCasts ~= true then return end
	local adornment = Instance.new("SphereHandleAdornment")
	adornment.Adornee = Workspace.Terrain
	adornment.CFrame = atCF
	adornment.Radius = 0.4
	adornment.Transparency = 0.25
	adornment.Color3 = color --(wasPierce == false) and Color3.new(0.2, 1, 0.5) or Color3.new(1, 0.2, 0.2)
	adornment.Parent = GetFastCastVisualizationContainer()
	return adornment
end

-----------------------------------------------------------
------------------------ CORE CODE ------------------------
-----------------------------------------------------------

-- Simple raycast alias
local function Cast(origin, direction, ignoreDescendantsInstance, ignoreWater)
	local castRay = Ray.new(origin, direction)
	return Workspace:FindPartOnRay(castRay, ignoreDescendantsInstance, false, ignoreWater)
end

-- This function casts a ray with a whitelist.
local function CastWithWhitelist(origin, direction, whitelist, ignoreWater)
	if not whitelist or typeof(whitelist) ~= "table" then
		-- This array is faulty.
		error("Call in CastWhitelist failed! Whitelist table is either nil, or is not actually a table.", 0)
	end
	local castRay = Ray.new(origin, direction)
	-- Now here's something bizarre: FindPartOnRay and FindPartOnRayWithIgnoreList have a "terrainCellsAreCubes" boolean before ignoreWater. FindPartOnRayWithWhitelist, on the other hand, does not!
	return Workspace:FindPartOnRayWithWhitelist(castRay, whitelist, ignoreWater)
end

-- This function casts a ray with a blacklist.
local function CastWithBlacklist(origin, direction, blacklist, ignoreWater)
	if not blacklist or typeof(blacklist) ~= "table" then
		-- This array is faulty
		error("Call in CastBlacklist failed! Blacklist table is either nil, or is not actually a table.", 0)
	end
	local castRay = Ray.new(origin, direction)
	return Workspace:FindPartOnRayWithIgnoreList(castRay, blacklist, false, ignoreWater)
end

-- This function casts a ray with a blacklist but not for Humanoid Penetration.
local function CastWithBlacklistAndNoHumPenetration(origin, direction, blacklist, ignoreWater)
	if not blacklist or typeof(blacklist) ~= "table" then
		-- This array is faulty
		error("Call in CastBlacklist failed! Blacklist table is either nil, or is not actually a table.", 0)
	end
	local castRay = Ray.new(origin, direction)
	local hitPart, hitPoint, hitNormal, hitMaterial = nil, origin + direction, Vector3.new(0,1,0), Enum.Material.Air
	local success = false	
	repeat
		hitPart, hitPoint, hitNormal, hitMaterial = Workspace:FindPartOnRayWithIgnoreList(castRay, blacklist, false, ignoreWater)
		if hitPart then
			if (hitPart.Transparency > 0.75
				or hitPart.Name == "Handle"
				or hitPart.Name == "Effect"
				or hitPart.Name == "Bullet"
				or hitPart.Name == "Hole" )then
				--or (hitPart.Parent:FindFirstChild("Humanoid") and hitPart.Parent.Humanoid.Health == 0)) then
				table.insert(blacklist, hitPart)
				success	= false
			else
				success	= true
			end
		else
			success	= true
		end
	until success
	return hitPart, hitPoint, hitNormal, hitMaterial
end

-- Thanks to zoebasil for supplying the velocity and position functions below. (I've modified these functions)
-- I was having a huge issue trying to get it to work and I had overcomplicated a bunch of stuff.
-- GetPositionAtTime is used in physically simulated rays (Where Caster.HasPhysics == true or the specific Fire has a specified acceleration).
-- This returns the location that the bullet will be at when you specify the amount of time the bullet has existed, the original location of the bullet, and the velocity it was launched with.
local function GetPositionAtTime(time, origin, initialVelocity, acceleration)
	local force = Vector3.new((acceleration.X * time^2) / 2,(acceleration.Y * time^2) / 2, (acceleration.Z * time^2) / 2)
	return origin + (initialVelocity * time) + force
end

-- A variant of the function above that returns the velocity at a given point in time.
local function GetVelocityAtTime(time, initialVelocity, acceleration)
	return initialVelocity + acceleration * time
end

-- Simulate a raycast.
local function SimulateCast(origin, direction, velocity, castFunction, lengthChangedEvent, rayHitEvent, rayExitedEvent, cosmeticBulletObject, listOrIgnoreDescendantsInstance, ignoreWater, bulletAcceleration, bulletData, whizData, hitData, penetrationData)
	PrintDebug("Cast simulation requested.")
	if type(velocity) == "number" then
		velocity = direction.Unit * velocity
	end

	local penetrationPower = penetrationData ~= nil and penetrationData.penetrationDepth or 0
	local penetrationCount = penetrationData ~= nil and penetrationData.penetrationAmount or 0
	local bulletAcceleration = bulletAcceleration or Vector3.new() -- Fix bug reported by Spooce: Failing to pass in the bulletAcceleration parameter throws an error, so add a fallback of Vector3.new()
	local distance = direction.Magnitude -- This will be a unit vector multiplied by the maximum distance.
	local normalizedDir = direction.Unit
	local upgradedDir = (normalizedDir + velocity).Unit -- This rotates the direction of the bullet by the initial velocity, allowing 3D velocity to occur in the first place.
	local initialVelocity = upgradedDir * velocity.Magnitude

	local totalDelta = 0
	local distanceTravelled = 0
	local lastPoint = origin

	local self = {}
	local isRunningPenetration = false
	local didHitHumanoid = false
	local originalList = listOrIgnoreDescendantsInstance
	local originalCastFunction = castFunction

	local function Fire(delta, customAt)
		PrintDebug("Casting for frame.")
		totalDelta = totalDelta + delta
		local at = customAt or GetPositionAtTime(totalDelta, origin, initialVelocity, bulletAcceleration)
		local totalDisplacement = (at - lastPoint) -- This is the displacement from where the ray was on the last from to where the ray is now.

		-- NEW BEHAVIOR:
		-- Displacement needs to define velocity. The reason peoples' casts were going crazy was because on the line below I used to multiply by velocity.Magnitude
		-- Okay, cool, so that's effectively the initial velocity. Now say we're at the top of an arc in a physics cast. Bullet sure isn't going the same speed!
		-- We need to recalculate velocity based on displacement, NOT use the defined value.
		-- How I missed this is beyond me.
		-- Bonus ducks: This also allows me to implement GFink's request (see https://devforum.roblox.com/t/making-a-combat-game-with-ranged-weapons-fastcast-may-be-the-module-for-you/133474/282?u=etithespirit)

		local segmentVelocity = GetVelocityAtTime(totalDelta, initialVelocity, bulletAcceleration) 
		-- local rayDir = totalDisplacement.Unit * segmentVelocity.Magnitude * delta -- Direction of the ray is the direction from last to now * the velocity * deltaTime
		local rayDir = totalDisplacement.Unit * segmentVelocity.Magnitude * delta
		local hit, point, normal, material = castFunction(lastPoint, rayDir, listOrIgnoreDescendantsInstance, ignoreWater)

		local rayDisplacement = (point - lastPoint).Magnitude
		-- For clarity -- totalDisplacement is how far the ray would have traveled if it hit nothing,
		-- and rayDisplacement is how far the ray really traveled (which will be identical to totalDisplacement if it did indeed hit nothing)

		lengthChangedEvent:Fire(origin, lastPoint, rayDir.Unit, rayDisplacement, segmentVelocity, cosmeticBulletObject, bulletData, whizData, hitData)

		local rayVisualization = nil
		if (delta > 0) then
			rayVisualization = DbgVisualizeSegment(CFrame.new(lastPoint, lastPoint + rayDir), rayDisplacement)
		end

		if hit and hit ~= cosmeticBulletObject then
			local start = tick()
			local unit = rayDir.Unit
			local maxExtent = hit.Size.Magnitude * unit
			local exitHit, exitPoint, exitNormal, exitMaterial = CastWithWhitelist(point + maxExtent, -maxExtent, {hit}, ignoreWater)
			--local diff = exitPoint - point
			--local dist = Vector3.new():Dot(unit, diff)
			local dist = (exitPoint - point).Magnitude

			-- SANITY CHECK: Don't allow the user to yield or run otherwise extensive code that takes longer than one frame/heartbeat to execute.
			if (penetrationData ~= nil) and (penetrationData.penetrationType == "WallPenetration" and ((penetrationData.canPenetrateFunction ~= nil) and (penetrationPower > dist)) or (penetrationData.penetrationType == "HumanoidPenetration" and ((penetrationData.canPenetrateHumanoidFunction ~= nil) and (penetrationCount > 0)))) then
				if (isRunningPenetration) then
					error("ERROR: The latest call to canPenetrateFunction/canPenetrateHumanoidFunction took too long to complete! This cast is going to suffer desyncs which WILL cause unexpected behavior and errors.")
					-- Use error. This should absolutely abort the cast.
				end
				isRunningPenetration = true
				didHitHumanoid = false
			end

			if penetrationData == nil or (penetrationData ~= nil and ((penetrationData.penetrationType == "WallPenetration" and (penetrationPower < dist)) or (penetrationData.penetrationType == "HumanoidPenetration" and ((penetrationData.canPenetrateHumanoidFunction(origin, rayDir.Unit, hit, point, normal, material, segmentVelocity, penetrationCount, hitData) == false) or (penetrationCount <= 0))))) then
				PrintDebug("Penetrating data is nil or penetrationPower is lower than dist/penetrationCount is at 0. Ending cast and firing RayHit.")
				isRunningPenetration = false
				-- Penetrate function is nil, or it's not nil and it returned false (we cannot penetrate this object).
				-- Hit.

				RemoveList[self] = true
				rayHitEvent:Fire(origin, rayDir.Unit, hit, point, normal, material, segmentVelocity, cosmeticBulletObject, hitData)
				DbgVisualizeHit(CFrame.new(point), Color3.new(0.2, 1, 0.5))
				return
			else
				if rayVisualization ~= nil then
					rayVisualization.Color3 = Color3.new(0.4, 0.05, 0.05) -- Turn it red to signify that the cast was scrapped.
				end
				DbgVisualizeHit(CFrame.new(point), Color3.new(1, 0.2, 0.2))

				PrintDebug("Penetrating returned 'penetratedHumanoid' or 'penetratedObject'/TRUE to penetrate this hit. Processing...")
				isRunningPenetration = false
				-- Nope! We want to penetrate this part.				
				-- Now this is gonna be DISGUSTING. 
				-- We need to run this until we fufill that lost distance, so if some guy decides to layer up like 10 parts right next to eachother, we need to handle all of those in a single frame
				-- The only way to do this isn't particularly pretty but it needs to be quick.
				if penetrationData.penetrationType == "WallPenetration" then
					local penetrationType = penetrationData ~= nil and penetrationData.canPenetrateFunction(origin, rayDir.Unit, hit, point, normal, material, segmentVelocity, hitData)		
					if (castFunction == CastWithWhitelist) then
						-- User is using whitelist. We need to pull this from their list.
						-- n.b. this function is offered by the sandboxed table system. It's not stock.
						--[[if penetrationType == "penetratedHumanoid" and (hit.Parent:FindFirstChildOfClass("Humanoid") and hit.Parent:FindFirstChildOfClass("Humanoid").Health > 0) or (hit.Parent.Parent:FindFirstChildOfClass("Humanoid") and hit.Parent.Parent:FindFirstChildOfClass("Humanoid").Health > 0) then
							if exitHit and FastCast.RayExit then
								rayExitedEvent:Fire(point + maxExtent, -maxExtent, exitHit, exitPoint, exitNormal, exitMaterial, segmentVelocity, hitData)
								DbgVisualizeHit(CFrame.new(exitPoint), Color3.fromRGB(13, 105, 172))
							end
							local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid") or hit.Parent.Parent:FindFirstChildOfClass("Humanoid")
							table.removeObject(listOrIgnoreDescendantsInstance, humanoid.Parent)
							--penetrationPower = penetrationPower
							local toReduce = 1-((dist/penetrationPower/1.1))
							penetrationPower = penetrationPower * toReduce
							PrintDebug("Whitelist cast detected, removed " .. tostring(humanoid.Parent) .. " from the whitelist.")
						]]if penetrationType == "penetratedObject" then
							if exitHit and FastCast.RayExit then
								rayExitedEvent:Fire(point + maxExtent, -maxExtent, exitHit, exitPoint, exitNormal, exitMaterial, segmentVelocity, hitData)
								DbgVisualizeHit(CFrame.new(exitPoint), Color3.fromRGB(13, 105, 172))
							end
							table.removeObject(listOrIgnoreDescendantsInstance, hit)
							--penetrationPower = penetrationPower - dist
							local toReduce = 1-((dist/penetrationPower/1.1))
							penetrationPower = penetrationPower * toReduce
							PrintDebug("Whitelist cast detected, removed " .. tostring(hit) .. " from the whitelist.")
						end
					elseif (castFunction == CastWithBlacklistAndNoHumPenetration) then
						--[[if penetrationType == "penetratedHumanoid" and (hit.Parent:FindFirstChildOfClass("Humanoid") and hit.Parent:FindFirstChildOfClass("Humanoid").Health > 0) or (hit.Parent.Parent:FindFirstChildOfClass("Humanoid") and hit.Parent.Parent:FindFirstChildOfClass("Humanoid").Health > 0) then
							if exitHit and FastCast.RayExit then
								rayExitedEvent:Fire(point + maxExtent, -maxExtent, exitHit, exitPoint, exitNormal, exitMaterial, segmentVelocity, hitData)
								DbgVisualizeHit(CFrame.new(exitPoint), Color3.fromRGB(13, 105, 172))
							end
							local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid") or hit.Parent.Parent:FindFirstChildOfClass("Humanoid")
							table.insert(listOrIgnoreDescendantsInstance, humanoid.Parent)
							--penetrationPower = penetrationPower
							local toReduce = 1-((dist/penetrationPower/1.1))
							penetrationPower = penetrationPower * toReduce
							PrintDebug("Blacklist cast detected, added " .. tostring(humanoid.Parent) .. " to the blacklist.")
						]]if penetrationType == "penetratedObject" then
							if exitHit and FastCast.RayExit then
								rayExitedEvent:Fire(point + maxExtent, -maxExtent, exitHit, exitPoint, exitNormal, exitMaterial, segmentVelocity, hitData)
								DbgVisualizeHit(CFrame.new(exitPoint), Color3.fromRGB(13, 105, 172))
							end
							table.removeObject(listOrIgnoreDescendantsInstance, hit)
							--penetrationPower = penetrationPower - dist
							local toReduce = 1-((dist/penetrationPower/1.1))
							penetrationPower = penetrationPower * toReduce
							PrintDebug("Blacklist cast detected, added " .. tostring(hit) .. " to the blacklist.")	
						end
					else
						-- This is where things get finnicky.
						-- We can't reparent the object. If we do this, we risk altering behavior of the developer's game which has undesirable effects.
						-- We need to swap cast functions on the fly here. This is gonna get NASTY. Oh well. It should only happen once under this new behavior.
						castFunction = CastWithBlacklistAndNoHumPenetration
						listOrIgnoreDescendantsInstance = listOrIgnoreDescendantsInstance:GetDescendants()	
						if penetrationType == "penetratedHumanoid" and (hit.Parent:FindFirstChildOfClass("Humanoid") and hit.Parent:FindFirstChildOfClass("Humanoid").Health > 0) or (hit.Parent.Parent:FindFirstChildOfClass("Humanoid") and hit.Parent.Parent:FindFirstChildOfClass("Humanoid").Health > 0) then
							if exitHit and FastCast.RayExit then
								rayExitedEvent:Fire(point + maxExtent, -maxExtent, exitHit, exitPoint, exitNormal, exitMaterial, segmentVelocity, hitData)
								DbgVisualizeHit(CFrame.new(exitPoint), Color3.fromRGB(13, 105, 172))
							end
							local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid") or hit.Parent.Parent:FindFirstChildOfClass("Humanoid")
							table.insert(listOrIgnoreDescendantsInstance, humanoid.Parent)
							--penetrationPower = penetrationPower
							local toReduce = 1-((dist/penetrationPower/1.1))
							penetrationPower = penetrationPower * toReduce
							PrintDebug("Stock cast detected, transformed cast into blacklist cast and added " .. tostring(humanoid.Parent) .. " to the blacklist.")
							if penetrationType == "penetratedObject" then
								if exitHit and FastCast.RayExit then
									rayExitedEvent:Fire(point + maxExtent, -maxExtent, exitHit, exitPoint, exitNormal, exitMaterial, segmentVelocity, hitData)
									DbgVisualizeHit(CFrame.new(exitPoint), Color3.fromRGB(13, 105, 172))
								end
								table.insert(listOrIgnoreDescendantsInstance, hit)
								--penetrationPower = penetrationPower - dist
								local toReduce = 1-((dist/penetrationPower/1.1))
								penetrationPower = penetrationPower * toReduce
								PrintDebug("Stock cast detected, transformed cast into blacklist cast and added " .. tostring(hit) .. " to the blacklist.")						
							end				
						end
					end
				elseif penetrationData.penetrationType == "HumanoidPenetration" then
					if (castFunction == CastWithBlacklist) then
						-- User is using whitelist. We need to pull this from their list.
						-- n.b. this function is offered by the sandboxed table system. It's not stock.
						if (hit.Parent:FindFirstChildOfClass("Humanoid") and hit.Parent:FindFirstChildOfClass("Humanoid").Health > 0) or (hit.Parent.Parent:FindFirstChildOfClass("Humanoid") and hit.Parent.Parent:FindFirstChildOfClass("Humanoid").Health > 0) then
							didHitHumanoid = true
							local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid") or hit.Parent.Parent:FindFirstChildOfClass("Humanoid")
							table.removeObject(listOrIgnoreDescendantsInstance, humanoid.Parent)
							PrintDebug("Whitelist cast detected, removed " .. tostring(humanoid.Parent) .. " from the whitelist.")
						else
							didHitHumanoid = false
							table.removeObject(listOrIgnoreDescendantsInstance, hit)
							PrintDebug("Whitelist cast detected, removed " .. tostring(hit) .. " from the whitelist.")
						end
					elseif (castFunction == CastWithWhitelist) then
						if (hit.Parent:FindFirstChildOfClass("Humanoid") and hit.Parent:FindFirstChildOfClass("Humanoid").Health > 0) then --or (hit.Parent.Parent:FindFirstChildOfClass("Humanoid") and hit.Parent.Parent:FindFirstChildOfClass("Humanoid").Health > 0) then
							didHitHumanoid = true
							local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid") or hit.Parent.Parent:FindFirstChildOfClass("Humanoid")
							table.insert(listOrIgnoreDescendantsInstance, humanoid.Parent)
							PrintDebug("Blacklist cast detected, added " .. tostring(humanoid.Parent) .. " to the blacklist.")
						else
							didHitHumanoid = false
							table.insert(listOrIgnoreDescendantsInstance, hit)
							PrintDebug("Blacklist cast detected, added " .. tostring(hit) .. " to the blacklist.")	
						end
					else
						-- This is where things get finnicky.
						-- We can't reparent the object. If we do this, we risk altering behavior of the developer's game which has undesirable effects.
						-- We need to swap cast functions on the fly here. This is gonna get NASTY. Oh well. It should only happen once under this new behavior.
						castFunction = CastWithBlacklist
						listOrIgnoreDescendantsInstance = listOrIgnoreDescendantsInstance:GetDescendants()
						if (hit.Parent:FindFirstChildOfClass("Humanoid") and hit.Parent:FindFirstChildOfClass("Humanoid").Health > 0) then --or (hit.Parent.Parent:FindFirstChildOfClass("Humanoid") and hit.Parent.Parent:FindFirstChildOfClass("Humanoid").Health > 0) then
							didHitHumanoid = true
							local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid") or hit.Parent.Parent:FindFirstChildOfClass("Humanoid")
							table.insert(listOrIgnoreDescendantsInstance, humanoid.Parent)
							PrintDebug("Stock cast detected, transformed cast into blacklist cast and added " .. tostring(humanoid.Parent) .. " to the blacklist.")
						else
							didHitHumanoid = false
							table.insert(listOrIgnoreDescendantsInstance, hit)
							PrintDebug("Stock cast detected, transformed cast into blacklist cast and added " .. tostring(hit) .. " to the blacklist.")						
						end				
					end					
				end

				-- So now just cast again!
				-- Cast with 0 deltaTime and from the prespecified point (this saves a smidge of performance since we don't need to try to recalculate a position value that will come out to be the same thing.)
				PrintDebug("Recasting for penetration...")
				Fire(0, at)

				-- Then set lastPoint.
				lastPoint = point
				-- We used to do ^ above, but this caused undesired effects and zero-length casts. Oops.

				if penetrationData ~= nil then
					if penetrationData.penetrationType ~= "WallPenetration" then
						if didHitHumanoid then
							penetrationCount = hit and (penetrationCount - 1) or 0
							PrintDebug("penetrationCount is reduced to... "..penetrationCount.." for hitting humanoid.")
						else
							PrintDebug("penetrationCount is not reduced for not hitting humanoid (or the humanoid died).")
						end
					else
						PrintDebug("DISTANCE: "..dist.." studs")
						PrintDebug("CURRENT PENETRATION DEPTH: "..penetrationPower.." studs")
					end
				end

				-- And exit the function here too.
				return
			end
		end

		-- Then set lastPoint here as well.
		lastPoint = point	
		distanceTravelled = distanceTravelled + rayDisplacement

		if distanceTravelled > distance then
			RemoveList[self] = true
			rayHitEvent:Fire(origin, rayDir.Unit, nil, lastPoint, nil, nil, Vector3.new(), cosmeticBulletObject, hitData)
		end
	end

	function self.Update(delta)
		Fire(delta)
	end

	--[[Thread:Spawn(function()
		Projectiles[self] = true
	end)]]
	-- Too fast?
	if RunService:IsClient() then
		spawn(function()
			Projectiles[self] = true
		end)
	else
		Thread:Spawn(function()
			Projectiles[self] = true
		end)
	end
end

local function BaseFireMethod(self, origin, directionWithMagnitude, velocity, cosmeticBulletObject, ignoreDescendantsInstance, ignoreWater, bulletAcceleration, bulletData, whizData, hitData, list, isWhitelist, penetrationData)
	MandateType(origin, "Vector3", "origin")
	MandateType(directionWithMagnitude, "Vector3", "directionWithMagnitude")
	assert(typeof(velocity) == "Vector3" or typeof(velocity) == "number", ERR_INVALID_TYPE:format("velocity", "Variant<Vector3, number>", typeof(velocity))) -- This one's an odd one out.
	MandateType(cosmeticBulletObject, "Instance", "cosmeticBulletObject", true)
	MandateType(ignoreDescendantsInstance, "Instance", "ignoreDescendantsInstance", true)
	MandateType(ignoreWater, "boolean", "ignoreWater", true)
	MandateType(bulletAcceleration, "Vector3", "bulletAcceleration", true)
	MandateType(list, "table", "list", true)
	-- isWhitelist is strictly internal so it doesn't need to get sanity checked, because last I checked, I'm not insane c:
	-- ... I hope
	-- However, as of Version 9.0.0, a penetrate function can be specified
	MandateType(penetrationData, "table", "penetrationData", true)

	-- Now get into the guts of this.
	local castFunction = Cast
	local ignoreOrList = ignoreDescendantsInstance
	if list ~= nil then
		ignoreOrList = list
		if isWhitelist then
			castFunction = CastWithWhitelist
		else
			castFunction = (penetrationData and penetrationData.penetrationType ~= "WallPenetration" and CastWithBlacklist or CastWithBlacklistAndNoHumPenetration) or CastWithBlacklistAndNoHumPenetration
		end
	end

	SimulateCast(origin, directionWithMagnitude, velocity, castFunction, self.LengthChanged, self.RayHit, self.RayExited, cosmeticBulletObject, ignoreOrList, ignoreWater, bulletAcceleration, bulletData, whizData, hitData, penetrationData)
end

-----------------------------------------------------------
------------------------- EXPORTS -------------------------
-----------------------------------------------------------

-- Constructor.
function FastCast.new()
	return setmetatable({
		LengthChanged = Signal:CreateNewSignal(),
		RayHit = Signal:CreateNewSignal(),
		RayExited = Signal:CreateNewSignal()
	}, FastCast)
end

-- Fire with stock ray
function FastCast:Fire(origin, directionWithMagnitude, velocity, cosmeticBulletObject, ignoreDescendantsInstance, ignoreWater, bulletAcceleration, bulletData, whizData, hitData, penetrationData)
	assert(getmetatable(self) == FastCast, ERR_NOT_INSTANCE:format("Fire", "FastCast.new()"))
	BaseFireMethod(self, origin, directionWithMagnitude, velocity, cosmeticBulletObject, ignoreDescendantsInstance, ignoreWater, bulletAcceleration, bulletData, whizData, hitData, nil, nil, penetrationData)
end

-- Fire with whitelist
function FastCast:FireWithWhitelist(origin, directionWithMagnitude, velocity, whitelist, cosmeticBulletObject, ignoreWater, bulletAcceleration, bulletData, whizData, hitData, penetrationData)
	assert(getmetatable(self) == FastCast, ERR_NOT_INSTANCE:format("FireWithWhitelist", "FastCast.new()"))
	BaseFireMethod(self, origin, directionWithMagnitude, velocity, cosmeticBulletObject, nil, ignoreWater, bulletAcceleration, bulletData, whizData, hitData, whitelist, true, penetrationData)
end

-- Fire with blacklist
function FastCast:FireWithBlacklist(origin, directionWithMagnitude, velocity, blacklist, cosmeticBulletObject, ignoreWater, bulletAcceleration, bulletData, whizData, hitData, penetrationData)
	assert(getmetatable(self) == FastCast, ERR_NOT_INSTANCE:format("FireWithBlacklist", "FastCast.new()"))
	BaseFireMethod(self, origin, directionWithMagnitude, velocity, cosmeticBulletObject, nil, ignoreWater, bulletAcceleration, bulletData, whizData, hitData, blacklist, false, penetrationData)
end

TargetEvent:Connect(function(dt)
	for i, v in next, Projectiles, nil do
		if RemoveList[i] then
			RemoveList[i] = nil
			Projectiles[i] = nil
		else
			i.Update(dt)
		end
	end
end)

-- Export
return FastCast