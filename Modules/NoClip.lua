return function(env)
	local Services = env.Services
	local Utilities = env.Utilities
	local Notify = env.Notify

	local NoClip = { Enabled = false, Connection = nil }

	function NoClip:Enable()
		if self.Enabled then return end
		local character = Services.LocalPlayer.Character
		if not character then return end
		self.Enabled = true

		Utilities.SaveOriginalCollisions(character)
		self.Connection = Services.RunService.Stepped:Connect(function()
			if not NoClip.Enabled then return end
			local char = Services.LocalPlayer.Character
			if not char then return end
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end)
		table.insert(Utilities.Connections, self.Connection)
		Notify("NoClip Enabled", "Collision disabled for character", 3, "unlock")
	end

	function NoClip:Disable()
		if not self.Enabled then return end
		self.Enabled = false
		if self.Connection then
			Utilities.CleanupConnection(self.Connection)
			self.Connection = nil
		end
		local character = Services.LocalPlayer.Character
		if character then
			Utilities.RestoreCollisions(character)
		end
		Notify("NoClip Disabled", "Collision restored for character", 3, "lock")
	end

	function NoClip:Cleanup()
		if self.Enabled then self:Disable() end
	end

	function NoClip:Reset()
		self:Cleanup()
	end

	return NoClip
end
