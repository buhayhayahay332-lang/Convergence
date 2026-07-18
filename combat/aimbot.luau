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
Aimbot.inputConn   = nil
Aimbot.inputEndConn = nil

Aimbot.KEYBIND      = nil 
Aimbot.KEYBIND_MODE = "Hold"               
Aimbot.ACTIVE       = false                

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

local function isKeybindHeld()
    local kb = Aimbot.KEYBIND
    if not kb or typeof(kb) ~= "EnumItem" then return false end

    if kb.EnumType == Enum.KeyCode then
        return UserInputService:IsKeyDown(kb)
    elseif kb.EnumType == Enum.UserInputType then
        return UserInputService:IsMouseButtonPressed(kb)
    end

    return false
end

function Aimbot.startInput()
    if Aimbot.inputConn then Aimbot.inputConn:Disconnect() end
    if Aimbot.inputEndConn then Aimbot.inputEndConn:Disconnect() end

    Aimbot.inputConn = UserInputService.InputBegan:Connect(function(input, _processed)
        if not Aimbot.ENABLED then return end
        local kb = Aimbot.KEYBIND
        if not kb then return end

        local match = (input.KeyCode == kb) or (input.UserInputType == kb)
        if not match then return end

        if Aimbot.KEYBIND_MODE == "Toggle" then
            Aimbot.ACTIVE = not Aimbot.ACTIVE
        else
            Aimbot.ACTIVE = true
        end
    end)

    Aimbot.inputEndConn = UserInputService.InputEnded:Connect(function(input)
        if Aimbot.KEYBIND_MODE ~= "Hold" then return end
        local kb = Aimbot.KEYBIND
        if not kb then return end

        local match = (input.KeyCode == kb) or (input.UserInputType == kb)
        if match then
            Aimbot.ACTIVE = false
        end
    end)
end

function Aimbot.startRender()
    if Aimbot.renderConn then Aimbot.renderConn:Disconnect() end

    Aimbot.renderConn = RunService.RenderStepped:Connect(function()
        updateCircle()

        if not Aimbot.ENABLED then
            fovCircle.Visible = false
            Aimbot.ACTIVE = false
            return
        end

        fovCircle.Visible = true

        local shouldAim
        if Aimbot.KEYBIND_MODE == "Hold" then
            shouldAim = isKeybindHeld()
        else
            shouldAim = Aimbot.ACTIVE
        end

        local camera = workspace.CurrentCamera
        local target = shouldAim and Aimbot.getNearestTarget() or nil

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
        Aimbot.ACTIVE = false
        fovCircle.Visible = false
    end
end

function Aimbot.cleanup()
    if Aimbot.renderConn   then Aimbot.renderConn:Disconnect()   end
    if Aimbot.inputConn    then Aimbot.inputConn:Disconnect()    end
    if Aimbot.inputEndConn then Aimbot.inputEndConn:Disconnect() end
    fovCircle:Remove()
end

function Aimbot.init()
    Aimbot.startRender()
    Aimbot.startInput()
end

return Aimbot