return function(env)
	local NoClip = loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/NMHub/main/Modules/NoClip.lua"))()(env)
	local Flight = loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/NMHub/main/Modules/Flight.lua"))()(env)
	local InfiniteJump = loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/NMHub/main/Modules/InfiniteJump.lua"))()(env)

	return {
		NoClip = NoClip,
		Flight = Flight,
		InfiniteJump = InfiniteJump,
	}
end
