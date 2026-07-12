return function(Rayfield)
	local enabled = true

	local function Notify(title, content, duration, image)
		if not enabled then return end
		Rayfield:Notify({
			Title = title,
			Content = content,
			Duration = duration or 4,
			Image = image or "info",
		})
	end

	local function RawNotify(data)
		Rayfield:Notify(data)
	end

	local function SetEnabled(value)
		enabled = value
	end

	return {
		Notify = Notify,
		RawNotify = RawNotify,
		SetEnabled = SetEnabled,
	}
end
