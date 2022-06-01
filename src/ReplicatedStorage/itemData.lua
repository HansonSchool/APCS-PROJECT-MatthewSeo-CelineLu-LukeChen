--{"inv":{"Hot Dog": 5, Pizza": 10,"Taco": 15, "Drink":20}}

local module = {
	["Hotdog"] = {
		Name = "Hotdog",
		Price = 5,
		Description = "A hot dog is a food consisting of a grilled or steamed sausage served in the slit of a partially sliced bun.",
		Bonus = 0
	};
	["Pizza"] = {
		Name = "Pizza",
		Price = 10,
		Description = "Pizza is a dish of Italian origin consisting of a usually round, flat base of leavened wheat-based dough topped with tomatoes, cheese, and often various other ingredients, which is then baked at a high temperature, traditionally in a wood-fired oven.",
		Bonus = 3
	};
	["Taco"] = {
		Name = "Taco",
		Price = 15,
		Description = "A taco is a traditional Mexican dish consisting of a small hand-sized corn or wheat tortilla topped with a filling.",
		Bonus = 5
	};
	["Drink"] = {
		Name = "Drink",
		Price = 20,
		Description = "A drink is a liquid intended for human consumption. In addition to their basic function of satisfying thirst, drinks play important roles in human culture.",
		Bonus = 7
	}
}

return module
