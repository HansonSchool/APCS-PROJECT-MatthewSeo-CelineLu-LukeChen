local button = script.Parent
button.MouseButton1Click:Connect(function()
	script.Parent.Visible = false
	script.Parent.Parent.Parent.Inventory.Visible = false
	script.Parent.Parent.Parent.shopButton.TextButton.Visible = true

	print("hi")
end)

