-- RK Ice Breaker – Fixed UI + Rainbow Header + Multitouch 🔥

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Wait for character and HRP
local function getHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

-- Create GUI
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "IceBreakerUI"
gui.ResetOnSpawn = false

-- 🌈 Rainbow Header Text
local header = Instance.new("TextLabel")
header.Name = "RainbowHeader"
header.Parent = gui
header.Size = UDim2.new(0, 200, 0, 20)
header.Position = UDim2.new(0.5, -100, 0, 10) -- Top center
header.AnchorPoint = Vector2.new(0.5, 0)
header.BackgroundTransparency = 1
header.Text = "Rafsan Zami Scripts"
header.TextSize = 12
header.Font = Enum.Font.GothamSemibold
header.TextColor3 = Color3.fromRGB(255, 0, 0)
header.ZIndex = 20

-- 🌈 Rainbow animation
local hue = 0
RunService.RenderStepped:Connect(function()
    hue = (hue + 1) % 360
    local color = Color3.fromHSV(hue / 360, 1, 1)
    header.TextColor3 = color
end)

-- 🧊 Ice Button
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 75, 0, 75)
button.Position = UDim2.new(0, 155, 0, 55)
button.BackgroundColor3 = Color3.new(0, 0, 0)
button.Text = "Ice"
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.GothamBold
button.TextSize = 17
button.BorderSizePixel = 0
button.AnchorPoint = Vector2.new(0.5, 0.5)
button.Parent = gui
button.Name = "IceButton"
button.AutoButtonColor = false
button.BackgroundTransparency = 0
button.ClipsDescendants = true
button.ZIndex = 10
button.Active = true
button.Draggable = false

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 1000)
corner.Parent = button

-- ✅ Press animation
local function animatePress()
    local shrink = TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(0, 60, 0, 60)})
    local restore = TweenService:Create(button, TweenInfo.new(0.1), {Size = UDim2.new(0, 75, 0, 75)})
    shrink:Play()
    shrink.Completed:Connect(function()
        restore:Play()
    end)
end

-- ✅ Force teleport (X-only, max range, stun-proof)
local function teleport()
    local hrp = getHRP()
    local currentPos = hrp.Position

    local direction = 1
    local range = 150
    local targetX = currentPos.X + (range * direction)
    local targetPos = Vector3.new(targetX, currentPos.Y, currentPos.Z)

    local platform = Instance.new("Part")
    platform.Size = Vector3.new(5, 1, 5)
    platform.Position = Vector3.new(targetX, currentPos.Y - 3, currentPos.Z)
    platform.Anchored = true
    platform.Transparency = 1
    platform.CanCollide = true
    platform.Parent = Workspace

    hrp.CFrame = CFrame.new(platform.Position + Vector3.new(0, 3, 0))
    game:GetService("Debris"):AddItem(platform, 0.5)
end

-- ✅ Real press detection (no drag)
local isDragging = false

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

button.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
    end
end)

button.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if not isDragging then
            animatePress()
            teleport()
        end
    end
end)

-- 📱 Multitouch fix – detects taps even while joystick is held
UserInputService.TouchStarted:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    local touchPos = input.Position
    local absPos = button.AbsolutePosition
    local absSize = button.AbsoluteSize

    local withinX = touchPos.X >= absPos.X and touchPos.X <= absPos.X + absSize.X
    local withinY = touchPos.Y >= absPos.Y and touchPos.Y <= absPos.Y + absSize.Y

    if withinX and withinY then
        animatePress()
        teleport()
    end
end)
