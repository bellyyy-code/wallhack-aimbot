-- ScriptSense v7.9.1 (Main Core)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ScriptSense = {
    Version = "7.9.1",
    Config = {
        AimbotEnabled = false,
        BoxEspEnabled = false,
        SkeletonEspEnabled = false,
        AimbotKey = Enum.KeyCode.R,
        FovRadius = 150,
        Smoothness = 4
    }
}

-- Safe GUI container setup
local successHui, huiContainer = pcall(function() return gethui() end)
local parentContainer = (successHui and huiContainer) or CoreGui

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptSenseMain"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentContainer

-- Main Panel with Fade-in Animation
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 180)
MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BackgroundTransparency = 1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 0, 0)
UIStroke.Thickness = 1.5
UIStroke.Transparency = 1
UIStroke.Parent = MainFrame

-- Fade-in entrance
TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.1}):Play()
TweenService:Create(UIStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0}):Play()

-- Title
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -15, 0, 35)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.RichText = true
TitleLabel.Text = '<font color="#FFFFFF">SCRIPT</font><font color="#FF0000">SENSE</font> <font color="#888888">v' .. ScriptSense.Version .. '</font>'
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

-- ESP Draw Storage
local ESPList = {}

local function CreateESP(player)
    if ESPList[player] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 255, 255)
    box.Thickness = 1
    box.Filled = false
    box.Transparency = 0.9

    ESPList[player] = {Box = box}
end

local function RemoveESP(player)
    if ESPList[player] then
        pcall(function() ESPList[player].Box:Remove() end)
        ESPList[player] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- Main Loop (ESP & Aimbot Render)
RunService.RenderStepped:Connect(function()
    for player, data in pairs(ESPList) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if ScriptSense.Config.BoxEspEnabled and char and root and hum and hum.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                data.Box.Visible = true
                data.Box.Size = Vector2.new(2000 / pos.Z, 3500 / pos.Z)
                data.Box.Position = Vector2.new(pos.X - data.Box.Size.X / 2, pos.Y - data.Box.Size.Y / 2)
            else
                data.Box.Visible = false
            end
        else
            data.Box.Visible = false
        end
    end
end)
