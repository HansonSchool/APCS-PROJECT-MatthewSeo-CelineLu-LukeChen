local RoundSystem = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = game.Players.LocalPlayer

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

local PlayerGUI = LocalPlayer.PlayerGui

local GameGUI = PlayerGUI:WaitForChild("GameGUI")
local RoundUI = GameGUI:WaitForChild("Round")
local RedScoreUI = RoundUI:WaitForChild("Red")
local BlueScoreUI = RoundUI:WaitForChild("Blue")
local ModeUI = RoundUI:WaitForChild("GameMode")
local TimeUI = RoundUI:WaitForChild("Time")

local Menu = PlayerGUI:WaitForChild("Menu")
local PlayButton = Menu.MainMenu.TopBar.Play

function RoundSystem.UpdateTime()
	if Countdown.Value then
		TimeUI.Text = "Countdown"
	else
		if not ShowResults.Value then

		end
		local Seconds = Time.Value % 60
		if Seconds < 10 then
			Seconds = "0"..Seconds
		end

		TimeUI.Text = math.floor(Time.Value/60)..":"..Seconds 
	end
end

function RoundSystem.UpdateScore()
	RedScoreUI.Point.Text = RedScore.Value
	BlueScoreUI.Point.Text = BlueScore.Value
end

function RoundSystem.UpdateResult()

end

return RoundSystem