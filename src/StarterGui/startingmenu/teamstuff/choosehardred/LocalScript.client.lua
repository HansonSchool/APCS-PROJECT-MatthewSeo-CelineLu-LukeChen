local button = script.Parent
button.MouseButton1Click:Connect(function()
	script.Parent.Visible = false
	script.Parent.Parent.choosehardblue.Visible = false
	script.Parent.Parent.changetohardblue.Visible = true
	print("hi")
end)

