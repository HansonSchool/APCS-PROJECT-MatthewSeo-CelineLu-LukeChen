local buildConstraints = require(script:WaitForChild("buildConstraints"))
local buildCollisionFilters = require(script:WaitForChild("buildCollisionFilters"))

--[[
		Format:
		{
			["WaistRigAttachment"] = {
				Joint = UpperTorso.Waist<Motor6D>,
				Attachment0 = LowerTorso.WaistRigAttachment<Attachment>,
				Attachment1 = UpperToros.WaistRigAttachment<Attachment>,
			},
			...
		}
--]]
function buildAttachmentMap(character)
	local attachmentMap = {}
	
	-- GetConnectedParts doesn't work until parts have been parented to Workspace, so
	-- we can't use it (unless we want to have that silly restriction for creating ragdolls)
	for _,part in pairs(character:GetChildren()) do
		if part:IsA("BasePart") then
			for _,attachment in pairs(part:GetChildren()) do
				if attachment:IsA("Attachment") then
					local jointName = attachment.Name:match("^(.+)RigAttachment$")
					local joint = jointName and attachment.Parent:FindFirstChild(jointName) or nil
					
					if joint then
						attachmentMap[attachment.Name] = {
							Joint = joint,
							Attachment0=joint.Part0[attachment.Name]; 
							Attachment1=joint.Part1[attachment.Name];
						}
					end
				end
			end
		end
	end
	
	return attachmentMap
end

return function(humanoid)
	local character = humanoid.Parent
	
	humanoid.BreakJointsOnDeath = false
	
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if rootPart then
		rootPart.CanCollide = false
	end 

	local attachmentMap = buildAttachmentMap(character)
	local ragdollConstraints = buildConstraints(attachmentMap)
	local collisionFilters = buildCollisionFilters(attachmentMap, character.PrimaryPart)

	collisionFilters.Parent = ragdollConstraints
	ragdollConstraints.Parent = character
	
	game:GetService("CollectionService"):AddTag(humanoid, "Ragdoll")
end