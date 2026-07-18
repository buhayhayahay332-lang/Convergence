--movement.luau
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Movement = {}
Movement.WALKSPEED   = 16
Movement.FLY_ENABLED = false
Movement.FLY_SPEED   = 50
Movement.NOCLIP      = false
Movement.spawnConn   = nil
Movement.renderConn  = nil
Movement.noclipConn  = nil
Movement.TP_KEYBIND  = nil
Movement.tpInputConn = nil

local function getChar()     return LocalPlayer.Character end
local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHumanoid()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

function Movement.setWalkSpeed(speed)
    Movement.WALKSPEED = speed
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = speed end
end

local bv, bg 

local function cleanFlyObjects()
    if bv and bv.Parent then bv:Destroy() end
    if bg and bg.Parent then bg:Destroy() end
    bv, bg = nil, nil
end

function Movement.startFly()
    local hrp = getHRP()
    if not hrp then return end
    cleanFlyObjects()

    local hum = getHumanoid()
    if hum then hum.PlatformStand = true end

    bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Parent   = hrp

    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.P         = 1e4
    bg.CFrame    = hrp.CFrame
    bg.Parent    = hrp

    if Movement.renderConn then Movement.renderConn:Disconnect() end
    Movement.renderConn = RunService.RenderStepped:Connect(function()
        if not Movement.FLY_ENABLED then return end
        local hrp2 = getHRP()
        if not hrp2 or not bv or not bg then return end

        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W)           then dir += cam.CFrame.LookVector          end
        if UserInputService:IsKeyDown(Enum.KeyCode.S)           then dir -= cam.CFrame.LookVector          end
        if UserInputService:IsKeyDown(Enum.KeyCode.A)           then dir -= cam.CFrame.RightVector         end
        if UserInputService:IsKeyDown(Enum.KeyCode.D)           then dir += cam.CFrame.RightVector         end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then dir += Vector3.new(0, 1, 0)           end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0)           end

        bv.Velocity = dir.Magnitude > 0 and dir.Unit * Movement.FLY_SPEED or Vector3.zero
        bg.CFrame   = cam.CFrame
    end)
end

function Movement.stopFly()
    cleanFlyObjects()
    if Movement.renderConn then
        Movement.renderConn:Disconnect()
        Movement.renderConn = nil
    end
    local hum = getHumanoid()
    if hum then hum.PlatformStand = false end
end

function Movement.toggleFly()
    Movement.FLY_ENABLED = not Movement.FLY_ENABLED
    if Movement.FLY_ENABLED then Movement.startFly() else Movement.stopFly() end
end

function Movement.startNoclip()
    if Movement.noclipConn then Movement.noclipConn:Disconnect() end
    Movement.noclipConn = RunService.Stepped:Connect(function()
        if not Movement.NOCLIP then return end
        local char = getChar()
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

function Movement.stopNoclip()
    if Movement.noclipConn then
        Movement.noclipConn:Disconnect()
        Movement.noclipConn = nil
    end
end

function Movement.toggleNoclip()
    Movement.NOCLIP = not Movement.NOCLIP
    if Movement.NOCLIP then Movement.startNoclip() else Movement.stopNoclip() end
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
    else
    end
end

local function onSpawn()
    task.wait(0.5)
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = Movement.WALKSPEED end
    if Movement.FLY_ENABLED then Movement.startFly()   end
    if Movement.NOCLIP      then Movement.startNoclip() end
end

function Movement.startTpKeybind()
    if Movement.tpInputConn then Movement.tpInputConn:Disconnect() end
    Movement.tpInputConn = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        local kb = Movement.TP_KEYBIND
        if not kb then return end
        local match = (input.KeyCode == kb) or (input.UserInputType == kb)
        if match then
            Movement.tpToNearestEnemy()
        end
    end)
end

function Movement.cleanup()
    Movement.stopFly()
    Movement.stopNoclip()
    if Movement.spawnConn then
        Movement.spawnConn:Disconnect()
        Movement.spawnConn = nil
    end
    if Movement.tpInputConn then
        Movement.tpInputConn:Disconnect()
        Movement.tpInputConn = nil
    end
end

function Movement.init()
    if LocalPlayer.Character then task.spawn(onSpawn) end
    if Movement.spawnConn then Movement.spawnConn:Disconnect() end
    Movement.spawnConn = LocalPlayer.CharacterAdded:Connect(function()
        task.spawn(onSpawn)
    end)
    Movement.startTpKeybind()
end

return Movement  