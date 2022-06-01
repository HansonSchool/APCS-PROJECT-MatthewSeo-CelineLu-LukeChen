local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local LocalPlayer = game.Players.LocalPlayer

local RoundSystem = require(ReplicatedStorage.modules.RoundSystem)

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
local Menu = PlayerGUI:WaitForChild("Menu")

Time.Changed:Connect(RoundSystem.UpdateTime)
RedScore.Changed:Connect(RoundSystem.UpdateScore)
BlueScore.Changed:Connect(RoundSystem.UpdateScore)
ShowResults.Changed:Connect(RoundSystem.UpdateResult)


