local getgc       = getgc or function() return {} end
local RunService  = cloneref(game:GetService("RunService"))
local Players     = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer

local GunMod = {}

GunMod.Config = {
    InfiniteAmmo = true,
}

local State = {
    updateGUIFns  = {},
    heartbeatConn = nil,
}

local function isUpdateGUI(func)
    local ok, consts = pcall(debug.getconstants, func)
    if not ok or not consts then return false end
    local hasTween, hasAmmoPerMag = false, false
    for _, c in pairs(consts) do
        if c == "TweenSizeAndPosition" then hasTween      = true end
        if c == "AmmoPerMag"           then hasAmmoPerMag = true end
    end
    return hasTween and hasAmmoPerMag
end

local function scan()
    for _, func in ipairs(getgc(true)) do
        if type(func) == "function" and isUpdateGUI(func) then
            local found = false
            for _, f in ipairs(State.updateGUIFns) do
                if f == func then found = true break end
            end
            if not found then
                table.insert(State.updateGUIFns, func)
            end
        end
    end
end

local function startHeartbeat()
    if State.heartbeatConn then State.heartbeatConn:Disconnect() end
    State.heartbeatConn = RunService.Heartbeat:Connect(function()
        if not GunMod.Config.InfiniteAmmo then return end
        for _, fn in ipairs(State.updateGUIFns) do
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
    GunMod.Config.InfiniteAmmo = not GunMod.Config.InfiniteAmmo
end

function GunMod.cleanup()
    if State.heartbeatConn then
        State.heartbeatConn:Disconnect()
        State.heartbeatConn = nil
    end
end

function GunMod.init()
    task.wait(2)
    scan()
    startHeartbeat()

    LocalPlayer.CharacterAdded:Connect(function()
        State.updateGUIFns = {}
        task.wait(2)
        scan()
    end)
end

return GunMod