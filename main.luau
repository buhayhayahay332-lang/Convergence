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
    GunMod = "combat/gunmodification.luau",
    Silent  = "combat/silent.luau",
})

local GunMod = M.GunMod
local Silent  = M.Silent

task.spawn(function()
    GunMod.init()
    Silent.init()
end)

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
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local AimBox = Tabs.Combat:AddLeftGroupbox("Silent Aim", "target")

AimBox:AddToggle("SilentEnabled", {
    Text     = "Enable Silent Aim",
    Default  = Silent.ENABLED,
    Tooltip  = "BULLET TPw",
    Callback = function(Value)
        if Value ~= Silent.ENABLED then
            Silent.toggle()
        end
    end,
})

Toggles.SilentEnabled:OnChanged(function()
    if Toggles.SilentEnabled.Value ~= Silent.ENABLED then
        Silent.toggle()
    end
end)

AimBox:AddSlider("SilentFOV", {
    Text     = "FOV",
    Default  = Silent.FOV,
    Min      = 1,
    Max      = 360,
    Rounding = 0,
    Suffix   = "°",
    Tooltip  = "Cone ANGLE (degrees) not CIRCLE",
    Callback = function(Value)
        Silent.FOV = Value
    end,
})

AimBox:AddDivider()

AimBox:AddButton({
    Text    = "Re-scan Hooks",
    Tooltip = "Re-Hook",
    Func    = function()
        task.spawn(Silent.init)
        Library:Notify({
            Title       = "Silent Aim",
            Description = "Re-scanning hooks...",
            Time        = 3,
        })
    end,
})

local WeaponBox = Tabs.Combat:AddRightGroupbox("Weapons", "zap")

WeaponBox:AddToggle("InfiniteAmmo", {
    Text     = "Infinite Ammo",
    Default  = GunMod.INFINITE_AMMO,
    Tooltip  = "Self Explanatory",
    Callback = function(Value)
        if Value ~= GunMod.INFINITE_AMMO then
            GunMod.toggleInfiniteAmmo()
        end
    end,
})

Toggles.InfiniteAmmo:OnChanged(function()
    if Toggles.InfiniteAmmo.Value ~= GunMod.INFINITE_AMMO then
        GunMod.toggleInfiniteAmmo()
    end
end)

WeaponBox:AddDivider()

WeaponBox:AddButton({
    Text    = "Re-scan",
    Tooltip = "Re-scan ammo",
    Func    = function()
        task.spawn(GunMod.reinit)
        Library:Notify({
            Title       = "Weapons",
            Description = "re-scanning...",
            Time        = 3,
        })
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
SaveManager:SetFolder("ASTRO-CONVERGENCE/configs")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()

Library:OnUnload(function()
    if GunMod.heartbeatConn then
        GunMod.heartbeatConn:Disconnect()
        GunMod.heartbeatConn = nil
    end
    print("ASTRO-CONVERGENCE unloaded.")
end)