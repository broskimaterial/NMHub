return function(env)
	local Services = env.Services
	local Utilities = env.Utilities
	local Notify = env.Notify

	local SkeletonBones = {
		{"Head", "UpperTorso"},
		{"UpperTorso", "LowerTorso"},
		{"LowerTorso", "HumanoidRootPart"},
		{"UpperTorso", "LeftUpperArm"},
		{"LeftUpperArm", "LeftLowerArm"},
		{"LeftLowerArm", "LeftHand"},
		{"UpperTorso", "RightUpperArm"},
		{"RightUpperArm", "RightLowerArm"},
		{"RightLowerArm", "RightHand"},
		{"LowerTorso", "LeftUpperLeg"},
		{"LeftUpperLeg", "LeftLowerLeg"},
		{"LeftLowerLeg", "LeftFoot"},
		{"LowerTorso", "RightUpperLeg"},
		{"RightUpperLeg", "RightLowerLeg"},
		{"RightLowerLeg", "RightFoot"},
	}

	local SkeletonBonesR6 = {
		{"Head", "Torso"},
		{"Torso", "HumanoidRootPart"},
		{"Torso", "Left Arm"},
		{"Torso", "Right Arm"},
		{"Torso", "Left Leg"},
		{"Torso", "Right Leg"},
	}

	local ESP = {
		Enabled = false,
		Connection = nil,
		PlayerAddedConn = nil,
		PlayerRemovingConn = nil,
		PlayerDrawings = {},
		HighlightInstances = {},
		Settings = {
			Box = false,
			CornerBox = false,
			Name = false,
			Distance = false,
			Health = false,
			Skeleton = false,
			Tracers = false,
			HeadDot = false,
			Chams = false,
		},
	}

	function ESP:CreatePlayerDrawings(player)
		if self.PlayerDrawings[player] then
			self:DestroyPlayerDrawings(player)
		end
		local d = {}

		local success = pcall(Drawing.new, "Square")
		if not success then return end

		d.Box = Drawing.new("Square")
		d.Box.Visible = false
		d.Box.Thickness = 1
		d.Box.Filled = false
		d.Box.Color = Color3.fromRGB(255, 255, 255)
		d.Box.Transparency = 1

		d.CornerBox = {}
		for _ = 1, 4 do
			local line = Drawing.new("Line")
			line.Visible = false
			line.Thickness = 1
			line.Color = Color3.fromRGB(255, 255, 255)
			line.Transparency = 1
			table.insert(d.CornerBox, line)
		end

		d.Name = Drawing.new("Text")
		d.Name.Visible = false
		d.Name.Center = true
		d.Name.Size = 14
		d.Name.Color = Color3.fromRGB(255, 255, 255)
		d.Name.Outline = true
		d.Name.OutlineColor = Color3.fromRGB(0, 0, 0)

		d.Distance = Drawing.new("Text")
		d.Distance.Visible = false
		d.Distance.Center = true
		d.Distance.Size = 12
		d.Distance.Color = Color3.fromRGB(255, 255, 200)
		d.Distance.Outline = true
		d.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)

		d.Health = Drawing.new("Text")
		d.Health.Visible = false
		d.Health.Center = true
		d.Health.Size = 12
		d.Health.Color = Color3.fromRGB(0, 255, 0)
		d.Health.Outline = true
		d.Health.OutlineColor = Color3.fromRGB(0, 0, 0)

		d.HealthBar = Drawing.new("Square")
		d.HealthBar.Visible = false
		d.HealthBar.Thickness = 1
		d.HealthBar.Filled = true
		d.HealthBar.Color = Color3.fromRGB(0, 255, 0)

		d.Tracer = Drawing.new("Line")
		d.Tracer.Visible = false
		d.Tracer.Thickness = 1
		d.Tracer.Color = Color3.fromRGB(255, 255, 255)
		d.Tracer.Transparency = 1

		d.HeadDot = Drawing.new("Circle")
		d.HeadDot.Visible = false
		d.HeadDot.Filled = true
		d.HeadDot.Thickness = 1
		d.HeadDot.NumSides = 12
		d.HeadDot.Radius = 4
		d.HeadDot.Color = Color3.fromRGB(255, 255, 255)

		d.Skeleton = {}
		for _ = 1, #SkeletonBones do
			local line = Drawing.new("Line")
			line.Visible = false
			line.Thickness = 1
			line.Color = Color3.fromRGB(255, 255, 255)
			line.Transparency = 1
			table.insert(d.Skeleton, line)
		end

		d.Chams = nil

		self.PlayerDrawings[player] = d
	end

	function ESP:DestroyPlayerDrawings(player)
		local d = self.PlayerDrawings[player]
		if not d then return end

		if d.Box then d.Box:Remove() end
		if d.CornerBox then
			for _, line in pairs(d.CornerBox) do
				if line then line:Remove() end
			end
		end
		if d.Name then d.Name:Remove() end
		if d.Distance then d.Distance:Remove() end
		if d.Health then d.Health:Remove() end
		if d.HealthBar then d.HealthBar:Remove() end
		if d.Tracer then d.Tracer:Remove() end
		if d.HeadDot then d.HeadDot:Remove() end
		if d.Skeleton then
			for _, line in pairs(d.Skeleton) do
				if line then line:Remove() end
			end
		end
		if d.Chams then
			Utilities.CleanupInstance(d.Chams)
		end

		self.PlayerDrawings[player] = nil
	end

	function ESP:HidePlayerDrawings(player)
		local d = self.PlayerDrawings[player]
		if not d then return end
		d.Box.Visible = false
		d.Name.Visible = false
		d.Distance.Visible = false
		d.Health.Visible = false
		d.HealthBar.Visible = false
		d.Tracer.Visible = false
		d.HeadDot.Visible = false
		for _, line in pairs(d.Skeleton) do
			line.Visible = false
		end
		for _, line in pairs(d.CornerBox) do
			line.Visible = false
		end
	end

	function ESP:DestroyAllPlayerDrawings()
		for player in pairs(self.PlayerDrawings) do
			self:DestroyPlayerDrawings(player)
		end
		table.clear(self.PlayerDrawings)
	end

	function ESP:DestroyHighlightInstances()
		for _, instance in pairs(self.HighlightInstances) do
			Utilities.CleanupInstance(instance)
		end
		table.clear(self.HighlightInstances)
	end

	function ESP:GetPlayerColor(player)
		if player.Team and player.TeamColor then
			return player.TeamColor.Color
		end
		return Color3.fromRGB(255, 255, 255)
	end

	function ESP:IsOnScreen(worldPos)
		local camera = Services.Workspace.CurrentCamera
		if not camera then return false, nil end
		local vec, onScreen = camera:WorldToViewportPoint(worldPos)
		return vec, onScreen
	end

	function ESP:GetCornerBoxLines(x, y, w, h, size)
		size = size or math.min(w, h) * 0.2
		if size > 10 then size = 10 end
		return {
			{x, y, x + size, y},
			{x, y, x, y + size},
			{x + w, y, x + w - size, y},
			{x + w, y, x + w, y + size},
			{x, y + h, x + size, y + h},
			{x, y + h, x, y + h - size},
			{x + w, y + h, x + w - size, y + h},
			{x + w, y + h, x + w, y + h - size},
		}
	end

	function ESP:Update()
		if not self.Enabled then return end

		local camera = Services.Workspace.CurrentCamera
		if not camera then return end

		for _, player in pairs(Services.Players:GetPlayers()) do
			if player == Services.LocalPlayer then continue end

			local char = player.Character
			if not char then
				if self.PlayerDrawings[player] then
					self:HidePlayerDrawings(player)
				end
				continue
			end

			local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
			local head = char:FindFirstChild("Head")
			if not root or not head then
				if self.PlayerDrawings[player] then
					self:HidePlayerDrawings(player)
				end
				continue
			end

			local color = self:GetPlayerColor(player)

			local headPos, headOnScreen = self:IsOnScreen(head.Position)
			local rootPos, rootOnScreen = self:IsOnScreen(root.Position)
			if not headOnScreen and not rootOnScreen then
				if self.PlayerDrawings[player] then
					self:HidePlayerDrawings(player)
				end
				continue
			end

			local dist = (camera.CFrame.Position - root.Position).Magnitude
			local d = self.PlayerDrawings[player]
			if not d then continue end

			-- Calculate box using actual projected body bounds (head to feet)
			local screenHeight = (rootPos.Y - headPos.Y) * 2
			local boxHeight = math.max(screenHeight, 20)
			local boxWidth = boxHeight * 0.55
			local boxPos = Vector2.new(rootPos.X - boxWidth / 2, headPos.Y)
			local boxSize = Vector2.new(boxWidth, boxHeight)

			local displayColor = Color3.fromRGB(
				math.floor(color.R * 255),
				math.floor(color.G * 255),
				math.floor(color.B * 255)
			)

			if self.Settings.Box then
				d.Box.Size = boxSize
				d.Box.Position = boxPos
				d.Box.Color = displayColor
				d.Box.Transparency = 1
				d.Box.Visible = true
			else
				d.Box.Visible = false
			end

			if self.Settings.CornerBox then
				local corners = self:GetCornerBoxLines(boxPos.X, boxPos.Y, boxSize.X, boxSize.Y)
				for i, line in pairs(d.CornerBox) do
					local corner = corners[i]
					if corner then
						line.From = Vector2.new(corner[1], corner[2])
						line.To = Vector2.new(corner[3], corner[4])
						line.Color = displayColor
						line.Transparency = 1
						line.Visible = true
					end
				end
			else
				for _, line in pairs(d.CornerBox) do
					line.Visible = false
				end
			end

			if self.Settings.Name then
				d.Name.Position = Vector2.new(boxPos.X + boxSize.X / 2, boxPos.Y - 14)
				d.Name.Text = player.Name
				d.Name.Color = displayColor
				d.Name.Visible = true
			else
				d.Name.Visible = false
			end

			if self.Settings.Distance then
				d.Distance.Position = Vector2.new(boxPos.X + boxSize.X / 2, boxPos.Y + boxSize.Y + 2)
				d.Distance.Text = tostring(math.floor(dist)) .. " studs"
				d.Distance.Color = displayColor
				d.Distance.Visible = true
			else
				d.Distance.Visible = false
			end

			if self.Settings.Health then
				local hum = char:FindFirstChild("Humanoid")
				local healthStr = "?"
				local healthPct = 1
				if hum then
					healthStr = tostring(math.floor(hum.Health)) .. "/" .. tostring(math.floor(hum.MaxHealth))
					healthPct = hum.Health / hum.MaxHealth
				end
				d.Health.Position = Vector2.new(boxPos.X + boxSize.X + 4, boxPos.Y + boxSize.Y / 2 - 6)
				d.Health.Text = healthStr
				d.Health.Color = Color3.fromRGB(
					math.floor(255 * (1 - healthPct)),
					math.floor(255 * healthPct),
					0
				)
				d.Health.Visible = true

				d.HealthBar.Size = Vector2.new(4, boxSize.Y)
				d.HealthBar.Position = Vector2.new(boxPos.X - 6, boxPos.Y)
				d.HealthBar.Color = Color3.fromRGB(
					math.floor(255 * (1 - healthPct)),
					math.floor(255 * healthPct),
					0
				)
				d.HealthBar.Visible = true
			else
				d.Health.Visible = false
				d.HealthBar.Visible = false
			end

			if self.Settings.Tracers then
				local screenSize = camera.ViewportSize
				d.Tracer.From = Vector2.new(screenSize.X / 2, screenSize.Y)
				d.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
				d.Tracer.Color = displayColor
				d.Tracer.Transparency = 1
				d.Tracer.Visible = true
			else
				d.Tracer.Visible = false
			end

			if self.Settings.HeadDot then
				local headScreen = self:IsOnScreen(head.Position)
				d.HeadDot.Position = Vector2.new(headScreen.X, headScreen.Y)
				d.HeadDot.Color = displayColor
				d.HeadDot.Visible = true
			else
				d.HeadDot.Visible = false
			end

			if self.Settings.Skeleton then
				local isR6 = char:FindFirstChild("Torso") ~= nil
				local bones = isR6 and SkeletonBonesR6 or SkeletonBones
				for i, bonePair in pairs(bones) do
					local part1 = char:FindFirstChild(bonePair[1])
					local part2 = char:FindFirstChild(bonePair[2])
					if part1 and part2 then
						local p1, onScreen1 = self:IsOnScreen(part1.Position)
						local p2, onScreen2 = self:IsOnScreen(part2.Position)
						if onScreen1 and onScreen2 and d.Skeleton[i] then
							d.Skeleton[i].From = Vector2.new(p1.X, p1.Y)
							d.Skeleton[i].To = Vector2.new(p2.X, p2.Y)
							d.Skeleton[i].Color = displayColor
							d.Skeleton[i].Transparency = 1
							d.Skeleton[i].Visible = true
						elseif d.Skeleton[i] then
							d.Skeleton[i].Visible = false
						end
					elseif d.Skeleton[i] then
						d.Skeleton[i].Visible = false
					end
				end
			else
				for _, line in pairs(d.Skeleton) do
					line.Visible = false
				end
			end

			if self.Settings.Chams then
				if not d.Chams or not d.Chams.Parent then
					local highlight = Instance.new("Highlight")
					highlight.Adornee = char
					highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					highlight.FillColor = displayColor
					highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
					highlight.FillTransparency = 0.5
					highlight.Parent = Services.CoreGui
					d.Chams = highlight
					table.insert(self.HighlightInstances, highlight)
				else
					d.Chams.Adornee = char
				end
			elseif d.Chams then
				Utilities.CleanupInstance(d.Chams)
				d.Chams = nil
			end
		end
	end

	function ESP:Enable()
		if self.Enabled then return end
		self.Enabled = true

		local drawSuccess = pcall(Drawing.new, "Square")
		if not drawSuccess then
			Notify("ESP Warning", "Drawing API unavailable — ESP features may not render", 5, "alert-triangle")
		else
			local testSquare = Drawing.new("Square")
			testSquare:Remove()
		end

		for _, player in pairs(Services.Players:GetPlayers()) do
			if player ~= Services.LocalPlayer then
				self:CreatePlayerDrawings(player)
			end
		end

		self.PlayerAddedConn = Services.Players.PlayerAdded:Connect(function(player)
			ESP:CreatePlayerDrawings(player)
		end)
		table.insert(Utilities.Connections, self.PlayerAddedConn)

		self.PlayerRemovingConn = Services.Players.PlayerRemoving:Connect(function(player)
			ESP:DestroyPlayerDrawings(player)
		end)
		table.insert(Utilities.Connections, self.PlayerRemovingConn)

		self.Connection = Services.RunService.RenderStepped:Connect(function()
			ESP:Update()
		end)
		table.insert(Utilities.Connections, self.Connection)

		Notify("ESP Enabled", "Visual enhancements activated", 3, "eye")
	end

	function ESP:Disable()
		if not self.Enabled then return end
		self.Enabled = false

		if self.Connection then
			Utilities.CleanupConnection(self.Connection)
			self.Connection = nil
		end
		if self.PlayerAddedConn then
			Utilities.CleanupConnection(self.PlayerAddedConn)
			self.PlayerAddedConn = nil
		end
		if self.PlayerRemovingConn then
			Utilities.CleanupConnection(self.PlayerRemovingConn)
			self.PlayerRemovingConn = nil
		end

		self:DestroyAllPlayerDrawings()
		self:DestroyHighlightInstances()

		Notify("ESP Disabled", "Visual enhancements deactivated", 3, "eye-off")
	end

	function ESP:Cleanup()
		if self.Enabled then self:Disable() end
	end

	function ESP:Reset()
		self:Cleanup()
	end

	return ESP
end
