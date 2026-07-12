return function(env)
	local Rayfield = env.Rayfield
	local themes = {"Amethyst", "Aqua", "Blood", "Cherry", "Crimson", "Dark", "DeepSea", "Emerald",
		"Fluorescent", "Gold", "Light", "Midnight", "Ocean", "Orchid", "Royal", "Ruby", "Sand",
		"Sapphire", "Sentinel", "Serenity", "Sky", "Sunset", "Tidal", "Titanium", "Tokyo"}
	local currentTheme = "Amethyst"

	return {
		GetThemes = function() return themes end,
		GetCurrent = function() return currentTheme end,
		SetTheme = function(name)
			currentTheme = name
			if Rayfield and Rayfield.ChangeTheme then
				Rayfield:ChangeTheme(name)
			end
		end,
	}
end
