local button = script.Parent
button.MouseButton1Click:Connect(function()
	script.Parent.Visible = false
	script.Parent.Parent.Gamemode.Visible = true
	script.Parent.Parent.hardgamemode.Visible = true
	script.Parent.Parent.normalgamemode.Visible = true
	
	script.Parent.Parent.choosered.Visible = false
	script.Parent.Parent.choosehardred.Visible = false
	script.Parent.Parent.chooseblue.Visible = false
	script.Parent.Parent.choosehardblue.Visible = false
	
	script.Parent.Parent.changetored.Visible = false
	script.Parent.Parent.changetoblue.Visible = false
	script.Parent.Parent.changetohardred.Visible = false
	script.Parent.Parent.changetohardblue.Visible = false
	print("hi")
end)

