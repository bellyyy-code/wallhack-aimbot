local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    repeat task.wait() LocalPlayer = Players.LocalPlayer until LocalPlayer
end

local Camera = Workspace.CurrentCamera

local ScriptSense = {}
ScriptSense.Version = "7.9.1"
ScriptSense.Active = true

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

-- Main UI Container
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

-- Ultra-smooth FOV Circle
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
WatermarkLabel.Text = '<font color="#FFFFFF">SCRIPT</font> <font color="#FF0000">SENSE</font> <font color="#AAAAAA">v' .. ScriptSense.Version .. '</font>'
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
MenuToggleArrow.Text = "▲"
MenuToggleArrow.LayoutOrder = 2
MenuToggleArrow.Parent = WatermarkContainer

local ArrowStroke = Instance.new("UIStroke")
ArrowStroke.Color = Color3.fromRGB(60, 60, 60)
ArrowStroke.Thickness = 1
ArrowStroke.Parent = MenuToggleArrow

-- Main Control Panel Frame
local MainControlPanel = Instance.new("Frame")
MainControlPanel.Name = "MainControlPanel"
MainControlPanel.Size = UDim2.new(0, 260, 0, 390)
MainControlPanel.Position = UDim2.new(0.5, -130, 0.5, -195)
MainControlPanel.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainControlPanel.BackgroundTransparency = 0.1
MainControlPanel.BorderSizePixel = 0
MainControlPanel.ClipsDescendants = true
MainControlPanel.Visible = true
MainControlPanel.Parent = ScreenGui

local PanelStroke = Instance.new("UIStroke")
PanelStroke.Color = Color3.fromRGB(50, 50, 50)
PanelStroke.Thickness = 2
PanelStroke.Transparency = 0
PanelStroke.Parent = MainControlPanel

-- Main Panel Title Bar
local MainTitleBar = Instance.new("Frame")
MainTitleBar.Size = UDim2.new(1, 0, 0, 35)
MainTitleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainTitleBar.BackgroundTransparency = 0
MainTitleBar.BorderSizePixel = 0
MainTitleBar.Parent = MainControlPanel

local MainTitleLabel = Instance.new("TextLabel")
MainTitleLabel.Size = UDim2.new(1, -15, 1, 0)
MainTitleLabel.Position = UDim2.new(0, 12, 0, 0)
MainTitleLabel.BackgroundTransparency = 1
MainTitleLabel.RichText = true
MainTitleLabel.Text = '<font color="#FFFFFF">SCRIPT</font> <font color="#FF0000">SENSE</font> <font color="#888888">v' .. ScriptSense.Version .. '</font>'
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

local function GetKeyName(keyCode)
    local name = keyCode.Name
    if name == "Backquote" then return "`" end
    return string.lower(name)
end

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

-- SCRIPT SENSE MULTI-FLING GUI Window
local FlingGuiWindow = Instance.new("Frame")
FlingGuiWindow.Name = "FlingGuiWindow"
FlingGuiWindow.Size = UDim2.new(0, 300, 0, 370)
FlingGuiWindow.Position = UDim2.new(0.5, 130, 0.5, -210)
FlingGuiWindow.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FlingGuiWindow.BorderSizePixel = 0
FlingGuiWindow.ClipsDescendants = true
FlingGuiWindow.Active = true
FlingGuiWindow.Draggable = true
FlingGuiWindow.Visible = false
FlingGuiWindow.Parent = ScreenGui

local FlingStroke = Instance.new("UIStroke")
FlingStroke.Color = Color3.fromRGB(70, 70, 70)
FlingStroke.Thickness = 2
FlingStroke.Parent = FlingGuiWindow

local FlingTitleBar = Instance.new("Frame")
FlingTitleBar.Size = UDim2.new(1, 0, 0, 30)
FlingTitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FlingTitleBar.BorderSizePixel = 0
FlingTitleBar.Parent = FlingGuiWindow

local FlingTitle = Instance.new("TextLabel")
FlingTitle.Size = UDim2.new(1, -30, 1, 0)
FlingTitle.Position = UDim2.new(0, 10, 0, 0)
FlingTitle.BackgroundTransparency = 1
FlingTitle.RichText = true
FlingTitle.Text = '<font color="#FFFFFF">SCRIPT SENSE</font> <font color="#FF0000">MULTI-FLING</font>'
FlingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingTitle.TextSize = 16
FlingTitle.Font = Enum.Font.GothamBold
FlingTitle.TextXAlignment = Enum.TextXAlignment.Left
FlingTitle.Parent = FlingTitleBar

local FlingCloseBtn = Instance.new("TextButton")
FlingCloseBtn.Size = UDim2.new(0, 30, 0, 30)
FlingCloseBtn.Position = UDim2.new(1, -30, 0, 0)
FlingCloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
FlingCloseBtn.BackgroundTransparency = 0.5
FlingCloseBtn.BorderSizePixel = 0
FlingCloseBtn.Text = "X"
FlingCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingCloseBtn.Font = Enum.Font.GothamBold
FlingCloseBtn.TextSize = 14
FlingCloseBtn.Parent = FlingTitleBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Position = UDim2.new(0, 10, 0, 35)
StatusLabel.Size = UDim2.new(1, -20, 0, 25)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Select targets to fling"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 16
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = FlingGuiWindow

local SelectionFrame = Instance.new("Frame")
SelectionFrame.Position = UDim2.new(0, 10, 0, 65)
SelectionFrame.Size = UDim2.new(1, -20, 0, 200)
SelectionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SelectionFrame.BorderSizePixel = 0
SelectionFrame.Parent = FlingGuiWindow

local PlayerScrollFrame = Instance.new("ScrollingFrame")
PlayerScrollFrame.Position = UDim2.new(0, 5, 0, 5)
PlayerScrollFrame.Size = UDim2.new(1, -10, 1, -10)
PlayerScrollFrame.BackgroundTransparency = 1
PlayerScrollFrame.BorderSizePixel = 0
PlayerScrollFrame.ScrollBarThickness = 6
PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScrollFrame.Parent = SelectionFrame

local StartButton = Instance.new("TextButton")
StartButton.Position = UDim2.new(0, 10, 0, 275)
StartButton.Size = UDim2.new(0.5, -15, 0, 40)
StartButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
StartButton.BorderSizePixel = 0
StartButton.Text = "START FLING"
StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StartButton.Font = Enum.Font.SourceSansBold
StartButton.TextSize = 16
StartButton.Parent = FlingGuiWindow

local StopButton = Instance.new("TextButton")
StopButton.Position = UDim2.new(0.5, 5, 0, 275)
StopButton.Size = UDim2.new(0.5, -15, 0, 40)
StopButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
StopButton.BorderSizePixel = 0
StopButton.Text = "STOP FLING"
StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StopButton.Font = Enum.Font.SourceSansBold
StopButton.TextSize = 16
StopButton.Parent = FlingGuiWindow

local SelectAllButton = Instance.new("TextButton")
SelectAllButton.Position = UDim2.new(0, 10, 0, 325)
SelectAllButton.Size = UDim2.new(0.5, -15, 0, 30)
SelectAllButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SelectAllButton.BorderSizePixel = 0
SelectAllButton.Text = "SELECT ALL"
SelectAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectAllButton.Font = Enum.Font.SourceSans
SelectAllButton.TextSize = 14
SelectAllButton.Parent = FlingGuiWindow

local DeselectAllButton = Instance.new("TextButton")
DeselectAllButton.Position = UDim2.new(0.5, 5, 0, 325)
DeselectAllButton.Size = UDim2.new(0.5, -15, 0, 30)
DeselectAllButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
DeselectAllButton.BorderSizePixel = 0
DeselectAllButton.Text = "DESELECT ALL"
DeselectAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DeselectAllButton.Font = Enum.Font.SourceSans
DeselectAllButton.TextSize = 14
DeselectAllButton.Parent = FlingGuiWindow

local SelectedTargets = {}
local PlayerCheckboxes = {}
local FlingActive = false
getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight

local function Message(TitleText, TextContent, Time)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = TitleText,
            Text = TextContent,
            Duration = Time or 5
        })
    end)
end

-- Create Menu Rows for Hub Features
CreateControlRow(MainContainer, "Aimbot: [OFF]", function()
    ScriptSense.Config.AimbotEnabled = not ScriptSense.Config.AimbotEnabled
end, function(btn)
    local state = ScriptSense.Config.AimbotEnabled and "ON" or "OFF"
    local color = ScriptSense.Config.AimbotEnabled and "#00FF00" or "#FF0000"
    btn.Text = "Aimbot: [" .. '<font color="' .. color .. '">' .. state .. '</font>' .. "]"
end)

CreateControlRow(MainContainer, "Wallhack (ESP): [OFF]", function()
    ScriptSense.Config.WallhackEnabled = not ScriptSense.Config.WallhackEnabled
end, function(btn)
    local state = ScriptSense.Config.WallhackEnabled and "ON" or "OFF"
    local color = ScriptSense.Config.WallhackEnabled and "#00FF00" or "#FF0000"
    btn.Text = "Wallhack (ESP): [" .. '<font color="' .. color .. '">' .. state .. '</font>' .. "]"
end)

CreateControlRow(MainContainer, "Fly: [OFF]", function()
    ScriptSense.Config.FlyEnabled = not ScriptSense.Config.FlyEnabled
end, function(btn)
    local state = ScriptSense.Config.FlyEnabled and "ON" or "OFF"
    local color = ScriptSense.Config.FlyEnabled and "#00FF00" or "#FF0000"
    btn.Text = "Fly: [" .. '<font color="' .. color .. '">' .. state .. '</font>' .. "]"
end)

CreateControlRow(MainContainer, "Speedhack: [OFF]", function()
    ScriptSense.Config.SpeedhackEnabled = not ScriptSense.Config.SpeedhackEnabled
end, function(btn)
    local state = ScriptSense.Config.SpeedhackEnabled and "ON" or "OFF"
    local color = ScriptSense.Config.SpeedhackEnabled and "#00FF00" or "#FF0000"
    btn.Text = "Speedhack: [" .. '<font color="' .. color .. '">' .. state .. '</font>' .. "]"
end)

CreateControlRow(MainContainer, "Open Multi-Fling Menu", function()
    FlingGuiWindow.Visible = not FlingGuiWindow.Visible
end)

CreateControlRow(MainContainer, "Open Keybind Manager", function()
    ToggleKeybindsMenu()
end)

-- Refresh all control rows to reflect initial state
for _, updateFn in ipairs(controlRowUpdateCallbacks) do
    pcall(updateFn)
end

MainContainer.CanvasSize = UDim2.new(0, 0, 0, #controlRowFrames * 42)

-- Toggle Menu Visibility via Arrow or Keybind
local menuVisible = true
MenuToggleArrow.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    MainControlPanel.Visible = menuVisible
    MenuToggleArrow.Text = menuVisible and "▲" or "▼"
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == ScriptSense.Config.Keybinds.MenuToggle then
        menuVisible = not menuVisible
        MainControlPanel.Visible = menuVisible
        MenuToggleArrow.Text = menuVisible and "▲" or "▼"
    end
end)

local function CountSelectedTargets()
    local count = 0
    for _ in pairs(SelectedTargets) do
        count = count + 1
    end
    return count
end

local function UpdateStatus()
    local count = CountSelectedTargets()
    if FlingActive then
        StatusLabel.Text = "Flinging " .. count .. " target(s)"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    else
        StatusLabel.Text = count .. " target(s) selected" 
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

local function RefreshPlayerList()
    for _, child in pairs(PlayerScrollFrame:GetChildren()) do
        child:Destroy()
    end
    PlayerCheckboxes = {}
    
    local PlayerList = Players:GetPlayers()
    table.sort(PlayerList, function(a, b) return a.Name:lower() < b.Name:lower() end)
    
    local yPosition = 5
    for _, player in ipairs(PlayerList) do
        if player ~= LocalPlayer then
            local PlayerEntry = Instance.new("Frame")
            PlayerEntry.Size = UDim2.new(1, -10, 0, 30)
            PlayerEntry.Position = UDim2.new(0, 5, 0, yPosition)
            PlayerEntry.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            PlayerEntry.BorderSizePixel = 0
            PlayerEntry.Parent = PlayerScrollFrame
            
            local Checkbox = Instance.new("TextButton")
            Checkbox.Size = UDim2.new(0, 24, 0, 24)
            Checkbox.Position = UDim2.new(0, 3, 0.5, -12)
            Checkbox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            Checkbox.BorderSizePixel = 0
            Checkbox.Text = ""
            Checkbox.Parent = PlayerEntry
            
            local Checkmark = Instance.new("TextLabel")
            Checkmark.Size = UDim2.new(1, 0, 1, 0)
            Checkmark.BackgroundTransparency = 1
            Checkmark.Text = "✓"
            Checkmark.TextColor3 = Color3.fromRGB(0, 255, 0)
            Checkmark.TextSize = 18
            Checkmark.Font = Enum.Font.SourceSansBold
            Checkmark.Visible = SelectedTargets[player.Name] ~= nil
            Checkmark.Parent = Checkbox
            
            local NameLabel = Instance.new("TextLabel")
            NameLabel.Size = UDim2.new(1, -35, 1, 0)
            NameLabel.Position = UDim2.new(0, 30, 0, 0)
            NameLabel.BackgroundTransparency = 1
            NameLabel.Text = player.Name
            NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            NameLabel.TextSize = 16
            NameLabel.Font = Enum.Font.SourceSans
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
            NameLabel.Parent = PlayerEntry
            
            local ClickArea = Instance.new("TextButton")
            ClickArea.Size = UDim2.new(1, 0, 1, 0)
            ClickArea.BackgroundTransparency = 1
            ClickArea.Text = ""
            ClickArea.ZIndex = 2
            ClickArea.Parent = PlayerEntry
            
            ClickArea.MouseButton1Click:Connect(function()
                if SelectedTargets[player.Name] then
                    SelectedTargets[player.Name] = nil
                    Checkmark.Visible = false
                else
                    SelectedTargets[player.Name] = player
                    Checkmark.Visible = true
                end
                UpdateStatus()
            end)
            
            PlayerCheckboxes[player.Name] = {
                Entry = PlayerEntry,
                Checkmark = Checkmark
            }
            
            yPosition = yPosition + 35
        end
    end
    PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition + 5)
end

local function ToggleAllPlayers(select)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local checkboxData = PlayerCheckboxes[player.Name]
            if checkboxData then
                if select then
                    SelectedTargets[player.Name] = player
                    checkboxData.Checkmark.Visible = true
                else
                    SelectedTargets[player.Name] = nil
                    checkboxData.Checkmark.Visible = false
                end
            end
        end
    end
    UpdateStatus()
end

local function SkidFling(TargetPlayer)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    if not TCharacter then return end
    
    local THumanoid, TRootPart, THead, Accessory, Handle
    if TCharacter:FindFirstChildOfClass("Humanoid") then
        THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    end
    if THumanoid and THumanoid.RootPart then
        TRootPart = THumanoid.RootPart
    end
    if TCharacter:FindFirstChild("Head") then
        THead = TCharacter.Head
    end
    if TCharacter:FindFirstChildOfClass("Accessory") then
        Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    end
    if Accessory and Accessory:FindFirstChild("Handle") then
        Handle = Accessory.Handle
    end
    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then
            getgenv().OldPos = RootPart.CFrame
        end
        
        if THumanoid and THumanoid.Sit then
            return Message("Error", TargetPlayer.Name .. " is sitting", 2)
        end
        
        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif Handle then
            workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then
            workspace.CurrentCamera.CameraSubject = THumanoid
        end
        
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then
            return
        end
        
        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
        
        local SFBasePart = function(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                end
            until Time + TimeToWait < tick() or not FlingActive
        end
        
        workspace.FallenPartsDestroyHeight = 0/0
        
        local BV = Instance.new("BodyVelocity")
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        
        if TRootPart then
            SFBasePart(TRootPart)
        elseif THead then
            SFBasePart(THead)
        elseif Handle then
            SFBasePart(Handle)
        else
            return Message("Error", TargetPlayer.Name .. " has no valid parts", 2)
        end
        
        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid
        
        if getgenv().OldPos then
            repeat
                RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                Humanoid:ChangeState("GettingUp")
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new()
                    end
                end
                task.wait()
            until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
            workspace.FallenPartsDestroyHeight = getgenv().FPDH
        end
    else
        return Message("Error", "Your character is not ready", 2)
    end
end

local function StartFling()
    if FlingActive then return end
    
    local count = CountSelectedTargets()
    if count == 0 then
        StatusLabel.Text = "No targets selected!"
        task.wait(1)
        UpdateStatus()
        return
    end
    
    FlingActive = true
    UpdateStatus()
    Message("Started", "Flinging " .. count .. " targets", 2)
    
    task.spawn(function()
        while FlingActive do
            local validTargets = {}
            for name, player in pairs(SelectedTargets) do
                if player and player.Parent then
                    validTargets[name] = player
                else
                    SelectedTargets[name] = nil
                    local checkbox = PlayerCheckboxes[name]
                    if checkbox then
                        checkbox.Checkmark.Visible = false
                    end
                end
            end
            
            for _, player in pairs(validTargets) do
                if FlingActive then
                    SkidFling(player)
                    task.wait(0.1)
                else
                    break
                end
            end
            UpdateStatus()
            task.wait(0.5)
        end
    end)
end

local function StopFling()
    if not FlingActive then return end
    FlingActive = false
    UpdateStatus()
    Message("Stopped", "Fling has been stopped", 2)
end

StartButton.MouseButton1Click:Connect(StartFling)
StopButton.MouseButton1Click:Connect(StopFling)
SelectAllButton.MouseButton1Click:Connect(function() ToggleAllPlayers(true) end)
DeselectAllButton.MouseButton1Click:Connect(function() ToggleAllPlayers(false) end)
FlingCloseBtn.MouseButton1Click:Connect(function()
    StopFling()
    FlingGuiWindow.Visible = false
end)

Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(function(player)
    if SelectedTargets[player.Name] then
        SelectedTargets[player.Name] = nil
    end
    RefreshPlayerList()
    UpdateStatus()
end)

RefreshPlayerList()
Message("ScriptSense", "Loaded successfully v" .. ScriptSense.Version, 3)
