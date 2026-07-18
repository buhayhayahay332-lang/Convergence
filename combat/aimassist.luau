local M = {}

local players            = cloneref(game:GetService("Players"))
local run_service        = cloneref(game:GetService("RunService"))
local user_input_service = cloneref(game:GetService("UserInputService"))
local workspace_service  = cloneref(game:GetService("Workspace"))

local local_player = players.LocalPlayer
local camera       = workspace_service.CurrentCamera

M.Config = {
    Enabled         = false,
    TeamCheck       = false,
    VisibilityCheck = false,
    Activation      = "right_mouse",
    TargetPart      = "Head",
    UseClosestPart  = false,
    FovEnabled      = true,
    FovRadius       = 120,
    FovColor        = Color3.fromRGB(255, 255, 255),
    FovThickness    = 1,
    Smoothness      = 0.18,
    MaxDistance     = 2000,
}

local fov_circle         = Drawing.new("Circle")
fov_circle.Visible       = false
fov_circle.Filled        = false
fov_circle.Radius        = M.Config.FovRadius
fov_circle.Color         = M.Config.FovColor
fov_circle.Thickness     = M.Config.FovThickness
fov_circle.NumSides      = 64

local connection         = nil

local visibility_params = RaycastParams.new()
visibility_params.FilterType  = Enum.RaycastFilterType.Exclude
visibility_params.IgnoreWater = true

local function update_camera()
    camera = workspace_service.CurrentCamera
end

local function is_alive(character)
    if not character then return false end
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    return character:FindFirstChild("HumanoidRootPart") ~= nil
end

local function same_team(target)
    if not M.Config.TeamCheck then return false end
    if not local_player or not target then return false end
    if not local_player.Team or not target.Team then return false end
    return local_player.Team == target.Team
end

local function activation_down()
    local mode = M.Config.Activation
    if mode == "always" then
        return true
    elseif mode == "left_mouse" then
        return user_input_service:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    elseif mode == "either_mouse" then
        return user_input_service:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
            or user_input_service:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    else
        return user_input_service:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    end
end

local function is_visible(part, character)
    if not M.Config.VisibilityCheck then return true end
    local local_char = local_player and local_player.Character
    local exclude = { camera }
    if local_char then table.insert(exclude, local_char) end
    visibility_params.FilterDescendantsInstances = exclude
    local origin    = camera.CFrame.Position
    local direction = part.Position - origin
    local hit       = workspace_service:Raycast(origin, direction, visibility_params)
    if not hit then return true end
    return hit.Instance and hit.Instance:IsDescendantOf(character)
end

local function get_target_part(character)
    local p = character:FindFirstChild(M.Config.TargetPart)
    if p and p:IsA("BasePart") then return p end
    local h = character:FindFirstChild("Head")
    if h and h:IsA("BasePart") then return h end
    return character:FindFirstChild("HumanoidRootPart")
end

local closest_parts = {
    "Head","LeftFoot","LeftHand","LeftLowerArm","LeftLowerLeg",
    "LeftUpperArm","LeftUpperLeg","LowerTorso","RightFoot",
    "RightHand","RightLowerArm","RightLowerLeg","RightUpperArm",
    "RightUpperLeg","UpperTorso"
}

local function get_closest_part(character, center)
    local best, bestDist = nil, math.huge
    for _, name in ipairs(closest_parts) do
        local part = character:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            local sp, on = camera:WorldToViewportPoint(part.Position)
            if on then
                local d = math.sqrt((sp.X - center.X)^2 + (sp.Y - center.Y)^2)
                if d < bestDist then bestDist, best = d, part end
            end
        end
    end
    return best
end

local function find_best_target()
    if not camera then return nil end
    local best, bestDist = nil, math.huge
    local center = camera.ViewportSize / 2

    for _, target in ipairs(players:GetPlayers()) do
        if target ~= local_player and not same_team(target) then
            local char = target.Character
            if is_alive(char) then
                local part = M.Config.UseClosestPart
                    and get_closest_part(char, center)
                    or  get_target_part(char)

                if part then
                    local worldDist = (part.Position - camera.CFrame.Position).Magnitude
                    if worldDist <= M.Config.MaxDistance then
                        local sp, on = camera:WorldToViewportPoint(part.Position)
                        if on then
                            local d2 = math.sqrt((sp.X - center.X)^2 + (sp.Y - center.Y)^2)
                            local inFov = not M.Config.FovEnabled or d2 <= M.Config.FovRadius
                            if inFov and d2 < bestDist and is_visible(part, char) then
                                bestDist, best = d2, part
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

local function step()
    -- update fov circle
    fov_circle.Radius    = M.Config.FovRadius
    fov_circle.Color     = M.Config.FovColor
    fov_circle.Thickness = M.Config.FovThickness
    fov_circle.Visible   = M.Config.Enabled and M.Config.FovEnabled
    if camera then
        fov_circle.Position = camera.ViewportSize / 2
    end

    if not M.Config.Enabled then return end
    if not activation_down() then return end
    if not camera then return end

    local part = find_best_target()
    if not part then return end

    local current = camera.CFrame
    local target  = CFrame.lookAt(current.Position, part.Position)
    camera.CFrame = current:Lerp(target, math.clamp(M.Config.Smoothness, 0.01, 1))
end

function M.toggle()
    M.Config.Enabled = not M.Config.Enabled
    if not M.Config.Enabled then
        fov_circle.Visible = false
    end
end

function M.init()
    workspace_service:GetPropertyChangedSignal("CurrentCamera"):Connect(update_camera)
    connection = run_service.RenderStepped:Connect(step)
end

function M.cleanup()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    fov_circle.Visible = false
    fov_circle:Remove()
end

return M