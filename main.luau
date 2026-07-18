local function loadFrom(baseUrl, paths)
    local loaded = {}
    for name, path in next, paths do
        loaded[name] = loadstring(game:HttpGet(baseUrl .. path))()
    end
    return loaded
end

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/buhayhayahay332-lang/Libs/refs/heads/main/finobe%20ui/source.lua"
))()

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

local Window = Library:Window({ name = "CONVERGENCE" })

local CombatTab     = Window:Tab({ name = "Combat"      })
local MovementTab   = Window:Tab({ name = "Movement"    })
local UISettingsTab = Window:Tab({ name = "UI Settings" })

CombatTab.OpenTab()  -- auto-open first tab (mirrors AutoShow = true)

local CombatLeft  = CombatTab:Column()
local CombatRight = CombatTab:Column()

local AimTabs      = CombatLeft:MultiSection({ Names = { "Silent", "AimAssist" } })
local SilentSec    = AimTabs[1]
local AimAssistSec = AimTabs[2]

SilentSec:Toggle({
    Name     = "Enable Silent Aim / Bullet TP",
    Flag     = "SilentEnabled",
    Default  = Silent.Config.Enabled,
    Tooltip  = "Teleports bullet to enemy head, bypasses walls",
    Callback = function(Value)
        if Value ~= Silent.Config.Enabled then Silent.toggle() end
    end,
})

SilentSec:Slider({
    Name      = "FOV",
    Flag      = "SilentFOV",
    Default   = Silent.Config.FOV,
    Min       = 1,
    Max       = 360,
    Intervals = 1,   
    Suffix    = "°",
    Callback  = function(Value)
        Silent.Config.FOV = Value
    end,
})

AimAssistSec:Toggle({
    Name     = "Enable Aim Assist",
    Flag     = "AimAssistEnabled",
    Default  = AimAssist.Config.Enabled,
    Tooltip  = "Smoothly pulls camera toward nearest enemy",
    Callback = function(Value)
        if Value ~= AimAssist.Config.Enabled then AimAssist.toggle() end
    end,
})

AimAssistSec:Dropdown({
    Name     = "Activation",
    Flag     = "AimAssistActivation",
    Items    = { "always", "right_mouse", "left_mouse", "either_mouse" },
    Default  = AimAssist.Config.Activation,
    Callback = function(Value)
        AimAssist.Config.Activation = Value
    end,
})

AimAssistSec:Dropdown({
    Name     = "Target Part",
    Flag     = "AimAssistPart",
    Items    = { "Head", "UpperTorso", "HumanoidRootPart" },
    Default  = AimAssist.Config.TargetPart,
    Callback = function(Value)
        AimAssist.Config.TargetPart = Value
    end,
})

AimAssistSec:Slider({
    Name      = "FOV Radius",
    Flag      = "AimAssistFOV",
    Default   = AimAssist.Config.FovRadius,
    Min       = 10,
    Max       = 500,
    Intervals = 1,
    Suffix    = "px",
    Tooltip   = "Screen-space FOV circle radius",
    Callback  = function(Value)
        AimAssist.Config.FovRadius = Value
    end,
})

AimAssistSec:Slider({
    Name      = "Smoothness",
    Flag      = "AimAssistSmoothness",
    Default   = math.floor(AimAssist.Config.Smoothness * 100),
    Min       = 1,
    Max       = 100,
    Intervals = 1,
    Suffix    = "%",
    Tooltip   = "Lower = smoother pull",
    Callback  = function(Value)
        AimAssist.Config.Smoothness = Value / 100
    end,
})

AimAssistSec:Slider({
    Name      = "Max Distance",
    Flag      = "AimAssistMaxDist",
    Default   = AimAssist.Config.MaxDistance,
    Min       = 100,
    Max       = 5000,
    Intervals = 1,
    Suffix    = " studs",
    Callback  = function(Value)
        AimAssist.Config.MaxDistance = Value
    end,
})

AimAssistSec:Toggle({
    Name     = "Team Check",
    Flag     = "AimAssistTeamCheck",
    Default  = AimAssist.Config.TeamCheck,
    Tooltip  = "Skip teammates",
    Callback = function(Value)
        AimAssist.Config.TeamCheck = Value
    end,
})

AimAssistSec:Toggle({
    Name     = "Visibility Check",
    Flag     = "AimAssistVisCheck",
    Default  = AimAssist.Config.VisibilityCheck,
    Tooltip  = "Only target visible enemies",
    Callback = function(Value)
        AimAssist.Config.VisibilityCheck = Value
    end,
})

AimAssistSec:Toggle({
    Name     = "Show FOV Circle",
    Flag     = "AimAssistFovVisible",
    Default  = AimAssist.Config.FovEnabled,
    Callback = function(Value)
        AimAssist.Config.FovEnabled = Value
    end,
})

local WeaponSec = CombatRight:Section({ Name = "Weapons" })

WeaponSec:Toggle({
    Name     = "Infinite Ammo",
    Flag     = "InfiniteAmmo",
    Default  = GunMod.Config.InfiniteAmmo,
    Tooltip  = "Unlimited ammo",
    Callback = function(Value)
        if Value ~= GunMod.Config.InfiniteAmmo then GunMod.toggleInfiniteAmmo() end
    end,
})

local MovLeft  = MovementTab:Column()
local MovRight = MovementTab:Column()

local CharSec = MovLeft:Section({ Name = "Character" })

CharSec:Slider({
    Name      = "Walk Speed",
    Flag      = "WalkSpeed",
    Default   = Movement.Config.WalkSpeed,
    Min       = 1,
    Max       = 500,
    Intervals = 1,
    Tooltip   = "Character walk speed",
    Callback  = function(Value)
        Movement.setWalkSpeed(Value)
    end,
})


CharSec:Toggle({
    Name     = "Fly",
    Flag     = "FlyEnabled",
    Default  = Movement.Config.FlyEnabled,
    Tooltip  = "W/A/S/D to move, Space up, LCtrl down",
    Callback = function(Value)
        if Value ~= Movement.Config.FlyEnabled then Movement.toggleFly() end
    end,
})

CharSec:Slider({
    Name      = "Fly Speed",
    Flag      = "FlySpeed",
    Default   = Movement.Config.FlySpeed,
    Min       = 1,
    Max       = 500,
    Intervals = 1,
    Tooltip   = "Speed while flying",
    Callback  = function(Value)
        Movement.Config.FlySpeed = Value
    end,
})

CharSec:Toggle({
    Name     = "Phase Through Walls",
    Flag     = "NoclipEnabled",
    Default  = Movement.Config.Noclip,
    Tooltip  = "Disables collision on character",
    Callback = function(Value)
        if Value ~= Movement.Config.Noclip then Movement.toggleNoclip() end
    end,
})

local TpSec = MovRight:Section({ Name = "Teleport" })

TpSec:ButtonHolder({})
TpSec:Button({
    name     = "TP to Nearest Enemy",
    callback = function()
        Movement.tpToNearestEnemy()
    end,
})

local TpKbLabel = TpSec:Label({ name = "TP Keybind" })
TpKbLabel:Keybind({
    flag     = "TpKeybind",
    mode     = "toggle",
    name     = "TP Key",         
    callback = function(_active)
        local flagData = Library.Flags["TpKeybind"]
        if flagData then
            Movement.Config.TpKeybind = flagData.Key
        end
    end,
})
Movement.Config.TpKeybind = Library.Flags["TpKeybind"] and Library.Flags["TpKeybind"].Key or nil

local UILeft  = UISettingsTab:Column()
local UIRight = UISettingsTab:Column()

local MenuSec = UILeft:Section({ Name = "Menu" })

MenuSec:Toggle({
    Name     = "Show Keybind List",
    Flag     = "KeybindMenuOpen",
    Default  = false,
    Callback = function(Value)
        Library.KeybindListFrame.Visible = Value
    end,
})

local MenuKbLabel = MenuSec:Label({ name = "Menu Keybind" })
MenuKbLabel:Keybind({
    flag     = "MenuKeybind",
    key      = Enum.KeyCode.RightShift,
    mode     = "toggle",
    default  = true,
    name     = "Toggle Menu",
    callback = function(active)
        Window.SetMenuVisibility(active)
    end,
})

local ConfigSec = UIRight:Section({ Name = "Config" })

local CONFIG_PATH = "CONVERGENCE/configs/config.json"

ConfigSec:ButtonHolder({})
ConfigSec:Button({
    name     = "Save Config",
    callback = function()
        if not isfolder("CONVERGENCE/configs") then
            makefolder("CONVERGENCE/configs")
        end
        writefile(CONFIG_PATH, Library:GetConfig())
        Library:Notification({ text = "Config saved!", time = 3 })
    end,
})

ConfigSec:ButtonHolder({})
ConfigSec:Button({
    name     = "Load Config",
    callback = function()
        if isfile(CONFIG_PATH) then
            Library:LoadConfig(readfile(CONFIG_PATH))
            Library:Notification({ text = "Config loaded!", time = 3 })
        else
            Library:Notification({ text = "No config found.", time = 3 })
        end
    end,
})

ConfigSec:ButtonHolder({})
ConfigSec:Button({
    name     = "Unload",
    callback = function()
        GunMod.cleanup()
        Silent.cleanup()
        AimAssist.cleanup()
        Movement.cleanup()
        for _, conn in next, Library.Connections do
            pcall(function() conn:Disconnect() end)
        end
        for _, gui in next, Library.Guis do
            pcall(function() gui:Destroy() end)
        end
        for _, drawing in next, Library.Drawings do
            pcall(function() drawing:Remove() end)
        end
        print("CONVERGENCE unloaded.")
    end,
})

task.spawn(function()
    if isfile(CONFIG_PATH) then
        Library:LoadConfig(readfile(CONFIG_PATH))
    end
end)
