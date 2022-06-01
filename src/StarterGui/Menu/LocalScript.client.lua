local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local LocalPlayer = game.Players.LocalPlayer

local PlayerGUI = LocalPlayer.PlayerGui
local Menu = PlayerGUI:WaitForChild("Menu")
local PlayButton = Menu.MainMenu.TopBar.Play

local settings		= ReplicatedStorage.ServerValues
local AllowSpawn	= settings.AllowSpawn

local deploying = false

local function CalculateSpawnPos()
	local bk				=LocalPlayer.TeamColor == BrickColor.new("Really red") and "R" or "B"
	local map				=workspace:WaitForChild("Map")
	local teleport			=map:FindFirstChild("Teleport")
	local chosen			=teleport[bk.."1"]
	local required			=250
	local approved

	repeat 	
		chosen=teleport[bk..math.random(1,2)]
		local pp=game.Players:GetChildren()
		local disapproved
		for i=1,#pp do
			local v=pp[i]
			if v.TeamColor~=LocalPlayer.TeamColor and workspace:FindFirstChild(v.Name) and v.Character and v.Character.Parent then
				local ptor=v.Character:FindFirstChild("HumanoidRootPart")
				if ptor then
					local dist=(ptor.Position-chosen.Position).magnitude
					if dist<required then
						disapproved=true
						required=required-4
					end
				end
			end
		end
		wait(.01)
		if not disapproved then approved=true end
	until approved

	--print("Furthest distance for enemy is "..ceil(furthest).." studs at block " ..chosen.Name)
	return CFrame.new((chosen.Position+Vector3.new(0,3,0)))
end

function Deploy()
	Menu.Enabled = false	
	
	if not AllowSpawn.Value or not workspace:FindFirstChild("Map") then return end
	deploying=true

	local spawnpos = CalculateSpawnPos()

	ReplicatedStorage.RemoteEvent:FireServer("spawn", spawnpos, 100)

	deploying=false
end	

PlayButton.MouseButton1Click:Connect(Deploy)

