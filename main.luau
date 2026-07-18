local function loadFrom(baseUrl, paths)
    local loaded = {}
    for name, path in next, paths do
        loaded[name] = loadstring(game:HttpGet(baseUrl .. path))()
    end
    return loaded
end

local GUI = loadFrom("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/", {
    Library      = "Library.lua",
    ThemeManager = "addons/ThemeManager.lua",
    SaveManager  = "addons/SaveManager.lua",
})

local Library      = GUI.Library
local ThemeManager = GUI.ThemeManager
local SaveManager  = GUI.SaveManager

local M = loadFrom("https://raw.githubusercontent.com/buhayhayahay332-lang/Convergence/main/", {
    GunMod   = "combat/gunmodification.luau",
    Silent   = "combat/silent.luau",
    Aimbot   = "combat/aimbot.luau",
    Movement = "localplayer/movement.luau",
})

local GunMod   = M.GunMod
local Silent   = M.Silent
local Aimbot   = M.Aimbot
local Movement = M.Movement

task.spawn(GunMod.init)
task.spawn(Silent.init)
task.spawn(Aimbot.init)
task.spawn(Movement.init)

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
    Title            = "CONVERGENCE",
    Footer           = "combat suite",
    NotifySide       = "Right",
    ShowCustomCursor = true,
    Center           = true,
    AutoShow         = true,
})

local Tabs = {
    Combat          = Window:AddTab("Combat",      "crosshair"),
    Movement        = Window:AddTab("Movement",    "person-standing"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}


local AimTabbox = Tabs.Combat:AddLeftTabbox()
local SilentTab = AimTabbox:AddTab("Silent")
local AimbotTab = AimTabbox:AddTab("Aimbot")

SilentTab:AddToggle("SilentEnabled", {
    Text     = "Enable Silent Aim/ Bullet Tp",
    Default  = Silent.ENABLED,
    Tooltip  = "tp to enemy head",
    Callback = function(Value)
        if Value ~= Silent.ENABLED then Silent.toggle() end
    end,
})

Toggles.SilentEnabled:OnChanged(function()
    if Toggles.SilentEnabled.Value ~= Silent.ENABLED then
        Silent.toggle()
    end
end)

SilentTab:AddSlider("SilentFOV", {
    Text     = "FOV",
    Default  = Silent.FOV,
    Min      = 1,
    Max      = 360,
    Rounding = 0,
    Suffix   = "°",
    Tooltip  = "Cone angle not fov circle",
    Callback = function(Value)
        Silent.FOV = Value
    end,
})

SilentTab:AddDivider()

AimbotTab:AddToggle("AimbotEnabled", {
    Text     = "Enable Aimbot",
    Default  = Aimbot.ENABLED,
    Tooltip  = "Snaps camera towards the nearest enemy within FOV",
    Callback = function(Value)
        if Value ~= Aimbot.ENABLED then Aimbot.toggle() end
    end,
})

Toggles.AimbotEnabled:OnChanged(function()
    if Toggles.AimbotEnabled.Value ~= Aimbot.ENABLED then
        Aimbot.toggle()
    end
end)

AimbotTab:AddSlider("AimbotFOV", {
    Text     = "FOV",
    Default  = Aimbot.FOV,
    Min      = 1,
    Max      = 500,
    Rounding = 0,
    Suffix   = "px",
    Tooltip  = "Screen-space radius (pixels) to look for targets",
    Callback = function(Value)
        Aimbot.FOV = Value
    end,
})

AimbotTab:AddSlider("AimbotSmoothness", {
    Text     = "Smoothness",
    Default  = math.floor(Aimbot.SMOOTHNESS * 100),
    Min      = 1,
    Max      = 100,
    Rounding = 0,
    Suffix   = "%",
    Tooltip  = "Higher = snappier, lower = smoother",
    Callback = function(Value)
        Aimbot.SMOOTHNESS = Value / 100
    end,
})

AimbotTab:AddDropdown("AimbotPart", {
    Values   = { "Head", "UpperTorso", "HumanoidRootPart" },
    Default  = Aimbot.TARGET_PART,
    Text     = "Target Part",
    Tooltip  = "Which body part to aim at",
    Callback = function(Value)
        Aimbot.TARGET_PART = Value
    end,
})

AimbotTab:AddToggle("AimbotTeamCheck", {
    Text     = "Team Check",
    Default  = Aimbot.TEAM_CHECK,
    Tooltip  = "Skip teammates",
    Callback = function(Value)
        Aimbot.TEAM_CHECK = Value
    end,
})

local WeaponBox = Tabs.Combat:AddRightGroupbox("Weapons", "zap")

WeaponBox:AddToggle("InfiniteAmmo", {
    Text     = "Infinite Ammo",
    Default  = GunMod.INFINITE_AMMO,
    Tooltip  = "inf ammo",
    Callback = function(Value)
        if Value ~= GunMod.INFINITE_AMMO then GunMod.toggleInfiniteAmmo() end
    end,
})

Toggles.InfiniteAmmo:OnChanged(function()
    if Toggles.InfiniteAmmo.Value ~= GunMod.INFINITE_AMMO then
        GunMod.toggleInfiniteAmmo()
    end
end)


local MoveBox = Tabs.Movement:AddLeftGroupbox("Character", "footprints")

MoveBox:AddSlider("WalkSpeed", {
    Text     = "Walk Speed",
    Default  = Movement.WALKSPEED,
    Min      = 1,
    Max      = 500,
    Rounding = 0,
    Tooltip  = "Set character walk speed",
    Callback = function(Value)
        Movement.setWalkSpeed(Value)
    end,
})

MoveBox:AddDivider()

MoveBox:AddToggle("FlyEnabled", {
    Text     = "Fly",
    Default  = Movement.FLY_ENABLED,
    Tooltip  = "W/A/S/D to move, Space to go up, LCtrl to go down",
    Callback = function(Value)
        if Value ~= Movement.FLY_ENABLED then Movement.toggleFly() end
    end,
})

Toggles.FlyEnabled:OnChanged(function()
    if Toggles.FlyEnabled.Value ~= Movement.FLY_ENABLED then
        Movement.toggleFly()
    end
end)

MoveBox:AddSlider("FlySpeed", {
    Text     = "Fly Speed",
    Default  = Movement.FLY_SPEED,
    Min      = 1,
    Max      = 500,
    Rounding = 0,
    Tooltip  = "Speed while flying",
    Callback = function(Value)
        Movement.FLY_SPEED = Value
    end,
})

MoveBox:AddDivider()

MoveBox:AddToggle("NoclipEnabled", {
    Text     = "Phase Through Walls",
    Default  = Movement.NOCLIP,
    Tooltip  = "Disables collision on all character parts",
    Callback = function(Value)
        if Value ~= Movement.NOCLIP then Movement.toggleNoclip() end
    end,
})

Toggles.NoclipEnabled:OnChanged(function()
    if Toggles.NoclipEnabled.Value ~= Movement.NOCLIP then
        Movement.toggleNoclip()
    end
end)

local TeleportBox = Tabs.Movement:AddRightGroupbox("Teleport", "map-pin")

TeleportBox:AddButton({
    Text    = "TP to Nearest Enemy",
    Tooltip = "Teleports you behind the closest enemy",
    Func    = function()
        Movement.tpToNearestEnemy()
    end,
})


local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default  = Library.KeybindFrame.Visible,
    Text     = "Show Keybind Menu",
    Callback = function(Value)
        Library.KeybindFrame.Visible = Value
    end,
})

MenuGroup:AddToggle("ShowCustomCursor", {
    Text     = "Custom Cursor",
    Default  = true,
    Callback = function(Value)
        Library.ShowCustomCursor = Value
    end,
})

MenuGroup:AddDropdown("NotificationSide", {
    Values   = { "Left", "Right" },
    Default  = "Right",
    Text     = "Notification Side",
    Callback = function(Value)
        Library:SetNotifySide(Value)
    end,
})

MenuGroup:AddDivider()

MenuGroup:AddLabel("Menu Keybind")
    :AddKeyPicker("MenuKeybind", {
        Default = "RightShift",
        NoUI    = true,
        Text    = "Toggle menu",
    })

MenuGroup:AddButton({
    Text = "Unload",
    Func = function()
        Library:Unload()
    end,
})

Library.ToggleKeybind = Options.MenuKeybind


ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("CONVERGENCE")
SaveManager:SetFolder("ASTRO/configs")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()

Library:OnUnload(function()
    if GunMod.heartbeatConn then
        GunMod.heartbeatConn:Disconnect()
        GunMod.heartbeatConn = nil
    end
    if Aimbot.renderConn then
        Aimbot.renderConn:Disconnect()
        Aimbot.renderConn = nil
    end
    Movement.cleanup()
    print("ASTRO-CONVERGENCE unloaded.")
end)
