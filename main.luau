local function loadFrom(baseUrl, paths)
    local loaded = {}
    for name, path in next, paths do
        loaded[name] = loadstring(game:HttpGet(baseUrl .. path))()
    end
    return loaded
end

local GUI = loadFrom("https://raw.githubusercontent.com/buhayhayahay332-lang/Libs/refs/heads/main/n_hack%20ui/", {
    Library = "source.luau",
})

local Library = GUI.Library

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

local Window    = Library:Window({})
local Watermark = Library:Watermark({ Name = "CONVERGENCE" })


local CombatPage = Window:Page({ Name = "Combat" })

local AimSubPage       = CombatPage:SubPage({ Name = "Aim" })
local SilentSection    = AimSubPage:Section({ Name = "Silent Aim", Side = 1 })
local AimAssistSection = AimSubPage:Section({ Name = "Aim Assist", Side = 2 })

SilentSection:Toggle({
    Name     = "Enable",
    Flag     = "SilentEnabled",
    Default  = Silent.Config.Enabled,
    Callback = function(Value)
        if Value ~= Silent.Config.Enabled then Silent.toggle() end
    end,
})

SilentSection:Slider({
    Name     = "FOV",
    Flag     = "SilentFOV",
    Default  = Silent.Config.FOV,
    Min      = 1,
    Max      = 360,
    Decimals = 0,
    Suffix   = "°",
    Callback = function(Value)
        Silent.Config.FOV = Value
    end,
})

AimAssistSection:Toggle({
    Name     = "Enable",
    Flag     = "AimAssistEnabled",
    Default  = AimAssist.Config.Enabled,
    Callback = function(Value)
        if Value ~= AimAssist.Config.Enabled then AimAssist.toggle() end
    end,
}):Settings() -- right click the toggle to bind a key for hold/toggle/always

AimAssistSection:Dropdown({
    Name     = "Activation",
    Flag     = "AimAssistActivation",
    Default  = AimAssist.Config.Activation,
    Items    = { "always", "right_mouse", "left_mouse", "either_mouse" },
    Callback = function(Value)
        AimAssist.Config.Activation = Value
    end,
})

AimAssistSection:Dropdown({
    Name     = "Target Part",
    Flag     = "AimAssistPart",
    Default  = AimAssist.Config.TargetPart,
    Items    = { "Head", "UpperTorso", "HumanoidRootPart" },
    Callback = function(Value)
        AimAssist.Config.TargetPart = Value
    end,
})

AimAssistSection:Slider({
    Name     = "FOV Radius",
    Flag     = "AimAssistFOV",
    Default  = AimAssist.Config.FovRadius,
    Min      = 10,
    Max      = 500,
    Decimals = 0,
    Suffix   = "px",
    Callback = function(Value)
        AimAssist.Config.FovRadius = Value
    end,
})

AimAssistSection:Slider({
    Name     = "Smoothness",
    Flag     = "AimAssistSmoothness",
    Default  = math.floor(AimAssist.Config.Smoothness * 100),
    Min      = 1,
    Max      = 100,
    Decimals = 0,
    Suffix   = "%",
    Callback = function(Value)
        AimAssist.Config.Smoothness = Value / 100
    end,
})

AimAssistSection:Slider({
    Name     = "Max Distance",
    Flag     = "AimAssistMaxDist",
    Default  = AimAssist.Config.MaxDistance,
    Min      = 100,
    Max      = 5000,
    Decimals = 0,
    Suffix   = " studs",
    Callback = function(Value)
        AimAssist.Config.MaxDistance = Value
    end,
})

AimAssistSection:Toggle({
    Name     = "Team Check",
    Flag     = "AimAssistTeamCheck",
    Default  = AimAssist.Config.TeamCheck,
    Callback = function(Value)
        AimAssist.Config.TeamCheck = Value
    end,
})

AimAssistSection:Toggle({
    Name     = "Visibility Check",
    Flag     = "AimAssistVisCheck",
    Default  = AimAssist.Config.VisibilityCheck,
    Callback = function(Value)
        AimAssist.Config.VisibilityCheck = Value
    end,
})

AimAssistSection:Toggle({
    Name     = "Show FOV Circle",
    Flag     = "AimAssistFovVisible",
    Default  = AimAssist.Config.FovEnabled,
    Callback = function(Value)
        AimAssist.Config.FovEnabled = Value
    end,
})

local WeaponsSubPage = CombatPage:SubPage({ Name = "Weapons" })
local GunsSection    = WeaponsSubPage:Section({ Name = "Guns", Side = 1 })

GunsSection:Toggle({
    Name     = "Infinite Ammo",
    Flag     = "InfiniteAmmo",
    Default  = GunMod.Config.InfiniteAmmo,
    Callback = function(Value)
        if Value ~= GunMod.Config.InfiniteAmmo then GunMod.toggleInfiniteAmmo() end
    end,
})

local MovementPage = Window:Page({ Name = "Movement" })

local CharSubPage     = MovementPage:SubPage({ Name = "Character" })
local CharSection     = CharSubPage:Section({ Name = "Movement", Side = 1 })
local TeleportSection = CharSubPage:Section({ Name = "Teleport",  Side = 2 })

CharSection:Slider({
    Name     = "Walk Speed",
    Flag     = "WalkSpeed",
    Default  = Movement.Config.WalkSpeed,
    Min      = 1,
    Max      = 500,
    Decimals = 0,
    Callback = function(Value)
        Movement.setWalkSpeed(Value)
    end,
})

CharSection:Toggle({
    Name     = "Fly",
    Flag     = "FlyEnabled",
    Default  = Movement.Config.FlyEnabled,
    Callback = function(Value)
        if Value ~= Movement.Config.FlyEnabled then Movement.toggleFly() end
    end,
})

CharSection:Slider({
    Name     = "Fly Speed",
    Flag     = "FlySpeed",
    Default  = Movement.Config.FlySpeed,
    Min      = 1,
    Max      = 500,
    Decimals = 0,
    Callback = function(Value)
        Movement.Config.FlySpeed = Value
    end,
})

CharSection:Toggle({
    Name     = "Noclip",
    Flag     = "NoclipEnabled",
    Default  = Movement.Config.Noclip,
    Callback = function(Value)
        if Value ~= Movement.Config.Noclip then Movement.toggleNoclip() end
    end,
})

TeleportSection:Button({
    Name     = "TP to Nearest Enemy",
    Callback = function()
        Movement.tpToNearestEnemy()
    end,
})

TeleportSection:Toggle({
    Name     = "TP Keybind",
    Flag     = "TpKeybindEnabled",
    Default  = false,
    Callback = function(Value)
        if Value then
            Movement.tpToNearestEnemy()
            Library.SetFlags["TpKeybindEnabled"](false)
        end
    end,
}):Settings()

Window:CreateSettingsPage()

Library:Notification("CONVERGENCE loaded", 3, Library.Theme["Accent"])

local OriginalExit = Library.Exit
Library.Exit = function(Self)
    GunMod.cleanup()
    AimAssist.cleanup()
    Movement.cleanup()
    OriginalExit(Self)
end
