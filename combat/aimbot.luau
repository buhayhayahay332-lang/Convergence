--aimbot.luau
local Players          = cloneref(game:GetService("Players"))
local RunService       = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))

local LocalPlayer = Players.LocalPlayer

local Aimbot = {}
Aimbot.ENABLED     = false
Aimbot.FOV         = 120
Aimbot.SMOOTHNESS  = 0.15
Aimbot.TARGET_PART = "Head"
Aimbot.TEAM_CHECK  = false
Aimbot.renderConn  = nil

Aimbot.KEYBIND_MODE = "Hold"
Aimbot.ACTIVE       = false   

Aimbot.getKeybindPicker = nil

local fovCircle = Drawing.new("Circle")
fovCircle.Visible      = false
fovCircle.Thickness    = 1
fovCircle.Color        = Color3.fromRGB(255, 255, 255)
fovCircle.Filled       = false
fovCircle.NumSides     = 64
fovCircle.Radius       = Aimbot.FOV
fovCircle.Transparency = 1

local function updateCircle()
    local camera = workspace.CurrentCamera
    fovCircle.Position = Vector2.new(
        camera.ViewportSize.X / 2,
        camera.ViewportSize.Y / 2
    )
    fovCircle.Radius = Aimbot.FOV
end

function Aimbot.isTeammate(player)
    if player == LocalPlayer then return true end
    if Aimbot.TEAM_CHECK and LocalPlayer.Team and player.Team then
        return player.Team == LocalPlayer.Team
    end
    return false
end

function Aimbot.getNearestTarget()
    local camera   = workspace.CurrentCamera
    local center   = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local closest  = nil
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

local function shouldAimNow()
    if Aimbot.KEYBIND_MODE == "Always" then
        return true
    end

    local picker = Aimbot.getKeybindPicker and Aimbot.getKeybindPicker()
    if not picker then
        return Aimbot.ACTIVE
    end

    return picker.Toggled == true
end

function Aimbot.startRender()
    if Aimbot.renderConn then Aimbot.renderConn:Disconnect() end

    Aimbot.renderConn = RunService.RenderStepped:Connect(function()
        updateCircle()

        if not Aimbot.ENABLED then
            fovCircle.Visible = false
            return
        end

        fovCircle.Visible = true

        local camera = workspace.CurrentCamera
        local target = shouldAimNow() and Aimbot.getNearestTarget() or nil

        if target then
            fovCircle.Color = Color3.fromRGB(255, 80, 80)
            local goal    = CFrame.new(camera.CFrame.Position, target.Position)
            camera.CFrame = camera.CFrame:Lerp(goal, Aimbot.SMOOTHNESS)
        else
            fovCircle.Color = Color3.fromRGB(255, 255, 255)
        end
    end)
end

function Aimbot.toggle()
    Aimbot.ENABLED = not Aimbot.ENABLED
    if not Aimbot.ENABLED then
        fovCircle.Visible = false
    end
end

function Aimbot.cleanup()
    if Aimbot.renderConn then Aimbot.renderConn:Disconnect() end
    fovCircle:Remove()
end

function Aimbot.init()
    Aimbot.startRender()
end

return Aimbot