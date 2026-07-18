local Players          = cloneref(game:GetService("Players"))
local RunService       = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))

local LocalPlayer = Players.LocalPlayer

local Aimbot = {}

Aimbot.Config = {
    Enabled     = false,
    FOV         = 120,
    Smoothness  = 0.15,
    TargetPart  = "Head",
    TeamCheck   = true,
    Keybind     = nil,
    KeybindMode = "Hold",
}

local State = {
    Active       = false,
    renderConn   = nil,
    inputConn    = nil,
    inputEndConn = nil,
}

local fovCircle        = Drawing.new("Circle")
fovCircle.Visible      = false
fovCircle.Thickness    = 1
fovCircle.Color        = Color3.fromRGB(255, 255, 255)
fovCircle.Filled       = false
fovCircle.NumSides     = 64
fovCircle.Radius       = Aimbot.Config.FOV
fovCircle.Transparency = 1

local function updateCircle()
    local vp           = workspace.CurrentCamera.ViewportSize
    fovCircle.Position = Vector2.new(vp.X / 2, vp.Y / 2)
    fovCircle.Radius   = Aimbot.Config.FOV
end

local function isTeammate(player)
    if player == LocalPlayer then return true end
    if Aimbot.Config.TeamCheck and LocalPlayer.Team and player.Team then
        return player.Team == LocalPlayer.Team
    end
    return false
end

local function getNearestTarget()
    local camera   = workspace.CurrentCamera
    local vp       = camera.ViewportSize
    local center   = Vector2.new(vp.X / 2, vp.Y / 2)
    local closest  = nil
    local bestDist = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if not isTeammate(player) then
            local char = player.Character
            if char then
                local hum  = char:FindFirstChildOfClass("Humanoid")
                local part = char:FindFirstChild(Aimbot.Config.TargetPart)
                if part and hum and hum.Health > 0 then
                    local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist2D <= Aimbot.Config.FOV and dist2D < bestDist then
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
    local kb = Aimbot.Config.Keybind
    if kb == nil then return false end

    if kb == Enum.UserInputType.MouseButton1 then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    elseif kb == Enum.UserInputType.MouseButton2 then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    elseif kb == Enum.UserInputType.MouseButton3 then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton3)
    elseif typeof(kb) == "EnumItem" and kb.EnumType == Enum.KeyCode then
        return UserInputService:IsKeyDown(kb)
    end

    return false
end

local function shouldAim()
    if not Aimbot.Config.Enabled then return false end
    if Aimbot.Config.Keybind == nil then return false end

    if Aimbot.Config.KeybindMode == "Hold" then
        return isKeybindHeld()
    else
        return State.Active
    end
end

local function startInput()
    if State.inputConn    then State.inputConn:Disconnect()    end
    if State.inputEndConn then State.inputEndConn:Disconnect() end

    State.inputConn = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if not Aimbot.Config.Enabled then return end
        local kb = Aimbot.Config.Keybind
        if kb == nil then return end

        local match = (input.KeyCode == kb) or (input.UserInputType == kb)
        if not match then return end

        if Aimbot.Config.KeybindMode == "Toggle" then
            State.Active = not State.Active
        end
    end)

    State.inputEndConn = UserInputService.InputEnded:Connect(function(input)
        if Aimbot.Config.KeybindMode ~= "Hold" then return end
        local kb = Aimbot.Config.Keybind
        if kb == nil then return end

        local match = (input.KeyCode == kb) or (input.UserInputType == kb)
        if match then
            State.Active = false
        end
    end)
end

local function startRender()
    if State.renderConn then State.renderConn:Disconnect() end

    State.renderConn = RunService.RenderStepped:Connect(function()
        updateCircle()

        if not Aimbot.Config.Enabled then
            fovCircle.Visible = false
            State.Active      = false
            return
        end

        fovCircle.Visible = true

        if not shouldAim() then
            fovCircle.Color = Color3.fromRGB(255, 255, 255)
            return
        end

        local camera = workspace.CurrentCamera
        local target = getNearestTarget()

        if target then
            fovCircle.Color = Color3.fromRGB(255, 80, 80)
            local goal    = CFrame.new(camera.CFrame.Position, target.Position)
            camera.CFrame = camera.CFrame:Lerp(goal, Aimbot.Config.Smoothness)
        else
            fovCircle.Color = Color3.fromRGB(255, 255, 255)
        end
    end)
end

function Aimbot.toggle()
    Aimbot.Config.Enabled = not Aimbot.Config.Enabled
    State.Active          = false
    fovCircle.Visible     = false
    print(Aimbot.Config.Enabled and "✅ [Aimbot] ON" or "❌ [Aimbot] OFF")
end

function Aimbot.resetActive()
    State.Active = false
end

function Aimbot.cleanup()
    if State.renderConn   then State.renderConn:Disconnect()   end
    if State.inputConn    then State.inputConn:Disconnect()    end
    if State.inputEndConn then State.inputEndConn:Disconnect() end
    State.renderConn   = nil
    State.inputConn    = nil
    State.inputEndConn = nil
    fovCircle:Remove()
end

function Aimbot.init()
    startRender()
    startInput()
end

return Aimbot