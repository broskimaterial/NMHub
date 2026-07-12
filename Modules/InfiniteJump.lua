return function(env)
	local Services = env.Services
	local Utilities = env.Utilities
	local Notify = env.Notify

	local InfiniteJump = {
		Enabled = false,
		InputBegan = nil,
		InputEnded = nil,
		JumpKeyDown = false,
	}

	function InfiniteJump:Enable()
		if self.Enabled then return end
		self.Enabled = true
		self.JumpKeyDown = false

		self.InputBegan = Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not InfiniteJump.Enabled then return end
			if gameProcessed then return end
			if input.KeyCode ~= Enum.KeyCode.Space then return end
			if InfiniteJump.JumpKeyDown then return end
			InfiniteJump.JumpKeyDown = true

			local char = Services.LocalPlayer.Character
			local hum = char and char:FindFirstChild("Humanoid")
			if not hum then return end

			local state = hum:GetState()
			if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end)
		table.insert(Utilities.Connections, self.InputBegan)

		self.InputEnded = Services.UserInputService.InputEnded:Connect(function(input, gameProcessed)
			if input.KeyCode == Enum.KeyCode.Space then
				InfiniteJump.JumpKeyDown = false
			end
		end)
		table.insert(Utilities.Connections, self.InputEnded)

		Notify("Air Jump Enabled", "Infinite jump active — press Space mid-air for extra jumps", 3, "arrow-up")
	end

	function InfiniteJump:Disable()
		if not self.Enabled then return end
		self.Enabled = false
		if self.InputBegan then
			Utilities.CleanupConnection(self.InputBegan)
			self.InputBegan = nil
		end
		if self.InputEnded then
			Utilities.CleanupConnection(self.InputEnded)
			self.InputEnded = nil
		end
		self.JumpKeyDown = false
		Notify("Air Jump Disabled", "Normal jumping restored", 3, "arrow-down")
	end

	function InfiniteJump:Cleanup()
		if self.Enabled then self:Disable() end
	end

	function InfiniteJump:Reset()
		self:Cleanup()
	end

	return InfiniteJump
end
