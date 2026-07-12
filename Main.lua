local BASE_URL = "https://raw.githubusercontent.com/broskimaterial/NMHub/main"

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Services = loadstring(game:HttpGet(BASE_URL .. "/Services.lua"))()()
Services._connections = {}
local Utilities = loadstring(game:HttpGet(BASE_URL .. "/Utilities.lua"))()()
local Notifications = loadstring(game:HttpGet(BASE_URL .. "/Notifications.lua"))()(Rayfield)

local Logger = loadstring(game:HttpGet(BASE_URL .. "/Logger.lua"))()()

--------------------------------------------------------------------
-- Notification Queue (FIFO, max 3 visible, spam prevention)
--------------------------------------------------------------------
do
	local queue = {}
	local spamCooldown = {}
	local MAX_VISIBLE = 3
	local COOLDOWN = 3
	local originalNotify = Notifications.Notify
	local originalRaw = Notifications.RawNotify

	Notifications.Notify = function(title, content, duration, image)
		local key = title:lower()
		local now = tick()
		if spamCooldown[key] and now - spamCooldown[key] < COOLDOWN then return end
		spamCooldown[key] = now

		table.insert(queue, { Title = title, Content = content, Duration = duration or 4, Image = image or "info" })
		if #queue > MAX_VISIBLE then table.remove(queue, 1) end
		for _, entry in ipairs(queue) do
			originalNotify(entry.Title, entry.Content, entry.Duration, entry.Image)
		end
	end

	Notifications.RawNotify = function(data)
		originalRaw(data)
	end
end

local env = {
	BASE_URL = BASE_URL,
	Services = Services,
	Utilities = Utilities,
	Logger = Logger,
	Notify = Notifications.Notify,
}

local Diagnostics = loadstring(game:HttpGet(BASE_URL .. "/Diagnostics.lua"))()(env)
local ThemeManager = loadstring(game:HttpGet(BASE_URL .. "/ThemeManager.lua"))()({ Rayfield = Rayfield })
local PluginManager = loadstring(game:HttpGet(BASE_URL .. "/PluginManager.lua"))()(env)
local Profiles = loadstring(game:HttpGet(BASE_URL .. "/Profiles.lua"))()(env)

local NoClip = loadstring(game:HttpGet(BASE_URL .. "/Modules/NoClip.lua"))()(env)
local Flight = loadstring(game:HttpGet(BASE_URL .. "/Modules/Flight.lua"))()(env)
local InfiniteJump = loadstring(game:HttpGet(BASE_URL .. "/Modules/InfiniteJump.lua"))()(env)
local Visuals = loadstring(game:HttpGet(BASE_URL .. "/Modules/Visuals.lua"))()(env)

--------------------------------------------------------------------
-- Version Check
--------------------------------------------------------------------
local VersionInfo = loadstring(game:HttpGet(BASE_URL .. "/Version.lua"))()
local CURRENT_VERSION = (VersionInfo and VersionInfo.Version) or "0.0.0"
local CURRENT_BUILD = (VersionInfo and VersionInfo.Build) or 0
env.Version = CURRENT_VERSION
env.Build = CURRENT_BUILD

local LATEST_VERSION
local versionSuccess = pcall(function()
	LATEST_VERSION = game:HttpGet(BASE_URL .. "/Version.txt"):gsub("%s+", "")
end)

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
-- Update Notification
--------------------------------------------------------------------
task.spawn(function()
	if versionSuccess and LATEST_VERSION and LATEST_VERSION ~= CURRENT_VERSION then
		Notifications.Notify("NMHub Update Available", "v" .. LATEST_VERSION .. " available (current: v" .. CURRENT_VERSION .. ")", 10, "download")
	end
end)

--------------------------------------------------------------------
-- Destroy Hub
--------------------------------------------------------------------
local function DestroyHub()
	NoClip:Cleanup()
	Flight:Cleanup()
	InfiniteJump:Cleanup()
	Visuals:Cleanup()

	PluginManager.CleanupAll()

	for _, conn in pairs(Services._connections) do
		Utilities.CleanupConnection(conn)
	end
	Services._connections = {}

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

local FlightVertSlider = MainTab:CreateSlider({
	Name = "Vertical Speed",
	Range = {10, 200},
	Increment = 5,
	Suffix = " studs/s",
	CurrentValue = 50,
	Flag = "FlightVertSpeed",
	Callback = function(Value) Flight.VerticalSpeed = Value end,
})

local FlightAccelSlider = MainTab:CreateSlider({
	Name = "Flight Acceleration",
	Range = {5, 100},
	Increment = 5,
	Suffix = "%",
	CurrentValue = 15,
	Flag = "FlightAcceleration",
	Callback = function(Value) Flight.Acceleration = Value / 100 end,
})

local FlightModeDropdown = MainTab:CreateDropdown({
	Name = "Flight Mode",
	Options = {"Smooth", "Instant", "Hover"},
	CurrentOption = "Smooth",
	Flag = "FlightMode",
	Callback = function(Value) Flight.Mode = Value end,
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

VisualsTab:CreateDivider()
local VisualSettingsSection = VisualsTab:CreateSection("Visual Settings")

local LineThicknessSlider = VisualsTab:CreateSlider({
	Name = "ESP Line Thickness",
	Range = {1, 5},
	Increment = 1,
	Suffix = "px",
	CurrentValue = 1,
	Flag = "EspLineThickness",
	Callback = function(Value) Visuals.Settings.LineThickness = Value end,
})

local MaxDistanceSlider = VisualsTab:CreateSlider({
	Name = "Max ESP Distance",
	Range = {100, 5000},
	Increment = 100,
	Suffix = " studs",
	CurrentValue = 5000,
	Flag = "EspMaxDistance",
	Callback = function(Value) Visuals.Settings.MaxDistance = Value end,
})

local RefreshRateSlider = VisualsTab:CreateSlider({
	Name = "ESP Refresh Rate",
	Range = {1, 10},
	Increment = 1,
	Suffix = " frames",
	CurrentValue = 1,
	Flag = "EspRefreshRate",
	Callback = function(Value) Visuals.Settings.RefreshRate = Value end,
})

local EspOutlineToggle = VisualsTab:CreateToggle({
	Name = "Box Outline",
	CurrentValue = false,
	Flag = "EspOutlineToggle",
	Callback = function(Value) Visuals.Settings.Outline = Value end,
})

local EspTextOutlineToggle = VisualsTab:CreateToggle({
	Name = "Text Outline",
	CurrentValue = true,
	Flag = "EspTextOutlineToggle",
	Callback = function(Value) Visuals.Settings.TextOutline = Value end,
})

VisualsTab:CreateDivider()
local EspAestheticSection = VisualsTab:CreateSection("Aesthetics")

local TransparencySlider = VisualsTab:CreateSlider({
	Name = "ESP Transparency",
	Range = {0, 10},
	Increment = 1,
	Suffix = "/10",
	CurrentValue = 10,
	Flag = "EspTransparency",
	Callback = function(Value) Visuals.Settings.Transparency = Value / 10 end,
})

local TextSizeSlider = VisualsTab:CreateSlider({
	Name = "ESP Text Size",
	Range = {10, 30},
	Increment = 1,
	Suffix = "px",
	CurrentValue = 14,
	Flag = "EspTextSize",
	Callback = function(Value) Visuals.Settings.TextSize = Value end,
})

local TracerOriginDropdown = VisualsTab:CreateDropdown({
	Name = "Tracer Origin",
	Options = {"Bottom", "Crosshair", "Mouse"},
	CurrentOption = "Bottom",
	Flag = "EspTracerOrigin",
	Callback = function(Value) Visuals.Settings.TracerOrigin = Value end,
})

local DistanceFadeToggle = VisualsTab:CreateToggle({
	Name = "Distance Fade",
	CurrentValue = false,
	Flag = "EspDistanceFade",
	Callback = function(Value) Visuals.Settings.DistanceFade = Value end,
})


-- Keybinds Tab
local KeybindsSection = KeybindsTab:CreateSection("Keybind Summary")
KeybindsTab:CreateLabel("N  — NoClip Toggle", "keyboard")
KeybindsTab:CreateLabel("F  — Flight Toggle", "keyboard")
KeybindsTab:CreateLabel("J  — Air Jump Toggle", "keyboard")
KeybindsTab:CreateLabel("P  — ESP Toggle", "keyboard")

local KeybindsRemapSection = KeybindsTab:CreateSection("Remap Keybinds")

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

local ProfileSection = SettingsTab:CreateSection("Profiles")

local ProfileDropdown = SettingsTab:CreateDropdown({
	Name = "Active Profile",
	Options = Profiles.GetProfiles(),
	CurrentOption = Profiles.GetCurrent(),
	Flag = "ActiveProfile",
	Callback = function(Value)
		if Value ~= Profiles.GetCurrent() then
			Profiles.Switch(Value)
			Profiles.Save()
			Notifications.Notify("Profile Switched", "Reload script to apply profile: " .. Value, 5, "refresh-cw")
		end
	end,
})

local NewProfileInput = SettingsTab:CreateInput({
	Name = "New Profile Name",
	PlaceholderText = "Enter name...",
	Flag = "NewProfileName",
	Callback = function(Value)
		if Value and #Value > 0 then
			if Profiles.Create(Value) then
				ProfileDropdown:SetOptions(Profiles.GetProfiles())
				ProfileDropdown:Set(Value)
				Notifications.Notify("Profile Created", "Profile '" .. Value .. "' created", 3, "check-circle")
			end
		end
	end,
})

local DeleteProfileButton = SettingsTab:CreateButton({
	Name = "Delete Current Profile",
	Callback = function()
		local name = Profiles.GetCurrent()
		if name == "Default" then
			Notifications.Notify("Cannot Delete", "Default profile cannot be deleted", 3, "alert-triangle")
			return
		end
		Profiles.Delete(name)
		ProfileDropdown:SetOptions(Profiles.GetProfiles())
		ProfileDropdown:Set(Profiles.GetCurrent())
		Notifications.Notify("Profile Deleted", "Profile '" .. name .. "' deleted", 3, "trash-2")
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
SettingsTab:CreateLabel("NMHub v" .. CURRENT_VERSION, "shield")
SettingsTab:CreateLabel("Built with Sirius (Rayfield) UI Library", "code")
SettingsTab:CreateLabel("Features: NoClip, Flight, Air Jump, ESP", "list")
SettingsTab:CreateLabel("All keybinds are rebindable in Keybinds tab", "keyboard")

local ThemeSection = SettingsTab:CreateSection("Theme")
local ThemeDropdown = SettingsTab:CreateDropdown({
	Name = "Theme Selector",
	Options = ThemeManager.GetThemes(),
	CurrentOption = ThemeManager.GetCurrent(),
	Flag = "ThemeDropdown",
	Callback = function(Value)
		ThemeManager.SetTheme(Value)
	end,
})

local NavSection = SettingsTab:CreateSection("Quick Navigation")
SettingsTab:CreateButton({
	Name = "Open Main Tab",
	Callback = function() Window:SelectTab(1) end,
})
SettingsTab:CreateButton({
	Name = "Open Visuals Tab",
	Callback = function() Window:SelectTab(2) end,
})
SettingsTab:CreateButton({
	Name = "Open Keybinds Tab",
	Callback = function() Window:SelectTab(3) end,
})

local DiagnosticsSection = SettingsTab:CreateSection("Diagnostics")
local FpsLabel = SettingsTab:CreateLabel("FPS: --", "activity")
local PingLabel = SettingsTab:CreateLabel("Ping: -- ms", "wifi")

task.spawn(function()
	while task.wait(1) do
		local data = Diagnostics.Collect()
		FpsLabel:Set("FPS: " .. data.FPS)
		PingLabel:Set("Ping: " .. data.Ping .. " ms | Memory: " .. math.floor(data.Memory) .. " KB")
	end
end)

--------------------------------------------------------------------
-- Hub API (exposed to plugins)
--------------------------------------------------------------------
env.Hub = {
	Services = Services,
	Utilities = Utilities,
	Logger = Logger,
	Notify = Notifications.Notify,
	Rayfield = Rayfield,
	Window = Window,
	NoClip = NoClip,
	Flight = Flight,
	InfiniteJump = InfiniteJump,
	Visuals = Visuals,
}
env.Hub.MainTab = MainTab
env.Hub.VisualsTab = VisualsTab
env.Hub.KeybindsTab = KeybindsTab
env.Hub.SettingsTab = SettingsTab

--------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------
task.spawn(function()
	PluginManager.LoadAll()
	local count = PluginManager.GetCount()
	if count > 0 then
		Logger.Info("Plugins loaded: " .. count)
	end
end)

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
