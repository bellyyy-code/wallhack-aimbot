local ScriptSense = {}
ScriptSense.Version = "7.4.0"
ScriptSense.Active = true

-- Services Retrieval
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

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

-- Full Cleanup
local successHui, huiContainer = pcall(function() return gethui() end)
if successHui and huiContainer then
    for _, child in ipairs(huiContainer:GetChildren()) do
        if child.Name == "ScriptSenseEnterpriseGUI" then
            SafeDestroy(child)
        end
    end
end

pcall(function()
    for _, child in ipairs(CoreGui:GetChildren()) do
        if child.Name == "ScriptSenseEnterpriseGUI" then
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

-- Main Control Panel Frame
local MainControlPanel = Instance.new("Frame")
MainControlPanel.Name = "MainControlPanel"
MainControlPanel.Size = UDim2.new(0, 240, 0, 500)
MainControlPanel.Position = UDim2.new(0, 20, 0, 65)
MainControlPanel.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainControlPanel.BorderSizePixel = 0
MainControlPanel.Visible = false
MainControlPanel.Parent = ScreenGui

local PanelStroke = Instance.new("UIStroke")
PanelStroke.Color = Color3.fromRGB(50, 50, 50)
PanelStroke.Thickness = 2
PanelStroke.Transparency = 1
PanelStroke.Parent = MainControlPanel

local isPanelVisible = false
local function ToggleMenuVisibility()
    isPanelVisible = not isPanelVisible
    MainControlPanel.Visible = isPanelVisible
    MenuToggleArrow.Text = isPanelVisible and "▼" or "▲"
end

MenuToggleArrow.MouseButton1Click:Connect(ToggleMenuVisibility)

-- Keybinds Menu Window (With Mouse Wheel Scroll support)
local KeybindsMenuWindow = Instance.new("Frame")
KeybindsMenuWindow.Name = "KeybindsMenuWindow"
KeybindsMenuWindow.Size = UDim2.new(0, 300, 0, 390)
KeybindsMenuWindow.Position = UDim2.new(0.5, -150, 0.5, -195)
KeybindsMenuWindow.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
KeybindsMenuWindow.BorderSizePixel = 0
KeybindsMenuWindow.Visible = false
KeybindsMenuWindow.Parent = ScreenGui

local KbStroke = Instance.new("UIStroke")
KbStroke.Color = Color3.fromRGB(70, 70, 70)
KbStroke.Thickness = 2
KbStroke.Parent = KeybindsMenuWindow

local KbTitle = Instance.new("TextLabel")
KbTitle.Size = UDim2.new(1, 0, 0, 40)
KbTitle.BackgroundTransparency = 1
KbTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KbTitle.TextSize = 14
KbTitle.Font = Enum.Font.GothamBold
KbTitle.Text = "  KEYBIND MANAGER"
KbTitle.TextXAlignment = Enum.TextXAlignment.Left
KbTitle.Parent = KeybindsMenuWindow

local KbContainer = Instance.new("ScrollingFrame")
KbContainer.Name = "KbContainer"
KbContainer.Size = UDim2.new(1, 0, 1, -40)
KbContainer.Position = UDim2.new(0, 0, 0, 40)
KbContainer.BackgroundTransparency = 1
KbContainer.BorderSizePixel = 0
KbContainer.ScrollBarThickness = 6
KbContainer.Active = true
KbContainer.Parent = KeybindsMenuWindow

local KbListLayout = Instance.new("UIListLayout")
KbListLayout.SortOrder = Enum.SortOrder.LayoutOrder
KbListLayout.Padding = UDim.new(0, 4)
KbListLayout.Parent = KbContainer

local PopulateKeybindsDisplay
local ToggleKeybindsMenu = function()
    KeybindsMenuWindow.Visible = not KeybindsMenuWindow.Visible
    if KeybindsMenuWindow.Visible then PopulateKeybindsDisplay() end
end

local controlRowUpdateCallbacks = {}
local controlRowFrames = {}

local function CreateControlRow(parent, posY, initialText, callback, updateCallback)
    local rowFrame = Instance.new("Frame")
    rowFrame.Size = UDim2.new(1, -20, 0, 35)
    rowFrame.Position = UDim2.new(0, 10, 0, posY)
    rowFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    rowFrame.BackgroundTransparency = 1
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

local activeRebindKey = nil
local function GetKeyName(keyCode)
    local name = keyCode.Name
    if name == "Backquote" then return "`" end
    return string.lower(name)
end

-- Populate Panel Rows with live state updates
local verticalOffset = 15

CreateControlRow(MainControlPanel, verticalOffset, "wallhack: off | bind: g", function()
    ScriptSense.Config.WallhackEnabled = not ScriptSense.Config.WallhackEnabled
end, function(btn)
    local status = ScriptSense.Config.WallhackEnabled and "on" or "off"
    btn.Text = "  wallhack: " .. status .. " | bind: " .. string.lower(GetKeyName(ScriptSense.Config.Keybinds.Wallhack))
end)
verticalOffset = verticalOffset + 42

CreateControlRow(MainControlPanel, verticalOffset, "aimbot: off | bind: r", function()
    if not IsRobloxMenuOpen() then ScriptSense.Config.AimbotEnabled = not ScriptSense.Config.AimbotEnabled end
end, function(btn)
    local status = ScriptSense.Config.AimbotEnabled and "on" or "off"
    btn.Text = "  aimbot: " .. status .. " | bind: " .. string.lower(GetKeyName(ScriptSense.Config.Keybinds.Aimbot))
end)
verticalOffset = verticalOffset + 42

CreateControlRow(MainControlPanel, verticalOffset, "godmode: off | bind: c", function()
    ScriptSense.Config.GodmodeEnabled = not ScriptSense.Config.GodmodeEnabled
end, function(btn)
    local status = ScriptSense.Config.GodmodeEnabled and "on" or "off"
    btn.Text = "  godmode: " .. status .. " | bind: " .. string.lower(GetKeyName(ScriptSense.Config.Keybinds.Godmode))
end)
verticalOffset = verticalOffset + 42

CreateControlRow(MainControlPanel, verticalOffset, "fly: off | bind: f", function()
    ScriptSense.Config.FlyEnabled = not ScriptSense.Config.FlyEnabled
end, function(btn)
    local status = ScriptSense.Config.FlyEnabled and "on" or "off"
    btn.Text = "  fly: " .. status .. " | bind: " .. string.lower(GetKeyName(ScriptSense.Config.Keybinds.Fly))
end)
verticalOffset = verticalOffset + 42

CreateControlRow(MainControlPanel, verticalOffset, "skeleton esp: off | bind: x", function()
    ScriptSense.Config.SkeletonEspEnabled = not ScriptSense.Config.SkeletonEspEnabled
end, function(btn)
    local status = ScriptSense.Config.SkeletonEspEnabled and "on" or "off"
    btn.Text = "  skeleton esp: " .. status .. " | bind: " .. string.lower(GetKeyName(ScriptSense.Config.Keybinds.Skeleton))
end)
verticalOffset = verticalOffset + 42

CreateControlRow(MainControlPanel, verticalOffset, "box esp: off | bind: b", function()
    ScriptSense.Config.BoxEspEnabled = not ScriptSense.Config.BoxEspEnabled
end, function(btn)
    local status = ScriptSense.Config.BoxEspEnabled and "on" or "off"
    btn.Text = "  box esp: " .. status .. " | bind: " .. string.lower(GetKeyName(ScriptSense.Config.Keybinds.BoxEsp))
end)
verticalOffset = verticalOffset + 42

CreateControlRow(MainControlPanel, verticalOffset, "name esp: off | bind: n", function()
    ScriptSense.Config.NameEspEnabled = not ScriptSense.Config.NameEspEnabled
end, function(btn)
    local status = ScriptSense.Config.NameEspEnabled and "on" or "off"
    btn.Text = "  name esp: " .. status .. " | bind: " .. string.lower(GetKeyName(ScriptSense.Config.Keybinds.NameEsp))
end)
verticalOffset = verticalOffset + 42

CreateControlRow(MainControlPanel, verticalOffset, "speedhack: off | speed: 32 | bind: v", function()
    ScriptSense.Config.SpeedhackEnabled = not ScriptSense.Config.SpeedhackEnabled
    if not ScriptSense.Config.SpeedhackEnabled then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = ScriptSense.Config.DefaultWalkSpeed end
    end
end, function(btn)
    local status = ScriptSense.Config.SpeedhackEnabled and "on" or "off"
    btn.Text = "  speedhack: " .. status .. " | speed: " .. ScriptSense.Config.SpeedhackSpeed .. " | bind: " .. string.lower(GetKeyName(ScriptSense.Config.Keybinds.Speedhack))
end)
verticalOffset = verticalOffset + 42

CreateControlRow(MainControlPanel, verticalOffset, "anti-aim: off | bind: u", function()
    ScriptSense.Config.AntiAimEnabled = not ScriptSense.Config.AntiAimEnabled
end, function(btn)
    local status = ScriptSense.Config.AntiAimEnabled and "on" or "off"
    btn.Text = "  anti-aim: " .. status .. " | bind: " .. string.lower(GetKeyName(ScriptSense.Config.Keybinds.AntiAim))
end)
verticalOffset = verticalOffset + 42

-- Teleport Window
local TeleportWindow = Instance.new("ScrollingFrame")
TeleportWindow.Name = "TeleportWindow"
TeleportWindow.Size = UDim2.new(0, 300, 0, 360)
TeleportWindow.Position = UDim2.new(0.5, -150, 0.5, -180)
TeleportWindow.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TeleportWindow.BorderSizePixel = 0
TeleportWindow.ScrollBarThickness = 6
TeleportWindow.Active = true
TeleportWindow.Visible = false
TeleportWindow.Parent = ScreenGui

local TpStroke = Instance.new("UIStroke")
TpStroke.Color = Color3.fromRGB(70, 70, 70)
TpStroke.Thickness = 2
TpStroke.Parent = TeleportWindow

local TpLayout = Instance.new("UIListLayout")
TpLayout.SortOrder = Enum.SortOrder.LayoutOrder
TpLayout.Parent = TeleportWindow

CreateControlRow(MainControlPanel, verticalOffset, "teleport menu", function()
    TeleportWindow.Visible = not TeleportWindow.Visible
end)
verticalOffset = verticalOffset + 42

-- Multi Fling Window
local FlingWindow = Instance.new("Frame")
FlingWindow.Name = "FlingWindow"
FlingWindow.Size = UDim2.new(0, 300, 0, 390)
FlingWindow.Position = UDim2.new(0.5, -150, 0.5, -195)
FlingWindow.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
FlingWindow.BorderSizePixel = 0
FlingWindow.Visible = false
FlingWindow.Parent = ScreenGui

local FlingStroke = Instance.new("UIStroke")
FlingStroke.Color = Color3.fromRGB(70, 70, 70)
FlingStroke.Thickness = 2
FlingStroke.Parent = FlingWindow

local FlingTitleBar = Instance.new("Frame")
FlingTitleBar.Size = UDim2.new(1, 0, 0, 35)
FlingTitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FlingTitleBar.BorderSizePixel = 0
FlingTitleBar.Parent = FlingWindow

local FlingTitle = Instance.new("TextLabel")
FlingTitle.Size = UDim2.new(1, -35, 1, 0)
FlingTitle.Position = UDim2.new(0, 10, 0, 0)
FlingTitle.BackgroundTransparency = 1
FlingTitle.RichText = true
FlingTitle.Text = '<font color="#FFFFFF">SCRIPT</font> <font color="#FF0000">SENSE MULTI FLING</font>'
FlingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingTitle.Font = Enum.Font.GothamBold
FlingTitle.TextSize = 14
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
    FlingWindow.Visible = false
end)

local FlingStatusLabel = Instance.new("TextLabel")
FlingStatusLabel.Position = UDim2.new(0, 10, 0, 45)
FlingStatusLabel.Size = UDim2.new(1, -20, 0, 25)
FlingStatusLabel.BackgroundTransparency = 1
FlingStatusLabel.Text = "Select targets to fling"
FlingStatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingStatusLabel.Font = Enum.Font.Gotham
FlingStatusLabel.TextSize = 13
FlingStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
FlingStatusLabel.Parent = FlingWindow

local SelectionFrame = Instance.new("Frame")
SelectionFrame.Position = UDim2.new(0, 10, 0, 75)
SelectionFrame.Size = UDim2.new(1, -20, 0, 190)
SelectionFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
SelectionFrame.BorderSizePixel = 0
SelectionFrame.Parent = FlingWindow

local SelStroke = Instance.new("UIStroke")
SelStroke.Color = Color3.fromRGB(45, 45, 45)
SelStroke.Thickness = 1
SelStroke.Parent = SelectionFrame

local PlayerScrollFrame = Instance.new("ScrollingFrame")
PlayerScrollFrame.Position = UDim2.new(0, 5, 0, 5)
PlayerScrollFrame.Size = UDim2.new(1, -10, 1, -10)
PlayerScrollFrame.BackgroundTransparency = 1
PlayerScrollFrame.BorderSizePixel = 0
PlayerScrollFrame.ScrollBarThickness = 4
PlayerScrollFrame.Active = true
PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScrollFrame.Parent = SelectionFrame

local PlayerListLayout = Instance.new("UIListLayout")
PlayerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
PlayerListLayout.Padding = UDim.new(0, 4)
PlayerListLayout.Parent = PlayerScrollFrame

local FlingStartButton = Instance.new("TextButton")
FlingStartButton.Position = UDim2.new(0, 10, 0, 275)
FlingStartButton.Size = UDim2.new(0.5, -15, 0, 35)
FlingStartButton.BackgroundColor3 = Color3.fromRGB(0, 150, 60)
FlingStartButton.BorderSizePixel = 0
FlingStartButton.Text = "START FLING"
FlingStartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingStartButton.Font = Enum.Font.GothamBold
FlingStartButton.TextSize = 13
FlingStartButton.Parent = FlingWindow

local FlingStopButton = Instance.new("TextButton")
FlingStopButton.Position = UDim2.new(0.5, 5, 0, 275)
FlingStopButton.Size = UDim2.new(0.5, -15, 0, 35)
FlingStopButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
FlingStopButton.BorderSizePixel = 0
FlingStopButton.Text = "STOP FLING"
FlingStopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingStopButton.Font = Enum.Font.GothamBold
FlingStopButton.TextSize = 13
FlingStopButton.Parent = FlingWindow

local SelectAllButton = Instance.new("TextButton")
SelectAllButton.Position = UDim2.new(0, 10, 0, 320)
SelectAllButton.Size = UDim2.new(0.5, -15, 0, 30)
SelectAllButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SelectAllButton.BorderSizePixel = 0
SelectAllButton.Text = "SELECT ALL"
SelectAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectAllButton.Font = Enum.Font.GothamMedium
SelectAllButton.TextSize = 12
SelectAllButton.Parent = FlingWindow

local DeselectAllButton = Instance.new("TextButton")
DeselectAllButton.Position = UDim2.new(0.5, 5, 0, 320)
DeselectAllButton.Size = UDim2.new(0.5, -15, 0, 30)
DeselectAllButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
DeselectAllButton.BorderSizePixel = 0
DeselectAllButton.Text = "DESELECT ALL"
DeselectAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DeselectAllButton.Font = Enum.Font.GothamMedium
DeselectAllButton.TextSize = 12
DeselectAllButton.Parent = FlingWindow

CreateControlRow(MainControlPanel, verticalOffset, "multi fling menu", function()
    FlingWindow.Visible = not FlingWindow.Visible
end)
verticalOffset = verticalOffset + 42

CreateControlRow(MainControlPanel, verticalOffset, "keybinds menu | bind: `", function()
    ToggleKeybindsMenu()
end)
verticalOffset = verticalOffset + 42

-- Intro Sequence
task.spawn(function()
    local fullText = "SCRIPT SENSE MULTI FLING"
    local totalChars = #fullText
    local totalDuration = 2.0
    local charDelay = totalDuration / totalChars

    local function getPartialText(count)
        local scriptPart = string.sub("SCRIPT", 1, math.min(count, 6))
        local res = '<font color="#FFFFFF">' .. scriptPart .. '</font>'
        if count > 6 then
            res = res .. '<font color="#FF0000">' .. string.sub(" SENSE MULTI FLING", 1, count - 6) .. '</font>'
        end
        return res
    end

    for i = 1, totalChars do
        WatermarkLabel.Text = getPartialText(i)
        task.wait(charDelay)
    end
    WatermarkLabel.Text = '<font color="#FFFFFF">SCRIPT</font> <font color="#FF0000">SENSE MULTI FLING</font>'

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
            end)
        end
    end
end)

-- Helper to update row texts dynamically
local function RefreshControlRowTexts()
    for _, callback in ipairs(controlRowUpdateCallbacks) do
        pcall(callback)
    end
end

-- Keybinds window population
PopulateKeybindsDisplay = function()
    for _, child in ipairs(KbContainer:GetChildren()) do
        if child:IsA("Frame") then SafeDestroy(child) end
    end

    local bindsData = {
        {"Wallhack", "Wallhack", ScriptSense.Config.Keybinds.Wallhack},
        {"Aimbot", "Aimbot", ScriptSense.Config.Keybinds.Aimbot},
        {"Godmode", "Godmode", ScriptSense.Config.Keybinds.Godmode},
        {"Fly", "Fly", ScriptSense.Config.Keybinds.Fly},
        {"Skeleton ESP", "Skeleton", ScriptSense.Config.Keybinds.Skeleton},
        {"Box ESP", "BoxEsp", ScriptSense.Config.Keybinds.BoxEsp},
        {"Name ESP", "NameEsp", ScriptSense.Config.Keybinds.NameEsp},
        {"Speedhack", "Speedhack", ScriptSense.Config.Keybinds.Speedhack},
        {"Anti-Aim", "AntiAim", ScriptSense.Config.Keybinds.AntiAim},
        {"Menu Toggle", "MenuToggle", ScriptSense.Config.Keybinds.MenuToggle},
    }

    for _, data in ipairs(bindsData) do
        local labelName, configKey, keyCode = data[1], data[2], data[3]
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -10, 0, 35)
        row.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        row.BorderSizePixel = 0
        row.Parent = KbContainer

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(45, 45, 45)
        stroke.Thickness = 1
        stroke.Parent = row

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.TextColor3 = Color3.fromRGB(230, 230, 230)
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamMedium
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = row

        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 12)
        padding.Parent = btn

        if activeRebindKey == configKey then
            btn.Text = "  [ " .. labelName .. " ] -> Press any key..."
            btn.TextColor3 = Color3.fromRGB(255, 100, 100)
        else
            btn.Text = "  " .. labelName .. " -> [" .. string.upper(GetKeyName(keyCode)) .. "]"
        end

        btn.MouseButton1Click:Connect(function()
            activeRebindKey = configKey
            PopulateKeybindsDisplay()
        end)
    end
    KbContainer.CanvasSize = UDim2.new(0, 0, 0, KbListLayout.AbsoluteContentSize.Y)
end

-- Teleport list refresh
local function RefreshPlayerTeleportList()
    for _, child in ipairs(TeleportWindow:GetChildren()) do
        if child:IsA("TextButton") then SafeDestroy(child) end
    end
    for _, playerObj in ipairs(Players:GetPlayers()) do
        if playerObj ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, 0, 0, 40)
            pBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            pBtn.TextSize = 14
            pBtn.Font = Enum.Font.Gotham
            pBtn.Text = "  Teleport to -> " .. playerObj.Name
            pBtn.TextXAlignment = Enum.TextXAlignment.Left
            pBtn.Parent = TeleportWindow

            pBtn.MouseButton1Click:Connect(function()
                pcall(function()
                    local tChar, lChar = playerObj.Character, LocalPlayer.Character
                    if tChar and tChar:FindFirstChild("HumanoidRootPart") and lChar and lChar:FindFirstChild("HumanoidRootPart") then
                        lChar.HumanoidRootPart.CFrame = tChar.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                    end
                end)
            end)
        end
    end
    TeleportWindow.CanvasSize = UDim2.new(0, 0, 0, TpLayout.AbsoluteContentSize.Y)
end

Players.PlayerAdded:Connect(RefreshPlayerTeleportList)
Players.PlayerRemoving:Connect(RefreshPlayerTeleportList)
RefreshPlayerTeleportList()

-- Multi Fling Logic Setup
local SelectedTargets = {}
local PlayerCheckboxes = {}
local FlingActive = false
getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight

local function Message(Title, Text, Time)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = Title,
            Text = Text,
            Duration = Time or 5
        })
    end)
end

local function CountSelectedTargets()
    local count = 0
    for _ in pairs(SelectedTargets) do count = count + 1 end
    return count
end

local function UpdateFlingStatus()
    local count = CountSelectedTargets()
    if FlingActive then
        FlingStatusLabel.Text = "Flinging " .. count .. " target(s)"
        FlingStatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    else
        FlingStatusLabel.Text = count .. " target(s) selected" 
        FlingStatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

local function RefreshFlingPlayerList()
    for _, child in pairs(PlayerScrollFrame:GetChildren()) do
        if child:IsA("Frame") then SafeDestroy(child) end
    end
    PlayerCheckboxes = {}
    
    local PlayerList = Players:GetPlayers()
    table.sort(PlayerList, function(a, b) return a.Name:lower() < b.Name:lower() end)
    
    local yPosition = 0
    for _, player in ipairs(PlayerList) do
        if player ~= LocalPlayer then
            local PlayerEntry = Instance.new("Frame")
            PlayerEntry.Size = UDim2.new(1, -10, 0, 30)
            PlayerEntry.Position = UDim2.new(0, 5, 0, yPosition)
            PlayerEntry.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            PlayerEntry.BorderSizePixel = 0
            PlayerEntry.Parent = PlayerScrollFrame
            
            local Checkbox = Instance.new("TextButton")
            Checkbox.Size = UDim2.new(0, 20, 0, 20)
            Checkbox.Position = UDim2.new(0, 5, 0.5, -10)
            Checkbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Checkbox.BorderSizePixel = 0
            Checkbox.Text = ""
            Checkbox.Parent = PlayerEntry
            
            local Checkmark = Instance.new("TextLabel")
            Checkmark.Size = UDim2.new(1, 0, 1, 0)
            Checkmark.BackgroundTransparency = 1
            Checkmark.Text = "✓"
            Checkmark.TextColor3 = Color3.fromRGB(0, 255, 0)
            Checkmark.TextSize = 14
            Checkmark.Font = Enum.Font.GothamBold
            Checkmark.Visible = SelectedTargets[player.Name] ~= nil
            Checkmark.Parent = Checkbox
            
            local NameLabel = Instance.new("TextLabel")
            NameLabel.Size = UDim2.new(1, -30, 1, 0)
            NameLabel.Position = UDim2.new(0, 30, 0, 0)
            NameLabel.BackgroundTransparency = 1
            NameLabel.Text = player.Name
            NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            NameLabel.TextSize = 13
            NameLabel.Font = Enum.Font.Gotham
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
                UpdateFlingStatus()
            end)
            
            PlayerCheckboxes[player.Name] = {
                Entry = PlayerEntry,
                Checkmark = Checkmark
            }
            
            yPosition = yPosition + 34
        end
    end
    PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition)
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
    UpdateFlingStatus()
end

local function SkidFling(TargetPlayer)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    if not TCharacter then return end
    
    local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    local TRootPart = THumanoid and THumanoid.RootPart
    local THead = TCharacter:FindFirstChild("Head")
    local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    local Handle = Accessory and Accessory:FindFirstChild("Handle")
    
    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then
            getgenv().OldPos = RootPart.CFrame
        end
        
        if THumanoid and THumanoid.Sit then return end
        
        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif Handle then
            workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then
            workspace.CurrentCamera.CameraSubject = THumanoid
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
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
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
        
        if TRootPart then SFBasePart(TRootPart)
        elseif THead then SFBasePart(THead)
        elseif Handle then SFBasePart(Handle) end
        
        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid
        
        if getgenv().OldPos then
            repeat
                RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                Humanoid:ChangeState("GettingUp")
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new() end
                end
                task.wait()
            until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
            workspace.FallenPartsDestroyHeight = getgenv().FPDH
        end
    end
end

local function StartFling()
    if FlingActive then return end
    local count = CountSelectedTargets()
    if count == 0 then
        FlingStatusLabel.Text = "No targets selected!"
        task.wait(1)
        UpdateFlingStatus()
        return
    end
    
    FlingActive = true
    UpdateFlingStatus()
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
                    if checkbox then checkbox.Checkmark.Visible = false end
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
            UpdateFlingStatus()
            task.wait(0.5)
        end
    end)
end

local function StopFling()
    if not FlingActive then return end
    FlingActive = false
    UpdateFlingStatus()
    Message("Stopped", "Fling has been stopped", 2)
end

FlingStartButton.MouseButton1Click:Connect(StartFling)
FlingStopButton.MouseButton1Click:Connect(StopFling)
SelectAllButton.MouseButton1Click:Connect(function() ToggleAllPlayers(true) end)
DeselectAllButton.MouseButton1Click:Connect(function() ToggleAllPlayers(false) end)

Players.PlayerAdded:Connect(RefreshFlingPlayerList)
Players.PlayerRemoving:Connect(function(player)
    if SelectedTargets[player.Name] then SelectedTargets[player.Name] = nil end
    RefreshFlingPlayerList()
    UpdateFlingStatus()
end)

RefreshFlingPlayerList()
UpdateFlingStatus()

-- 1. Wallhack Engine
RunService.Stepped:Connect(function()
    if ScriptSense.Config.WallhackEnabled then
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

-- 2. Flight Engine
local ActiveBodyGyro, ActiveBodyVelocity = nil, nil
RunService.RenderStepped:Connect(function()
    local character = LocalPlayer.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if rootPart and humanoid then
            if ScriptSense.Config.FlyEnabled then
                humanoid.PlatformStand = true
                if not ActiveBodyGyro or not ActiveBodyGyro.Parent then
                    ActiveBodyGyro = Instance.new("BodyGyro")
                    ActiveBodyGyro.P = 9e4
                    ActiveBodyGyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
                    ActiveBodyGyro.Parent = rootPart
                end
                if not ActiveBodyVelocity or not ActiveBodyVelocity.Parent then
                    ActiveBodyVelocity = Instance.new("BodyVelocity")
                    ActiveBodyVelocity.MaxForce = Vector3.new(9e4, 9e4, 9e4)
                    ActiveBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    ActiveBodyVelocity.Parent = rootPart
                end

                ActiveBodyGyro.CFrame = Camera.CFrame
                local moveVector = Vector3.new(0, 0, 0)
                local speed = ScriptSense.Config.FlySpeed

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector = moveVector - Vector3.new(0, 1, 0) end

                if moveVector.Magnitude > 0 then
                    ActiveBodyVelocity.Velocity = moveVector.Unit * speed
                else
                    ActiveBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                end
            else
                if ActiveBodyGyro then SafeDestroy(ActiveBodyGyro) ActiveBodyGyro = nil end
                if ActiveBodyVelocity then SafeDestroy(ActiveBodyVelocity) ActiveBodyVelocity = nil end
                if humanoid.PlatformStand and not ScriptSense.Config.AntiAimEnabled then
                    humanoid.PlatformStand = false
                end
            end
        end
    end
end)

-- 3. Speedhack Engine (Configurable speed & dynamic status)
RunService.Stepped:Connect(function()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if ScriptSense.Config.SpeedhackEnabled then
            humanoid.WalkSpeed = ScriptSense.Config.SpeedhackSpeed
        end
    end
end)

-- 4. Native Drawing Skeleton ESP
local DrawingSkeletonRegistry = {}
local function PurgeDrawingSkeleton(playerTarget)
    if DrawingSkeletonRegistry[playerTarget] then
        for _, line in pairs(DrawingSkeletonRegistry[playerTarget]) do pcall(function() line:Remove() end) end
        DrawingSkeletonRegistry[playerTarget] = nil
    end
end

RunService.RenderStepped:Connect(function()
    for _, playerObj in ipairs(Players:GetPlayers()) do
        if playerObj ~= LocalPlayer and ScriptSense.Config.SkeletonEspEnabled then
            local character = playerObj.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if character and humanoid and humanoid.Health > 0 then
                local head = character:FindFirstChild("Head")
                local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
                local leftArm = character:FindFirstChild("LeftHand") or character:FindFirstChild("LeftLowerArm") or character:FindFirstChild("Left Arm")
                local rightArm = character:FindFirstChild("RightHand") or character:FindFirstChild("RightLowerArm") or character:FindFirstChild("Right Arm")
                local leftLeg = character:FindFirstChild("LeftFoot") or character:FindFirstChild("LeftLowerLeg") or character:FindFirstChild("Left Leg")
                local rightLeg = character:FindFirstChild("RightFoot") or character:FindFirstChild("RightLowerLeg") or character:FindFirstChild("Right Leg")

                if head and torso then
                    if not DrawingSkeletonRegistry[playerObj] then
                        local success, lines = pcall(function()
                            return {
                                HeadToTorso = Drawing.new("Line"),
                                TorsoToLeftArm = Drawing.new("Line"),
                                TorsoToRightArm = Drawing.new("Line"),
                                TorsoToLeftLeg = Drawing.new("Line"),
                                TorsoToRightLeg = Drawing.new("Line"),
                            }
                        end)
                        if success and lines then
                            DrawingSkeletonRegistry[playerObj] = lines
                            for _, l in pairs(lines) do l.Visible = false l.Color = Color3.fromRGB(0, 255, 255) l.Thickness = 1.5 end
                        end
                    end
                    local lines = DrawingSkeletonRegistry[playerObj]
                    if lines then
                        local function upd(lObj, pA, pB)
                            if lObj and pA and pB then
                                local posA, vA = Camera:WorldToViewportPoint(pA.Position)
                                local posB, vB = Camera:WorldToViewportPoint(pB.Position)
                                if vA or vB then
                                    lObj.From = Vector2.new(posA.X, posA.Y)
                                    lObj.To = Vector2.new(posB.X, posB.Y)
                                    lObj.Visible = true
                                else lObj.Visible = false end
                            elseif lObj then lObj.Visible = false end
                        end
                        upd(lines.HeadToTorso, head, torso)
                        upd(lines.TorsoToLeftArm, torso, leftArm)
                        upd(lines.TorsoToRightArm, torso, rightArm)
                        upd(lines.TorsoToLeftLeg, torso, leftLeg)
                        upd(lines.TorsoToRightLeg, torso, rightLeg)
                    end
                else PurgeDrawingSkeleton(playerObj) end
            else PurgeDrawingSkeleton(playerObj) end
        else PurgeDrawingSkeleton(playerObj) end
    end
end)

-- 5. Native Drawing Box ESP
local DrawingBoxRegistry = {}
local function PurgeDrawingBox(playerTarget)
    if DrawingBoxRegistry[playerTarget] then pcall(function() DrawingBoxRegistry[playerTarget]:Remove() end) DrawingBoxRegistry[playerTarget] = nil end
end

RunService.RenderStepped:Connect(function()
    for _, playerObj in ipairs(Players:GetPlayers()) do
        if playerObj ~= LocalPlayer and ScriptSense.Config.BoxEspEnabled then
            local character = playerObj.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            local head = character and character:FindFirstChild("Head")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if character and hrp and head and humanoid and humanoid.Health > 0 then
                if not DrawingBoxRegistry[playerObj] then
                    local success, box = pcall(function()
                        local sq = Drawing.new("Square")
                        sq.Visible = false sq.Color = Color3.fromRGB(0, 255, 255) sq.Thickness = 1 sq.Filled = false
                        return sq
                    end)
                    if success and box then DrawingBoxRegistry[playerObj] = box end
                end
                local box = DrawingBoxRegistry[playerObj]
                if box then
                    local rootPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                        local height = math.abs(headPos.Y - legPos.Y)
                        local width = height / 2
                        box.Size = Vector2.new(width, height)
                        box.Position = Vector2.new(rootPos.X - width / 2, headPos.Y)
                        box.Visible = true
                    else box.Visible = false end
                end
            else PurgeDrawingBox(playerObj) end
        else PurgeDrawingBox(playerObj) end
    end
end)

-- 6. Name ESP
local DrawingNameRegistry = {}
local function PurgeNameEsp(playerTarget)
    if DrawingNameRegistry[playerTarget] then pcall(function() DrawingNameRegistry[playerTarget]:Remove() end) DrawingNameRegistry[playerTarget] = nil end
end

RunService.RenderStepped:Connect(function()
    for _, playerObj in ipairs(Players:GetPlayers()) do
        if playerObj ~= LocalPlayer and ScriptSense.Config.NameEspEnabled then
            local character = playerObj.Character
            local head = character and character:FindFirstChild("Head")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            if character and head and humanoid and humanoid.Health > 0 then
                if not DrawingNameRegistry[playerObj] then
                    local success, txt = pcall(function()
                        local t = Drawing.new("Text")
                        t.Visible = false t.Center = true t.Outline = true t.Color = Color3.fromRGB(255, 255, 255) t.Size = 13
                        return t
                    end)
                    if success and txt then DrawingNameRegistry[playerObj] = txt end
                end
                local txt = DrawingNameRegistry[playerObj]
                if txt then
                    local headPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
                    if onScreen then
                        txt.Text = playerObj.Name .. " [" .. math.floor(humanoid.Health) .. "HP]"
                        txt.Position = Vector2.new(headPos.X, headPos.Y)
                        txt.Visible = true
                    else txt.Visible = false end
                end
            else PurgeNameEsp(playerObj) end
        else PurgeNameEsp(playerObj) end
    end
end)

-- 7. Aimbot Engine + FOV Circle
local FOVCircleDrawing = pcall(function() return Drawing.new("Circle") end) and Drawing.new("Circle") or nil
if FOVCircleDrawing then
    FOVCircleDrawing.Visible = false
    FOVCircleDrawing.Thickness = 1
    FOVCircleDrawing.Color = Color3.fromRGB(255, 255, 255)
    FOVCircleDrawing.Filled = false
    FOVCircleDrawing.Transparency = 0.5
end

RunService.RenderStepped:Connect(function()
    if FOVCircleDrawing then
        if ScriptSense.Config.AimbotEnabled and ScriptSense.Config.FovCircleEnabled and not IsRobloxMenuOpen() then
            FOVCircleDrawing.Position = UserInputService:GetMouseLocation()
            FOVCircleDrawing.Radius = ScriptSense.Config.AimbotFovRadius
            FOVCircleDrawing.Visible = true
        else
            FOVCircleDrawing.Visible = false
        end
    end

    if ScriptSense.Config.AimbotEnabled and not IsRobloxMenuOpen() then
        local targetPlayer = nil
        local shortestDistance = ScriptSense.Config.AimbotFovRadius
        for _, playerObj in ipairs(Players:GetPlayers()) do
            if playerObj ~= LocalPlayer then
                local character = playerObj.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                local head = character and character:FindFirstChild("Head")
                if character and humanoid and humanoid.Health > 0 and head then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            targetPlayer = playerObj
                        end
                    end
                end
            end
        end
        if targetPlayer and targetPlayer.Character then
            local targetHead = targetPlayer.Character:FindFirstChild("Head")
            if targetHead then
                local currentCFrame = Camera.CFrame
                local targetCFrame = CFrame.new(currentCFrame.Position, targetHead.Position)
                Camera.CFrame = currentCFrame:Lerp(targetCFrame, 1 / math.clamp(ScriptSense.Config.AimbotSmoothness, 1, 20))
            end
        end
    end
end)

-- 8. Godmode Engine
RunService.Stepped:Connect(function()
    if ScriptSense.Config.GodmodeEnabled then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then pcall(function() humanoid.MaxHealth = math.huge humanoid.Health = math.huge end) end
    end
end)

-- 9. Anti-Aim Engine (Works perfectly even during ShiftLock)
RunService.RenderStepped:Connect(function()
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if hrp and humanoid then
        if ScriptSense.Config.AntiAimEnabled then
            humanoid.AutoRotate = false
            local currentPos = hrp.Position
            ScriptSense.Config.CurrentSpinAngle = (ScriptSense.Config.CurrentSpinAngle + ScriptSense.Config.SpinSpeed) % 360
            hrp.CFrame = CFrame.new(currentPos) * CFrame.Angles(0, math.rad(ScriptSense.Config.CurrentSpinAngle), 0)
        else
            humanoid.AutoRotate = true
        end
    end
end)

-- Periodic UI Status Updater
task.spawn(function()
    while task.wait(0.2) do
        RefreshControlRowTexts()
    end
end)

-- Input Handling for Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if activeRebindKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            ScriptSense.Config.Keybinds[activeRebindKey] = input.KeyCode
            activeRebindKey = nil
            PopulateKeybindsDisplay()
            RefreshControlRowTexts()
        end
        return
    end
    if gameProcessed then return end

    if input.KeyCode == ScriptSense.Config.Keybinds.MenuToggle then ToggleMenuVisibility()
    elseif input.KeyCode == ScriptSense.Config.Keybinds.Wallhack then ScriptSense.Config.WallhackEnabled = not ScriptSense.Config.WallhackEnabled
    elseif input.KeyCode == ScriptSense.Config.Keybinds.Aimbot and not IsRobloxMenuOpen() then ScriptSense.Config.AimbotEnabled = not ScriptSense.Config.AimbotEnabled
    elseif input.KeyCode == ScriptSense.Config.Keybinds.Godmode then ScriptSense.Config.GodmodeEnabled = not ScriptSense.Config.GodmodeEnabled
    elseif input.KeyCode == ScriptSense.Config.Keybinds.Fly then ScriptSense.Config.FlyEnabled = not ScriptSense.Config.FlyEnabled
    elseif input.KeyCode == ScriptSense.Config.Keybinds.Skeleton then ScriptSense.Config.SkeletonEspEnabled = not ScriptSense.Config.SkeletonEspEnabled
    elseif input.KeyCode == ScriptSense.Config.Keybinds.BoxEsp then ScriptSense.Config.BoxEspEnabled = not ScriptSense.Config.BoxEspEnabled
    elseif input.KeyCode == ScriptSense.Config.Keybinds.NameEsp then ScriptSense.Config.NameEspEnabled = not ScriptSense.Config.NameEspEnabled
    elseif input.KeyCode == ScriptSense.Config.Keybinds.Speedhack then 
        ScriptSense.Config.SpeedhackEnabled = not ScriptSense.Config.SpeedhackEnabled
        if not ScriptSense.Config.SpeedhackEnabled then
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.WalkSpeed = ScriptSense.Config.DefaultWalkSpeed end
        end
    elseif input.KeyCode == ScriptSense.Config.Keybinds.AntiAim then ScriptSense.Config.AntiAimEnabled = not ScriptSense.Config.AntiAimEnabled end
    
    RefreshControlRowTexts()
end)

print("[ScriptSense v7.4.0]: Fully integrated with Wheel Scroll, ShiftLock Anti-Aim, and Speedhack.")
return ScriptSense
