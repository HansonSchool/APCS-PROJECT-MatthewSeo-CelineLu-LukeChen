local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Glass = {"1565824613"; "1565825075";}
local Metal = {"282954522"; "282954538"; "282954576"; "1565756607"; "1565756818";}
local Grass = {"1565830611"; "1565831129"; "1565831468"; "1565832329";}
local Wood = {"287772625"; "287772674"; "287772718"; "287772829"; "287772902";}
local Concrete = {"287769261"; "287769348"; "287769415"; "287769483"; "287769538";}
local Explosion = {"287390459"; "287390954"; "287391087"; "287391197"; "287391361"; "287391499"; "287391567";}
local Cracks = {"342190504"; "342190495"; "342190488"; "342190510";}
local Hits = {"363818432"; "363818488"; "363818567"; "363818611"; "363818653";}
local Whizz = {"342190005"; "342190012"; "342190017"; "342190024";}

local HitFX = game.ReplicatedStorage:WaitForChild("BulletHitFX")
local HitParticles = HitFX:WaitForChild("Particles")
local HitSounds = HitFX:WaitForChild("Sounds")

local BulletHole = {}

function BulletHole.HitEffect(IgnoreList,Storage,Position, HitPart, Normal, Material--[[,Settings]])
	if HitPart == nil or HitPart.Name == "nil" then return end
	
	if IgnoreList[HitPart.Name] then return end -- if it exists inside ignore list then return
	
	local Attachment = Instance.new("Attachment")
	Attachment.CFrame = CFrame.new(Position, Position - Normal) * CFrame.Angles(math.rad(90),math.rad(0),0)
	Attachment.Parent = workspace.Terrain
	
	local BulletAttachment = Instance.new("Attachment")
	BulletAttachment.CFrame = CFrame.new(Position, Position - Normal) * CFrame.Angles(math.rad(90),math.rad(0),0)
	BulletAttachment.Parent = workspace.Terrain

	local BulletHole = workspace.Hole:Clone() 
	BulletHole.CFrame = BulletAttachment.CFrame 
	BulletHole.Parent = BulletAttachment
	IgnoreList[#IgnoreList + 1] = BulletHole
	
	if HitPart then
		if HitPart.Name == "Terrain" then
			BulletHole.Decal1.Color3 = workspace.Terrain:GetMaterialColor(Material)
		else
			BulletHole.Decal1.Color3 = HitPart.Color
		end
		
		coroutine.wrap(function()
			local Info = TweenInfo.new(
				3,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.InOut,
				0,
				false,
				2
			)
			
			local Properties = {
				Transparency = 1
			}
			
			local Tween = TweenService:Create(BulletHole.Decal1, Info, Properties)
			local Tween2 = TweenService:Create(BulletHole.Decal2, Info, Properties)
			Tween:Play()
			Tween2:Play()
		end)()
		
		delay(.1,function()
			Debris:AddItem(BulletAttachment, 5)
		end)
	end
	
	if HitPart.Name == "Head" then
		local BulletWhizz = HitSounds.Humanoid:Clone()
		BulletWhizz.Parent = Attachment
		BulletWhizz.Volume = math.random(20,30)/10
		BulletWhizz.PlaybackSpeed = math.random(34, 50)/40
		BulletWhizz.SoundId = "rbxassetid://" .. Hits[math.random(1, 5)]
		BulletWhizz:Play()

		local Particles = HitParticles.Head:Clone()
		Particles.Parent = Attachment
		
		delay(.1,function()
			Particles.Enabled = false
			Debris:AddItem(Attachment, Particles.Lifetime.Max)
		end)

	elseif HitPart.Name == "HumanoidRootPart" or HitPart.Name == "UpperTorso" or HitPart.Name == "LowerTorso" or HitPart.Name == "RightUpperArm" or HitPart.Name == "RightLowerArm" or HitPart.Name == "RightHand" or HitPart.Name == "LeftUpperArm" or HitPart.Name == "LeftLowerArm" or HitPart.Name == "LeftHand" or HitPart.Name == "RightUpperLeg" or HitPart.Name == "RightLowerLeg" or HitPart.Name == "RightFoot" or HitPart.Name == "LeftUpperLeg" or HitPart.Name == "LeftLowerLeg" or HitPart.Name == "LeftFoot" then
		local BulletWhizz = HitSounds.Humanoid:Clone()
		BulletWhizz.Parent = Attachment
		BulletWhizz.Volume = math.random(20,30)/10
		BulletWhizz.PlaybackSpeed = math.random(34, 46)/40
		BulletWhizz.SoundId = "rbxassetid://" .. Hits[math.random(1, 5)]
		BulletWhizz:Play()

		local Particles = HitParticles.Body:Clone()
		Particles.Parent = Attachment
		
		delay(.05,function()
			Particles.Enabled = false
			Debris:AddItem(Attachment, Particles.Lifetime.Max)
		end)

	elseif HitPart.Parent:IsA("Accessory") then
		local BulletWhizz = HitSounds.Humanoid:Clone()
		BulletWhizz.Parent = Attachment
		BulletWhizz.Volume = math.random(20,30)/10
		BulletWhizz.PlaybackSpeed = math.random(34, 50)/40
		BulletWhizz.SoundId = "rbxassetid://" .. Hits[math.random(1, 5)]
		BulletWhizz:Play()

		local Particles = HitParticles.Accessory:Clone()
		Particles.Parent = Attachment
		Particles.EmissionDirection = "Front"
		
		delay(.15,function()
			Particles.Enabled = false
			Debris:AddItem(Attachment, Particles.Lifetime.Max)
		end)

	elseif Material == Enum.Material.Concrete or Material == Enum.Material.Slate or Material == Enum.Material.Cobblestone or Material == Enum.Material.Brick or Material == Enum.Material.Granite or Material == Enum.Material.Basalt or Material == Enum.Material.Rock or Material == Enum.Material.CrackedLava or Material == Enum.Material.Limestone or Material == Enum.Material.Asphalt or Material == Enum.Material.Sandstone then
		local BulletWhizz = HitSounds.Material:Clone()
		BulletWhizz.Parent = Attachment
		BulletWhizz.Volume = math.random(20,30)/10
		BulletWhizz.PlaybackSpeed = math.random(38, 46)/40
		BulletWhizz.SoundId = "rbxassetid://" .. Concrete[math.random(1, 5)]
		BulletWhizz:Play()	

		local Particle = HitParticles.Concrete:Clone()
		Particle.Parent = Attachment
		
		delay(.1,function()
			Particle.Enabled = false
			Debris:AddItem(Attachment, Particle.Lifetime.Max)
		end)
		
		local Billboard = Instance.new("BillboardGui", Attachment)
		Billboard.Adornee = Attachment
		
		local flashsize = math.random(10, 15)/10
		Billboard.Size = UDim2.new(flashsize, 0, flashsize, 0)
		
		local flash = Instance.new("ImageLabel", Billboard)
		flash.BackgroundTransparency = 1
		flash.Size = UDim2.new(0.05, 0, 0.05, 0)
		flash.Position = UDim2.new(0.5, 0, 0.5, 0)
		flash.Image = "http://www.roblox.com/asset/?id=476778304"
		flash.ImageTransparency = math.random(0, .5)
		flash.Rotation = math.random(0, 360)
		flash:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.1)	
		game.Debris:AddItem(Billboard, 0.1)

	elseif Material == Enum.Material.Wood then
		local BulletWhizz = HitSounds.Material:Clone()
		BulletWhizz.Parent = Attachment
		BulletWhizz.Volume = math.random(20,30)/10
		BulletWhizz.PlaybackSpeed = math.random(38, 50)/40
		BulletWhizz.SoundId = "rbxassetid://" .. Wood[math.random(1, 5)]
		BulletWhizz:Play()

		local Particles = HitParticles.Wood:Clone()
		Particles.Color = ColorSequence.new(HitPart.Color)
		Particles.Parent = Attachment

		delay(.1,function()
			Particles.Enabled = false
			Debris:AddItem(Attachment, Particles.Lifetime.Max)
		end)
		
		local Billboard = Instance.new("BillboardGui", Attachment)
		Billboard.Adornee = Attachment
		
		local flashsize = math.random(10, 15)/10
		Billboard.Size = UDim2.new(flashsize, 0, flashsize, 0)
		local flash = Instance.new("ImageLabel", Billboard)
		flash.BackgroundTransparency = 1
		flash.Size = UDim2.new(0.05, 0, 0.05, 0)
		flash.Position = UDim2.new(0.5, 0, 0.5, 0)
		flash.Image = "http://www.roblox.com/asset/?id=476778304"
		flash.ImageTransparency = math.random(0, .5)
		flash.Rotation = math.random(0, 360)
		flash:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.1)	
		game.Debris:AddItem(Billboard, 0.1)

	elseif Material == Enum.Material.WoodPlanks then
		local BulletWhizz = HitSounds.Material:Clone()
		BulletWhizz.Parent = Attachment
		BulletWhizz.Volume = math.random(20,30)/10
		BulletWhizz.PlaybackSpeed = math.random(38, 50)/40
		BulletWhizz.SoundId = "rbxassetid://" .. Wood[math.random(1, 5)]
		BulletWhizz:Play()

		local Particles = HitParticles.Planks:Clone()
		Particles.Color = ColorSequence.new(workspace.Terrain:GetMaterialColor(Material))
		Particles.Parent = Attachment

		delay(.1,function()
			Particles.Enabled = false
			Debris:AddItem(Attachment, Particles.Lifetime.Max)
		end)
		local Billboard = Instance.new("BillboardGui", Attachment)
		Billboard.Adornee = Attachment
		local flashsize = math.random(10, 15)/10
		Billboard.Size = UDim2.new(flashsize, 0, flashsize, 0)
		local flash = Instance.new("ImageLabel", Billboard)
		flash.BackgroundTransparency = 1
		flash.Size = UDim2.new(0.05, 0, 0.05, 0)
		flash.Position = UDim2.new(0.5, 0, 0.5, 0)
		flash.Image = "http://www.roblox.com/asset/?id=476778304"
		flash.ImageTransparency = math.random(0, .5)
		flash.Rotation = math.random(0, 360)
		flash:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.1)	
		game.Debris:AddItem(Billboard, 0.1)

	elseif Material == Enum.Material.Fabric then
		local BulletWhizz = HitSounds.Material:Clone()
		BulletWhizz.Parent = Attachment
		BulletWhizz.Volume = math.random(20,30)/10
		BulletWhizz.PlaybackSpeed = math.random(38, 50)/40
		BulletWhizz.SoundId = "rbxassetid://" .. Grass[math.random(1, 4)]
		BulletWhizz:Play()

		local Particles = HitParticles.Fabric:Clone()
		Particles.Color = ColorSequence.new(HitPart.Color)
		Particles.Parent = Attachment

		delay(.1,function()
			Particles.Enabled = false
			Debris:AddItem(Attachment, Particles.Lifetime.Max)
		end)
		local Billboard = Instance.new("BillboardGui", Attachment)
		Billboard.Adornee = Attachment
		local flashsize = math.random(10, 15)/10
		Billboard.Size = UDim2.new(flashsize, 0, flashsize, 0)
		local flash = Instance.new("ImageLabel", Billboard)
		flash.BackgroundTransparency = 1
		flash.Size = UDim2.new(0.05, 0, 0.05, 0)
		flash.Position = UDim2.new(0.5, 0, 0.5, 0)
		flash.Image = "http://www.roblox.com/asset/?id=476778304"
		flash.ImageTransparency = math.random(0, .5)
		flash.Rotation = math.random(0, 360)
		flash:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.1)	
		game.Debris:AddItem(Billboard, 0.1)

	elseif Material == Enum.Material.Grass or Material == Enum.Material.Sand or Material == Enum.Material.Ground or Material == Enum.Material.Snow or Material == Enum.Material.Mud or Material == Enum.Material.LeafyGrass then
		local BulletWhizz = HitSounds.Material:Clone()
		BulletWhizz.Parent = Attachment
		BulletWhizz.Volume = math.random(20,30)/10
		BulletWhizz.PlaybackSpeed = math.random(38, 50)/40
		BulletWhizz.SoundId = "rbxassetid://" .. Grass[math.random(1, 4)]
		BulletWhizz:Play()

		local Particles = HitParticles.Grass:Clone()
		Particles.Color = ColorSequence.new(workspace.Terrain:GetMaterialColor(Material))
		Particles.Parent = Attachment

		delay(.1,function()
			Particles.Enabled = false
			Debris:AddItem(Attachment, Particles.Lifetime.Max)
		end)
		local Billboard = Instance.new("BillboardGui", Attachment)
		Billboard.Adornee = Attachment
		local flashsize = math.random(10, 15)/10
		Billboard.Size = UDim2.new(flashsize, 0, flashsize, 0)
		local flash = Instance.new("ImageLabel", Billboard)
		flash.BackgroundTransparency = 1
		flash.Size = UDim2.new(0.05, 0, 0.05, 0)
		flash.Position = UDim2.new(0.5, 0, 0.5, 0)
		flash.Image = "http://www.roblox.com/asset/?id=476778304"
		flash.ImageTransparency = math.random(0, .5)
		flash.Rotation = math.random(0, 360)
		flash:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.1)	
		game.Debris:AddItem(Billboard, 0.1)

	elseif Material == Enum.Material.Plastic or Material == Enum.Material.SmoothPlastic then
		local BulletWhizz = HitSounds.Humanoid:Clone()
		BulletWhizz.Parent = Attachment
		BulletWhizz.Volume = math.random(20,30)/10
		BulletWhizz.PlaybackSpeed = math.random(32, 50)/40
		BulletWhizz.SoundId = "rbxassetid://" .. Cracks[math.random(1, 4)]
		BulletWhizz:Play()
		
		local Particles = HitParticles.Plastic:Clone()
		Particles.Parent = Attachment

		delay(.1,function()
			Particles.Enabled = false
			Debris:AddItem(Attachment, Particles.Lifetime.Max)
		end)
		local Billboard = Instance.new("BillboardGui", Attachment)
		Billboard.Adornee = Attachment
		local flashsize = math.random(10, 15)/10
		Billboard.Size = UDim2.new(flashsize, 0, flashsize, 0)
		local flash = Instance.new("ImageLabel", Billboard)
		flash.BackgroundTransparency = 1
		flash.Size = UDim2.new(0.05, 0, 0.05, 0)
		flash.Position = UDim2.new(0.5, 0, 0.5, 0)
		flash.Image = "http://www.roblox.com/asset/?id=476778304"
		flash.ImageTransparency = math.random(0, .5)
		flash.Rotation = math.random(0, 360)
		flash:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.1)	
		game.Debris:AddItem(Billboard, 0.1)

	elseif Material == Enum.Material.ForceField then
		local BulletWhizz = HitSounds.Humanoid:Clone()
		BulletWhizz.Parent = Attachment
		BulletWhizz.Volume = math.random(20,30)/10
		BulletWhizz.PlaybackSpeed = math.random(32, 50)/40
		BulletWhizz.SoundId = "rbxassetid://" .. Whizz[math.random(1, 4)]
		BulletWhizz:Play()
		
		local Po = Instance.new("PointLight", Attachment)
		Po.Color = HitPart.Color
		Po.Brightness = 2
		Po.Shadows = true
		Po.Range = math.random(8, 10)
		game.Debris:AddItem(Po, 0.05)
		local Billboard = Instance.new("BillboardGui", Attachment)
		Billboard.Adornee = Attachment
		local flashsize = math.random(15, 30)/10
		Billboard.Size = UDim2.new(flashsize, 0, flashsize, 0)
		local flash = Instance.new("ImageLabel", Billboard)
		flash.BackgroundTransparency = 1
		flash.Size = UDim2.new(0.05, 0, 0.05, 0)
		flash.Position = UDim2.new(0.45, 0, 0.45, 0)
		flash.Image = "http://www.roblox.com/asset/?id=233113663"
		flash.ImageTransparency = math.random(0, .5)
		flash.Rotation = math.random(0, 360)
		flash:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.15)	
		game.Debris:AddItem(Billboard, 0.07)
		game.Debris:AddItem(Attachment, 1)			

	elseif Material == Enum.Material.CorrodedMetal or Material == Enum.Material.Metal or Material == Enum.Material.DiamondPlate then
		local BulletWhizz = HitSounds.Metal:Clone()
		BulletWhizz.Parent = Attachment
		BulletWhizz.Volume = math.random(20,30)/10
		BulletWhizz.PlaybackSpeed = math.random(38, 58)/40
		BulletWhizz.SoundId = "rbxassetid://" .. Metal[math.random(1, 5)]
		BulletWhizz:Play()

		local Particles = HitParticles.Metal:Clone()
		Particles.Parent = Attachment

		delay(.1,function()
			Particles.Enabled = false
			Debris:AddItem(Attachment, Particles.Lifetime.Max)
		end)
		local Po = Instance.new("PointLight", Attachment)
		Po.Color = Color3.fromRGB(255, 150, 0)
		Po.Brightness = 2
		Po.Shadows = true
		Po.Range = math.random(8, 10)
		game.Debris:AddItem(Po, 0.05)
		local Billboard = Instance.new("BillboardGui", Attachment)
		Billboard.Adornee = Attachment
		local flashsize = math.random(15, 30)/10
		Billboard.Size = UDim2.new(flashsize, 0, flashsize, 0)
		local flash = Instance.new("ImageLabel", Billboard)
		flash.BackgroundTransparency = 1
		flash.Size = UDim2.new(0.05, 0, 0.05, 0)
		flash.Position = UDim2.new(0.45, 0, 0.45, 0)
		flash.Image = "http://www.roblox.com/asset/?id=233113663"
		flash.ImageTransparency = math.random(0, .5)
		flash.Rotation = math.random(0, 360)
		flash:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.15)	
		game.Debris:AddItem(Billboard, 0.07)
		
	elseif  HitPart.Name == "_Glass" then
		local BulletWhizz = HitSounds.Material:Clone()
		BulletWhizz.Parent = Attachment
		BulletWhizz.Volume = math.random(20,30)/10
		BulletWhizz.PlaybackSpeed = math.random(32, 60)/40
		BulletWhizz.SoundId = "rbxassetid://" .. Glass[math.random(1, 2)]
		BulletWhizz:Play()

		local Billboard = Instance.new("BillboardGui", Attachment)
		Billboard.Adornee = Attachment
		local flashsize = math.random(10, 15)/10
		Billboard.Size = UDim2.new(flashsize, 0, flashsize, 0)
		local flash = Instance.new("ImageLabel", Billboard)
		flash.BackgroundTransparency = 1
		flash.Size = UDim2.new(0.05, 0, 0.05, 0)
		flash.Position = UDim2.new(0.5, 0, 0.5, 0)
		flash.Image = "http://www.roblox.com/asset/?id=476778304"
		flash.ImageTransparency = math.random(0, .5)
		flash.Rotation = math.random(0, 360)
		flash:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.1)	
		game.Debris:AddItem(Billboard, 0.1)
		HitPart:Destroy()
		
	elseif Material == Enum.Material.Glass or Material == Enum.Material.Ice or Material == Enum.Material.Glacier then
		local BulletWhizz = HitSounds.Material:Clone()
		BulletWhizz.Parent = Attachment
		BulletWhizz.Volume = math.random(20,30)/10
		BulletWhizz.PlaybackSpeed = math.random(32, 60)/40
		BulletWhizz.SoundId = "rbxassetid://" .. Glass[math.random(1, 2)]
		BulletWhizz:Play()

		local Particles = HitParticles.Glass:Clone()
		Particles.Parent = Attachment

		delay(.1,function()
			Particles.Enabled = false
			Debris:AddItem(Attachment, Particles.Lifetime.Max)
		end)
		local Billboard = Instance.new("BillboardGui", Attachment)
		Billboard.Adornee = Attachment
		local flashsize = math.random(10, 15)/10
		Billboard.Size = UDim2.new(flashsize, 0, flashsize, 0)
		local flash = Instance.new("ImageLabel", Billboard)
		flash.BackgroundTransparency = 1
		flash.Size = UDim2.new(0.05, 0, 0.05, 0)
		flash.Position = UDim2.new(0.5, 0, 0.5, 0)
		flash.Image = "http://www.roblox.com/asset/?id=476778304"
		flash.ImageTransparency = math.random(0, .5)
		flash.Rotation = math.random(0, 360)
		flash:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.1)	
		game.Debris:AddItem(Billboard, 0.1)

	else
		local BulletWhizz = HitSounds.Humanoid:Clone()
		BulletWhizz.Parent = Attachment
		BulletWhizz.Volume = math.random(20,30)/10
		BulletWhizz.PlaybackSpeed = math.random(32, 50)/40
		BulletWhizz.SoundId = "rbxassetid://" .. Cracks[math.random(1, 4)]
		BulletWhizz:Play()
		
		local Particles = HitParticles:WaitForChild("General"):Clone()
		Particles.Parent = Attachment
		
		delay(.1,function()
			Particles.Enabled = false
			Debris:AddItem(Attachment, Particles.Lifetime.Max)
		end)
		
		local Billboard = Instance.new("BillboardGui", Attachment)
		Billboard.Adornee = Attachment
		local flashsize = math.random(10, 15)/10
		Billboard.Size = UDim2.new(flashsize, 0, flashsize, 0)
		local flash = Instance.new("ImageLabel", Billboard)
		flash.BackgroundTransparency = 1
		flash.Size = UDim2.new(0.05, 0, 0.05, 0)
		flash.Position = UDim2.new(0.5, 0, 0.5, 0)
		flash.Image = "http://www.roblox.com/asset/?id=476778304"
		flash.ImageTransparency = math.random(0, .5)
		flash.Rotation = math.random(0, 360)
		flash:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.1)	
		game.Debris:AddItem(Billboard, 0.1)
	end
end

return BulletHole
