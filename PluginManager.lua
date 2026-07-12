return function(env)
	local BASE_URL = env.BASE_URL or ""
	local Logger = env.Logger
	local loaded = {}
	local statuses = {}

	local function ScanAndLoad()
		local pluginUrls = {
			BASE_URL .. "/Plugins/",
		}

		local urlIndex = 1
		while true do
			local url = pluginUrls[urlIndex]
			if not url then break end
			local success, files = pcall(function()
				return game:HttpGet(url)
			end)
			if success then
				for _, filename in pairs(files) do
					if filename:match("%.lua$") then
						local pluginUrl = url .. filename
						local ok, plugin = pcall(function()
							return loadstring(game:HttpGet(pluginUrl))()(env)
						end)
						if ok and plugin and plugin.Name then
							loaded[plugin.Name] = plugin
							statuses[plugin.Name] = "Loaded"
							if Logger then
								Logger.Info("Plugin loaded: " .. plugin.Name .. " v" .. (plugin.Version or "?"))
							end
						end
					end
				end
			end
			urlIndex = urlIndex + 1
		end
	end

	return {
		LoadAll = ScanAndLoad,
		GetPlugins = function() return loaded end,
		GetStatus = function(name) return statuses[name] end,
		GetCount = function()
			local count = 0
			for _ in pairs(loaded) do count = count + 1 end
			return count
		end,
		CleanupAll = function()
			for _, plugin in pairs(loaded) do
				if plugin.Cleanup then
					pcall(plugin.Cleanup)
				end
			end
		end,
	}
end
