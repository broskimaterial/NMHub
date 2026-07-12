--[[
	NMHub — Loader
	=======================
	Paste this into your executor to load NMHub.
	
	NOTE: Replace brokimaterial below with your GitHub brokimaterial
	before using, or host the files on your own server.
]]

local BASE_URL = "https://raw.githubusercontent.com/brokimaterial/NMHub/main"

loadstring(game:HttpGet(BASE_URL .. "/Main.lua"))()
