return function(env)
	local Services = env.Services
	local Utilities = env.Utilities
	local Notify = env.Notify

	local Flight = {
		Enabled = false,
		Connection = nil,
		FlightVelocity = nil,
		FlightGyro = nil,
		Speed = 50,
		VerticalSpeed = 50,
		Acceleration = 0.15,
		Mode = "Smooth",
		SmoothTarget = Vector3.zero,
	}

	function Flight:Enable()
		if self.Enabled then return end
		local character = Services.LocalPlayer.Character
		local humanoid = character and character:FindFirstChild("Humanoid")
		local rootPart = character and character:FindFirstChild("HumanoidRootPart")
		if not character or not humanoid or not rootPart then
			self.Enabled = false
			return
		end
		self.Enabled = true

		humanoid.PlatformStand = true

		self.FlightVelocity = Instance.new("BodyVelocity")
		self.FlightVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		self.FlightVelocity.Velocity = Vector3.zero
		self.FlightVelocity.Parent = rootPart
		table.insert(Utilities.Instances, self.FlightVelocity)

		self.FlightGyro = Instance.new("BodyGyro")
		self.FlightGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		self.FlightGyro.P = 9000
		self.FlightGyro.D = 500
		self.FlightGyro.CFrame = rootPart.CFrame
		self.FlightGyro.Parent = rootPart
		table.insert(Utilities.Instances, self.FlightGyro)

		local uis = Services.UserInputService
		self.Connection = Services.RunService.RenderStepped:Connect(function(dt)
			if not Flight.Enabled then return end
			local char = Services.LocalPlayer.Character
			local rp = char and char:FindFirstChild("HumanoidRootPart")
			if not rp then return end

			local camera = Services.Workspace.CurrentCamera
			if not camera then return end

			local moveDir = Vector3.zero
			local cameraCFrame = camera.CFrame
			local speed = Flight.Speed
			local vertSpeed = Flight.VerticalSpeed

			if uis:IsKeyDown(Enum.KeyCode.W) then
				moveDir = moveDir + cameraCFrame.LookVector
			end
			if uis:IsKeyDown(Enum.KeyCode.S) then
				moveDir = moveDir - cameraCFrame.LookVector
			end
			if uis:IsKeyDown(Enum.KeyCode.A) then
				moveDir = moveDir - cameraCFrame.RightVector
			end
			if uis:IsKeyDown(Enum.KeyCode.D) then
				moveDir = moveDir + cameraCFrame.RightVector
			end
			if uis:IsKeyDown(Enum.KeyCode.Space) then
				moveDir = moveDir + Vector3.new(0, 1, 0) * (vertSpeed / speed)
			end
			if uis:IsKeyDown(Enum.KeyCode.LeftShift) then
				moveDir = moveDir - Vector3.new(0, 1, 0) * (vertSpeed / speed)
			end

			if moveDir.Magnitude > 0 then
				moveDir = moveDir.Unit * speed
			end

			if Flight.Mode == "Instant" then
				Flight.SmoothTarget = moveDir
			else
				Flight.SmoothTarget = Flight.SmoothTarget:Lerp(moveDir, Flight.Acceleration)
				if Flight.SmoothTarget.Magnitude < 0.5 then
					Flight.SmoothTarget = Vector3.zero
				end
			end

			if Flight.FlightVelocity then
				Flight.FlightVelocity.Velocity = Flight.SmoothTarget
			end
			if Flight.FlightGyro then
				Flight.FlightGyro.CFrame = cameraCFrame
			end
		end)
		table.insert(Utilities.Connections, self.Connection)

		Notify("Flight Enabled", "Camera-relative flight activated", 3, "navigation")
	end

	function Flight:Disable()
		if not self.Enabled then return end
		self.Enabled = false
		if self.Connection then
			Utilities.CleanupConnection(self.Connection)
			self.Connection = nil
		end
		Utilities.CleanupInstance(self.FlightVelocity)
		self.FlightVelocity = nil
		Utilities.CleanupInstance(self.FlightGyro)
		self.FlightGyro = nil

		local character = Services.LocalPlayer.Character
		if character then
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.PlatformStand = false
			end
		end
		Notify("Flight Disabled", "Flight deactivated", 3, "navigation-off")
	end

	function Flight:Cleanup()
		if self.Enabled then self:Disable() end
	end

	function Flight:Reset()
		self:Cleanup()
	end

	return Flight
end
