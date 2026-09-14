local ScriptSense = {}
ScriptSense.Version = "7.7.4"
ScriptSense.Active = true

-- Services Retrieval
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    repeat task.wait() LocalPlayer = Players.LocalPlayer until LocalPlayer
end

local Camera = Workspace.CurrentCamera

-- Robust Event-Driven Roblox Menu Tracking
local isRobloxMenuOpen = false

GuiService.MenuOpened:Connect(function()
    isRobloxMenuOpen = true
end)

GuiService.MenuClosed:Connect(function()
    isRobloxMenuOpen = false
end)

local function IsRobloxMenuOpen()
    if isRobloxMenuOpen then return true end
    local success, isOpen = pcall(function()
        return GuiService:IsMenuOpen()
    end)
    return success and isOpen or false
end

-- Global Configuration Registry
ScriptSense.Config = {
    AimbotEnabled = false,
    WallhackEnabled = false,
    GodmodeEnabled = false,
    FlyEnabled = false,
    SkeletonEspEnabled = false,
    BoxEspEnabled = false,
    NameEspEnabled = false,
    AntiAimEnabled = false,
    SpeedhackEnabled = false,

    FlySpeed = 50,
    SpeedhackSpeed = 32,
    DefaultWalkSpeed = 16,
    SpinSpeed = 25,
    AntiAimHeadAngle = 90,
    AimbotSmoothness = 4,
    AimbotFovRadius = 150,
    CurrentSpinAngle = 0,
    TpTarget = "",

    Keybinds = {
        Wallhack = Enum.KeyCode.G,
        Aimbot = Enum.KeyCode.R,
        Godmode = Enum.KeyCode.C,
        Fly = Enum.KeyCode.F,
        Skeleton = Enum.KeyCode.X,
        BoxEsp = Enum.KeyCode.B,
        NameEsp = Enum.KeyCode.N,
        AntiAim = Enum.KeyCode.U,
        Speedhack = Enum.KeyCode.V,
        MenuToggle = Enum.KeyCode.Backquote,
    }
}

local function SafeDestroy(instance)
    if instance and typeof(instance) == "Instance" then
        pcall(function() instance:Destroy() end)
    end
end

-- Full Cleanup of previous instances
local successHui, huiContainer = pcall(function() return gethui() end)
if successHui and huiContainer then
    for _, child in ipairs(huiContainer:GetChildren()) do
        if child.Name == "ScriptSenseEnterpriseGUI" or child.Name == "ScriptSenseESPContainer" then
            SafeDestroy(child)
        end
    end
end

pcall(function()
    for _, child in ipairs(CoreGui:GetChildren()) do
        if child.Name == "ScriptSenseEnterpriseGUI" or child.Name == "ScriptSenseESPContainer" then
            SafeDestroy(child)
        end
    end
end)

pcall(function()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        for _, child in ipairs(pg:GetChildren()) do
            if child.Name == "ScriptSenseEnterpriseGUI" or child.Name == "ScriptSenseESPContainer" then
                SafeDestroy(child)
            end
        end
    end
end)

-- Main UI Container (PlayerGui priority for Opium macOS compatibility)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptSenseEnterpriseGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

local playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
if playerGui then
    ScreenGui.Parent = playerGui
else
    pcall(function() ScreenGui.Parent = CoreGui end)
end

local ESPContainer = Instance.new("Folder")
ESPContainer.Name = "ScriptSenseESPContainer"
ESPContainer.Parent = ScreenGui

-- Ultra-smooth & perfectly round FOV Circle Initialization (NumSides = 128)
local fovCircle = nil
pcall(function()
    fovCircle = Drawing.new("Circle")
    fovCircle.Visible = false
    fovCircle.Thickness = 1.5
    fovCircle.Color = Color3.fromRGB(255, 255, 255)
    fovCircle.Filled = false
    fovCircle.Transparency = 0.9
    fovCircle.NumSides = 128
end)

-- Watermark Container
local WatermarkContainer = Instance.new("Frame")
WatermarkContainer.Name = "WatermarkContainer"
WatermarkContainer.AnchorPoint = Vector2.new(0, 0)
WatermarkContainer.Size = UDim2.new(0, 0, 0, 45)
WatermarkContainer.Position = UDim2.new(0, 20, 0, 15)
WatermarkContainer.BackgroundTransparency = 1
WatermarkContainer.AutomaticSize = Enum.AutomaticSize.X
WatermarkContainer.Parent = ScreenGui

local WatermarkLayout = Instance.new("UIListLayout")
WatermarkLayout.FillDirection = Enum.FillDirection.Horizontal
WatermarkLayout.SortOrder = Enum.SortOrder.LayoutOrder
WatermarkLayout.VerticalAlignment = Enum.VerticalAlignment.Center
WatermarkLayout.Padding = UDim.new(0, 8)
WatermarkLayout.Parent = WatermarkContainer

local WatermarkLabel = Instance.new("TextLabel")
WatermarkLabel.Name = "WatermarkLabel"
WatermarkLabel.Size = UDim2.new(0, 0, 1, 0)
WatermarkLabel.AutomaticSize = Enum.AutomaticSize.X
WatermarkLabel.BackgroundTransparency = 1
WatermarkLabel.TextSize = 20
WatermarkLabel.Font = Enum.Font.GothamBold
WatermarkLabel.RichText = true
WatermarkLabel.Text = '<font color="#FFFFFF">SCRIPT</font> <font color="#FF0000">SENSE</font>'
WatermarkLabel.TextXAlignment = Enum.TextXAlignment.Left
WatermarkLabel.LayoutOrder = 1
WatermarkLabel.Parent = WatermarkContainer

-- Menu Toggle Arrow Button
local MenuToggleArrow = Instance.new("TextButton")
MenuToggleArrow.Name = "MenuToggleArrow"
MenuToggleArrow.Size = UDim2.new(0, 26, 0, 26)
MenuToggleArrow.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MenuToggleArrow.BackgroundTransparency = 0.5
MenuToggleArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuToggleArrow.TextTransparency = 0
MenuToggleArrow.TextSize = 13
MenuToggleArrow.Font = Enum.Font.GothamBold
MenuToggleArrow.Text = "▼"
MenuToggleArrow.LayoutOrder = 2
MenuToggleArrow.Parent = WatermarkContainer

local ArrowStroke = Instance.new("UIStroke")
ArrowStroke.Color = Color3.fromRGB(60, 60, 60)
ArrowStroke.Thickness = 1
ArrowStroke.Parent = MenuToggleArrow

-- Main Control Panel Frame
local MainControlPanel = Instance.new("Frame")
MainControlPanel.Name = "MainControlPanel"
MainControlPanel.Size = UDim2.new(0, 260, 0, 480)
MainControlPanel.Position = UDim2.new(0, 20, 0, 65)
MainControlPanel.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainControlPanel.BorderSizePixel = 0
MainControlPanel.ClipsDescendants = true
MainControlPanel.Visible = false
MainControlPanel.Parent = ScreenGui

local PanelStroke = Instance.new("UIStroke")
PanelStroke.Color = Color3.fromRGB(50, 50, 50)
PanelStroke.Thickness = 2
PanelStroke.Parent = MainControlPanel

-- Main Panel Title Bar
local MainTitleBar = Instance.new("Frame")
MainTitleBar.Size = UDim2.new(1, 0, 0, 35)
MainTitleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainTitleBar.BorderSizePixel = 0
MainTitleBar.Parent = MainControlPanel

local MainTitleLabel = Instance.new("TextLabel")
MainTitleLabel.Size = UDim2.new(1, -15, 1, 0)
MainTitleLabel.Position = UDim2.new(0, 12, 0, 0)
MainTitleLabel.BackgroundTransparency = 1
MainTitleLabel.RichText = true
MainTitleLabel.Text = '<font color="#FFFFFF">SCRIPT</font> <font color="#FF0000">SENSE</font> <font color="#AAAAAA">v' .. ScriptSense.Version .. '</font>'
MainTitleLabel.Font = Enum.Font.GothamBold
MainTitleLabel.TextSize = 12
MainTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
MainTitleLabel.Parent = MainTitleBar

-- Main Footer Bar
local MainFooterBar = Instance.new("Frame")
MainFooterBar.Name = "MainFooterBar"
MainFooterBar.Size = UDim2.new(1, 0, 0, 30)
MainFooterBar.Position = UDim2.new(0, 0, 1, -30)
MainFooterBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFooterBar.BorderSizePixel = 0
MainFooterBar.Parent = MainControlPanel

local MainFooterLabel = Instance.new("TextLabel")
MainFooterLabel.Size = UDim2.new(1, -15, 1, 0)
MainFooterLabel.Position = UDim2.new(0, 12, 0, 0)
MainFooterLabel.BackgroundTransparency = 1
MainFooterLabel.RichText = true
MainFooterLabel.Text = '<font color="#FFFFFF">SCRIPT</font> <font color="#FF0000">SENSE</font> <font color="#AAAAAA">v' .. ScriptSense.Version .. '</font>'
MainFooterLabel.Font = Enum.Font.GothamBold
MainFooterLabel.TextSize = 10
MainFooterLabel.TextXAlignment = Enum.TextXAlignment.Left
MainFooterLabel.Parent = MainFooterBar

local MainContainer = Instance.new("ScrollingFrame")
MainContainer.Name = "MainContainer"
MainContainer.Size = UDim2.new(1, 0, 1, -65)
MainContainer.Position = UDim2.new(0, 0, 0, 35)
MainContainer.BackgroundTransparency = 1
MainContainer.BorderSizePixel = 0
MainContainer.ScrollBarThickness = 4
MainContainer.Active = true
MainContainer.Parent = MainControlPanel

local MainListLayout = Instance.new("UIListLayout")
MainListLayout.SortOrder = Enum.SortOrder.LayoutOrder
MainListLayout.Padding = UDim.new(0, 4)
MainListLayout.Parent = MainContainer

local isPanelVisible = false
local function ToggleMenuVisibility()
    isPanelVisible = not isPanelVisible
    MainControlPanel.Visible = isPanelVisible
    MenuToggleArrow.Text = isPanelVisible and "▲" or "▼"
end

MenuToggleArrow.MouseButton1Click:Connect(ToggleMenuVisibility)

-- Keybinds Menu Window
local KeybindsMenuWindow = Instance.new("Frame")
KeybindsMenuWindow.Name = "KeybindsMenuWindow"
KeybindsMenuWindow.Size = UDim2.new(0, 320, 0, 420)
KeybindsMenuWindow.Position = UDim2.new(0.5, -160, 0.5, -210)
KeybindsMenuWindow.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
KeybindsMenuWindow.BorderSizePixel = 0
KeybindsMenuWindow.ClipsDescendants = true
KeybindsMenuWindow.Visible = false
KeybindsMenuWindow.Parent = ScreenGui

local KbStroke = Instance.new("UIStroke")
KbStroke.Color = Color3.fromRGB(70, 70, 70)
KbStroke.Thickness = 2
KbStroke.Parent = KeybindsMenuWindow

local KbTitleBar = Instance.new("Frame")
KbTitleBar.Size = UDim2.new(1, 0, 0, 35)
KbTitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
KbTitleBar.BorderSizePixel = 0
KbTitleBar.Parent = KeybindsMenuWindow

local KbTitle = Instance.new("TextLabel")
KbTitle.Size = UDim2.new(1, -35, 1, 0)
KbTitle.Position = UDim2.new(0, 12, 0, 0)
KbTitle.BackgroundTransparency = 1
KbTitle.RichText = true
KbTitle.Text = '<font color="#FFFFFF">SCRIPT</font> <font color="#FF0000">SENSE</font> — KEYBIND MANAGER'
KbTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KbTitle.TextSize = 12
KbTitle.Font = Enum.Font.GothamBold
KbTitle.TextXAlignment = Enum.TextXAlignment.Left
KbTitle.Parent = KbTitleBar

local KbCloseBtn = Instance.new("TextButton")
KbCloseBtn.Size = UDim2.new(0, 35, 0, 35)
KbCloseBtn.Position = UDim2.new(1, -35, 0, 0)
KbCloseBtn.BackgroundTransparency = 1
KbCloseBtn.Text = "✕"
KbCloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
KbCloseBtn.Font = Enum.Font.GothamBold
KbCloseBtn.TextSize = 14
KbCloseBtn.Parent = KbTitleBar

KbCloseBtn.MouseButton1Click:Connect(function()
    KeybindsMenuWindow.Visible = false
end)

local KbContainer = Instance.new("ScrollingFrame")
KbContainer.Name = "KbContainer"
KbContainer.Size = UDim2.new(1, 0, 1, -35)
KbContainer.Position = UDim2.new(0, 0, 0, 35)
KbContainer.BackgroundTransparency = 1
KbContainer.BorderSizePixel = 0
KbContainer.ScrollBarThickness = 6
KbContainer.Active = true
KbContainer.Parent = KeybindsMenuWindow

local KbListLayout = Instance.new("UIListLayout")
KbListLayout.SortOrder = Enum.SortOrder.LayoutOrder
KbListLayout.Padding = UDim.new(0, 4)
KbListLayout.Parent = KbContainer

local ToggleKeybindsMenu = function()
    KeybindsMenuWindow.Visible = not KeybindsMenuWindow.Visible
end

-- SCRIPT SENSE FLING GUI Window
local FlingGuiWindow = Instance.new("Frame")
FlingGuiWindow.Name = "FlingGuiWindow"
FlingGuiWindow.Size = UDim2.new(0, 240, 0, 130)
FlingGuiWindow.Position = UDim2.new(0.5, 130, 0.5, -210)
FlingGuiWindow.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
FlingGuiWindow.BorderSizePixel = 0
FlingGuiWindow.ClipsDescendants = true
FlingGuiWindow.Visible = false
FlingGuiWindow.Parent = ScreenGui

local FlingStroke = Instance.new("UIStroke")
FlingStroke.Color = Color3.fromRGB(70, 70, 70)
FlingStroke.Thickness = 2
FlingStroke.Parent = FlingGuiWindow

local FlingTitleBar = Instance.new("Frame")
FlingTitleBar.Size = UDim2.new(1, 0, 0, 35)
FlingTitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FlingTitleBar.BorderSizePixel = 0
FlingTitleBar.Parent = FlingGuiWindow

local FlingTitle = Instance.new("TextLabel")
FlingTitle.Size = UDim2.new(1, -35, 1, 0)
FlingTitle.Position = UDim2.new(0, 12, 0, 0)
FlingTitle.BackgroundTransparency = 1
FlingTitle.RichText = true
FlingTitle.Text = '<font color="#FFFFFF">SCRIPT SENSE</font> <font color="#FF0000">FLING GUI</font>'
FlingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingTitle.TextSize = 12
FlingTitle.Font = Enum.Font.GothamBold
FlingTitle.TextXAlignment = Enum.TextXAlignment.Left
FlingTitle.Parent = FlingTitleBar

local FlingCloseBtn = Instance.new("TextButton")
FlingCloseBtn.Size = UDim2.new(0, 35, 0, 35)
FlingCloseBtn.Position = UDim2.new(1, -35, 0, 0)
FlingCloseBtn.BackgroundTransparency = 1
FlingCloseBtn.Text = "✕"
FlingCloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
FlingCloseBtn.Font = Enum.Font.GothamBold
FlingCloseBtn.TextSize = 14
FlingCloseBtn.Parent = FlingTitleBar

FlingCloseBtn.MouseButton1Click:Connect(function()
    FlingGuiWindow.Visible = false
end)

local FlingActionButton = Instance.new("TextButton")
FlingActionButton.Size = UDim2.new(1, -24, 0, 45)
FlingActionButton.Position = UDim2.new(0, 12, 0, 55)
FlingActionButton.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
FlingActionButton.BorderSizePixel = 0
FlingActionButton.Text = "Включить Fling"
FlingActionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingActionButton.Font = Enum.Font.GothamBold
FlingActionButton.TextSize = 13
FlingActionButton.Parent = FlingGuiWindow

local flingActive = false
FlingActionButton.MouseButton1Click:Connect(function()
    flingActive = not flingActive
    if flingActive then
        FlingActionButton.Text = "Выключить Fling"
        FlingActionButton.BackgroundColor3 = Color3.fromRGB(50, 170, 50)
        task.spawn(function()
            while flingActive do
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local rootPart = character.HumanoidRootPart
                    local bav = rootPart:FindFirstChild("ScriptSenseFlingVelocity")
                    if not bav then
                        bav = Instance.new("BodyAngularVelocity")
                        bav.Name = "ScriptSenseFlingVelocity"
                        bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                        bav.AngularVelocity = Vector3.new(0, 99999, 0)
                        bav.Parent = rootPart
                    end
                end
                task.wait()
            end
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local bav = character.HumanoidRootPart:FindFirstChild("ScriptSenseFlingVelocity")
                if bav then bav:Destroy() end
            end
        end)
    else
        FlingActionButton.Text = "Включить Fling"
        FlingActionButton.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local bav = character.HumanoidRootPart:FindFirstChild("ScriptSenseFlingVelocity")
            if bav then bav:Destroy() end
        end
    end
end)

local controlRowUpdateCallbacks = {}
local controlRowFrames = {}

local function CreateControlRow(parent, initialText, callback, updateCallback)
    local rowFrame = Instance.new("Frame")
    rowFrame.Size = UDim2.new(1, 0, 0, 38)
    rowFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    rowFrame.BackgroundTransparency = 0.2
    rowFrame.BorderSizePixel = 0
    rowFrame.Visible = true
    rowFrame.Parent = parent

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(45, 45, 45)
    stroke.Thickness = 1
    stroke.Parent = rowFrame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.TextColor3 = Color3.fromRGB(230, 230, 230)
    button.TextSize = 13
    button.Font = Enum.Font.GothamMedium
    button.Text = initialText
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.Parent = rowFrame

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.Parent = button

    if callback then
        button.MouseButton1Click:Connect(function()
            pcall(callback)
            if updateCallback then updateCallback(button) end
        end)
    end

    if updateCallback then
        table.insert(controlRowUpdateCallbacks, function()
            updateCallback(button)
        end)
    end

    table.insert(controlRowFrames, rowFrame)
    return rowFrame, button
end

local function CreateTextBoxRow(parent, labelText, initialValue, onTextChanged)
    local rowFrame = Instance.new("Frame")
    rowFrame.Size = UDim2.new(1, 0, 0, 38)
    rowFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    rowFrame.BackgroundTransparency = 0.2
    rowFrame.BorderSizePixel = 0
    rowFrame.Visible = true
    rowFrame.Parent = parent

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(45, 45, 45)
    stroke.Thickness = 1
    stroke.Parent = rowFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = "  " .. labelText
    label.Parent = rowFrame

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0, 70, 0, 24)
    textBox.Position = UDim2.new(1, -82, 0.5, -12)
    textBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    textBox.BackgroundTransparency = 0
    textBox.BorderSizePixel = 0
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 12
    textBox.Font = Enum.Font.GothamMedium
    textBox.Text = tostring(initialValue)
    textBox.ClearTextOnFocus = false
    textBox.Parent = rowFrame

    local tbStroke = Instance.new("UIStroke")
    tbStroke.Color = Color3.fromRGB(50, 50, 50)
    tbStroke.Thickness = 1
    tbStroke.Parent = textBox

    textBox.FocusLost:Connect(function(enterPressed)
        local num = tonumber(textBox.Text)
        if num then
            onTextChanged(num)
            textBox.Text = tostring(num)
        else
            onTextChanged(textBox.Text)
        end
    end)

    table.insert(controlRowFrames, rowFrame)
    return rowFrame
end

local function GetKeyName(keyCode)
    local name = keyCode.Name
    if name == "Backquote" then return "`" end
    return string.lower(name)
end

-- Create Keybind manager rows inside KeybindsMenuWindow
for featureName, keyEnum in pairs(ScriptSense.Config.Keybinds) do
    CreateControlRow(KbContainer, featureName .. " bind: " .. GetKeyName(keyEnum), function(btn)
        btn.Text = "  [press any key for " .. string.lower(featureName) .. "]..."
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                ScriptSense.Config.Keybinds[featureName] = input.KeyCode
                btn.Text = "  " .. string.lower(featureName) .. " bind: " .. GetKeyName(input.KeyCode)
                if connection then connection:Disconnect() end
            end
        end)
    end)
end

-- Populate Panel Rows
CreateControlRow(MainContainer, "wallhack: off | bind: g", function()
    ScriptSense.Config.WallhackEnabled = not ScriptSense.Config.WallhackEnabled
end, function(btn)
    local status = ScriptSense.Config.WallhackEnabled and "on" or "off"
    btn.Text = "  wallhack: " .. status .. " | bind: " .. string.lower(GetKeyName(ScriptSense.Config.Keybinds.Wallhack))
end)

CreateControlRow(MainContainer, "aimbot: off | bind: r", function()
    if not IsRobloxMenuOpen() then ScriptSense.Config.AimbotEnabled = not ScriptSense.Config.AimbotEnabled end
end, function(btn)
    local status = ScriptSense.Config.AimbotEnabled and "on" or "off"
    btn.Text = "  aimbot: " .. status .. " | bind: " .. string.lower(GetKeyName(ScriptSense.Config.Keybinds.Aimbot))
end)

CreateTextBoxRow(MainContainer, "aimbot | fov radius", ScriptSense.Config.AimbotFovRadius, function(val)
    ScriptSense.Config.AimbotFovRadius = tonumber(val) or ScriptSense.Config.AimbotFovRadius
    if fovCircle then fovCircle.Radius = ScriptSense.Config.AimbotFovRadius end
end)

CreateControlRow(MainContainer, "godmode: off | bind: c", function()
    ScriptSense.Config.GodmodeEnabled = not ScriptSense.Config.GodmodeEnabled
end, function(btn)
    local status = ScriptSense.Config.GodmodeEnabled and "on" or "off"
    btn.Text = "  godmode: " .. status .. " | bind: " .. string.lower(GetKeyName(ScriptSense.Config.Keybinds.Godmode))
end)

CreateControlRow(MainContainer, "fly: off | bind: f", function()
    ScriptSense.Config.FlyEnabled = not ScriptSense.Config.FlyEnabled
end, function(btn)
    local status = ScriptSense.Config.FlyEnabled and "on" or "off"
    btn.Text = "  fly: " .. status .. " | bind: " .. string.lower(GetKeyName(ScriptSense.Config.Keybinds.Fly))
end)

CreateControlRow(MainContainer, "skeleton esp: off | bind: x", function()
    ScriptSense.Config.SkeletonEspEnabled = not ScriptSense.Config.SkeletonEspEnabled
end, function(btn)
    local status = ScriptSense.Config.SkeletonEspEnabled and "on" or "off"
    btn.Text = "  skeleton esp: " .. status .. " | bind: " .. string.lower(GetKeyName(ScriptSense.Config.Keybinds.Skeleton))
end)

CreateControlRow(MainContainer, "box esp: off | bind: b", function()
    ScriptSense.Config.BoxEspEnabled = not ScriptSense.Config.BoxEspEnabled
end, function(btn)
    local status = ScriptSense.Config.BoxEspEnabled and "on" or "off"
    btn.Text = "  box esp: " .. status .. " | bind: " .. string.lower(GetKeyName(ScriptSense.Config.Keybinds.BoxEsp))
end)

CreateControlRow(MainContainer, "name esp: off | bind: n", function()
    ScriptSense.Config.NameEspEnabled = not ScriptSense.Config.NameEspEnabled
end, function(btn)
    local status = ScriptSense.Config.NameEspEnabled and "on" or "off"
    btn.Text = "  name esp: " .. status .. " | bind: " .. string.lower(GetKeyName(ScriptSense.Config.Keybinds.NameEsp))
end)

CreateControlRow(MainContainer, "speedhack: off | bind: v", function()
    ScriptSense.Config.SpeedhackEnabled = not ScriptSense.Config.SpeedhackEnabled
    if not ScriptSense.Config.SpeedhackEnabled then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = ScriptSense.Config.DefaultWalkSpeed end
    end
end, function(btn)
    local status = ScriptSense.Config.SpeedhackEnabled and "on" or "off"
    btn.Text = "  speedhack: " .. status .. " | bind: " .. string.lower(GetKeyName(ScriptSense.Config.Keybinds.Speedhack))
end)

CreateTextBoxRow(MainContainer, "speedhack | speed", ScriptSense.Config.SpeedhackSpeed, function(val)
    ScriptSense.Config.SpeedhackSpeed = tonumber(val) or ScriptSense.Config.SpeedhackSpeed
end)

CreateControlRow(MainContainer, "anti-aim: off | bind: u", function()
    ScriptSense.Config.AntiAimEnabled = not ScriptSense.Config.AntiAimEnabled
end, function(btn)
    local status = ScriptSense.Config.AntiAimEnabled and "on" or "off"
    btn.Text = "  anti-aim: " .. status .. " | bind: " .. string.lower(GetKeyName(ScriptSense.Config.Keybinds.AntiAim))
end)

CreateTextBoxRow(MainContainer, "anti aim | speed", ScriptSense.Config.SpinSpeed, function(val)
    ScriptSense.Config.SpinSpeed = tonumber(val) or ScriptSense.Config.SpinSpeed
end)

CreateTextBoxRow(MainContainer, "anti aim | angle", ScriptSense.Config.AntiAimHeadAngle, function(val)
    ScriptSense.Config.AntiAimHeadAngle = tonumber(val) or ScriptSense.Config.AntiAimHeadAngle
end)

CreateTextBoxRow(MainContainer, "tp | target name", ScriptSense.Config.TpTarget, function(val)
    ScriptSense.Config.TpTarget = tostring(val)
end)

CreateControlRow(MainContainer, "teleport to player", function()
    local targetName = string.lower(ScriptSense.Config.TpTarget or "")
    if targetName == "" then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and (string.sub(string.lower(player.Name), 1, #targetName) == targetName or string.sub(string.lower(player.DisplayName), 1, #targetName) == targetName) then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
            end
            break
        end
    end
end)

CreateControlRow(MainContainer, "open fling gui", function()
    FlingGuiWindow.Visible = not FlingGuiWindow.Visible
end)

CreateControlRow(MainContainer, "keybinds manager", function()
    ToggleKeybindsMenu()
end)

-- Global Keybinds Listener
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if UserInputService:GetFocusedTextBox() then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local keyCode = input.KeyCode
        
        if keyCode == ScriptSense.Config.Keybinds.MenuToggle then
            ToggleMenuVisibility()
        elseif keyCode == ScriptSense.Config.Keybinds.Wallhack then
            ScriptSense.Config.WallhackEnabled = not ScriptSense.Config.WallhackEnabled
        elseif keyCode == ScriptSense.Config.Keybinds.Aimbot then
            if not IsRobloxMenuOpen() then
                ScriptSense.Config.AimbotEnabled = not ScriptSense.Config.AimbotEnabled
            end
        elseif keyCode == ScriptSense.Config.Keybinds.Godmode then
            ScriptSense.Config.GodmodeEnabled = not ScriptSense.Config.GodmodeEnabled
        elseif keyCode == ScriptSense.Config.Keybinds.Fly then
            ScriptSense.Config.FlyEnabled = not ScriptSense.Config.FlyEnabled
        elseif keyCode == ScriptSense.Config.Keybinds.Skeleton then
            ScriptSense.Config.SkeletonEspEnabled = not ScriptSense.Config.SkeletonEspEnabled
        elseif keyCode == ScriptSense.Config.Keybinds.BoxEsp then
            ScriptSense.Config.BoxEspEnabled = not ScriptSense.Config.BoxEspEnabled
        elseif keyCode == ScriptSense.Config.Keybinds.NameEsp then
            ScriptSense.Config.NameEspEnabled = not ScriptSense.Config.NameEspEnabled
        elseif keyCode == ScriptSense.Config.Keybinds.Speedhack then
            ScriptSense.Config.SpeedhackEnabled = not ScriptSense.Config.SpeedhackEnabled
            if not ScriptSense.Config.SpeedhackEnabled then
                local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.WalkSpeed = ScriptSense.Config.DefaultWalkSpeed end
            end
        elseif keyCode == ScriptSense.Config.Keybinds.AntiAim then
            ScriptSense.Config.AntiAimEnabled = not ScriptSense.Config.AntiAimEnabled
        end
        
        for _, updateCb in ipairs(controlRowUpdateCallbacks) do
            pcall(updateCb)
        end
    end
end)

-- Main Loop
local activeDrawings = {}

local function ClearDrawings()
    for _, drawing in pairs(activeDrawings) do
        SafeDestroy(drawing)
    end
    activeDrawings = {}
end

RunService.RenderStepped:Connect(function(dt)
    if fovCircle then
        if ScriptSense.Config.AimbotEnabled then
            fovCircle.Visible = true
            fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            fovCircle.Radius = ScriptSense.Config.AimbotFovRadius
            fovCircle.NumSides = 128
        else
            fovCircle.Visible = false
        end
    end

    if ScriptSense.Config.SpeedhackEnabled then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = ScriptSense.Config.SpeedhackSpeed
        end
    end

    if ScriptSense.Config.AntiAimEnabled then
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if root and hum then
            hum.AutoRotate = false
            ScriptSense.Config.CurrentSpinAngle = (ScriptSense.Config.CurrentSpinAngle + ScriptSense.Config.SpinSpeed) % 360
            local camLook = Camera.CFrame.LookVector
            local camFlat = Vector3.new(camLook.X, 0, camLook.Z).Unit
            if camFlat.Magnitude == 0 then camFlat = Vector3.new(0, 0, -1) end
            local yawCFrame = CFrame.new(root.Position, root.Position + camFlat)
            root.CFrame = yawCFrame * CFrame.Angles(0, math.rad(ScriptSense.Config.CurrentSpinAngle), 0)
        end
    else
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.AutoRotate = true
        end
    end

    if ScriptSense.Config.AimbotEnabled and not IsRobloxMenuOpen() then
        local closestPlayer = nil
        local shortestDist = ScriptSense.Config.AimbotFovRadius
        local mousePos = UserInputService:GetMouseLocation()

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local rootPart = player.Character.HumanoidRootPart
                    local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            closestPlayer = player
                        end
                    end
                end
            end
        end

        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
            local targetHead = closestPlayer.Character.Head
            local targetPos = targetHead.Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), 1 / ScriptSense.Config.AimbotSmoothness)
        end
    end

    ClearDrawings()
    if ScriptSense.Config.BoxEspEnabled or ScriptSense.Config.SkeletonEspEnabled or ScriptSense.Config.NameEspEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local char = player.Character
                local rootPart = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                local humanoid = char:FindFirstChildOfClass("Humanoid")

                if rootPart and head and humanoid and humanoid.Health > 0 then
                    local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    if onScreen then
                        if ScriptSense.Config.BoxEspEnabled then
                            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                            local legPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                            local height = math.abs(headPos.Y - legPos.Y)
                            local width = height / 2

                            local box = Instance.new("Frame")
                            box.Name = "BoxESP"
                            box.Size = UDim2.new(0, width, 0, height)
                            box.Position = UDim2.new(0, rootPos.X - width/2, 0, headPos.Y)
                            box.BackgroundTransparency = 1
                            box.BorderSizePixel = 0
                            box.Parent = ESPContainer

                            local boxStroke = Instance.new("UIStroke")
                            boxStroke.Color = Color3.fromRGB(255, 50, 50)
                            boxStroke.Thickness = 1
                            box.Parent = box
                            boxStroke.Parent = box
                            table.insert(activeDrawings, box)
                        end

                        if ScriptSense.Config.NameEspEnabled then
                            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
                            local nameLabel = Instance.new("TextLabel")
                            nameLabel.Name = "NameESP"
                            nameLabel.Size = UDim2.new(0, 150, 0, 20)
                            nameLabel.Position = UDim2.new(0, headPos.X - 75, 0, headPos.Y - 20)
                            nameLabel.BackgroundTransparency = 1
                            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                            nameLabel.TextSize = 12
                            nameLabel.Font = Enum.Font.GothamBold
                            nameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
                            nameLabel.Parent = ESPContainer
                            table.insert(activeDrawings, nameLabel)
                        end

                        if ScriptSense.Config.SkeletonEspEnabled then
                            local function drawBone(part1, part2)
                                if part1 and part2 then
                                    local p1, s1 = Camera:WorldToViewportPoint(part1.Position)
                                    local p2, s2 = Camera:WorldToViewportPoint(part2.Position)
                                    if s1 and s2 then
                                        local line = Instance.new("Frame")
                                        local dist = (Vector2.new(p1.X, p1.Y) - Vector2.new(p2.X, p2.Y)).Magnitude
                                        line.Size = UDim2.new(0, 1, 0, dist)
                                        line.Position = UDim2.new(0, (p1.X + p2.X) / 2, 0, (p1.Y + p2.Y) / 2)
                                        line.AnchorPoint = Vector2.new(0.5, 0.5)
                                        line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                        line.BorderSizePixel = 0
                                        line.Rotation = math.deg(math.atan2(p2.Y - p1.Y, p2.X - p1.X)) - 90
                                        line.Parent = ESPContainer
                                        table.insert(activeDrawings, line)
                                    end
                                end
                            end

                            local upperTorso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                            local lowerTorso = char:FindFirstChild("LowerTorso") or upperTorso
                            local leftUpperArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
                            local rightUpperArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
                            local leftUpperLeg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg")
                            local rightUpperLeg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg")

                            drawBone(head, upperTorso)
                            drawBone(upperTorso, leftUpperArm)
                            drawBone(upperTorso, rightUpperArm)
                            drawBone(lowerTorso, leftUpperLeg)
                            drawBone(lowerTorso, rightUpperLeg)
                        end
                    end
                end
            end
        end
    end
end)
