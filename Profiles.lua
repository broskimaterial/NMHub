return function(env)
	local HttpService = game:GetService("HttpService")
	local profiles = {}
	local current = "Default"
	local folderName = "NMHub_Profiles"

	local function indexOf(tbl, val)
		for i, v in ipairs(tbl) do
			if v == val then return i end
		end
		return nil
	end

	local function ensureFolder()
		local s = pcall(function()
			return HttpService:JSONDecode(readfile(folderName .. "/index.json"))
		end)
		if not s then
			pcall(delfolder, folderName)
			pcall(createfolder, folderName)
			pcall(writefile, folderName .. "/index.json", HttpService:JSONEncode({ current = "Default" }))
		end
	end

	local function loadIndex()
		local s, d = pcall(function()
			return HttpService:JSONDecode(readfile(folderName .. "/index.json"))
		end)
		if s then
			current = d.current or "Default"
			profiles = d.profiles or { "Default" }
		end
	end

	local function saveIndex()
		pcall(writefile, folderName .. "/index.json", HttpService:JSONEncode({
			current = current,
			profiles = profiles,
		}))
	end

	local function saveProfile(name)
		pcall(writefile, folderName .. "/" .. name .. ".json", HttpService:JSONEncode({}))
	end

	local function loadProfile(name)
		local s, d = pcall(function()
			return HttpService:JSONDecode(readfile(folderName .. "/" .. name .. ".json"))
		end)
		return s and type(d) == "table"
	end

	pcall(ensureFolder)
	pcall(loadIndex)

	return {
		GetCurrent = function() return current end,
		GetProfiles = function() return profiles end,

		Switch = function(name)
			if name == current then return end
			pcall(saveProfile, current)
			current = name
			pcall(loadProfile, name)
			pcall(saveIndex)
		end,

		Create = function(name)
			if indexOf(profiles, name) then return false end
			table.insert(profiles, name)
			pcall(saveProfile, name)
			pcall(saveIndex)
			return true
		end,

		Delete = function(name)
			if name == "Default" then return false end
			local idx = indexOf(profiles, name)
			if not idx then return false end
			table.remove(profiles, idx)
			pcall(delfile, folderName .. "/" .. name .. ".json")
			if current == name then
				current = "Default"
				pcall(loadProfile, "Default")
			end
			pcall(saveIndex)
			return true
		end,

		Save = function() pcall(saveProfile, current) end,
	}
end
