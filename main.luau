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
    GunMod    = "combat/gunmodification.luau",
    Silent    = "combat/silent.luau",
    AimAssist = "combat/aimassist.luau",
    Movement  = "localplayer/movement.luau",
})

local GunMod    = M.GunMod
local Silent    = M.Silent
local AimAssist = M.AimAssist
local Movement  = M.Movement

task.spawn(GunMod.init)
task.spawn(Silent.init)
task.spawn(AimAssist.init)
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

local AimTabbox    = Tabs.Combat:AddLeftTabbox()
local SilentTab    = AimTabbox:AddTab("Silent")
local AimAssistTab = AimTabbox:AddTab("AimAssist")

SilentTab:AddToggle("SilentEnabled", {
    Text     = "Enable Silent Aim / Bullet TP",
    Default  = Silent.Config.Enabled,
    Tooltip  = "Teleports bullet to enemy head, bypasses walls",
    Callback = function(Value)
        if Value ~= Silent.Config.Enabled then Silent.toggle() end
    end,
})

SilentTab:AddSlider("SilentFOV", {
    Text     = "FOV",
    Default  = Silent.Config.FOV,
    Min      = 1,
    Max      = 360,
    Rounding = 0,
    Suffix   = "°",
    Tooltip  = "Cone angle for target detection",
    Callback = function(Value)
        Silent.Config.FOV = Value
    end,
})

AimAssistTab:AddToggle("AimAssistEnabled", {
    Text     = "Enable Aim Assist",
    Default  = AimAssist.Config.Enabled,
    Tooltip  = "Smoothly pulls camera toward nearest enemy",
    Callback = function(Value)
        if Value ~= AimAssist.Config.Enabled then AimAssist.toggle() end
    end,
})

AimAssistTab:AddDropdown("AimAssistActivation", {
    Values   = { "always", "right_mouse", "left_mouse", "either_mouse" },
    Default  = AimAssist.Config.Activation,
    Text     = "Activation",
    Tooltip  = "When aim assist is active",
    Callback = function(Value)
        AimAssist.Config.Activation = Value
    end,
})

AimAssistTab:AddDropdown("AimAssistPart", {
    Values   = { "Head", "UpperTorso", "HumanoidRootPart" },
    Default  = AimAssist.Config.TargetPart,
    Text     = "Target Part",
    Callback = function(Value)
        AimAssist.Config.TargetPart = Value
    end,
})

AimAssistTab:AddSlider("AimAssistFOV", {
    Text     = "FOV Radius",
    Default  = AimAssist.Config.FovRadius,
    Min      = 10,
    Max      = 500,
    Rounding = 0,
    Suffix   = "px",
    Tooltip  = "Screen-space FOV circle radius",
    Callback = function(Value)
        AimAssist.Config.FovRadius = Value
    end,
})

AimAssistTab:AddSlider("AimAssistSmoothness", {
    Text     = "Smoothness",
    Default  = math.floor(AimAssist.Config.Smoothness * 100),
    Min      = 1,
    Max      = 100,
    Rounding = 0,
    Suffix   = "%",
    Tooltip  = "Lower = smoother pull",
    Callback = function(Value)
        AimAssist.Config.Smoothness = Value / 100
    end,
})

AimAssistTab:AddSlider("AimAssistMaxDist", {
    Text     = "Max Distance",
    Default  = AimAssist.Config.MaxDistance,
    Min      = 100,
    Max      = 5000,
    Rounding = 0,
    Suffix   = " studs",
    Callback = function(Value)
        AimAssist.Config.MaxDistance = Value
    end,
})

AimAssistTab:AddToggle("AimAssistTeamCheck", {
    Text     = "Team Check",
    Default  = AimAssist.Config.TeamCheck,
    Tooltip  = "Skip teammates",
    Callback = function(Value)
        AimAssist.Config.TeamCheck = Value
    end,
})

AimAssistTab:AddToggle("AimAssistVisCheck", {
    Text     = "Visibility Check",
    Default  = AimAssist.Config.VisibilityCheck,
    Tooltip  = "Only target visible enemies",
    Callback = function(Value)
        AimAssist.Config.VisibilityCheck = Value
    end,
})

AimAssistTab:AddToggle("AimAssistFovVisible", {
    Text     = "Show FOV Circle",
    Default  = AimAssist.Config.FovEnabled,
    Callback = function(Value)
        AimAssist.Config.FovEnabled = Value
    end,
})

local WeaponBox = Tabs.Combat:AddRightGroupbox("Weapons", "zap")

WeaponBox:AddToggle("InfiniteAmmo", {
    Text     = "Infinite Ammo",
    Default  = GunMod.Config.InfiniteAmmo,
    Tooltip  = "Unlimited ammo",
    Callback = function(Value)
        if Value ~= GunMod.Config.InfiniteAmmo then GunMod.toggleInfiniteAmmo() end
    end,
})

local MoveBox = Tabs.Movement:AddLeftGroupbox("Character", "footprints")

MoveBox:AddSlider("WalkSpeed", {
    Text     = "Walk Speed",
    Default  = Movement.Config.WalkSpeed,
    Min      = 1,
    Max      = 500,
    Rounding = 0,
    Tooltip  = "Character walk speed",
    Callback = function(Value)
        Movement.setWalkSpeed(Value)
    end,
})

MoveBox:AddDivider()

MoveBox:AddToggle("FlyEnabled", {
    Text     = "Fly",
    Default  = Movement.Config.FlyEnabled,
    Tooltip  = "W/A/S/D to move, Space up, LCtrl down",
    Callback = function(Value)
        if Value ~= Movement.Config.FlyEnabled then Movement.toggleFly() end
    end,
})

MoveBox:AddSlider("FlySpeed", {
    Text     = "Fly Speed",
    Default  = Movement.Config.FlySpeed,
    Min      = 1,
    Max      = 500,
    Rounding = 0,
    Tooltip  = "Speed while flying",
    Callback = function(Value)
        Movement.Config.FlySpeed = Value
    end,
})

MoveBox:AddDivider()

MoveBox:AddToggle("NoclipEnabled", {
    Text     = "Phase Through Walls",
    Default  = Movement.Config.Noclip,
    Tooltip  = "Disables collision on character",
    Callback = function(Value)
        if Value ~= Movement.Config.Noclip then Movement.toggleNoclip() end
    end,
})

local TeleportBox = Tabs.Movement:AddRightGroupbox("Teleport", "map-pin")

TeleportBox:AddButton({
    Text    = "TP to Nearest Enemy",
    Tooltip = "Teleports you behind the closest enemy",
    Func    = function()
        Movement.tpToNearestEnemy()
    end,
})

TeleportBox:AddLabel("TP Keybind")
    :AddKeyPicker("TpKeybind", {
        Default         = "None",
        SyncToggleState = false,
        Mode            = "Always",
        Text            = "TP Key",
        NoUI            = false,
        Callback        = function(Value)
            Movement.Config.TpKeybind = Value
        end,
    })

Options.TpKeybind:OnChanged(function()
    Movement.Config.TpKeybind = Options.TpKeybind.Value
end)
Movement.Config.TpKeybind = Options.TpKeybind.Value

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
    GunMod.cleanup()
    Silent.cleanup()
    AimAssist.cleanup()
    Movement.cleanup()
    print("CONVERGENCE unloaded.")
end)
