--[[
	NMHub — Loader
	=======================
	Paste this into your executor to load NMHub.
	
	NOTE: Replace USERNAME below with your GitHub username
	before using, or host the files on your own server.
]]

local BASE_URL = "https://raw.githubusercontent.com/USERNAME/NMHub/main"

loadstring(game:HttpGet(BASE_URL .. "/Main.lua"))()
