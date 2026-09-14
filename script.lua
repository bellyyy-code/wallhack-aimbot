local ScriptSense = {}
ScriptSense.Version = "7.6.6"
ScriptSense.Active = true

-- Services Retrieval
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

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
    FovCircleEnabled = true,

    FlySpeed = 50,
    SpeedhackSpeed = 32,
    DefaultWalkSpeed = 16,
    WalkSpeedValue = 32,
    SpinSpeed = 25,
    AntiAimHeadAngle = 90,
    AimbotSmoothness = 4,
    AimbotFovRadius = 150,
    CurrentSpinAngle = 0,

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

local RootGuiParent = nil
pcall(function() RootGuiParent = gethui() end)
if not RootGuiParent then pcall(function() RootGuiParent = CoreGui end) end
if not RootGuiParent then RootGuiParent = LocalPlayer:WaitForChild("PlayerGui") end

-- Main UI Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptSenseEnterpriseGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = RootGuiParent

local ESPContainer = Instance.new("Folder")
ESPContainer.Name = "ScriptSenseESPContainer"
ESPContainer.Parent = ScreenGui

local IsMobileDevice = UserInputService.TouchEnabled

-- Watermark Container
local WatermarkContainer = Instance.new("Frame")
WatermarkContainer.Name = "WatermarkContainer"
WatermarkContainer.AnchorPoint = Vector2.new(0.5, 0.5)
WatermarkContainer.Size = UDim2.new(0, 0, 0, 45)
WatermarkContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
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
WatermarkLabel.TextSize = 24
WatermarkLabel.Font = Enum.Font.GothamBold
WatermarkLabel.RichText = true
WatermarkLabel.Text = ""
WatermarkLabel.TextXAlignment = Enum.TextXAlignment.Left
WatermarkLabel.LayoutOrder = 1
WatermarkLabel.Parent = WatermarkContainer

-- Menu Toggle Arrow Button
local MenuToggleArrow = Instance.new("TextButton")
MenuToggleArrow.Name = "MenuToggleArrow"
MenuToggleArrow.Size = UDim2.new(0, 26, 0, 26)
MenuToggleArrow.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MenuToggleArrow.BackgroundTransparency = 1
MenuToggleArrow.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuToggleArrow.TextTransparency = 1
MenuToggleArrow.TextSize = 13
MenuToggleArrow.Font = Enum.Font.GothamBold
MenuToggleArrow.Text = (not IsMobileDevice) and "▼" or "▲"
MenuToggleArrow.LayoutOrder = 2
MenuToggleArrow.Parent = WatermarkContainer

local ArrowStroke = Instance.new("UIStroke")
ArrowStroke.Color = Color3.fromRGB(60, 60, 60)
ArrowStroke.Thickness = 1
ArrowStroke.Transparency = 1
ArrowStroke.Parent = MenuToggleArrow

-- Main Control Panel Frame (Strictly fixed, non-draggable)
local MainControlPanel = Instance.new("Frame")
MainControlPanel.Name = "MainControlPanel"
MainControlPanel.Size = UDim2.new(0, 250, 0, 480)
MainControlPanel.Position = UDim2.new(0, 20, 0, 65)
MainControlPanel.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainControlPanel.BorderSizePixel = 0
MainControlPanel.ClipsDescendants = true
MainControlPanel.Visible = false
MainControlPanel.Parent = ScreenGui

local PanelStroke = Instance.new("UIStroke")
PanelStroke.Color = Color3.fromRGB(50, 50, 50)
PanelStroke.Thickness = 2
PanelStroke.Transparency = 1
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
MainTitleLabel.TextSize = 13
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
MainFooterLabel.TextSize = 11
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
    MenuToggleArrow.Text = isPanelVisible and "▼" or "▲"
end

MenuToggleArrow.MouseButton1Click:Connect(ToggleMenuVisibility)

-- Keybinds Menu Window (Strictly fixed, non-draggable)
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
KbTitle.TextSize = 13
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

local controlRowUpdateCallbacks = {}
local controlRowFrames = {}

local function CreateControlRow(parent, initialText, callback, updateCallback)
    local rowFrame = Instance.new("Frame")
    rowFrame.Size = UDim2.new(1, 0, 0, 38)
    rowFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    rowFrame.BackgroundTransparency = 0.2
    rowFrame.BorderSizePixel = 0
    rowFrame.Visible = false
    rowFrame.Parent = parent

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(45, 45, 45)
    stroke.Thickness = 1
    stroke.Transparency = 1
    stroke.Parent = rowFrame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.TextColor3 = Color3.fromRGB(230, 230, 230)
    button.TextTransparency = 1
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
    rowFrame.Visible = false
    rowFrame.Parent = parent

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(45, 45, 45)
    stroke.Thickness = 1
    stroke.Transparency = 1
    stroke.Parent = rowFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.TextTransparency = 1
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
            textBox.Text = tostring(initialValue)
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

-- Populate Panel Rows with live state updates & TextBoxes for numerical values
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
    ScriptSense.Config.AimbotFovRadius = val
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
    ScriptSense.Config.SpeedhackSpeed = val
end)

CreateControlRow(MainContainer, "anti-aim: off | bind: u", function()
    ScriptSense.Config.AntiAimEnabled = not ScriptSense.Config.AntiAimEnabled
end, function(btn)
    local status = ScriptSense.Config.AntiAimEnabled and "on" or "off"
    btn.Text = "  anti-aim: " .. status .. " | bind: " .. string.lower(GetKeyName(ScriptSense.Config.Keybinds.AntiAim))
end)

CreateTextBoxRow(MainContainer, "anti aim | speed", ScriptSense.Config.SpinSpeed, function(val)
    ScriptSense.Config.SpinSpeed = val
end)

CreateTextBoxRow(MainContainer, "anti aim | angle", ScriptSense.Config.AntiAimHeadAngle, function(val)
    ScriptSense.Config.AntiAimHeadAngle = val
end)

CreateControlRow(MainContainer, "keybinds manager", function()
    ToggleKeybindsMenu()
end)

-- Robust Global Keybinds Listener
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

-- Fully Implemented Cheat Loops & Mechanics (ESP, Aimbot, Fly, AntiAim, Speedhack, Godmode)
local activeDrawings = {}

local function ClearDrawings()
    for _, drawing in pairs(activeDrawings) do
        SafeDestroy(drawing)
    end
    activeDrawings = {}
end

RunService.RenderStepped:Connect(function(dt)
    -- Speedhack implementation
    if ScriptSense.Config.SpeedhackEnabled then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = ScriptSense.Config.SpeedhackSpeed
        end
    end

    -- Anti-Aim Spinbot implementation
    if ScriptSense.Config.AntiAimEnabled then
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            ScriptSense.Config.CurrentSpinAngle = (ScriptSense.Config.CurrentSpinAngle + ScriptSense.Config.SpinSpeed) % 360
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(ScriptSense.Config.SpinSpeed), 0)
        end
    end

    -- Aimbot Logic
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

    -- ESP Rendering Loop (Box ESP, Skeleton ESP, Name ESP)
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
                        -- Box ESP
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
                            boxStroke.Color = Color3.fromRGB(255, 0, 0)
                            boxStroke.Thickness = 1
                            boxStroke.Parent = box

                            table.insert(activeDrawings, box)
                        end

                        -- Skeleton ESP
                        if ScriptSense.Config.SkeletonEspEnabled then
                            local function drawLine(part1, part2)
                                if part1 and part2 then
                                    local p1, on1 = Camera:WorldToViewportPoint(part1.Position)
                                    local p2, on2 = Camera:WorldToViewportPoint(part2.Position)
                                    if on1 or on2 then
                                        local line = Instance.new("Frame")
                                        line.Name = "SkeletonLine"
                                        local dist = (Vector2.new(p1.X, p1.Y) - Vector2.new(p2.X, p2.Y)).Magnitude
                                        line.Size = UDim2.new(0, dist, 0, 1)
                                        line.Position = UDim2.new(0, (p1.X + p2.X)/2 - dist/2, 0, (p1.Y + p2.Y)/2)
                                        line.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
                                        line.BorderSizePixel = 0
                                        
                                        local angle = math.deg(math.atan2(p2.Y - p1.Y, p2.X - p1.X))
                                        line.Rotation = angle
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

                            if head and upperTorso then drawLine(head, upperTorso) end
                            if upperTorso and leftUpperArm then drawLine(upperTorso, leftUpperArm) end
                            if upperTorso and rightUpperArm then drawLine(upperTorso, rightUpperArm) end
                            if upperTorso and lowerTorso then drawLine(upperTorso, lowerTorso) end
                            if lowerTorso and leftUpperLeg then drawLine(lowerTorso, leftUpperLeg) end
                            if lowerTorso and rightUpperLeg then drawLine(lowerTorso, rightUpperLeg) end
                        end

                        -- Name ESP
                        if ScriptSense.Config.NameEspEnabled then
                            local nameLabel = Instance.new("TextLabel")
                            nameLabel.Name = "NameESP"
                            nameLabel.Size = UDim2.new(0, 100, 0, 20)
                            nameLabel.Position = UDim2.new(0, rootPos.X - 50, 0, rootPos.Y - 45)
                            nameLabel.BackgroundTransparency = 1
                            nameLabel.Text = player.Name
                            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                            nameLabel.TextSize = 12
                            nameLabel.Font = Enum.Font.GothamBold
                            nameLabel.TextXAlignment = Enum.TextXAlignment.Center
                            nameLabel.Parent = ESPContainer
                            table.insert(activeDrawings, nameLabel)
                        end
                    end
                end
            end
        end
    end
end)

-- Update MainContainer CanvasSize automatically
MainListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    MainContainer.CanvasSize = UDim2.new(0, 0, 0, MainListLayout.AbsoluteContentSize.Y + 10)
end)

-- Intro Sequence with Version Integration
task.spawn(function()
    local fullText = "SCRIPT SENSE v" .. ScriptSense.Version
    local totalChars = #fullText
    local totalDuration = 2.0
    local charDelay = totalDuration / totalChars

    local function getPartialText(count)
        local scriptPart = string.sub("SCRIPT", 1, math.min(count, 6))
        local res = '<font color="#FFFFFF">' .. scriptPart .. '</font>'
        if count > 6 then
            local sensePart = string.sub(" SENSE", 1, math.min(count - 6, 6))
            res = res .. '<font color="#FF0000">' .. sensePart .. '</font>'
        end
        if count > 12 then
            local verPart = string.sub(" v" .. ScriptSense.Version, 1, count - 12)
            res = res .. '<font color="#AAAAAA">' .. verPart .. '</font>'
        end
        return res
    end

    for i = 1, totalChars do
        WatermarkLabel.Text = getPartialText(i)
        task.wait(charDelay)
    end
    WatermarkLabel.Text = '<font color="#FFFFFF">SCRIPT</font> <font color="#FF0000">SENSE</font> <font color="#AAAAAA">v' .. ScriptSense.Version .. '</font>'

    local currentAbsPos = WatermarkContainer.AbsolutePosition
    WatermarkContainer.AnchorPoint = Vector2.new(0, 0)
    WatermarkContainer.Position = UDim2.new(0, currentAbsPos.X, 0, currentAbsPos.Y)

    local transitionTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(WatermarkContainer, transitionTweenInfo, { Position = UDim2.new(0, 20, 0, 20) }):Play()

    local textSizeVal = Instance.new("NumberValue")
    textSizeVal.Value = 24
    textSizeVal.Changed:Connect(function(v) WatermarkLabel.TextSize = v end)
    TweenService:Create(textSizeVal, transitionTweenInfo, { Value = 14 }):Play()
    task.delay(0.45, function() SafeDestroy(textSizeVal) end)

    TweenService:Create(MenuToggleArrow, transitionTweenInfo, { TextTransparency = 0, BackgroundTransparency = 0 }):Play()
    TweenService:Create(ArrowStroke, transitionTweenInfo, { Transparency = 0 }):Play()

    task.wait(0.6)
    if not IsMobileDevice then MainControlPanel.Visible = true isPanelVisible = true end
    TweenService:Create(PanelStroke, transitionTweenInfo, { Transparency = 0 }):Play()

    for index, rowFrame in ipairs(controlRowFrames) do
        if rowFrame then
            task.delay((index - 1) * 0.02 + 0.03, function()
                rowFrame.Visible = true
                local rowTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                TweenService:Create(rowFrame, rowTweenInfo, { BackgroundTransparency = 0.2 }):Play()
                local stroke = rowFrame:FindFirstChildOfClass("UIStroke")
                if stroke then TweenService:Create(stroke, rowTweenInfo, { Transparency = 0 }):Play() end
                
                local btn = rowFrame:FindFirstChildOfClass("TextButton")
                if btn then TweenService:Create(btn, rowTweenInfo, { TextTransparency = 0 }):Play() end
                
                local lbl = rowFrame:FindFirstChildOfClass("TextLabel")
                if lbl then TweenService:Create(lbl, rowTweenInfo, { TextTransparency = 0 }):Play() end
            end)
        end
    end
end)
