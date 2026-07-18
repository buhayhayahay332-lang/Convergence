--aimbot.luau
local Players          = cloneref(game:GetService("Players"))
local RunService       = cloneref(game:GetService("RunService"))

local LocalPlayer = Players.LocalPlayer

local Aimbot = {}
Aimbot.ENABLED     = false
Aimbot.FOV         = 120       -- screen-space radius in pixels
Aimbot.SMOOTHNESS  = 0.15      -- lerp alpha per frame; higher = snappier
Aimbot.TARGET_PART = "Head"
Aimbot.TEAM_CHECK  = false
Aimbot.renderConn  = nil

function Aimbot.isTeammate(player)
    if player == LocalPlayer then return true end
    if Aimbot.TEAM_CHECK and LocalPlayer.Team and player.Team then
        return player.Team == LocalPlayer.Team
    end
    return false
end

function Aimbot.getNearestTarget()
    local camera  = workspace.CurrentCamera
    local center  = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local closest = nil
    local bestDist = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if not Aimbot.isTeammate(player) then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local part     = character:FindFirstChild(Aimbot.TARGET_PART)
                if part and humanoid and humanoid.Health > 0 then
                    local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist2D <= Aimbot.FOV and dist2D < bestDist then
                            bestDist = dist2D
                            closest  = part
                        end
                    end
                end
            end
        end
    end

    return closest
end

function Aimbot.startRender()
    if Aimbot.renderConn then
        Aimbot.renderConn:Disconnect()
    end
    Aimbot.renderConn = RunService.RenderStepped:Connect(function()
        if not Aimbot.ENABLED then return end
        local camera = workspace.CurrentCamera
        local target = Aimbot.getNearestTarget()
        if target then
            local goal    = CFrame.new(camera.CFrame.Position, target.Position)
            camera.CFrame = camera.CFrame:Lerp(goal, Aimbot.SMOOTHNESS)
        end
    end)
end

function Aimbot.toggle()
    Aimbot.ENABLED = not Aimbot.ENABLED
end

function Aimbot.init()
    Aimbot.startRender()
end

return Aimbot
