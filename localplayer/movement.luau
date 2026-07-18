local Players          = cloneref(game:GetService("Players"))
local RunService       = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))

local LocalPlayer = Players.LocalPlayer

local Movement = {}

Movement.Config = {
    WalkSpeed  = 16,
    FlyEnabled = false,
    FlySpeed   = 50,
    Noclip     = false,
    TpKeybind  = nil,
}

local State = {
    spawnConn  = nil,
    flyConn    = nil,
    noclipConn = nil,
    tpConn     = nil,
    bv         = nil,
    bg         = nil,
}

local function getChar()
    return LocalPlayer.Character
end

local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

function Movement.setWalkSpeed(speed)
    Movement.Config.WalkSpeed = speed
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = speed end
end

local function cleanFly()
    if State.bv and State.bv.Parent then State.bv:Destroy() end
    if State.bg and State.bg.Parent then State.bg:Destroy() end
    State.bv = nil
    State.bg = nil
end

local function startFly()
    local hrp = getHRP()
    if not hrp then return end
    cleanFly()

    local hum = getHumanoid()
    if hum then hum.PlatformStand = true end

    State.bv          = Instance.new("BodyVelocity")
    State.bv.Velocity = Vector3.zero
    State.bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    State.bv.Parent   = hrp

    State.bg           = Instance.new("BodyGyro")
    State.bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    State.bg.P         = 1e4
    State.bg.CFrame    = hrp.CFrame
    State.bg.Parent    = hrp

    if State.flyConn then State.flyConn:Disconnect() end
    State.flyConn = RunService.RenderStepped:Connect(function()
        if not Movement.Config.FlyEnabled then return end
        local hrp2 = getHRP()
        if not hrp2 or not State.bv or not State.bg then return end

        local cam = workspace.CurrentCamera
        local dir = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W)           then dir += cam.CFrame.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.S)           then dir -= cam.CFrame.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.A)           then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D)           then dir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then dir += Vector3.yAxis          end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis          end

        State.bv.Velocity = dir.Magnitude > 0 and dir.Unit * Movement.Config.FlySpeed or Vector3.zero
        State.bg.CFrame   = cam.CFrame
    end)
end

local function stopFly()
    cleanFly()
    if State.flyConn then
        State.flyConn:Disconnect()
        State.flyConn = nil
    end
    local hum = getHumanoid()
    if hum then hum.PlatformStand = false end
end

function Movement.toggleFly()
    Movement.Config.FlyEnabled = not Movement.Config.FlyEnabled
    if Movement.Config.FlyEnabled then startFly() else stopFly() end
end

local function startNoclip()
    if State.noclipConn then State.noclipConn:Disconnect() end
    State.noclipConn = RunService.Stepped:Connect(function()
        if not Movement.Config.Noclip then return end
        local char = getChar()
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function stopNoclip()
    if State.noclipConn then
        State.noclipConn:Disconnect()
        State.noclipConn = nil
    end
end

function Movement.toggleNoclip()
    Movement.Config.Noclip = not Movement.Config.Noclip
    if Movement.Config.Noclip then startNoclip() else stopNoclip() end
end

function Movement.tpToNearestEnemy()
    local hrp = getHRP()
    if not hrp then return end

    local closest  = nil
    local bestDist = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char     = player.Character
            local enemyHRP = char and char:FindFirstChild("HumanoidRootPart")
            local hum      = char and char:FindFirstChildOfClass("Humanoid")
            if enemyHRP and hum and hum.Health > 0 then
                local dist = (enemyHRP.Position - hrp.Position).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    closest  = enemyHRP
                end
            end
        end
    end

    if closest then
        hrp.CFrame = closest.CFrame + closest.CFrame.LookVector * 2
    end
end

local function startTpKeybind()
    if State.tpConn then State.tpConn:Disconnect() end
    State.tpConn = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        local kb = Movement.Config.TpKeybind
        if kb == nil then return end
        local match = (input.KeyCode == kb) or (input.UserInputType == kb)
        if match then Movement.tpToNearestEnemy() end
    end)
end

local function onSpawn()
    task.wait(0.5)
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = Movement.Config.WalkSpeed end
    if Movement.Config.FlyEnabled then startFly()    end
    if Movement.Config.Noclip     then startNoclip() end
end

function Movement.cleanup()
    stopFly()
    stopNoclip()
    if State.spawnConn then State.spawnConn:Disconnect() State.spawnConn = nil end
    if State.tpConn    then State.tpConn:Disconnect()    State.tpConn    = nil end
end

function Movement.init()
    if LocalPlayer.Character then task.spawn(onSpawn) end

    if State.spawnConn then State.spawnConn:Disconnect() end
    State.spawnConn = LocalPlayer.CharacterAdded:Connect(function()
        task.spawn(onSpawn)
    end)

    startTpKeybind()
end

return Movement