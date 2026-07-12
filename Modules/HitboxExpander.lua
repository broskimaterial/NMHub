return function(env)
	local Players = env.Services.Players
	local LocalPlayer = env.Services.LocalPlayer
	local Utilities = env.Utilities
	local Notify = env.Notify

	local function FindTargetParts(character, targetType)
		if not character then return {} end
		if targetType == "All" then
			local parts = {}
			for _, v in pairs(character:GetDescendants()) do
				if v:IsA("BasePart") then
					parts[#parts + 1] = v
				end
			end
			return parts
		end
		local part = character:FindFirstChild(targetType)
		return part and { part } or {}
	end

	local function SavePartState(self, part)
		if self.ModifiedParts[part] then return end
		self.ModifiedParts[part] = {
			Size = part.Size,
			Transparency = part.Transparency,
			CanCollide = part.CanCollide,
		}
	end

	local function RestorePart(self, part)
		local state = self.ModifiedParts[part]
		if not state then return end
		if part.Parent then
			part.Size = state.Size
			part.Transparency = state.Transparency
			part.CanCollide = state.CanCollide
		end
		self.ModifiedParts[part] = nil
	end

	local function ApplyToCharacter(self, character)
		if not character then return end
		local parts = FindTargetParts(character, self.TargetPart)
		for i = 1, #parts do
			local part = parts[i]
			SavePartState(self, part)
			part.Size = part.Size * self.Size
			part.Transparency = self.Transparency
		end
	end

	local function ApplyToPlayer(self, player)
		if player == LocalPlayer then return end
		local char = player.Character
		if not char then return end
		if not char:FindFirstChild("Humanoid") then return end
		ApplyToCharacter(self, char)
	end

	local HitboxExpander = {
		Enabled = false,
		Size = 2,
		Transparency = 0,
		TargetPart = "HumanoidRootPart",
		ModifiedParts = {},
		PlayerList = {},
		PlayerData = {},
		PlayerAddedConn = nil,
		PlayerRemovingConn = nil,
	}

	function HitboxExpander:ApplyToAll()
		local list = self.PlayerList
		for i = 1, #list do
			ApplyToPlayer(self, list[i])
		end
	end

	function HitboxExpander:Enable()
		if self.Enabled then return end
		self.Enabled = true

		self.PlayerList = {}
		self.PlayerData = {}

		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				self.PlayerList[#self.PlayerList + 1] = player
				local conn = player.CharacterAdded:Connect(function(char)
					task.wait()
					if not HitboxExpander.Enabled then return end
					ApplyToCharacter(HitboxExpander, char)
				end)
				table.insert(Utilities.Connections, conn)
				self.PlayerData[player] = conn
				ApplyToPlayer(self, player)
			end
		end

		self.PlayerAddedConn = Players.PlayerAdded:Connect(function(player)
			if player == LocalPlayer then return end
			HitboxExpander.PlayerList[#HitboxExpander.PlayerList + 1] = player
			local conn = player.CharacterAdded:Connect(function(char)
				task.wait()
				if not HitboxExpander.Enabled then return end
				ApplyToCharacter(HitboxExpander, char)
			end)
			table.insert(Utilities.Connections, conn)
			HitboxExpander.PlayerData[player] = conn
			ApplyToPlayer(HitboxExpander, player)
		end)
		table.insert(Utilities.Connections, self.PlayerAddedConn)

		self.PlayerRemovingConn = Players.PlayerRemoving:Connect(function(player)
			local conn = HitboxExpander.PlayerData[player]
			if conn then
				Utilities.CleanupConnection(conn)
				HitboxExpander.PlayerData[player] = nil
			end
			local list = HitboxExpander.PlayerList
			for i = #list, 1, -1 do
				if list[i] == player then
					table.remove(list, i)
					break
				end
			end
		end)
		table.insert(Utilities.Connections, self.PlayerRemovingConn)

		Notify("Hitbox Expander Enabled", "Hitbox size set to " .. self.Size .. "x", 3, "maximize")
	end

	function HitboxExpander:Disable()
		if not self.Enabled then return end
		self.Enabled = false

		if self.PlayerAddedConn then
			Utilities.CleanupConnection(self.PlayerAddedConn)
			self.PlayerAddedConn = nil
		end
		if self.PlayerRemovingConn then
			Utilities.CleanupConnection(self.PlayerRemovingConn)
			self.PlayerRemovingConn = nil
		end

		for player, conn in pairs(self.PlayerData) do
			Utilities.CleanupConnection(conn)
		end
		self.PlayerData = {}

		local parts = {}
		for part in pairs(self.ModifiedParts) do
			parts[#parts + 1] = part
		end
		for i = 1, #parts do
			RestorePart(self, parts[i])
		end
		self.PlayerList = {}

		Notify("Hitbox Expander Disabled", "Original hitbox sizes restored", 3, "minimize")
	end

	function HitboxExpander:SetEnabled(value)
		if value then self:Enable() else self:Disable() end
	end

	function HitboxExpander:SetSize(value)
		if value == self.Size then return end
		self.Size = value
		if not self.Enabled then return end
		self:ApplyToAll()
	end

	function HitboxExpander:SetTransparency(value)
		if value == self.Transparency then return end
		self.Transparency = value
		if not self.Enabled then return end
		self:ApplyToAll()
	end

	function HitboxExpander:SetTargetPart(value)
		if value == self.TargetPart then return end
		self.TargetPart = value
		if not self.Enabled then return end
		local parts = {}
		for part in pairs(self.ModifiedParts) do
			parts[#parts + 1] = part
		end
		for i = 1, #parts do
			RestorePart(self, parts[i])
		end
		self:ApplyToAll()
	end

	function HitboxExpander:Destroy()
		self:Disable()
	end

	function HitboxExpander:Cleanup()
		if self.Enabled then self:Disable() end
	end

	function HitboxExpander:Reset()
		self:Cleanup()
	end

	return HitboxExpander
end
