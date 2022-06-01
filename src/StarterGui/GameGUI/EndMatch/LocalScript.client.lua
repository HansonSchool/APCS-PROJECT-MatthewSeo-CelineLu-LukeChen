local player	=game.Players.LocalPlayer
local pgui		=player.PlayerGui

local delay		=function(F) coroutine.resume(coroutine.create(F)) end	
local fr		=script.Parent
local result	=fr:WaitForChild("Result")

local repstore		=game.ReplicatedStorage
local settings		=repstore.ServerValues
local timer			=settings.Time
local countdown		=settings.Countdown
local RedScore		=settings.RedScore
local BlueScore		=settings.BlueScore
local gameresult	=settings.Winner
local showresult	=settings.ShowResults

function setresult()
	if showresult.Value then
		fr.Visible=true
		local color=Color3.new
		local bcolor=BrickColor.new
		
		if gameresult.Value == bcolor("Really red") then
			script.Parent.Mode.Text = "Red team wins!"
		elseif gameresult.Value == bcolor("Dark blue") then
			script.Parent.Mode.Text = "Blue team wins!"
		else
			script.Parent.Mode.Text = "It is a draw!"
		end
		
		if gameresult.Value==player.TeamColor then
			result.Text="You sold more food than the other team!"
			result.TextColor=bcolor("Bright green")
		elseif gameresult.Value==bcolor("Black") then
			result.Text="DRAW"
			result.TextColor=bcolor("Bright orange")
		else
			result.Text="u r fired"
			result.TextColor=bcolor("Bright red")
		end
	else
		fr.Visible=false
	end
end


setresult()
showresult.Changed:connect(setresult)
