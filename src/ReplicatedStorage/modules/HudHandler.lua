local Hud = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game.Players.LocalPlayer

local PlayerGUI = LocalPlayer.PlayerGui

local GameGUI = PlayerGUI:WaitForChild("GameGUI")
local AmmoHud = GameGUI:WaitForChild("AmmoHud")
local AmmoFrame = AmmoHud:WaitForChild("Frame")
local AmmoText = AmmoFrame:WaitForChild("Ammo")
local Health = AmmoFrame:WaitForChild("Health")
local MagText = AmmoFrame:WaitForChild("Mag")

function Hud:updateAmmo(Mag, Ammo)
	MagText.Text = Mag
	AmmoText.Text = "/ "..Ammo
end

return Hud