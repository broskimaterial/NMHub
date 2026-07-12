return function()
	local entries = {}
	local MAX = 500

	local function add(level, message)
		table.insert(entries, {
			timestamp = tick(),
			level = level,
			message = tostring(message),
		})
		if #entries > MAX then
			table.remove(entries, 1)
		end
	end

	return {
		Info = function(msg) add("INFO", msg) end,
		Warning = function(msg) add("WARN", msg) end,
		Error = function(msg) add("ERROR", msg) end,
		Debug = function(msg) add("DEBUG", msg) end,
		GetEntries = function() return entries end,
		Clear = function() entries = {} end,
	}
end
