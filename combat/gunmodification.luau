--gunmodification.luau
local getgc      = getgc or function() return {} end
local RunService = cloneref(game:GetService("RunService"))
local Players    = cloneref(game:GetService("Players"))

local GunMod = {}
GunMod.INFINITE_AMMO = true
GunMod.updateGUIFns  = {}
GunMod.heartbeatConn = nil
GunMod.spawnConn     = nil

function GunMod.isUpdateGUI(func)
    local ok, consts = pcall(debug.getconstants, func)
    if not ok or not consts then return false end
    local hasTween, hasAmmoPerMag = false, false
    for _, c in pairs(consts) do
        if c == "TweenSizeAndPosition" then hasTween     = true end
        if c == "AmmoPerMag"           then hasAmmoPerMag = true end
    end
    return hasTween and hasAmmoPerMag
end

function GunMod.scan()
    for _, func in ipairs(getgc(true)) do
        if type(func) == "function" and GunMod.isUpdateGUI(func) then
            local found = false
            for _, f in ipairs(GunMod.updateGUIFns) do
                if f == func then found = true break end
            end
            if not found then
                table.insert(GunMod.updateGUIFns, func)
            end
        end
    end
end

function GunMod.startHeartbeat()
    if GunMod.heartbeatConn then
        GunMod.heartbeatConn:Disconnect()
    end
    GunMod.heartbeatConn = RunService.Heartbeat:Connect(function()
        if not GunMod.INFINITE_AMMO then return end
        for _, fn in ipairs(GunMod.updateGUIFns) do
            local ok, upvals = pcall(debug.getupvalues, fn)
            if ok and upvals then
                local config = upvals[3]
                if type(config) == "table" then
                    pcall(debug.setupvalue, fn, 2, config.AmmoPerMag or 9999)
                    pcall(debug.setupvalue, fn, 4, config.MaxAmmo    or 9999)
                end
            end
        end
    end)
end

function GunMod.toggleInfiniteAmmo()
    GunMod.INFINITE_AMMO = not GunMod.INFINITE_AMMO
end

function GunMod.init()
    local LocalPlayer = Players.LocalPlayer

    local function onSpawn()
        GunMod.updateGUIFns = {}
        task.wait(2)
        GunMod.scan()
        GunMod.startHeartbeat()
    end

    if LocalPlayer.Character then
        task.spawn(onSpawn)
    end

    if GunMod.spawnConn then
        GunMod.spawnConn:Disconnect()
    end
    GunMod.spawnConn = LocalPlayer.CharacterAdded:Connect(function()
        task.spawn(onSpawn)
    end)
end

function GunMod.reinit()
    GunMod.updateGUIFns = {}
    task.wait(2)
    GunMod.scan()
end

return GunMod