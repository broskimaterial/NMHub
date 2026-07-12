local BASE_URL = "https://raw.githubusercontent.com/brokimaterial/NMHub/main"

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Services = loadstring(game:HttpGet(BASE_URL .. "/Services.lua"))()()
local Utilities = loadstring(game:HttpGet(BASE_URL .. "/Utilities.lua"))()()
local Notifications = loadstring(game:HttpGet(BASE_URL .. "/Notifications.lua"))()(Rayfield)

local env = {
	Services = Services,
	Utilities = Utilities,
	Notify = Notifications.Notify,
}

local NoClip = loadstring(game:HttpGet(BASE_URL .. "/Modules/NoClip.lua"))()(env)
local Flight = loadstring(game:HttpGet(BASE_URL .. "/Modules/Flight.lua"))()(env)
local InfiniteJump = loadstring(game:HttpGet(BASE_URL .. "/Modules/InfiniteJump.lua"))()(env)
local Visuals = loadstring(game:HttpGet(BASE_URL .. "/Modules/Visuals.lua"))()(env)

--------------------------------------------------------------------
-- Character Handling
--------------------------------------------------------------------
local Character = nil
local Humanoid = nil
local HumanoidRootPart = nil

local function OnCharacterAdded(character)
	Character = character
	Humanoid = character:WaitForChild("Humanoid")
	HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
	Services.Camera = Services.Workspace.CurrentCamera

	task.wait(0.5)

	if NoClip.Enabled then
		NoClip:Enable()
	end
	if Flight.Enabled then
		Utilities.CleanupInstance(Flight.FlightVelocity)
		Flight.FlightVelocity = nil
		Utilities.CleanupInstance(Flight.FlightGyro)
		Flight.FlightGyro = nil
		Flight.Enabled = false
		Flight:Enable()
	end
	if InfiniteJump.Enabled then
		InfiniteJump:Enable()
	end

	Notifications.Notify("Character Respawned", "Features restored after respawn", 3, "user-plus")
end

local CharacterAddedConn = Services.LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)
table.insert(Utilities.Connections, CharacterAddedConn)

--------------------------------------------------------------------
-- Destroy Hub
--------------------------------------------------------------------
local function DestroyHub()
	NoClip:Cleanup()
	Flight:Cleanup()
	InfiniteJump:Cleanup()
	Visuals:Cleanup()

	Utilities.ClearConnections()
	Utilities.ClearInstances()

	local character = Services.LocalPlayer.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		Utilities.RestoreCollisions(character)
		if humanoid then
			humanoid.PlatformStand = false
		end
	end

	Rayfield:Destroy()
end

--------------------------------------------------------------------
-- UI Creation
--------------------------------------------------------------------
local Window = Rayfield:CreateWindow({
	Name = "NMHub",
	Icon = "shield",
	LoadingTitle = "NMHub",
	LoadingSubtitle = "by MajuS",
	ShowText = "NMHub",
	Theme = "Amethyst",
	DisableRayfieldPrompts = false,
	DisableBuildWarnings = true,
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "NMHub",
		FileName = "Config",
	},
	Discord = {
		Enabled = false,
		Invite = "noinvitelink",
		RememberJoins = true,
	},
	KeySystem = false,
})

local MainTab = Window:CreateTab("Main", "home")
local VisualsTab = Window:CreateTab("Visuals", "eye")
local KeybindsTab = Window:CreateTab("Keybinds", "keyboard")
local SettingsTab = Window:CreateTab("Settings", "settings")

-- Main Tab
local MovementSection = MainTab:CreateSection("Movement & Combat")

local NoClipToggle = MainTab:CreateToggle({
	Name = "NoClip",
	CurrentValue = false,
	Flag = "NoClipToggle",
	Callback = function(Value)
		if Value then NoClip:Enable() else NoClip:Disable() end
	end,
})

local FlightToggle = MainTab:CreateToggle({
	Name = "Flight",
	CurrentValue = false,
	Flag = "FlightToggle",
	Callback = function(Value)
		if Value then Flight:Enable() else Flight:Disable() end
	end,
})

local FlightSpeedSlider = MainTab:CreateSlider({
	Name = "Flight Speed",
	Range = {20, 200},
	Increment = 5,
	Suffix = " studs/s",
	CurrentValue = 50,
	Flag = "FlightSpeedSlider",
	Callback = function(Value)
		Flight.Speed = Value
		Notifications.Notify("Speed Changed", "Flight speed set to " .. Value .. " studs/s", 2, "gauge")
	end,
})

local AirJumpToggle = MainTab:CreateToggle({
	Name = "Air Jump",
	CurrentValue = false,
	Flag = "AirJumpToggle",
	Callback = function(Value)
		if Value then InfiniteJump:Enable() else InfiniteJump:Disable() end
	end,
})

-- Visuals Tab
local EspSection = VisualsTab:CreateSection("ESP Settings")

local EspToggle = VisualsTab:CreateToggle({
	Name = "Enable ESP",
	CurrentValue = false,
	Flag = "EspToggle",
	Callback = function(Value)
		if Value then Visuals:Enable() else Visuals:Disable() end
	end,
})

VisualsTab:CreateDivider()

local VisualFeaturesSection = VisualsTab:CreateSection("ESP Features")

local BoxToggle = VisualsTab:CreateToggle({
	Name = "Box ESP",
	CurrentValue = false,
	Flag = "EspBoxToggle",
	Callback = function(Value) Visuals.Settings.Box = Value end,
})

local CornerBoxToggle = VisualsTab:CreateToggle({
	Name = "Corner Box ESP",
	CurrentValue = false,
	Flag = "EspCornerBoxToggle",
	Callback = function(Value) Visuals.Settings.CornerBox = Value end,
})

local NameToggle = VisualsTab:CreateToggle({
	Name = "Name ESP",
	CurrentValue = false,
	Flag = "EspNameToggle",
	Callback = function(Value) Visuals.Settings.Name = Value end,
})

local DistanceToggle = VisualsTab:CreateToggle({
	Name = "Distance ESP",
	CurrentValue = false,
	Flag = "EspDistanceToggle",
	Callback = function(Value) Visuals.Settings.Distance = Value end,
})

local HealthToggle = VisualsTab:CreateToggle({
	Name = "Health ESP",
	CurrentValue = false,
	Flag = "EspHealthToggle",
	Callback = function(Value) Visuals.Settings.Health = Value end,
})

local SkeletonToggle = VisualsTab:CreateToggle({
	Name = "Skeleton ESP",
	CurrentValue = false,
	Flag = "EspSkeletonToggle",
	Callback = function(Value) Visuals.Settings.Skeleton = Value end,
})

local TracersToggle = VisualsTab:CreateToggle({
	Name = "Tracers",
	CurrentValue = false,
	Flag = "EspTracersToggle",
	Callback = function(Value) Visuals.Settings.Tracers = Value end,
})

local HeadDotToggle = VisualsTab:CreateToggle({
	Name = "Head Dot",
	CurrentValue = false,
	Flag = "EspHeadDotToggle",
	Callback = function(Value) Visuals.Settings.HeadDot = Value end,
})

local ChamsToggle = VisualsTab:CreateToggle({
	Name = "Chams",
	CurrentValue = false,
	Flag = "EspChamsToggle",
	Callback = function(Value) Visuals.Settings.Chams = Value end,
})

-- Keybinds Tab
local KeybindsSection = KeybindsTab:CreateSection("Feature Keybinds")

local NoClipKeybind = KeybindsTab:CreateKeybind({
	Name = "NoClip Toggle",
	CurrentKeybind = "N",
	HoldToInteract = false,
	Flag = "NoClipKeybind",
	Callback = function()
		if NoClip.Enabled then
			NoClip:Disable()
			NoClipToggle:Set(false)
		else
			NoClip:Enable()
			NoClipToggle:Set(true)
		end
	end,
})

local FlightKeybind = KeybindsTab:CreateKeybind({
	Name = "Flight Toggle",
	CurrentKeybind = "F",
	HoldToInteract = false,
	Flag = "FlightKeybind",
	Callback = function()
		if Flight.Enabled then
			Flight:Disable()
			FlightToggle:Set(false)
		else
			Flight:Enable()
			FlightToggle:Set(true)
		end
	end,
})

local AirJumpKeybind = KeybindsTab:CreateKeybind({
	Name = "Air Jump Toggle",
	CurrentKeybind = "J",
	HoldToInteract = false,
	Flag = "AirJumpKeybind",
	Callback = function()
		if InfiniteJump.Enabled then
			InfiniteJump:Disable()
			AirJumpToggle:Set(false)
		else
			InfiniteJump:Enable()
			AirJumpToggle:Set(true)
		end
	end,
})

local EspKeybind = KeybindsTab:CreateKeybind({
	Name = "ESP Toggle",
	CurrentKeybind = "P",
	HoldToInteract = false,
	Flag = "EspKeybind",
	Callback = function()
		if Visuals.Enabled then
			Visuals:Disable()
			EspToggle:Set(false)
		else
			Visuals:Enable()
			EspToggle:Set(true)
		end
	end,
})

-- Settings Tab
local SettingsSection = SettingsTab:CreateSection("Preferences")

local NotificationsToggle = SettingsTab:CreateToggle({
	Name = "Enable Notifications",
	CurrentValue = true,
	Flag = "NotificationsToggle",
	Callback = function(Value)
		Notifications.SetEnabled(Value)
		Notifications.RawNotify({
			Title = "Notifications",
			Content = Value and "Notifications enabled" or "Notifications disabled",
			Duration = 2,
			Image = Value and "bell" or "bell-off",
		})
	end,
})

local ResetSettingsButton = SettingsTab:CreateButton({
	Name = "Reset Settings",
	Callback = function()
		Notifications.RawNotify({
			Title = "Settings Reset",
			Content = "Configuration reset. Reload script to apply defaults.",
			Duration = 3,
			Image = "refresh-cw",
		})
		task.wait(0.5)
		DestroyHub()
	end,
})

local DestroyHubButton = SettingsTab:CreateButton({
	Name = "Destroy Hub",
	Callback = function()
		DestroyHub()
	end,
})

local InfoSection = SettingsTab:CreateSection("Information")
SettingsTab:CreateLabel("NMHub v2.0.0", "shield")
SettingsTab:CreateLabel("Built with Sirius (Rayfield) UI Library", "code")
SettingsTab:CreateLabel("Features: NoClip, Flight, Air Jump, ESP", "list")
SettingsTab:CreateLabel("All keybinds are rebindable in Keybinds tab", "keyboard")

--------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------
if Services.LocalPlayer.Character then
	OnCharacterAdded(Services.LocalPlayer.Character)
end

Rayfield:LoadConfiguration()

Notifications.Notify("NMHub Loaded", "Script hub initialized successfully.", 5, "shield")
Notifications.Notify("Script Initialized", "All modules loaded and ready", 3, "check-circle")
Notifications.RawNotify({
	Title = "Welcome to NMHub",
	Content = "NoClip: N | Flight: F | Air Jump: J | ESP: P",
	Duration = 8,
	Image = "info",
})
