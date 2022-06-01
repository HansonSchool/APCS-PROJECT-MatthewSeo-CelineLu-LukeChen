local RoundSystem = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")



-- i liek the blue color : )
local settings		= ReplicatedStorage.ServerValues
local AllowSpawn	= settings.AllowSpawn
local BlueScore 	= settings.BlueScore
local Countdown 	= settings.Countdown
local GameMode 		= settings.GameMode
local MapName 		= settings.MapName
local MaxScore 		= settings.MaxScore
local RedScore 		= settings.RedScore
local ShowResults 	= settings.ShowResults
local Time			= settings.Time
local Winner 		= settings.Winner
local showresult  	= settings.ShowResults

local CurrentMode = "TDM"
local RoundTime		=15
local GameRunning	=false
local EndScore = 0
local Point = 0


local GameList = {
	TDM = {
		Name ="Team Scoring Match",
		Length = 10,
		StartScore = 0,
		EndScore = 250,
		KillScore = true,
	}	
}

local MapList = {"Poopy Town", "Garbage Place", "Desert"}
local GameModes = {"TDM"}

local Randomize = math.random(1, #MapList*#GameModes)

function CheckResult()
	if GameRunning then
		if RedScore.Value>=EndScore or BlueScore.Value>=EndScore then
			GameRunning=false
		end
	end
end

function GameResult()
	if RedScore.Value==BlueScore.Value then
		Winner.Value = BrickColor.new("Black")
	elseif RedScore.Value>=EndScore or RedScore.Value>BlueScore.Value then
		Winner.Value = game.Teams["Team Red"].TeamColor
	else
		Winner.Value=game.Teams["Team Blue"].TeamColor
	end
	
	showresult.Value=true
	wait(10)
	showresult.Value=false
end

function RoundReset()
	
end

function SpawnPlayers()
	
end

function BalanceTeam()
	
end

function CheckBalance()
	
end

function RoundSystem.GetMatch()
	local Map = MapList[(Randomize-1)%#MapList+1]
	local Mode = GameModes[(Randomize-1)%#GameModes+1]
	Randomize += 1
	
	return Map,Mode
end

function RoundSystem.StartMatch(MapName, Mode)
	local ModeData
	CurrentMode				= Mode
	ModeData				= GameList[CurrentMode]
	RoundTime				= ModeData.Length
	EndScore				= ModeData.EndScore
	GameMode.Value			= ModeData.Name
	MaxScore.Value			= ModeData.StartScore > 0 and ModeData.StartScore or EndScore
	
	RoundReset()
	
	RedScore.Value 			= ModeData.StartScore
	BlueScore.Value 		= ModeData.StartScore
	
	local Map = Instance.new("Model")
	Map.Parent = workspace
	Map.Name = "Map"
	
	local Parts = ServerStorage:WaitForChild("Maps"):FindFirstChild(MapName):GetChildren()
	local MapLoadCount = 0
	
	for Index, Value in ipairs(Parts) do
		MapLoadCount += 1
		if MapLoadCount % 100 == 0 then
			wait(0.15)
		end
		
		if Value:IsA("Model") then
			local ModelParts = Value:GetChildren()
			for Index, Value in ipairs(ModelParts) do
				MapLoadCount += 1
				if MapLoadCount % 50 == 0 then
					wait(0.15)
				end
			end
		end
		Value:Clone().Parent = Map
	end
	
	wait(5)
	AllowSpawn.Value = true
	Countdown.Value = true
	
	for Count = 5, 0, -1 do
		Time.Value += 1
		wait(1)
	end
	
	Countdown.Value = false
	GameRunning = true
	
	for Count = RoundTime * 60, 0, -1 do
		if GameRunning then
			Time.Value = Count
			CheckResult()
			wait(1)
		end
	end
	
	GameRunning = false
	AllowSpawn.Value = false
	GameResult()
	BalanceTeam()
	SpawnPlayers()
end


return RoundSystem
