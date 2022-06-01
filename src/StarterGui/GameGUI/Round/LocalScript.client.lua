local player		=game.Players.LocalPlayer
local repstore		=game.ReplicatedStorage
local settings		=repstore.ServerValues
local timer			=settings.Time
local countdown		=settings.Countdown
local RedScore		=settings.RedScore
local BlueScore		=settings.BlueScore
local maxscore		=settings.MaxScore

local fr			=script.Parent
local counting		=fr.Time

function matchclock()
	if countdown.Value then counting.Text="COUNTDOWN" return end
	local seconds=timer.Value%60
	if seconds<10 then
		seconds="0"..seconds
	end
	counting.Text=math.floor(timer.Value/60)..":"..seconds
end


timer.Changed:connect(matchclock)