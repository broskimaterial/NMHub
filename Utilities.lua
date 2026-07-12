return function()
	local Connections = {}
	local Instances = {}

	local function CleanupConnection(connection)
		if connection and connection.Connected then
			connection:Disconnect()
		end
	end

	local function CleanupInstance(instance)
		if instance and instance.Parent then
			instance:Destroy()
		end
	end

	local function ClearConnections()
		for _, conn in pairs(Connections) do
			CleanupConnection(conn)
		end
		table.clear(Connections)
	end

	local function ClearInstances()
		for _, inst in pairs(Instances) do
			CleanupInstance(inst)
		end
		table.clear(Instances)
	end

	local function SaveOriginalCollisions(character)
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part:SetAttribute("_OriginalCollision", part.CanCollide)
			end
		end
	end

	local function RestoreCollisions(character)
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				local original = part:GetAttribute("_OriginalCollision")
				if original ~= nil then
					part.CanCollide = original
					part:SetAttribute("_OriginalCollision", nil)
				end
			end
		end
	end

	return {
		Connections = Connections,
		Instances = Instances,
		CleanupConnection = CleanupConnection,
		CleanupInstance = CleanupInstance,
		ClearConnections = ClearConnections,
		ClearInstances = ClearInstances,
		SaveOriginalCollisions = SaveOriginalCollisions,
		RestoreCollisions = RestoreCollisions,
	}
end
