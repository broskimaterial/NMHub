return function(env)
	local Services = env.Services
	local Logger = env.Logger
	local frameTimes = {}
	local fpsUpdate = 0
	local currentFps = 0
	local currentPing = 0

	local function GetFps()
		fpsUpdate = fpsUpdate + 1
		if fpsUpdate >= 30 then
			local total = 0
			for _, t in ipairs(frameTimes) do
				total = total + t
			end
			currentFps = #frameTimes > 0 and math.floor(1 / (total / #frameTimes)) or 0
			frameTimes = {}
			fpsUpdate = 0
		end
		return currentFps
	end

	local heartbeat
	heartbeat = Services.RunService.Heartbeat:Connect(function(dt)
		table.insert(frameTimes, dt)
		if #frameTimes > 60 then
			table.remove(frameTimes, 1)
		end
	end)
	table.insert(Services._connections or {}, heartbeat)

	return {
		Collect = function()
			return {
				Version = env.Version or "0.0.0",
				Build = env.Build or 0,
				FPS = GetFps(),
				Ping = math.floor(Services.Players:GetNetworkPing() * 1000),
				Memory = collectgarbage("count"),
			}
		end,
	}
end
