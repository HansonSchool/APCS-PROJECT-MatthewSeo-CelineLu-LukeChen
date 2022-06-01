local button = script.Parent
button.MouseButton1Click:Connect(function()
	script.Parent.Visible = false
	script.Parent.Parent.choosehardred.Visible = false
	script.Parent.Parent.changetohardred.Visible = true
	print("hi")
end)

