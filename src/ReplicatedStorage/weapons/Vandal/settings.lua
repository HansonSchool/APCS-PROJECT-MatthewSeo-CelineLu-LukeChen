local root = script.Parent

local data = {
	Type = "Rifle",
	ProjectileType = "NewBullet";
	BulletSpeed = 2400;
	Acceleration = Vector3.new(0,0,0);
	CanSpinPart = false;
	SpinX = 3;
	SpinY = 0;
	SpinZ = 0;
	
	animations = {

		viewmodel = {
			idle = root.animations.idle,
			fire = root.animations.fire,
			reload = root.animations.reload,
		},

		player = {
			aim = root.serverAnimations.aim,
			aimFire = root.serverAnimations.aimFire,
			idle = root.serverAnimations.idle,
			idleFire = root.serverAnimations.idleFire,
		},
	},

	firing = {

		damage = 15,
		headshot = 30,
		rpm = 700,
		magCapacity = 30,
		velocity = 600,
		range = 5000,
	},
	
	PenetrationType = "WallPenetration", --"WallPenetration" or "HumanoidPenetration"
	PenetrationDepth = 0.5,--WallPenetraion"
	PenetrationAmount = 2, --HumanoidPenetration
	
	WhizSoundEnabled = true;
	WhizSoundID = {3809084884, 3809085250, 3809085650, 3809085996, 3809086455};
	WhizSoundVolume = 1;
	WhizSoundPitchMin = 1; --Minimum pitch factor you will acquire
	WhizSoundPitchMax = 1; --Maximum pitch factor you will acquire
	WhizDistance = 25;
}

return data
