-- default info, maybe a template if you want one accessible?

local root = script.Parent
local data = {

	-- information about animations
	animations = {
	
		-- first person
		viewmodel = {
			idle = root.animations.idle;
		}
	
	};
	
	-- information about how the gun fires
	firing = {
		rpm = 700;
	}
	
}

return data