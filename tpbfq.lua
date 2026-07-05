local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

---------------------------------------------------------
-- 0. 基础设置与文件系统初始化
---------------------------------------------------------
local FOLDER_NAME = "HAOXIAO_Player"
if makefolder and not isfolder(FOLDER_NAME) then
    makefolder(FOLDER_NAME)
end

if CoreGui:FindFirstChild("HAOXIAO_ImagePlayer_GUI") then
    CoreGui:FindFirstChild("HAOXIAO_ImagePlayer_GUI"):Destroy()
end
if CoreGui:FindFirstChild("HAOXIAO_Display") then
    CoreGui:FindFirstChild("HAOXIAO_Display"):Destroy()
end

local isMinimized = false
local sideUIOpen = false
local currentImageMode = "none" 
local isPlaying = false
local playSpeed = 30
local imageSize = 200
local canDragImg = false
local playTask = nil

---------------------------------------------------------
-- 1. 核心容器创建 (新增主 UI 白色描边)
---------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HAOXIAO_ImagePlayer_GUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local ImageDisplayGui = Instance.new("ScreenGui")
ImageDisplayGui.Name = "HAOXIAO_Display"
ImageDisplayGui.Parent = CoreGui

local ImageContainer = Instance.new("Frame")
ImageContainer.Size = UDim2.new(0, 200, 0, 200)
ImageContainer.Position = UDim2.new(0, 50, 1, -50)
ImageContainer.AnchorPoint = Vector2.new(0, 1)
ImageContainer.BackgroundTransparency = 1
ImageContainer.Visible = false
ImageContainer.Active = false
ImageContainer.Draggable = false
ImageContainer.Parent = ImageDisplayGui

local MainDraggable = Instance.new("Frame")
MainDraggable.Size = UDim2.new(0, 150, 0, 300)
MainDraggable.Position = UDim2.new(0.5, -75, 0.5, -150)
MainDraggable.BackgroundTransparency = 1
MainDraggable.Active = true
MainDraggable.Draggable = false
MainDraggable.Parent = ScreenGui

local MainBg = Instance.new("Frame")
MainBg.Size = UDim2.new(1, 0, 1, 0)
MainBg.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
MainBg.BackgroundTransparency = 0.8
MainBg.BorderSizePixel = 0
MainBg.Parent = MainDraggable

local MainBgCorner = Instance.new("UICorner", MainBg)
MainBgCorner.CornerRadius = UDim.new(0, 5)

-- 【新增】主外部 UI 白色描边
local MainBgStroke = Instance.new("UIStroke")
MainBgStroke.Color = Color3.fromRGB(255, 255, 255)
MainBgStroke.Thickness = 1
MainBgStroke.Parent = MainBg

---------------------------------------------------------
-- 2. 顶部分区
---------------------------------------------------------
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(0, 150, 0, 40)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainDraggable

local TopLine = Instance.new("Frame")
TopLine.Size = UDim2.new(1, 0, 0, 1)
TopLine.Position = UDim2.new(0, 0, 1, -1)
TopLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TopLine.BorderSizePixel = 0
TopLine.Parent = TopBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 40, 0, 40)
MinBtn.Position = UDim2.new(0, 0, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 20
MinBtn.Active = false 
MinBtn.Parent = TopBar

local Line1 = Instance.new("Frame")
Line1.Size = UDim2.new(0, 1, 1, 0)
Line1.Position = UDim2.new(1, -1, 0, 0)
Line1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Line1.BorderSizePixel = 0
Line1.Parent = MinBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(0, 40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 20
CloseBtn.Active = false 
CloseBtn.Parent = TopBar

local Line2 = Instance.new("Frame")
Line2.Size = UDim2.new(0, 1, 1, 0)
Line2.Position = UDim2.new(1, -1, 0, 0)
Line2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Line2.BorderSizePixel = 0
Line2.Parent = CloseBtn

local TitleArea = Instance.new("TextLabel")
TitleArea.Size = UDim2.new(0, 70, 0, 40)
TitleArea.Position = UDim2.new(0, 80, 0, 0)
TitleArea.BackgroundTransparency = 1
TitleArea.Text = "HAOXIAO"
TitleArea.TextColor3 = Color3.fromRGB(255, 255, 255) 
TitleArea.Font = Enum.Font.GothamBold
TitleArea.TextSize = 14
TitleArea.Parent = TopBar

---------------------------------------------------------
-- 3. 安全退出弹窗
---------------------------------------------------------
local ConfirmBox = Instance.new("Frame")
ConfirmBox.AnchorPoint = Vector2.new(0.5, 0.5) 
ConfirmBox.Size = UDim2.new(0, 0, 0, 0) 
ConfirmBox.Position = UDim2.new(0.5, 0, 0.5, 0)
ConfirmBox.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
ConfirmBox.BackgroundTransparency = 0.8
ConfirmBox.ClipsDescendants = true 
ConfirmBox.Visible = false
ConfirmBox.ZIndex = 10
ConfirmBox.Parent = MainDraggable

Instance.new("UICorner", ConfirmBox).CornerRadius = UDim.new(0, 10)

local ConfirmStroke = Instance.new("UIStroke")
ConfirmStroke.Color = Color3.fromRGB(255, 255, 255)
ConfirmStroke.Thickness = 1
ConfirmStroke.Parent = ConfirmBox

local ConfirmText = Instance.new("TextLabel")
ConfirmText.Size = UDim2.new(1, 0, 0, 73)
ConfirmText.BackgroundTransparency = 1
ConfirmText.Text = "确定退出?"
ConfirmText.TextColor3 = Color3.fromRGB(255, 255, 255)
ConfirmText.Font = Enum.Font.SourceSansBold
ConfirmText.TextSize = 18
ConfirmText.ZIndex = 11
ConfirmText.Parent = ConfirmBox

local ConfirmLine = Instance.new("Frame")
ConfirmLine.Size = UDim2.new(1, 0, 0, 1)
ConfirmLine.Position = UDim2.new(0, 0, 0, 73)
ConfirmLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ConfirmLine.BorderSizePixel = 0
ConfirmLine.ZIndex = 11
ConfirmLine.Parent = ConfirmBox

local CancelBtn = Instance.new("TextButton")
CancelBtn.Size = UDim2.new(0, 100, 0, 66)
CancelBtn.Position = UDim2.new(0, 0, 0, 74)
CancelBtn.BackgroundTransparency = 1
CancelBtn.Text = "取消"
CancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CancelBtn.ZIndex = 11
CancelBtn.Parent = ConfirmBox

local AcceptBtn = Instance.new("TextButton")
AcceptBtn.Size = UDim2.new(0, 100, 0, 66)
AcceptBtn.Position = UDim2.new(0, 100, 0, 74)
AcceptBtn.BackgroundTransparency = 1
AcceptBtn.Text = "确定"
AcceptBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
AcceptBtn.ZIndex = 11
AcceptBtn.Parent = ConfirmBox

local VLine = Instance.new("Frame")
VLine.Size = UDim2.new(0, 1, 1, 0)
VLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
VLine.BorderSizePixel = 0
VLine.ZIndex = 11
VLine.Parent = AcceptBtn

local function showConfirmBox()
    ConfirmBox.Visible = true
    TweenService:Create(ConfirmBox, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 200, 0, 140)}):Play()
end

local function hideConfirmBox()
    local tw = TweenService:Create(ConfirmBox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
    tw:Play()
    tw.Completed:Connect(function()
        if ConfirmBox.Size.X.Offset == 0 then ConfirmBox.Visible = false end
    end)
end

CancelBtn.MouseButton1Click:Connect(hideConfirmBox)
AcceptBtn.MouseButton1Click:Connect(function()
    if playTask then task.cancel(playTask) end
    ScreenGui:Destroy()
    ImageDisplayGui:Destroy()
    StarterGui:SetCore("SendNotification", {
        Title = "HAOXIAO";
        Text = "感谢使用~";
        Icon = "rbxassetid://87761482164390";
        Duration = 2;
    })
end)

---------------------------------------------------------
-- 4. 侧边栏 UI (新增白色描边)
---------------------------------------------------------
local SideUI = Instance.new("Frame")
SideUI.Size = UDim2.new(0, 0, 0, 300)
SideUI.Position = UDim2.new(1, 0, 0, 0)
SideUI.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
SideUI.BackgroundTransparency = 0.8 
SideUI.BorderSizePixel = 0
SideUI.ClipsDescendants = true
SideUI.Visible = false
SideUI.Parent = MainDraggable
Instance.new("UICorner", SideUI).CornerRadius = UDim.new(0, 5)

-- 【新增】侧边栏白色描边保持统一
local SideUIStroke = Instance.new("UIStroke")
SideUIStroke.Color = Color3.fromRGB(255, 255, 255)
SideUIStroke.Thickness = 1
SideUIStroke.Parent = SideUI

local SideTop = Instance.new("Frame")
SideTop.Size = UDim2.new(1, 0, 0, 40)
SideTop.BackgroundTransparency = 1
SideTop.Parent = SideUI

local SideTopLine = Instance.new("Frame")
SideTopLine.Size = UDim2.new(1, 0, 0, 1)
SideTopLine.Position = UDim2.new(0, 0, 1, -1)
SideTopLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SideTopLine.BorderSizePixel = 0
SideTopLine.Parent = SideTop

local SideTitle = Instance.new("TextLabel")
SideTitle.Size = UDim2.new(0, 110, 1, 0)
SideTitle.BackgroundTransparency = 1
SideTitle.Text = "文件夹"
SideTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SideTitle.Parent = SideTop

local SideMinBtn = Instance.new("TextButton")
SideMinBtn.Size = UDim2.new(0, 40, 1, 0)
SideMinBtn.Position = UDim2.new(0, 110, 0, 0)
SideMinBtn.BackgroundTransparency = 1
SideMinBtn.Text = "<"
SideMinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SideMinBtn.Parent = SideTop

local SideLine = Instance.new("Frame")
SideLine.Size = UDim2.new(0, 1, 1, 0)
SideLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SideLine.BorderSizePixel = 0
SideLine.Parent = SideMinBtn

local SideScroll = Instance.new("ScrollingFrame")
SideScroll.Size = UDim2.new(1, 0, 1, -40)
SideScroll.Position = UDim2.new(0, 0, 0, 40)
SideScroll.BackgroundTransparency = 1
SideScroll.ScrollBarThickness = 2
SideScroll.Active = true
SideScroll.Parent = SideUI
local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 5)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout.Parent = SideScroll

SideMinBtn.MouseButton1Click:Connect(function()
    sideUIOpen = false
    TweenService:Create(SideUI, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 300)}):Play()
    task.wait(0.3)
    SideUI.Visible = false
end)

---------------------------------------------------------
-- 5. 主内容区与模块工厂 (将模块宽度改为 140px)
---------------------------------------------------------
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, 0, 1, -40)
ContentArea.Position = UDim2.new(0, 0, 0, 40)
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants = true
ContentArea.Parent = MainDraggable

local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, 0, 1, 0)
ContentScroll.BackgroundTransparency = 1
ContentScroll.ScrollBarThickness = 2
ContentScroll.Active = true
ContentScroll.Parent = ContentArea
local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 5)
ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ContentLayout.Parent = ContentScroll

local function createModule(moduleType, text)
    local Mod = Instance.new("Frame")
    if moduleType == "Label" then
        Mod.Size = UDim2.new(0, 140, 0, 20) -- 【修改】标签宽度变为 140px
        Mod.BackgroundTransparency = 1
        local Lbl = Instance.new("TextLabel")
        Lbl.Size = UDim2.new(1, 0, 1, 0)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = " " .. text
        Lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.Parent = Mod
        return Mod, Lbl
    else
        Mod.Size = UDim2.new(0, 140, 0, 52) -- 【修改】功能模块宽度变为 140px
        Mod.BackgroundTransparency = 1
        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Color3.fromRGB(255, 255, 255)
        Stroke.Thickness = 1
        Stroke.Parent = Mod
        Instance.new("UICorner", Mod).CornerRadius = UDim.new(0, 5)
        
        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, -10, 0, 20)
        Title.Position = UDim2.new(0, 5, 0, 2)
        Title.BackgroundTransparency = 1
        Title.Text = text
        Title.TextColor3 = Color3.fromRGB(220, 220, 220)
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.TextSize = 12
        Title.Parent = Mod
        
        local Div = Instance.new("Frame")
        Div.Size = UDim2.new(1, 0, 0, 1)
        Div.Position = UDim2.new(0, 0, 0, 24)
        Div.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Div.BorderSizePixel = 0
        Div.Parent = Mod
        
        return Mod, Title
    end
end

createModule("Label", "文件名称").Parent = ContentScroll

local fileClickMod, fileClickTitle = createModule("Click", "未选择")
fileClickMod.Parent = ContentScroll
local OpenSideBtn = Instance.new("TextButton")
OpenSideBtn.Size = UDim2.new(1, 0, 0, 27)
OpenSideBtn.Position = UDim2.new(0, 0, 0, 25)
OpenSideBtn.BackgroundTransparency = 1
OpenSideBtn.Text = "点击选择 ➔"
OpenSideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenSideBtn.Parent = fileClickMod

createModule("Label", "启动设置").Parent = ContentScroll

local dispMod = createModule("Switch", "显示开关")
dispMod.Parent = ContentScroll
local DispToggle = Instance.new("TextButton")
DispToggle.Size = UDim2.new(0, 20, 0, 20)
DispToggle.Position = UDim2.new(0.5, -10, 0, 28)
DispToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
DispToggle.Text = ""
Instance.new("UICorner", DispToggle).CornerRadius = UDim.new(1, 0)
DispToggle.Parent = dispMod

local speedMod = createModule("Slider", "播放速度 (30 FPS)")
speedMod.Parent = ContentScroll
local SpeedSliderBg = Instance.new("Frame")
SpeedSliderBg.Size = UDim2.new(0, 115, 0, 4) -- 稍微调短配合140的宽度
SpeedSliderBg.Position = UDim2.new(0.5, -57.5, 0, 36)
SpeedSliderBg.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
SpeedSliderBg.Parent = speedMod
local SpeedKnob = Instance.new("TextButton")
SpeedKnob.Size = UDim2.new(0, 14, 0, 14)
SpeedKnob.Position = UDim2.new((30-1)/(60-1), -7, 0.5, -7)
SpeedKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SpeedKnob.Text = ""
Instance.new("UICorner", SpeedKnob).CornerRadius = UDim.new(1, 0)
SpeedKnob.Parent = SpeedSliderBg

local dragMod = createModule("Switch", "允许拖动图案")
dragMod.Parent = ContentScroll
local DragToggle = Instance.new("TextButton")
DragToggle.Size = UDim2.new(0, 20, 0, 20)
DragToggle.Position = UDim2.new(0.5, -10, 0, 28)
DragToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
DragToggle.Text = ""
Instance.new("UICorner", DragToggle).CornerRadius = UDim.new(1, 0)
DragToggle.Parent = dragMod

createModule("Label", "图片大小").Parent = ContentScroll

local sizeMod = createModule("Slider", "调整大小 (200px)")
sizeMod.Parent = ContentScroll
local SizeSliderBg = Instance.new("Frame")
SizeSliderBg.Size = UDim2.new(0, 115, 0, 4)
SizeSliderBg.Position = UDim2.new(0.5, -57.5, 0, 36)
SizeSliderBg.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
SizeSliderBg.Parent = sizeMod
local SizeKnob = Instance.new("TextButton")
SizeKnob.Size = UDim2.new(0, 14, 0, 14)
SizeKnob.Position = UDim2.new((200-20)/(800-20), -7, 0.5, -7)
SizeKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SizeKnob.Text = ""
Instance.new("UICorner", SizeKnob).CornerRadius = UDim.new(1, 0)
SizeKnob.Parent = SizeSliderBg

ContentScroll.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)

---------------------------------------------------------
-- 6. 核心逻辑 
---------------------------------------------------------

local function bindClick(btn, action)
    local clickStart
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            clickStart = input.Position
        end
    end)
    btn.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and clickStart then
            local dist = (input.Position - clickStart).Magnitude
            if dist < 5 then action() end 
            clickStart = nil
        end
    end)
end

bindClick(MinBtn, function()
    isMinimized = not isMinimized
    if isMinimized then
        hideConfirmBox()
        CloseBtn.Visible = false
        TitleArea.Visible = false
        TopLine.Visible = false
        ContentArea.Visible = false
        Line1.Visible = false
        if sideUIOpen then SideUI.Visible = false end
        
        MinBtn.Text = "+"
        
        TweenService:Create(MainDraggable, TweenInfo.new(0.3), {Size = UDim2.new(0, 40, 0, 40)}):Play()
        TweenService:Create(MainBgCorner, TweenInfo.new(0.3), {CornerRadius = UDim.new(0, 10)}):Play()
    else
        MinBtn.Text = "-"
        
        TweenService:Create(MainDraggable, TweenInfo.new(0.3), {Size = UDim2.new(0, 150, 0, 300)}):Play()
        TweenService:Create(MainBgCorner, TweenInfo.new(0.3), {CornerRadius = UDim.new(0, 5)}):Play()
        
        CloseBtn.Visible = true
        TitleArea.Visible = true
        TopLine.Visible = true
        ContentArea.Visible = true
        Line1.Visible = true
        if sideUIOpen then SideUI.Visible = true end
    end
end)

bindClick(CloseBtn, function()
    showConfirmBox()
end)

local draggingWindow = false
local dragStartPos, startWindowPos

MainDraggable.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingWindow = true
        dragStartPos = input.Position
        startWindowPos = MainDraggable.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingWindow and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartPos
        MainDraggable.Position = UDim2.new(
            startWindowPos.X.Scale, startWindowPos.X.Offset + delta.X,
            startWindowPos.Y.Scale, startWindowPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingWindow = false
    end
end)

local function stopPlayback()
    isPlaying = false
    if playTask then 
        task.cancel(playTask)
        playTask = nil 
    end
    for _, child in ipairs(ImageContainer:GetChildren()) do 
        child:Destroy() 
    end
end

local function startFolderPlayback(folderPath)
    stopPlayback()
    isPlaying = true
    currentImageMode = "folder"
    
    local files = {}
    if listfiles then pcall(function() files = listfiles(folderPath) end) end
    table.sort(files) 
    
    local validImages = {}
    for _, f in ipairs(files) do
        if f:match("%.png$") or f:match("%.jpg$") or f:match("%.jpeg$") then
            table.insert(validImages, f)
        end
    end
    
    if #validImages == 0 then fileClickTitle.Text = "文件夹为空" return end
    
    local framePool = {}
    for _, imgPath in ipairs(validImages) do
        local img = Instance.new("ImageLabel")
        img.Size = UDim2.new(1, 0, 1, 0)
        img.BackgroundTransparency = 1
        if getcustomasset then img.Image = getcustomasset(imgPath) end
        img.Visible = false
        img.Parent = ImageContainer
        table.insert(framePool, img)
    end
    
    playTask = task.spawn(function()
        local idx = 1
        local lastIdx = 1
        if #framePool > 0 then framePool[1].Visible = true end
        
        while isPlaying do
            task.wait(1 / playSpeed)
            if ImageContainer.Visible and #framePool > 0 then
                framePool[lastIdx].Visible = false
                idx = idx + 1
                if idx > #framePool then idx = 1 end
                framePool[idx].Visible = true
                lastIdx = idx
            end
        end
    end)
end

OpenSideBtn.MouseButton1Click:Connect(function()
    if sideUIOpen then return end
    sideUIOpen = true
    SideUI.Visible = true
    SideUI.Size = UDim2.new(0, 0, 0, 300)
    TweenService:Create(SideUI, TweenInfo.new(0.3), {Size = UDim2.new(0, 150, 0, 300)}):Play()
    
    for _, child in ipairs(SideScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    local items = {}
    if listfiles then pcall(function() items = listfiles(FOLDER_NAME) end) end
    table.sort(items) 
    
    for _, path in ipairs(items) do
        local itemName = path:match("([^/\\]+)$") or path
        local isDir = false
        if isfolder then pcall(function() isDir = isfolder(path) end) end
        
        local FileMod = Instance.new("Frame")
        FileMod.Size = UDim2.new(0, 140, 0, 60)
        FileMod.BackgroundTransparency = 1
        Instance.new("UICorner", FileMod).CornerRadius = UDim.new(0, 5)
        local FS = Instance.new("UIStroke")
        FS.Color = Color3.fromRGB(255, 255, 255)
        FS.Parent = FileMod
        
        local FBtn = Instance.new("TextButton")
        FBtn.Size = UDim2.new(1, 0, 1, 0)
        FBtn.BackgroundTransparency = 1
        FBtn.Text = (isDir and "文件夹:\n" or "图片:\n") .. itemName
        FBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        FBtn.TextSize = 12
        FBtn.Parent = FileMod
        
        FBtn.MouseButton1Click:Connect(function()
            if isDir then
                fileClickTitle.Text = "文件夹: " .. itemName
                startFolderPlayback(path)
            else
                fileClickTitle.Text = "图片: " .. itemName
                stopPlayback()
                currentImageMode = "single"
                
                local img = Instance.new("ImageLabel")
                img.Size = UDim2.new(1, 0, 1, 0)
                img.BackgroundTransparency = 1
                if getcustomasset then img.Image = getcustomasset(path) end
                img.Parent = ImageContainer
                img.Visible = true
            end
        end)
        FileMod.Parent = SideScroll
    end
    SideScroll.CanvasSize = UDim2.new(0, 0, 0, SideLayout.AbsoluteContentSize.Y + 10)
end)

DispToggle.MouseButton1Click:Connect(function()
    ImageContainer.Visible = not ImageContainer.Visible
    DispToggle.BackgroundColor3 = ImageContainer.Visible and Color3.fromRGB(171, 218, 171) or Color3.fromRGB(80, 80, 80)
end)

DragToggle.MouseButton1Click:Connect(function()
    canDragImg = not canDragImg
    ImageContainer.Active = canDragImg
    ImageContainer.Draggable = canDragImg
    DragToggle.BackgroundColor3 = canDragImg and Color3.fromRGB(171, 218, 171) or Color3.fromRGB(80, 80, 80)
end)

local function makeSlider(bg, knob, min, max, callback)
    local dragging = false
    
    knob.MouseButton1Down:Connect(function() dragging = true end)
    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                dragging = false
                return
            end
            
            local mousePos = UserInputService:GetMouseLocation().X
            local relX = math.clamp((mousePos - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            knob.Position = UDim2.new(relX, -7, 0.5, -7)
            local val = math.floor(min + (max - min) * relX)
            callback(val)
        end
    end)
end

makeSlider(SpeedSliderBg, SpeedKnob, 1, 60, function(val)
    playSpeed = val
    speedMod:FindFirstChild("TextLabel").Text = "播放速度 (" .. val .. " FPS)"
end)

makeSlider(SizeSliderBg, SizeKnob, 20, 800, function(val)
    imageSize = val
    sizeMod:FindFirstChild("TextLabel").Text = "调整大小 (" .. val .. "px)"
    ImageContainer.Size = UDim2.new(0, val, 0, val)
end)

print("HAOXIAO 播放器 - 140px模块 & 全局白边描边版 加载完毕！")

