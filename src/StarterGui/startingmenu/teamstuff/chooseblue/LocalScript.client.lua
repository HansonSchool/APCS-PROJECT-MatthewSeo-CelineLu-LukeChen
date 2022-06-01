local button = script.Parent
button.MouseButton1Click:Connect(function()
	script.Parent.Visible = false
	script.Parent.Parent.choosered.Visible = false
	--script.Parent.Parent.changetoblue.Visible = true
	script.Parent.Parent.changetored.Visible = true
	print("hi")
end)

