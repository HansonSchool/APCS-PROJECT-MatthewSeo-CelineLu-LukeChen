local button = script.Parent
button.MouseButton1Click:Connect(function()
	script.Parent.Visible = false
	script.Parent.Parent.Parent.close.TextButton.Visible = true
	script.Parent.Parent.Parent.Inventory.Visible = true
	print("hi")
end)

