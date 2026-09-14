local ScriptSense = {}
ScriptSense.Version = "6.5.0"
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
    AntiAimEnabled = false,
    TouchFlingEnabled = false,

    FlySpeed = 50,
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
        AntiAim = Enum.KeyCode.U,
        TouchFling = Enum.KeyCode.K,
        KickFling = Enum.KeyCode.Z,
        MenuToggle = Enum.KeyCode.Backquote,
    }
}

local function SafeDestroy(instance)
    if instance and typeof(instance) == "Instance" then
        pcall(function() instance:Destroy() end)
    end
end

-- Full Cleanup: clear from both gethui() and CoreGui to prevent caching
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
pcall(function()
    RootGuiParent = gethui()
end)
if not RootGuiParent then
    pcall(function()
        RootGuiParent = CoreGui
    end)
end
if not RootGuiParent then
    RootGuiParent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Main UI Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptSenseEnterpriseGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = RootGuiParent

local IsMobileDevice = UserInputService.TouchEnabled

-- Watermark Container (Starts strictly centered on screen using AnchorPoint 0.5, 0.5)
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
WatermarkLabel.TextSize = 28
WatermarkLabel.Font = Enum.Font.GothamBold
WatermarkLabel.RichText = true
WatermarkLabel.Text = ""
WatermarkLabel.TextXAlignment = Enum.TextXAlignment.Left
WatermarkLabel.TextTransparency = 0
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
MainControlPanel.Size = UDim2.new(0, 240, 0, 540)
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

-- Dedicated Interactive Keybinds Menu Window
local KeybindsMenuWindow = Instance.new("Frame")
KeybindsMenuWindow.Name = "KeybindsMenuWindow"
KeybindsMenuWindow.Size = UDim2.new(0, 300, 0, 420)
KeybindsMenuWindow.Position = UDim2.new(0.5, -150, 0.5, -210)
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
KbTitle.Position = UDim2.new(0, 0, 0, 0)
KbTitle.BackgroundTransparency = 1
KbTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KbTitle.TextSize = 14
KbTitle.Font = Enum.Font.GothamBold
KbTitle.Text = "  KEYBIND MANAGER (Click to rebind)"
KbTitle.TextXAlignment = Enum.TextXAlignment.Left
KbTitle.Parent = KeybindsMenuWindow

local KbContainer = Instance.new("ScrollingFrame")
KbContainer.Name = "KbContainer"
KbContainer.Size = UDim2.new(1, 0, 1, -40)
KbContainer.Position = UDim2.new(0, 0, 0, 40)
KbContainer.BackgroundTransparency = 1
KbContainer.BorderSizePixel = 0
KbContainer.ScrollBarThickness = 4
KbContainer.Parent = KeybindsMenuWindow

local KbListLayout = Instance.new("UIListLayout")
KbListLayout.SortOrder = Enum.SortOrder.LayoutOrder
KbListLayout.Padding = UDim.new(0, 4)
KbListLayout.Parent = KbContainer

local PopulateKeybindsDisplay

local function ToggleKeybindsMenu()
    KeybindsMenuWindow.Visible = not KeybindsMenuWindow.Visible
    if KeybindsMenuWindow.Visible then
        PopulateKeybindsDisplay()
    end
end

local UIComponentRegistry = {}
local controlRowFrames = {}

local function CreateControlRow(parent, posY, initialText, callback)
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
            local success, err = pcall(callback)
            if not success and err then
                warn("[ScriptSense Error]: " .. tostring(err))
            end
        end)
    end

    table.insert(controlRowFrames, rowFrame)
    return rowFrame, button
end

local startFlingThread
local activeRebindKey = nil

local function GetKeyName(keyCode)
    local name = keyCode.Name
    if name == "Backquote" then return "`" end
    return string.lower(name)
end

-- DropKick execution function
local function TriggerDropKick()
    local discord = "https://discord.gg/AeuSH2EQK"
    if setclipboard then
        setclipboard(discord)
    end
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "c00lkids103 Script",
            Text = "Discord copied! Join: " .. discord .. "\nMade by c00lkids103",
            Duration = 10,
            Button1 = "Okay"
        })
    end)
    task.spawn(function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/platinww/CrustyMain/refs/heads/main/universal/DropKick.lua"))()
        end)
        if success then
            print("✅ DropKick script loaded successfully!")
        else
            warn("❌ Failed to load DropKick script: " .. tostring(err))
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "c00lkids103 Script",
                    Text = "Failed to load DropKick script.\nCheck your executor or internet.",
                    Duration = 8,
                })
            end)
        end
    end)
end

-- Populate Main Control Panel Rows
local verticalOffset = 15

local _, wallhackRowBtn = CreateControlRow(MainControlPanel, verticalOffset, "wallhack: off | bind: g", function()
    ScriptSense.Config.WallhackEnabled = not ScriptSense.Config.WallhackEnabled
end)
UIComponentRegistry["wallhack"] = wallhackRowBtn
verticalOffset = verticalOffset + 42

local _, aimbotRowBtn = CreateControlRow(MainControlPanel, verticalOffset, "aimbot: off | bind: r", function()
    if not IsRobloxMenuOpen() then
        ScriptSense.Config.AimbotEnabled = not ScriptSense.Config.AimbotEnabled
    end
end)
UIComponentRegistry["aimbot"] = aimbotRowBtn
verticalOffset = verticalOffset + 42

local _, godmodeRowBtn = CreateControlRow(MainControlPanel, verticalOffset, "godmode: off | bind: c", function()
    ScriptSense.Config.GodmodeEnabled = not ScriptSense.Config.GodmodeEnabled
end)
UIComponentRegistry["godmode"] = godmodeRowBtn
verticalOffset = verticalOffset + 42

local _, flyRowBtn = CreateControlRow(MainControlPanel, verticalOffset, "fly: off | bind: f", function()
    ScriptSense.Config.FlyEnabled = not ScriptSense.Config.FlyEnabled
end)
UIComponentRegistry["fly"] = flyRowBtn
verticalOffset = verticalOffset + 42

local _, skeletonRowBtn = CreateControlRow(MainControlPanel, verticalOffset, "skeleton esp: off | bind: x", function()
    ScriptSense.Config.SkeletonEspEnabled = not ScriptSense.Config.SkeletonEspEnabled
end)
UIComponentRegistry["skeleton"] = skeletonRowBtn
verticalOffset = verticalOffset + 42

local _, boxEspRowBtn = CreateControlRow(MainControlPanel, verticalOffset, "box esp: off | bind: b", function()
    ScriptSense.Config.BoxEspEnabled = not ScriptSense.Config.BoxEspEnabled
end)
UIComponentRegistry["boxesp"] = boxEspRowBtn
verticalOffset = verticalOffset + 42

local _, antiAimRowBtn = CreateControlRow(MainControlPanel, verticalOffset, "anti-aim: off | bind: u", function()
    ScriptSense.Config.AntiAimEnabled = not ScriptSense.Config.AntiAimEnabled
end)
UIComponentRegistry["anti-aim"] = antiAimRowBtn
verticalOffset = verticalOffset + 42

local _, touchFlingRowBtn = CreateControlRow(MainControlPanel, verticalOffset, "touchfling: off | bind: k", function()
    ScriptSense.Config.TouchFlingEnabled = not ScriptSense.Config.TouchFlingEnabled
    if ScriptSense.Config.TouchFlingEnabled then
        startFlingThread()
    end
end)
UIComponentRegistry["touchfling"] = touchFlingRowBtn
verticalOffset = verticalOffset + 42

-- Teleport Window
local TeleportWindow = Instance.new("ScrollingFrame")
TeleportWindow.Name = "TeleportWindow"
TeleportWindow.Size = UDim2.new(0, 300, 0, 360)
TeleportWindow.Position = UDim2.new(0.5, -150, 0.5, -180)
TeleportWindow.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TeleportWindow.BorderSizePixel = 0
TeleportWindow.ScrollBarThickness = 6
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

-- DropKick (Kick Fling) integrated button with bind Z
CreateControlRow(MainControlPanel, verticalOffset, "kick fling (c00lkids103) | bind: z", function()
    TriggerDropKick()
end)
verticalOffset = verticalOffset + 42

CreateControlRow(MainControlPanel, verticalOffset, "keybinds menu | bind: `", function()
    ToggleKeybindsMenu()
end)
UIComponentRegistry["menutoggle"] = menuToggleRowBtn
verticalOffset = verticalOffset + 42

-- Intro Sequence (2s Typewriter)
task.spawn(function()
    local fullText = "SCRIPT SENSE [v6.5.0]"
    local totalChars = #fullText
    local totalDuration = 2.0
    local charDelay = totalDuration / totalChars

    local function getPartialText(count)
        local scriptPart = string.sub("SCRIPT", 1, math.min(count, 6))
        local res = '<font color="#FFFFFF">' .. scriptPart .. '</font>'
        
        if count > 6 then
            local spaceAndSense = string.sub(" SENSE", 1, count - 6)
            res = res .. '<font color="#FF0000">' .. spaceAndSense .. '</font>'
        end
        
        if count > 12 then
            local spaceAndVer = string.sub(" [v6.5.0]", 1, count - 12)
            res = res .. '<font color="#AAAAAA">' .. spaceAndVer .. '</font>'
        end
        
        return res
    end

    for i = 1, totalChars do
        WatermarkLabel.Text = getPartialText(i)
        task.wait(charDelay)
    end
    WatermarkLabel.Text = '<font color="#FFFFFF">SCRIPT</font> <font color="#FF0000">SENSE</font> <font color="#AAAAAA">[v6.5.0]</font>'

    local currentAbsPos = WatermarkContainer.AbsolutePosition
    WatermarkContainer.AnchorPoint = Vector2.new(0, 0)
    WatermarkContainer.Position = UDim2.new(0, currentAbsPos.X, 0, currentAbsPos.Y)

    local transitionTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local moveTween = TweenService:Create(WatermarkContainer, transitionTweenInfo, {
        Position = UDim2.new(0, 20, 0, 20)
    })
    moveTween:Play()

    local textSizeVal = Instance.new("NumberValue")
    textSizeVal.Value = 28
    textSizeVal.Changed:Connect(function(v)
        WatermarkLabel.TextSize = v
    end)
    TweenService:Create(textSizeVal, transitionTweenInfo, { Value = 16 }):Play()
    task.delay(0.45, function() SafeDestroy(textSizeVal) end)

    TweenService:Create(MenuToggleArrow, transitionTweenInfo, {
        TextTransparency = 0,
        BackgroundTransparency = 0
    }):Play()
    TweenService:Create(ArrowStroke, transitionTweenInfo, {
        Transparency = 0
    }):Play()

    moveTween.Completed:Wait()
    task.wait(0.2)

    if not IsMobileDevice then
        MainControlPanel.Visible = true
        isPanelVisible = true
    end

    TweenService:Create(PanelStroke, transitionTweenInfo, {
        Transparency = 0
    }):Play()

    for index, rowFrame in ipairs(controlRowFrames) do
        if rowFrame then
            task.delay((index - 1) * 0.03 + 0.03, function()
                rowFrame.Visible = true
                local rowTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

                TweenService:Create(rowFrame, rowTweenInfo, { BackgroundTransparency = 0.2 }):Play()
                
                local stroke = rowFrame:FindFirstChildOfClass("UIStroke")
                if stroke then
                    TweenService:Create(stroke, rowTweenInfo, { Transparency = 0 }):Play()
                end

                local btn = rowFrame:FindFirstChildOfClass("TextButton")
                if btn then
                    TweenService:Create(btn, rowTweenInfo, { TextTransparency = 0 }):Play()
                end
            end)
        end
    end
end)

-- Populate Interactive Keybinds Menu Content
PopulateKeybindsDisplay = function()
    for _, child in ipairs(KbContainer:GetChildren()) do
        if child:IsA("Frame") then
            SafeDestroy(child)
        end
    end

    local bindsData = {
        {"Wallhack", "Wallhack", ScriptSense.Config.Keybinds.Wallhack},
        {"Aimbot", "Aimbot", ScriptSense.Config.Keybinds.Aimbot},
        {"Godmode", "Godmode", ScriptSense.Config.Keybinds.Godmode},
        {"Fly", "Fly", ScriptSense.Config.Keybinds.Fly},
        {"Skeleton ESP", "Skeleton", ScriptSense.Config.Keybinds.Skeleton},
        {"Box ESP", "BoxEsp", ScriptSense.Config.Keybinds.BoxEsp},
        {"Anti-Aim", "AntiAim", ScriptSense.Config.Keybinds.AntiAim},
        {"TouchFling", "TouchFling", ScriptSense.Config.Keybinds.TouchFling},
        {"KickFling", "KickFling", ScriptSense.Config.Keybinds.KickFling},
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

local function RefreshPlayerTeleportList()
    for _, child in ipairs(TeleportWindow:GetChildren()) do
        if child:IsA("TextButton") then
            SafeDestroy(child)
        end
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
                    local targetChar = playerObj.Character
                    local localChar = LocalPlayer.Character
                    if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                        if localChar and localChar:FindFirstChild("HumanoidRootPart") then
                            localChar.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                        end
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

-- 1. Wallhack Engine
RunService.Stepped:Connect(function()
    if ScriptSense.Config.WallhackEnabled then
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
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

-- 3. TouchFling Engine
if not ReplicatedStorage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
    local detection = Instance.new("Decal")
    detection.Name = "juisdfj0i32i0eidsuf0iok"
    detection.Parent = ReplicatedStorage
end

local flingThread = nil
startFlingThread = function()
    if flingThread then return end
    flingThread = coroutine.create(function()
        local c, hrp, vel, movel = nil, nil, nil, 0.1
        while ScriptSense.Config.TouchFlingEnabled do
            RunService.Heartbeat:Wait()
            c = LocalPlayer.Character
            hrp = c and c:FindFirstChild("HumanoidRootPart")

            if hrp then
                vel = hrp.Velocity
                hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
                RunService.RenderStepped:Wait()
                hrp.Velocity = vel
                RunService.Stepped:Wait()
                hrp.Velocity = vel + Vector3.new(0, movel, 0)
                movel = -movel
            end
        end
        flingThread = nil
    end)
    coroutine.resume(flingThread)
end

-- 4. Native Drawing Skeleton ESP Rendering Engine (Pure Skeleton)
local DrawingSkeletonRegistry = {}

local function PurgeDrawingSkeleton(playerTarget)
    if DrawingSkeletonRegistry[playerTarget] then
        for _, line in pairs(DrawingSkeletonRegistry[playerTarget]) do
            pcall(function() line:Remove() end)
        end
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
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or rootPart
                
                local leftArm = character:FindFirstChild("LeftHand") or character:FindFirstChild("LeftLowerArm") or character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm")
                local rightArm = character:FindFirstChild("RightHand") or character:FindFirstChild("RightLowerArm") or character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm")
                local leftLeg = character:FindFirstChild("LeftFoot") or character:FindFirstChild("LeftLowerLeg") or character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg")
                local rightLeg = character:FindFirstChild("RightFoot") or character:FindFirstChild("RightLowerLeg") or character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg")

                if head and torso then
                    if not DrawingSkeletonRegistry[playerObj] then
                        local successCreate, linesTable = pcall(function()
                            return {
                                HeadToTorso = Drawing.new("Line"),
                                TorsoToLeftArm = Drawing.new("Line"),
                                TorsoToRightArm = Drawing.new("Line"),
                                TorsoToLeftLeg = Drawing.new("Line"),
                                TorsoToRightLeg = Drawing.new("Line"),
                            }
                        end)
                        if successCreate and linesTable then
                            DrawingSkeletonRegistry[playerObj] = linesTable
                            for _, line in pairs(linesTable) do
                                pcall(function()
                                    line.Visible = false
                                    line.Color = Color3.fromRGB(255, 255, 255)
                                    line.Thickness = 1.5
                                    line.Transparency = 1
                                end)
                            end
                        end
                    end

                    local lines = DrawingSkeletonRegistry[playerObj]
                    if lines then
                        local function updateLine(lineObj, partA, partB)
                            if lineObj and partA and partB then
                                local posA, visA = Camera:WorldToViewportPoint(partA.Position)
                                local posB, visB = Camera:WorldToViewportPoint(partB.Position)
                                if visA or visB then
                                    lineObj.From = Vector2.new(posA.X, posA.Y)
                                    lineObj.To = Vector2.new(posB.X, posB.Y)
                                    lineObj.Visible = true
                                else
                                    lineObj.Visible = false
                                end
                            elseif lineObj then
                                lineObj.Visible = false
                            end
                        end

                        updateLine(lines.HeadToTorso, head, torso)
                        updateLine(lines.TorsoToLeftArm, torso, leftArm)
                        updateLine(lines.TorsoToRightArm, torso, rightArm)
                        updateLine(lines.TorsoToLeftLeg, torso, leftLeg)
                        updateLine(lines.TorsoToRightLeg, torso, rightLeg)
                    end
                else
                    PurgeDrawingSkeleton(playerObj)
                end
            else
                PurgeDrawingSkeleton(playerObj)
            end
        else
            PurgeDrawingSkeleton(playerObj)
        end
    end
end)

Players.PlayerRemoving:Connect(function(playerObj)
    PurgeDrawingSkeleton(playerObj)
end)

-- 5. Native Drawing Box ESP Rendering Engine (Separate Box ESP)
local DrawingBoxRegistry = {}

local function PurgeDrawingBox(playerTarget)
    if DrawingBoxRegistry[playerTarget] then
        pcall(function() DrawingBoxRegistry[playerTarget]:Remove() end)
        DrawingBoxRegistry[playerTarget] = nil
    end
end

RunService.RenderStepped:Connect(function()
    for _, playerObj in ipairs(Players:GetPlayers()) do
        if playerObj ~= LocalPlayer and ScriptSense.Config.BoxEspEnabled then
            local character = playerObj.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")

            if character and humanoid and humanoid.Health > 0 and rootPart then
                if not DrawingBoxRegistry[playerObj] then
                    local successCreate, boxObj = pcall(function()
                        local sq = Drawing.new("Square")
                        sq.Visible = false
                        sq.Color = Color3.fromRGB(0, 255, 255)
                        sq.Thickness = 1.5
                        sq.Transparency = 1
                        sq.Filled = false
                        return sq
                    end)
                    if successCreate and boxObj then
                        DrawingBoxRegistry[playerObj] = boxObj
                    end
                end

                local box = DrawingBoxRegistry[playerObj]
                if box then
                    local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    if onScreen then
                        local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
                        local height = math.clamp(2500 / distance, 20, 500)
                        local width = height * 0.6

                        box.Size = Vector2.new(width, height)
                        box.Position = Vector2.new(rootPos.X - width / 2, rootPos.Y - height / 2)
                        box.Visible = true
                    else
                        box.Visible = false
                    end
                end
            else
                PurgeDrawingBox(playerObj)
            end
        else
            PurgeDrawingBox(playerObj)
        end
    end
end)

Players.PlayerRemoving:Connect(function(playerObj)
    PurgeDrawingBox(playerObj)
end)

-- 6. Anti-Aim Engine
RunService.Heartbeat:Connect(function()
    if ScriptSense.Config.AntiAimEnabled then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character.HumanoidRootPart
            ScriptSense.Config.CurrentSpinAngle = (ScriptSense.Config.CurrentSpinAngle + ScriptSense.Config.SpinSpeed) % 360
            rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, math.rad(ScriptSense.Config.CurrentSpinAngle), 0)
            rootPart.RotVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- 7. Godmode Engine
RunService.Stepped:Connect(function()
    if ScriptSense.Config.GodmodeEnabled then
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = humanoid.MaxHealth
            end
        end
    end
end)

-- 8. Aimbot Engine
local function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = ScriptSense.Config.AimbotFovRadius

    for _, playerObj in ipairs(Players:GetPlayers()) do
        if playerObj ~= LocalPlayer and playerObj.Character then
            local humanoid = playerObj.Character:FindFirstChildOfClass("Humanoid")
            local head = playerObj.Character:FindFirstChild("Head")
            if humanoid and humanoid.Health > 0 and head then
                local screenPoint, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = playerObj
                    end
                end
            end
        end
    end
    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if IsRobloxMenuOpen() then return end
    if ScriptSense.Config.AimbotEnabled then
        local target = GetClosestPlayerToCursor()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local headPos = target.Character.Head.Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, headPos), 1 / ScriptSense.Config.AimbotSmoothness)
        end
    end
end)

-- GUI Sync Loop
RunService.RenderStepped:Connect(function()
    if UIComponentRegistry["wallhack"] then 
        UIComponentRegistry["wallhack"].Text = "wallhack: " .. (ScriptSense.Config.WallhackEnabled and "on" or "off") .. " | bind: " .. GetKeyName(ScriptSense.Config.Keybinds.Wallhack) 
    end
    if UIComponentRegistry["aimbot"] then 
        UIComponentRegistry["aimbot"].Text = "aimbot: " .. (ScriptSense.Config.AimbotEnabled and "on" or "off") .. " | bind: " .. GetKeyName(ScriptSense.Config.Keybinds.Aimbot) 
    end
    if UIComponentRegistry["godmode"] then 
        UIComponentRegistry["godmode"].Text = "godmode: " .. (ScriptSense.Config.GodmodeEnabled and "on" or "off") .. " | bind: " .. GetKeyName(ScriptSense.Config.Keybinds.Godmode) 
    end
    if UIComponentRegistry["fly"] then 
        UIComponentRegistry["fly"].Text = "fly: " .. (ScriptSense.Config.FlyEnabled and "on" or "off") .. " | bind: " .. GetKeyName(ScriptSense.Config.Keybinds.Fly) 
    end
    if UIComponentRegistry["skeleton"] then 
        UIComponentRegistry["skeleton"].Text = "skeleton esp: " .. (ScriptSense.Config.SkeletonEspEnabled and "on" or "off") .. " | bind: " .. GetKeyName(ScriptSense.Config.Keybinds.Skeleton) 
    end
    if UIComponentRegistry["boxesp"] then 
        UIComponentRegistry["boxesp"].Text = "box esp: " .. (ScriptSense.Config.BoxEspEnabled and "on" or "off") .. " | bind: " .. GetKeyName(ScriptSense.Config.Keybinds.BoxEsp) 
    end
    if UIComponentRegistry["anti-aim"] then 
        UIComponentRegistry["anti-aim"].Text = "anti-aim: " .. (ScriptSense.Config.AntiAimEnabled and "on" or "off") .. " | bind: " .. GetKeyName(ScriptSense.Config.Keybinds.AntiAim) 
    end
    if UIComponentRegistry["touchfling"] then 
        UIComponentRegistry["touchfling"].Text = "touchfling: " .. (ScriptSense.Config.TouchFlingEnabled and "on" or "off") .. " | bind: " .. GetKeyName(ScriptSense.Config.Keybinds.TouchFling) 
    end
    if UIComponentRegistry["menutoggle"] then
        UIComponentRegistry["menutoggle"].Text = "keybinds menu | bind: " .. GetKeyName(ScriptSense.Config.Keybinds.MenuToggle)
    end
end)

-- Keybind Listener
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if UserInputService:GetFocusedTextBox() then return end

        if activeRebindKey then
            if input.KeyCode == Enum.KeyCode.Escape then
                activeRebindKey = nil
            elseif input.KeyCode ~= Enum.KeyCode.Unknown then
                ScriptSense.Config.Keybinds[activeRebindKey] = input.KeyCode
                activeRebindKey = nil
            end
            PopulateKeybindsDisplay()
            return
        end

        if input.KeyCode == ScriptSense.Config.Keybinds.Wallhack then
            ScriptSense.Config.WallhackEnabled = not ScriptSense.Config.WallhackEnabled
        elseif input.KeyCode == ScriptSense.Config.Keybinds.Aimbot then
            if not IsRobloxMenuOpen() then
                ScriptSense.Config.AimbotEnabled = not ScriptSense.Config.AimbotEnabled
            end
        elseif input.KeyCode == ScriptSense.Config.Keybinds.Godmode then
            ScriptSense.Config.GodmodeEnabled = not ScriptSense.Config.GodmodeEnabled
        elseif input.KeyCode == ScriptSense.Config.Keybinds.Fly then
            ScriptSense.Config.FlyEnabled = not ScriptSense.Config.FlyEnabled
        elseif input.KeyCode == ScriptSense.Config.Keybinds.Skeleton then
            ScriptSense.Config.SkeletonEspEnabled = not ScriptSense.Config.SkeletonEspEnabled
        elseif input.KeyCode == ScriptSense.Config.Keybinds.BoxEsp then
            ScriptSense.Config.BoxEspEnabled = not ScriptSense.Config.BoxEspEnabled
        elseif input.KeyCode == ScriptSense.Config.Keybinds.AntiAim then
            ScriptSense.Config.AntiAimEnabled = not ScriptSense.Config.AntiAimEnabled
        elseif input.KeyCode == ScriptSense.Config.Keybinds.TouchFling then
            ScriptSense.Config.TouchFlingEnabled = not ScriptSense.Config.TouchFlingEnabled
            if ScriptSense.Config.TouchFlingEnabled then
                startFlingThread()
            end
        elseif input.KeyCode == ScriptSense.Config.Keybinds.KickFling then
            TriggerDropKick()
        elseif input.KeyCode == ScriptSense.Config.Keybinds.MenuToggle then
            ToggleKeybindsMenu()
        end
    end
end)

print("[ScriptSense Enterprise v6.5.0]: Loaded successfully.")
