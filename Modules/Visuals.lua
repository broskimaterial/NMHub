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

	local function GetCharacterScreenBounds(character)
		local camera = Services.Workspace.CurrentCamera
		if not camera or not character then
			return 0, 0, 0, 0, 0, 0, false
		end

		local cf, size = character:GetBoundingBox()
		if not cf or not size or size.Magnitude == 0 then
			return 0, 0, 0, 0, 0, 0, false
		end

		local center = cf.Position
		local half = size / 2

		local corners = {
			center + Vector3.new(-half.X, -half.Y, -half.Z),
			center + Vector3.new( half.X, -half.Y, -half.Z),
			center + Vector3.new(-half.X,  half.Y, -half.Z),
			center + Vector3.new( half.X,  half.Y, -half.Z),
			center + Vector3.new(-half.X, -half.Y,  half.Z),
			center + Vector3.new( half.X, -half.Y,  half.Z),
			center + Vector3.new(-half.X,  half.Y,  half.Z),
			center + Vector3.new( half.X,  half.Y,  half.Z),
		}

		local minX, minY = math.huge, math.huge
		local maxX, maxY = -math.huge, -math.huge
		local anyOnScreen = false

		for _, corner in ipairs(corners) do
			local point, onScreen = camera:WorldToViewportPoint(corner)
			if onScreen then
				anyOnScreen = true
			end
			minX = math.min(minX, point.X)
			minY = math.min(minY, point.Y)
			maxX = math.max(maxX, point.X)
			maxY = math.max(maxY, point.Y)
		end

		if not anyOnScreen then
			return 0, 0, 0, 0, 0, 0, false
		end

		local width = maxX - minX
		local height = maxY - minY

		if width < 1 or height < 1 then
			return 0, 0, 0, 0, 0, 0, false
		end

		return minX, minY, maxX, maxY, width, height, true
	end

	local ESP = {
		Enabled = false,
		Connection = nil,
		PlayerAddedConn = nil,
		PlayerRemovingConn = nil,
		PlayerDrawings = {},
		HighlightInstances = {},
		FrameCounter = 0,
		PlayerList = {},
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
			LineThickness = 1,
			MaxDistance = 5000,
			RefreshRate = 1,
			Outline = false,
			TextOutline = true,
			Transparency = 1,
			TextSize = 14,
			TracerOrigin = "Bottom",
			DistanceFade = false,
			FriendColor = nil,
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
		for _ = 1, 8 do
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
		if self.Settings.FriendColor and player:IsFriendsWith(Services.LocalPlayer.UserId) then
			return self.Settings.FriendColor
		end
		if player.Team and player.TeamColor then
			return player.TeamColor.Color
		end
		return Color3.fromRGB(255, 255, 255)
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

		self.FrameCounter = self.FrameCounter + 1
		if self.FrameCounter % self.Settings.RefreshRate ~= 0 then
			return
		end

		local thickness = self.Settings.LineThickness
		local maxDist = self.Settings.MaxDistance
		local useOutline = self.Settings.Outline
		local useTextOutline = self.Settings.TextOutline
		local baseTransparency = self.Settings.Transparency
		local textSize = self.Settings.TextSize
		local tracerOrigin = self.Settings.TracerOrigin
		local localPlayer = Services.LocalPlayer
		local playerList = self.PlayerList

		for idx = 1, #playerList do
			local player = playerList[idx]
			repeat
				if player == localPlayer then break end

				local char = player.Character
				if not char then
					if self.PlayerDrawings[player] then
						self:HidePlayerDrawings(player)
					end
					break
				end

				local head = char:FindFirstChild("Head")
				local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")

				if root then
					local _, rootOnScreen = camera:WorldToViewportPoint(root.Position)
					if not rootOnScreen then
						if self.PlayerDrawings[player] then
							self:HidePlayerDrawings(player)
						end
						break
					end
				end

				local minX, minY, maxX, maxY, boxWidth, boxHeight, visible = GetCharacterScreenBounds(char)
				if not visible then
					if self.PlayerDrawings[player] then
						self:HidePlayerDrawings(player)
					end
					break
				end

				local color = self:GetPlayerColor(player)
				local displayColor = Color3.fromRGB(
					math.floor(color.R * 255),
					math.floor(color.G * 255),
					math.floor(color.B * 255)
				)

				local d = self.PlayerDrawings[player]
				if not d then break end

				if self.Settings.Box then
					d.Box.Size = Vector2.new(boxWidth, boxHeight)
					d.Box.Position = Vector2.new(minX, minY)
					d.Box.Color = displayColor
					d.Box.Transparency = baseTransparency
					d.Box.Thickness = thickness
					d.Box.Filled = useOutline
					d.Box.Visible = true
				else
					d.Box.Visible = false
				end

				if self.Settings.CornerBox then
					local corners = self:GetCornerBoxLines(minX, minY, boxWidth, boxHeight)
					for i = 1, 8 do
						local line = d.CornerBox[i]
						if line then
							local corner = corners[i]
							if corner then
								line.From = Vector2.new(corner[1], corner[2])
								line.To = Vector2.new(corner[3], corner[4])
							end
							line.Color = displayColor
							line.Thickness = thickness
							line.Transparency = baseTransparency
							line.Visible = true
						end
					end
				else
					for i = 1, #d.CornerBox do
						d.CornerBox[i].Visible = false
					end
				end

				if self.Settings.Name then
					d.Name.Position = Vector2.new(minX + boxWidth / 2, minY - 14)
					d.Name.Text = player.Name
					d.Name.Color = displayColor
					d.Name.Size = textSize
					d.Name.Outline = useTextOutline
					d.Name.Visible = true
				else
					d.Name.Visible = false
				end

				if self.Settings.Distance and root then
					local dist = (camera.CFrame.Position - root.Position).Magnitude
					if dist > maxDist then
						d.Distance.Visible = false
					else
						d.Distance.Position = Vector2.new(minX + boxWidth / 2, maxY + 2)
						d.Distance.Text = math.floor(dist) .. "s"
						d.Distance.Color = displayColor
						d.Distance.Size = textSize
						d.Distance.Outline = useTextOutline
						d.Distance.Visible = true
					end
				else
					d.Distance.Visible = false
				end

				if self.Settings.Health then
					local hum = char:FindFirstChild("Humanoid")
					local healthStr = "?"
					local healthPct = 1
					if hum then
						healthStr = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
						healthPct = hum.Health / hum.MaxHealth
					end
					local healthColor = Color3.fromRGB(
						math.floor(255 * (1 - healthPct)),
						math.floor(255 * healthPct),
						0
					)
					d.Health.Position = Vector2.new(maxX + 4, minY + boxHeight / 2 - 6)
					d.Health.Text = healthStr
					d.Health.Size = textSize
					d.Health.Color = healthColor
					d.Health.Outline = useTextOutline
					d.Health.Visible = true

					d.HealthBar.Size = Vector2.new(4, boxHeight)
					d.HealthBar.Position = Vector2.new(minX - 6, minY)
					d.HealthBar.Color = healthColor
					d.HealthBar.Visible = true
				else
					d.Health.Visible = false
					d.HealthBar.Visible = false
				end

				if self.Settings.Tracers and root then
					local rootVec = camera:WorldToViewportPoint(root.Position)
					local screenSize = camera.ViewportSize
					if tracerOrigin == "Crosshair" then
						d.Tracer.From = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
					elseif tracerOrigin == "Mouse" then
						local mousePos = Services.UserInputService:GetMouseLocation()
						d.Tracer.From = Vector2.new(mousePos.X, mousePos.Y)
					else
						d.Tracer.From = Vector2.new(screenSize.X / 2, screenSize.Y)
					end
					d.Tracer.To = Vector2.new(rootVec.X, rootVec.Y)
					d.Tracer.Color = displayColor
					d.Tracer.Thickness = thickness
					d.Tracer.Transparency = baseTransparency
					d.Tracer.Visible = true
				else
					d.Tracer.Visible = false
				end

				if self.Settings.HeadDot and head then
					local headVec = camera:WorldToViewportPoint(head.Position)
					d.HeadDot.Position = Vector2.new(headVec.X, headVec.Y)
					d.HeadDot.Color = displayColor
					d.HeadDot.Visible = true
				else
					d.HeadDot.Visible = false
				end

				if self.Settings.Skeleton then
					local isR6 = char:FindFirstChild("Torso") ~= nil
					local bones = isR6 and SkeletonBonesR6 or SkeletonBones
					local boneList = d.Skeleton
					for i = 1, #bones do
						local bonePair = bones[i]
						local part1 = char:FindFirstChild(bonePair[1])
						local part2 = char:FindFirstChild(bonePair[2])
						if part1 and part2 then
							local p1 = camera:WorldToViewportPoint(part1.Position)
							local p2 = camera:WorldToViewportPoint(part2.Position)
							if boneList[i] then
								boneList[i].From = Vector2.new(p1.X, p1.Y)
								boneList[i].To = Vector2.new(p2.X, p2.Y)
								boneList[i].Color = displayColor
								boneList[i].Thickness = thickness
								boneList[i].Transparency = baseTransparency
								boneList[i].Visible = true
							end
						elseif boneList[i] then
							boneList[i].Visible = false
						end
					end
				else
					for i = 1, #d.Skeleton do
						d.Skeleton[i].Visible = false
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
			until true
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

		self.PlayerList = {}
		for _, player in pairs(Services.Players:GetPlayers()) do
			if player ~= Services.LocalPlayer then
				self.PlayerList[#self.PlayerList + 1] = player
				self:CreatePlayerDrawings(player)
			end
		end

		self.PlayerAddedConn = Services.Players.PlayerAdded:Connect(function(player)
			if player ~= Services.LocalPlayer then
				self.PlayerList[#self.PlayerList + 1] = player
				ESP:CreatePlayerDrawings(player)
			end
		end)
		table.insert(Utilities.Connections, self.PlayerAddedConn)

		self.PlayerRemovingConn = Services.Players.PlayerRemoving:Connect(function(player)
			local list = self.PlayerList
			for i = #list, 1, -1 do
				if list[i] == player then
					table.remove(list, i)
					break
				end
			end
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
