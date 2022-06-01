local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")

local richText = require(ReplicatedStorage.modules.richText)
local module3D = require(ReplicatedStorage.modules.module3D)

local itemData = require(ReplicatedStorage.itemData)

local inventoryFrame = script.Parent
local inventoryFrameDesiredSize = inventoryFrame.Size 
inventoryFrame.Size = UDim2.new(0, 0, 0, 0) 
local inventoryFrameZeroSize = inventoryFrame.Size 

inventoryFrame.Visible = false 

local posSize = {} 

local invDebounce = false 

local inUi = false 
local canQuitUi = false 

local outlines = {}


local guiOpen = false
local scrollingFrame = script.Parent.Section.ScrollingFrame


local function newItem(itemSlot, index, value)
	itemSlot.Amount.Text = "x" .. value

	itemSlot.Outline.ImageTransparency = 0
end

local descFrame = script.Parent.Desc
local currSelected = nil

local viewportItems = {}

local function clearGui(p5)
	local children = scrollingFrame:GetChildren()
	for v16 = 1, #children do
		if children[v16]:IsA("ImageButton") and p5[children[v16].RealName.Value] == nil then
			if viewportItems[children[v16]] then
				viewportItems[children[v16]] = nil;
			end;
			children[v16]:Destroy()
		end
	end
end

local slotDebounce = false

local function updateInventory(max,weight)
	outlines = {}
	
	print(game.ReplicatedStorage.shopString.Value)
	local xd = game.ReplicatedStorage.shopString.Value
	local temp_inventory = game.HttpService:JSONDecode(xd)

	--{"slot1":[],"shirts":[],"inv":[[4,"Mistsplitter",2],[5,"Amenoma Kageuchi",1]],"head":[],"slot2":[],"pants":[],"slot3":[]}
	--{"slot1":[],"shirts":[],"inv":[{"Mistsplitter":2},{"Amenoma Kageuchi":1}],"head":[],"slot2":[],"pants":[],"slot3":[]}
	--{"slot1":[],"shirts":[],"inv":{"Amenoma Kageuchi":1,"Mistsplitter":2},"head":[],"slot2":[],"pants":[],"slot3":[]}
	
	
	--{"Hotdog": 5, "Pizza": 10,"Taco": 15, "Drink":20}
	--{"slot1":[],"shirts":[],"inv":{"Hotdog": 5, "Pizza": 10,"Taco": 15, "Drink":20},"head":[],"slot2":[],"pants":[],"slot3":[]}
	
	
	clearGui(temp_inventory)
	
	for index, value in pairs(temp_inventory.inv) do
		pcall(function()
			local itemSlot = scrollingFrame.UIGridLayout.UIAspectRatioConstraint.Templates.Temp:Clone()
			itemSlot.Name = itemData[index].Name
			itemSlot.RealName.Value = index
			itemSlot.Parent = scrollingFrame
			
			local renderItem = module3D:Attach3D(itemSlot.Frame, game.ReplicatedStorage.Foods:FindFirstChild(index):Clone())
			renderItem:SetDepthMultiplier(1)
			renderItem.Camera.FieldOfView = 25
			renderItem:SetActive(true)
			
			newItem(itemSlot, index, value)
			
			viewportItems[itemSlot] = renderItem;
			
			local viewportFrame = itemSlot.Frame:WaitForChild("ViewportFrame", 1)
			if viewportFrame then
				viewportFrame.ZIndex = 5
				viewportFrame.BackgroundColor3 = Color3.fromRGB(79, 79, 79)
			end	
		
			
			itemSlot.MouseButton1Click:Connect(function()
				if slotDebounce == true then return end
				slotDebounce = true
				descFrame.Visible = true

				currSelected = itemSlot
				
				--to avoid spamming but idk if i shud keep it
				delay(0.5, function() slotDebounce = false end) 
				
				if descFrame.ItemName.Text ~= index then
					descFrame.ItemName.Text = index
					
					richText:New(descFrame.TextLabel, itemData[index].Description, {
						ZIndex = 10, 
						Font = "GothamSemibold", 
						TextScale = 0.075, 
						AnimateStepFrequency = 3
					}):Animate(true)
				end
				
			end)
		end)
	end
end

local u1 = Vector2.new(0.25, 0.25)

local function resteUiGrid()
	local v33 = u1 * scrollingFrame.AbsoluteSize
	scrollingFrame.UIGridLayout.CellSize = UDim2.new(0, v33.X, 0, v33.Y)
	scrollingFrame.CanvasSize = UDim2.new(0, scrollingFrame.UIGridLayout.AbsoluteContentSize.X, 0, scrollingFrame.UIGridLayout.AbsoluteContentSize.Y)
end

UserInputService.InputBegan:Connect(function(input, absorbed)
	if absorbed then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		resteUiGrid()
		descFrame.Visible = false
	end
end)

script.Parent.Parent.shopButton.TextButton.MouseButton1Click:Connect(function()
	if inUi then 
		canQuitUi = true
		return
	end
	if invDebounce == false then
		inUi = true 
		inventoryFrame:TweenSize(inventoryFrameDesiredSize, "Out", "Quad", 0.25, true) 
		inventoryFrame.Visible = true 
		inventoryFrame.Parent.close.Visible = true
		spawn(function()
			while true do
				wait() 
				if canQuitUi == true then
					break 
				end 			
			end 
			canQuitUi = false 
			inUi = false 
			inventoryFrame:TweenSize(inventoryFrameZeroSize, "Out", "Quad", 0.25, true) 
			wait(0.25) 
			inventoryFrame.Visible = false 
			inventoryFrame.Parent.close.Visible = false
		end) 
	end 
	invDebounce = true 
	wait(0.25) 
	invDebounce = false 
end) 


script.Parent.Desc.Equip.MouseButton1Click:Connect(function()
	game.ReplicatedStorage.Event:Fire("projectileType", currSelected.Name)
end)

local rotDegree = 0
--for when player loads the game
updateInventory()

runService.Heartbeat:Connect(function()
	if inventoryFrame.Visible == true then
		resteUiGrid()
		rotDegree += 1
		for index, value in pairs(outlines) do
			if value ~= nil then
				value.Rotation = rotDegree
			else
				outlines[index] = nil
			end
		end
		for index, value in pairs(viewportItems) do
			value:SetDepthMultiplier(1)
			value.Camera.FieldOfView = 25
			value:SetCFrame(CFrame.Angles(0, tick() % (math.pi * 2), 0) * CFrame.Angles(math.rad(-2), 0, 0))
			if index == nil then
				viewportItems[index] = nil
			end
		end
	end
end)