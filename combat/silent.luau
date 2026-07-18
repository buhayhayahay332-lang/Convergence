--silent.luau
local newcclosure   = newcclosure   or function(f) return f end
local hookfunction  = hookfunction  or function(f, r) return f end
local clonefunction = clonefunction or function(f) return f end
local getgc         = getgc         or function() return {} end

local Workspace   = game:GetService("Workspace")
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Silent = {}
Silent.ENABLED      = true
Silent.FOV          = 180
Silent.hookedParams = {}
Silent.spawnConn    = nil

function Silent.isTeammate(player)
    if player == LocalPlayer then return true end
    if LocalPlayer.Team and player.Team then
        return player.Team == LocalPlayer.Team
    end
    return false
end

function Silent.getNearestEnemyHead()
    local camera      = Workspace.CurrentCamera
    local camPos      = camera.CFrame.Position
    local camLook     = camera.CFrame.LookVector
    local closest     = nil
    local closestDist = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if not Silent.isTeammate(player) then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local head     = character:FindFirstChild("Head")
                if head and humanoid and humanoid.Health > 0 then
                    local toHead = head.Position - camPos
                    local dist   = toHead.Magnitude
                    local angle  = math.deg(math.acos(math.clamp(camLook:Dot(toHead.Unit), -1, 1)))
                    if angle <= Silent.FOV / 2 and dist < closestDist then
                        closestDist = dist
                        closest     = head
                    end
                end
            end
        end
    end

    return closest
end

function Silent.getHitPosParams(func)
    local ok1, consts = pcall(debug.getconstants, func)
    if not ok1 or not consts then return nil end

    local hasUnitRay, hasShotgun, hasRaycast = false, false, false
    for _, c in ipairs(consts) do
        if c == "UnitRay"        then hasUnitRay = true end
        if c == "ShotgunEnabled" then hasShotgun = true end
        if c == "Raycast"        then hasRaycast = true end
    end
    if not (hasUnitRay and hasShotgun and hasRaycast) then return nil end

    local ok2, upvals = pcall(debug.getupvalues, func)
    if not ok2 or not upvals then return nil end
    for _, v in ipairs(upvals) do
        if typeof(v) == "RaycastParams" then return v end
    end
    return nil
end

function Silent.scan()
    local count = 0
    for _, func in ipairs(getgc(true)) do
        if type(func) == "function" then
            local params = Silent.getHitPosParams(func)
            if params and not Silent.hookedParams[params] then
                Silent.hookedParams[params] = true
                local original = clonefunction(func)

                hookfunction(func, newcclosure(function(firePoint, shotIndex)
                    if Silent.ENABLED then
                        local head = Silent.getNearestEnemyHead()
                        if head then
                            local camPos    = Workspace.CurrentCamera.CFrame.Position
                            local dirToHead = (head.Position - camPos).Unit
                            local fakeOrigin = head.Position - dirToHead * 1
                            return fakeOrigin, dirToHead
                        end
                    end
                    return original(firePoint, shotIndex)
                end))

                count = count + 1
            end
        end
    end
    print(count)
end

function Silent.toggle()
    Silent.ENABLED = not Silent.ENABLED
end

function Silent.init()
    local function onSpawn()
        Silent.hookedParams = {}
        task.wait(2)
        Silent.scan()
    end

    if LocalPlayer.Character then
        task.spawn(onSpawn)
    end

    if Silent.spawnConn then
        Silent.spawnConn:Disconnect()
    end
    Silent.spawnConn = LocalPlayer.CharacterAdded:Connect(function()
        task.spawn(onSpawn)
    end)
end

return Silent