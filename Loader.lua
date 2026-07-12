--[[
	NMHub — Loader
	=======================
	Paste this into your executor to load NMHub.
	
	NOTE: Replace broskimaterial below with your GitHub broskimaterial
	before using, or host the files on your own server.
]]

local BASE_URL = "https://raw.githubusercontent.com/broskimaterial/NMHub/main"

loadstring(game:HttpGet(BASE_URL .. "/Main.lua"))()
