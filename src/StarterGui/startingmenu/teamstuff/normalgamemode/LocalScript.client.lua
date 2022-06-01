local button = script.Parent
button.MouseButton1Click:Connect(function()
	script.Parent.Visible = false
	script.Parent.Parent.chooseblue.Visible = true
	script.Parent.Parent.choosered.Visible = true
	script.Parent.Parent.hardgamemode.Visible = false
	script.Parent.Parent.Gamemode.Visible = false
	script.Parent.Parent.back.Visible = true
	print("hi")
end)

