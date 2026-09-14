local ScriptSense = {}
ScriptSense.Version = "7.6.2"
ScriptSense.Active = true

-- Services Retrieval
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
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

-- Draggable Utility Function
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if connection then connection:Disconnect() end
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

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
MainControlPanel.Size = UDim2.new(0, 240, 0, 440)
MainControlPanel.Position = UDim2.new(0, 20, 0, 65)
MainControlPanel.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainControlPanel.BorderSizePixel = 0
MainControlPanel.ClipsDescendants = true
MainControlPanel.Visible = false
MainControlPanel.Parent = ScreenGui

MakeDraggable(MainControlPanel, MainControlPanel)

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

MakeDraggable(MainControlPanel, MainTitleBar)

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

-- Main Footer Bar (Bottom Name & Version)
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

-- Keybinds Menu Window
local KeybindsMenuWindow = Instance.new("Frame")
KeybindsMenuWindow.Name = "KeybindsMenuWindow"
KeybindsMenuWindow.Size = UDim2.new(0, 300, 0, 390)
KeybindsMenuWindow.Position = UDim2.new(0.5, -150, 0.5, -195)
KeybindsMenuWindow.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
KeybindsMenuWindow.BorderSizePixel = 0
KeybindsMenuWindow.ClipsDescendants = true
KeybindsMenuWindow.Visible = false
KeybindsMenuWindow.Parent = ScreenGui

MakeDraggable(KeybindsMenuWindow, KeybindsMenuWindow)

local KbStroke = Instance.new("UIStroke")
KbStroke.Color = Color3.fromRGB(70, 70, 70)
KbStroke.Thickness = 2
KbStroke.Parent = KeybindsMenuWindow

local KbTitleBar = Instance.new("Frame")
KbTitleBar.Size = UDim2.new(1, 0, 0, 35)
KbTitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
KbTitleBar.BorderSizePixel = 0
KbTitleBar.Parent = KeybindsMenuWindow

MakeDraggable(KeybindsMenuWindow, KbTitleBar)

local KbTitle = Instance.new("TextLabel")
KbTitle.Size = UDim2.new(1, -35, 1, 0)
KbTitle.Position = UDim2.new(0, 12, 0, 0)
KbTitle.BackgroundTransparency = 1
KbTitle.RichText = true
KbTitle.Text = '<font color="#FFFFFF">SCRIPT</font> <font color="#FF0000">SENSE</font> <font color="#AAAAAA">v' .. ScriptSense.Version .. '</font> — KEYBIND MANAGER'
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

local PopulateKeybindsDisplay
local ToggleKeybindsMenu = function()
    KeybindsMenuWindow.Visible = not KeybindsMenuWindow.Visible
    if KeybindsMenuWindow.Visible then PopulateKeybindsDisplay() end
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

local function CreateSliderRow(parent, labelText, minVal, maxVal, initialValue, onValueChanged)
    local rowFrame = Instance.new("Frame")
    rowFrame.Size = UDim2.new(1, 0, 0, 48)
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
    label.Size = UDim2.new(1, -24, 0, 20)
    label.Position = UDim2.new(0, 12, 0, 6)
    label.BackgroundTransparency = 1
    label.TextTransparency = 1
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = "  " .. labelText .. " (" .. tostring(initialValue) .. ")"
    label.Parent = rowFrame

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -24, 0, 6)
    sliderBg.Position = UDim2.new(0, 12, 0, 32)
    sliderBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = rowFrame

    local sliderBgStroke = Instance.new("UIStroke")
    sliderBgStroke.Color = Color3.fromRGB(50, 50, 50)
    sliderBgStroke.Thickness = 1
    sliderBgStroke.Transparency = 1
    sliderBgStroke.Parent = sliderBg

    local sliderFill = Instance.new("Frame")
    local initPercent = math.clamp((initialValue - minVal) / (maxVal - minVal), 0, 1)
    sliderFill.Size = UDim2.new(initPercent, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg

    local dragging = false
    local function updateValue(input)
        local pos = input.Position.X
        local absPos = sliderBg.AbsolutePosition.X
        local absSize = sliderBg.AbsoluteSize.X
        local percent = math.clamp((pos - absPos) / (absSize > 0 and absSize or 1), 0, 1)
        local val = math.floor(minVal + (maxVal - minVal) * percent)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        label.Text = "  " .. labelText .. " (" .. tostring(val) .. ")"
        onValueChanged(val)
    end

    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateValue(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateValue(input)
        end
    end)

    table.insert(controlRowFrames, rowFrame)
    return rowFrame
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

local activeRebindKey = nil
local function GetKeyName(keyCode)
    local name = keyCode.Name
    if name == "Backquote" then return "`" end
    return string.lower(name)
end

-- Populate Panel Rows with live state updates
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

CreateSliderRow(MainContainer, "speedhack | speed", 16, 200, ScriptSense.Config.SpeedhackSpeed, function(val)
    ScriptSense.Config.SpeedhackSpeed = val
end)

CreateControlRow(MainContainer, "anti-aim: off | bind: u", function()
    ScriptSense.Config.AntiAimEnabled = not ScriptSense.Config.AntiAimEnabled
end, function(btn)
    local status = ScriptSense.Config.AntiAimEnabled and "on" or "off"
    btn.Text = "  anti-aim: " .. status .. " | bind: " .. string.lower(GetKeyName(ScriptSense.Config.Keybinds.AntiAim))
end)

CreateSliderRow(MainContainer, "anti aim | speed", 1, 100, ScriptSense.Config.SpinSpeed, function(val)
    ScriptSense.Config.SpinSpeed = val
end)

CreateSliderRow(MainContainer, "anti aim | angle", 0, 360, ScriptSense.Config.AntiAimHeadAngle, function(val)
    ScriptSense.Config.AntiAimHeadAngle = val
end)

-- Teleport Window
local TeleportWindow = Instance.new("Frame")
TeleportWindow.Name = "TeleportWindow"
TeleportWindow.Size = UDim2.new(0, 300, 0, 360)
TeleportWindow.Position = UDim2.new(0.5, -150, 0.5, -180)
TeleportWindow.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TeleportWindow.BorderSizePixel = 0
TeleportWindow.ClipsDescendants = true
TeleportWindow.Visible = false
TeleportWindow.Parent = ScreenGui

MakeDraggable(TeleportWindow, TeleportWindow)

local TpStroke = Instance.new("UIStroke")
TpStroke.Color = Color3.fromRGB(70, 70, 70)
TpStroke.Thickness = 2
TpStroke.Parent = TeleportWindow

local TpTitleBar = Instance.new("Frame")
TpTitleBar.Size = UDim2.new(1, 0, 0, 35)
TpTitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TpTitleBar.BorderSizePixel = 0
TpTitleBar.Parent = TeleportWindow

MakeDraggable(TeleportWindow, TpTitleBar)

local TpTitle = Instance.new("TextLabel")
TpTitle.Size = UDim2.new(1, -35, 1, 0)
TpTitle.Position = UDim2.new(0, 12, 0, 0)
TpTitle.BackgroundTransparency = 1
TpTitle.RichText = true
TpTitle.Text = '<font color="#FFFFFF">SCRIPT</font> <font color="#FF0000">SENSE</font> <font color="#AAAAAA">v' .. ScriptSense.Version .. '</font> — TELEPORT MENU'
TpTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
TpTitle.Font = Enum.Font.GothamBold
TpTitle.TextSize = 13
TpTitle.TextXAlignment = Enum.TextXAlignment.Left
TpTitle.Parent = TpTitleBar

local TpCloseBtn = Instance.new("TextButton")
TpCloseBtn.Size = UDim2.new(0, 35, 0, 35)
TpCloseBtn.Position = UDim2.new(1, -35, 0, 0)
TpCloseBtn.BackgroundTransparency = 1
TpCloseBtn.Text = "✕"
TpCloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
TpCloseBtn.Font = Enum.Font.GothamBold
TpCloseBtn.TextSize = 14
TpCloseBtn.Parent = TpTitleBar

TpCloseBtn.MouseButton1Click:Connect(function()
    TeleportWindow.Visible = false
end)

local TpScrollFrame = Instance.new("ScrollingFrame")
TpScrollFrame.Size = UDim2.new(1, 0, 1, -35)
TpScrollFrame.Position = UDim2.new(0, 0, 0, 35)
TpScrollFrame.BackgroundTransparency = 1
TpScrollFrame.BorderSizePixel = 0
TpScrollFrame.ScrollBarThickness = 6
TpScrollFrame.Active = true
TpScrollFrame.Parent = TeleportWindow

local TpLayout = Instance.new("UIListLayout")
TpLayout.SortOrder = Enum.SortOrder.LayoutOrder
TpLayout.Parent = TpScrollFrame

CreateControlRow(MainContainer, "teleport menu", function()
    TeleportWindow.Visible = not TeleportWindow.Visible
end)

-- Multi Fling Window
local FlingWindow = Instance.new("Frame")
FlingWindow.Name = "FlingWindow"
FlingWindow.Size = UDim2.new(0, 300, 0, 390)
FlingWindow.Position = UDim2.new(0.5, -150, 0.5, -195)
FlingWindow.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
FlingWindow.BorderSizePixel = 0
FlingWindow.ClipsDescendants = true
FlingWindow.Visible = false
FlingWindow.Parent = ScreenGui

MakeDraggable(FlingWindow, FlingWindow)

local FlingStroke = Instance.new("UIStroke")
FlingStroke.Color = Color3.fromRGB(70, 70, 70)
FlingStroke.Thickness = 2
FlingStroke.Parent = FlingWindow

local FlingTitleBar = Instance.new("Frame")
FlingTitleBar.Size = UDim2.new(1, 0, 0, 35)
FlingTitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FlingTitleBar.BorderSizePixel = 0
FlingTitleBar.Parent = FlingWindow

MakeDraggable(FlingWindow, FlingTitleBar)

local FlingTitle = Instance.new("TextLabel")
FlingTitle.Size = UDim2.new(1, -35, 1, 0)
FlingTitle.Position = UDim2.new(0, 12, 0, 0)
FlingTitle.BackgroundTransparency = 1
FlingTitle.RichText = true
FlingTitle.Text = '<font color="#FFFFFF">SCRIPT</font> <font color="#FF0000">SENSE</font> <font color="#AAAAAA">v' .. ScriptSense.Version .. '</font> — MULTI FLING'
FlingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingTitle.Font = Enum.Font.GothamBold
FlingTitle.TextSize = 13
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

CreateControlRow(MainContainer, "multi fling menu", function()
    FlingWindow.Visible = not FlingWindow.Visible
end)

CreateControlRow(MainContainer, "keybinds menu | bind: `", function()
    ToggleKeybindsMenu()
end)

-- Global Keybinds Listener Integration
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
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
        
        -- Refresh control panel UI texts
        for _, updateCb in ipairs(controlRowUpdateCallbacks) do
            pcall(updateCb)
        end
    end
end)

-- Update MainContainer CanvasSize automatically
MainListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    MainContainer.CanvasSize = UDim2.new(0, 0, 0, MainListLayout.AbsoluteContentSize.Y + 10)
end)

-- Intro Sequence (2 seconds appearance duration) with Version Integration
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
