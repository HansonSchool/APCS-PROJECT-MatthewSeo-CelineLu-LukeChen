local button = script.Parent
button.MouseButton1Click:Connect(function()
	script.Parent.Visible = false
	script.Parent.Parent.choosehardblue.Visible = true
	script.Parent.Parent.choosehardred.Visible = true
	script.Parent.Parent.normalgamemode.Visible = false
	script.Parent.Parent.Gamemode.Visible = false
	script.Parent.Parent.back.Visible = true
	print("hi")
end)

