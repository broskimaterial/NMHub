return function(env)
	local Services = env.Services
	local Utilities = env.Utilities
	local Notify = env.Notify

	local Hitbox = {
		Enabled = false,
		Connection = nil,
		Size = 5,
		OriginalSizes = {},
	}

	function Hitbox:SaveSizes(character)
		self.OriginalSizes = {}
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				self.OriginalSizes[part] = part.Size
			end
		end
	end

	function Hitbox:RestoreSizes()
		for part, size in pairs(self.OriginalSizes) do
			if part and part.Parent then
				part.Size = size
			end
		end
		self.OriginalSizes = {}
	end

	function Hitbox:Apply(character)
		if not character then return end
		local hs = self.Size
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				part.Size = part.Size * hs
			end
		end
	end

	function Hitbox:Enable()
		if self.Enabled then return end
		local character = Services.LocalPlayer.Character
		if not character then return end
		self.Enabled = true

		self:SaveSizes(character)
		self:Apply(character)

		self.Connection = Services.LocalPlayer.CharacterAdded:Connect(function(char)
			task.wait(0.1)
			if Hitbox.Enabled then
				Hitbox:SaveSizes(char)
				Hitbox:Apply(char)
			end
		end)
		table.insert(Utilities.Connections, self.Connection)

		Notify("Hitbox Enabled", "Hitbox size set to " .. self.Size .. "x", 3, "maximize")
	end

	function Hitbox:Disable()
		if not self.Enabled then return end
		self.Enabled = false
		if self.Connection then
			Utilities.CleanupConnection(self.Connection)
			self.Connection = nil
		end
		self:RestoreSizes()
		Notify("Hitbox Disabled", "Original hitbox sizes restored", 3, "minimize")
	end

	function Hitbox:Cleanup()
		if self.Enabled then self:Disable() end
	end

	function Hitbox:Reset()
		self:Cleanup()
	end

	return Hitbox
end
