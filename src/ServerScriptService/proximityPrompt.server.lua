local ProximityPromptService = game:GetService("ProximityPromptService")
local rp = game:GetService("ReplicatedStorage")


-- Detect when prompt is triggered
local function onPromptTriggered(promptObject, player)
	rp.poop:FireClient(player, "reload")
end

ProximityPromptService.PromptTriggered:Connect(onPromptTriggered)
