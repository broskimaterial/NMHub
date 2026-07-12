return function(env)
	local BASE_URL = env.BASE_URL or ""
	local Logger = env.Logger
	local loaded = {}
	local pluginList = {}

	local function LoadFromUrl(url)
		local s, content = pcall(function()
			return game:HttpGet(url)
		end)
		if not s then return nil end
		local ok, plugin = pcall(loadstring, content)
		if not ok or not plugin then return nil end
		local ok2, instance = pcall(plugin, env)
		if not ok2 or not instance or not instance.Name then return nil end
		return instance
	end

	local function ScanAndLoad()
		local s, indexData = pcall(function()
			return game:HttpGet(BASE_URL .. "/plugins.json")
		end)
		if not s then
			if Logger then Logger.Warning("Plugin index not found") end
			return
		end

		local ok, entries = pcall(function()
			return game:GetService("HttpService"):JSONDecode(indexData)
		end)
		if not ok or type(entries) ~= "table" then
			if Logger then Logger.Warning("Invalid plugin index") end
			return
		end

		for _, entry in ipairs(entries) do
			local url = entry.url or (BASE_URL .. "/Plugins/" .. entry.file)
			local instance = LoadFromUrl(url)
			if instance then
				pluginList[#pluginList + 1] = instance
				loaded[instance.Name] = instance

				if instance.Init and env.Hub then
					pcall(instance.Init, env.Hub)
				end

				if Logger then
					Logger.Info("Plugin loaded: " .. instance.Name .. " v" .. (instance.Version or "?") .. " by " .. (instance.Author or "unknown"))
				end
			elseif Logger then
				Logger.Warning("Failed to load plugin: " .. (entry.name or entry.file or "unknown"))
			end
		end
	end

	return {
		LoadAll = ScanAndLoad,
		GetPlugins = function() return loaded end,
		GetList = function() return pluginList end,
		GetCount = function()
			local n = 0
			for _ in pairs(loaded) do n = n + 1 end
			return n
		end,
		CleanupAll = function()
			for _, plugin in ipairs(pluginList) do
				if plugin.Cleanup then
					pcall(plugin.Cleanup)
				end
			end
			for k in pairs(loaded) do loaded[k] = nil end
			for i = #pluginList, 1, -1 do pluginList[i] = nil end
		end,
	}
end
