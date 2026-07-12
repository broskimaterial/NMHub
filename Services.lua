return function()
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local Workspace = game:GetService("Workspace")
	local CoreGui = game:GetService("CoreGui")

	return {
		Players = Players,
		RunService = RunService,
		UserInputService = UserInputService,
		Workspace = Workspace,
		CoreGui = CoreGui,
		LocalPlayer = Players.LocalPlayer,
		Camera = Workspace.CurrentCamera,
	}
end
