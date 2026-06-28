-- Ken HUB Part 2/5 - UI Shell
-- Ken HUB Part 2/5 - UI Shell
local SCRIPT_VERSION = "1.82"
local K = _G.KenHubState
if not K or not K.CONFIG then
    error("[Ken HUB] Part 1 yuklenmedi - Loader.lua kullan")
end
local CONFIG = K.CONFIG
local player = K.player
local username = K.username
local RunService = K.RunService
local TweenService = K.TweenService
local ProximityPromptService = K.ProximityPromptService
local ReplicatedStorage = K.ReplicatedStorage
local HttpService = K.HttpService
local TeleportService = K.TeleportService
local createProtectedScreenGui = K.createProtectedScreenGui
local protectGuiElement = K.protectGuiElement
local namePrefix = K.namePrefix
local findPlayerPlot = K.findPlayerPlot
local setInvisibility = K.setInvisibility
local enablePetSnipe = K.enablePetSnipe
local disablePetSnipe = K.disablePetSnipe
local playerPlot = K.playerPlot
local character = K.character
local humanoid = K.humanoid
local humanoidRootPart = K.humanoidRootPart
local UserInputService = game:GetService("UserInputService")
local screenGui = createProtectedScreenGui((namePrefix or '') .. 'ESPVisuals')
screenGui.Enabled = true
pcall(function()
    _G.KenHubStatus("GUI olusturuldu -> " .. tostring(screenGui.Parent and screenGui.Parent.Name or "?"))
end)

local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
if _G.isMobile or _G.isDelta then
    mainFrame.Size = UDim2.new(0.94, 0, 0.78, 0)
    mainFrame.Position = UDim2.new(0.03, 0, 0.08, 0)
    mainFrame.AnchorPoint = Vector2.new(0, 0)
    mainFrame.Draggable = false
else
    mainFrame.Size = CONFIG.UI.FrameSize
    mainFrame.Position = UDim2.new(0.5, -290, 0.5, -190)
    mainFrame.Draggable = true
end
mainFrame.BackgroundColor3 = CONFIG.Colors.Panel
mainFrame.Active = true
mainFrame.Visible = true
_G.KenHubMainFrame = mainFrame
mainFrame.Parent = screenGui
protectGuiElement(mainFrame)
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Thickness = 1
mainStroke.Color = CONFIG.Colors.Stroke
mainStroke.Transparency = 0.4

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Parent = mainFrame
topBar.BackgroundColor3 = CONFIG.Colors.Background
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BorderSizePixel = 0
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)

local logo = Instance.new("ImageLabel")
logo.Name = "Logo"
logo.Parent = topBar
logo.BackgroundTransparency = 1
logo.Size = UDim2.new(0, 32, 0, 32)
logo.Position = UDim2.new(0, 8, 0.5, -16)
logo.Image = "rbxassetid://752641844224"
Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 8)

local titleHolder = Instance.new("Frame")
titleHolder.Parent = topBar
titleHolder.BackgroundTransparency = 1
titleHolder.Position = UDim2.new(0, 48, 0, 0)
titleHolder.Size = UDim2.new(1, -160, 1, 0)

local title = Instance.new("TextLabel")
title.Parent = titleHolder
title.BackgroundTransparency = 1
title.Text = "Ken HUB"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = CONFIG.Colors.Text
title.TextXAlignment = Enum.TextXAlignment.Left
title.Size = UDim2.new(1, 0, 1, 0)

local settingsBtn = Instance.new("TextButton")
settingsBtn.Parent = topBar
settingsBtn.BackgroundColor3 = CONFIG.Colors.Background
settingsBtn.Text = "⚙"
settingsBtn.Font = Enum.Font.GothamBold
settingsBtn.TextSize = 20
settingsBtn.TextColor3 = CONFIG.Colors.Text
settingsBtn.AutoButtonColor = false
settingsBtn.Size = UDim2.new(0, 32, 0, 32)
settingsBtn.Position = UDim2.new(1, -112, 0.5, -16)
Instance.new("UICorner", settingsBtn).CornerRadius = UDim.new(0, 8)

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Parent = topBar
minimizeBtn.BackgroundColor3 = CONFIG.Colors.Background
minimizeBtn.Text = "−"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 20
minimizeBtn.TextColor3 = CONFIG.Colors.Text
minimizeBtn.AutoButtonColor = false
minimizeBtn.Size = UDim2.new(0, 32, 0, 32)
minimizeBtn.Position = UDim2.new(1, -74, 0.5, -16)
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = topBar
closeBtn.BackgroundColor3 = CONFIG.Colors.Background
closeBtn.Text = "×"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.TextColor3 = CONFIG.Colors.Text
closeBtn.AutoButtonColor = false
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -36, 0.5, -16)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- Close button functionality (moved to comprehensive cleanup below)

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Parent = mainFrame
sidebar.BackgroundColor3 = CONFIG.Colors.Sidebar
sidebar.Size = UDim2.new(0, CONFIG.UI.SidebarWidth, 1, -40)
sidebar.Position = UDim2.new(0, 0, 0, 40)
sidebar.BorderSizePixel = 0
Instance.new("UIStroke", sidebar).Color = CONFIG.Colors.Stroke

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Parent = sidebar
sidebarLayout.Padding = UDim.new(0, 6)
sidebarLayout.FillDirection = Enum.FillDirection.Vertical
sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sidebarLayout.VerticalAlignment = Enum.VerticalAlignment.Top

-- Content Area
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Parent = mainFrame
contentArea.BackgroundTransparency = 1
contentArea.Position = UDim2.new(0, CONFIG.UI.SidebarWidth, 0, 40)
contentArea.Size = UDim2.new(1, -CONFIG.UI.SidebarWidth, 1, -40)

local contentLayout = Instance.new("UIListLayout")
contentLayout.Parent = contentArea
contentLayout.Padding = UDim.new(0, 10)
contentLayout.FillDirection = Enum.FillDirection.Vertical
contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder


-- Settings UI
local settingsFrame = Instance.new("Frame")
settingsFrame.Name = "SettingsFrame"
settingsFrame.Size = CONFIG.UI.SettingsFrameSize
settingsFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
settingsFrame.BackgroundColor3 = CONFIG.Colors.Panel
settingsFrame.Visible = false
settingsFrame.Active = true
settingsFrame.Draggable = true
settingsFrame.Parent = screenGui
Instance.new("UICorner", settingsFrame).CornerRadius = CONFIG.UI.CornerRadius
local settingsStroke = Instance.new("UIStroke", settingsFrame)
settingsStroke.Thickness = 1
settingsStroke.Color = CONFIG.Colors.Stroke
settingsStroke.Transparency = 0.4

local settingsTopBar = Instance.new("Frame")
settingsTopBar.Name = "SettingsTopBar"
settingsTopBar.Parent = settingsFrame
settingsTopBar.BackgroundColor3 = CONFIG.Colors.Background
settingsTopBar.Size = UDim2.new(1, 0, 0, 40)
settingsTopBar.BorderSizePixel = 0
Instance.new("UICorner", settingsTopBar).CornerRadius = UDim.new(0, 10)

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Parent = settingsTopBar
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "Settings"
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextSize = 18
settingsTitle.TextColor3 = CONFIG.Colors.Text
settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
settingsTitle.Position = UDim2.new(0, 10, 0, 0)
settingsTitle.Size = UDim2.new(1, -40, 1, 0)

local settingsCloseBtn = Instance.new("TextButton")
settingsCloseBtn.Parent = settingsTopBar
settingsCloseBtn.BackgroundColor3 = CONFIG.Colors.Background
settingsCloseBtn.Text = "×"
settingsCloseBtn.Font = Enum.Font.GothamBold
settingsCloseBtn.TextSize = 20
settingsCloseBtn.TextColor3 = CONFIG.Colors.Text
settingsCloseBtn.AutoButtonColor = false
settingsCloseBtn.Size = UDim2.new(0, 32, 0, 32)
settingsCloseBtn.Position = UDim2.new(1, -36, 0.5, -16)
Instance.new("UICorner", settingsCloseBtn).CornerRadius = UDim.new(0, 8)

local settingsContent = Instance.new("ScrollingFrame")
settingsContent.Name = "SettingsContent"
settingsContent.Parent = settingsFrame
settingsContent.BackgroundTransparency = 1
settingsContent.Position = UDim2.new(0, 10, 0, 40)
settingsContent.Size = UDim2.new(1, -20, 1, -40)
settingsContent.CanvasSize = UDim2.new(0, 0, 0, 0)
settingsContent.ScrollBarThickness = 3
settingsContent.ScrollBarImageColor3 = CONFIG.Colors.Stroke
settingsContent.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar

local settingsLayout = Instance.new("UIListLayout")
settingsLayout.Parent = settingsContent
settingsLayout.Padding = UDim.new(0, 8)
settingsLayout.FillDirection = Enum.FillDirection.Vertical
settingsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
settingsLayout.SortOrder = Enum.SortOrder.LayoutOrder

settingsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    pcall(function()
        settingsContent.CanvasSize = UDim2.new(0, 0, 0, settingsLayout.AbsoluteContentSize.Y + 10)
    end)
end)

-- Section Frames
local sections = {}
local function createSection(name)
    local sectionFrame = Instance.new("ScrollingFrame")
    sectionFrame.Name = name
    sectionFrame.BackgroundTransparency = 1
    sectionFrame.Size = UDim2.new(1, -20, 1, 0)
    sectionFrame.Position = UDim2.new(0, 10, 0, 0)
    sectionFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    sectionFrame.ScrollBarThickness = 3
    sectionFrame.ScrollBarImageColor3 = CONFIG.Colors.Stroke
    sectionFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
    sectionFrame.Visible = false
    sectionFrame.Parent = contentArea

    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = sectionFrame
    listLayout.Padding = UDim.new(0, 8)
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        pcall(function()
            sectionFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
        end)
    end)

    sections[name] = sectionFrame
    return sectionFrame
end

-- Tab Button Creator
local activeSection = nil
local function createTabButton(name, sectionName, iconId)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -12, 0, 36)
    button.BackgroundColor3 = CONFIG.Colors.Sidebar
    button.Text = ""
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 14
    button.TextColor3 = CONFIG.Colors.Text
    button.AutoButtonColor = false
    button.Parent = sidebar
    button.Name = sectionName .. "Button"
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 8, 0.5, -10)
    icon.BackgroundTransparency = 1
    icon.Image = iconId or "rbxassetid://603504740"
    icon.Parent = button

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -36, 1, 0)
    label.Position = UDim2.new(0, 32, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextColor3 = CONFIG.Colors.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button

    button.MouseEnter:Connect(function()
        if activeSection ~= sectionName then
            TweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = CONFIG.Colors.Hover }):Play()
        end
    end)
    button.MouseLeave:Connect(function()
        if activeSection ~= sectionName then
            TweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = CONFIG.Colors.Sidebar }):Play()
        end
    end)
    button.MouseButton1Click:Connect(function()
        if activeSection then
            sections[activeSection].Visible = false
            local prevButton = sidebar:FindFirstChild(activeSection .. "Button")
            if prevButton then
                TweenService:Create(prevButton, TweenInfo.new(0.15), { BackgroundColor3 = CONFIG.Colors.Sidebar }):Play()
            end
        end
        sections[sectionName].Visible = true
        TweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = CONFIG.Colors.Accent }):Play()
        activeSection = sectionName
    end)
    return button
end

-- Section Header Creator
local function createSectionHeader(parent, titleText)
    local success, _ = pcall(function()
        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, 0, 0, 28)
        header.BackgroundColor3 = CONFIG.Colors.SectionHeader
        header.Parent = parent
        Instance.new("UICorner", header).CornerRadius = UDim.new(0, 6)
        local stroke = Instance.new("UIStroke", header)
        stroke.Thickness = 0.8
        stroke.Color = CONFIG.Colors.Stroke
        stroke.Transparency = 0.6

        local label = Instance.new("TextLabel")
        label.Parent = header
        label.BackgroundTransparency = 1
        label.Text = titleText
        label.Font = Enum.Font.GothamBold
        label.TextSize = 15
        label.TextColor3 = CONFIG.Colors.Text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Position = UDim2.new(0, 10, 0, 0)
        label.Size = UDim2.new(1, -20, 1, 0)
    end)
    if not success then
        warn("Failed to create section header: " .. titleText)
    end
end

-- Switch Creator
local function createSwitch(parent, labelText, defaultState, callback)
    local switchData = {state = defaultState}
    local success, _ = pcall(function()
        -- Create main row frame
        switchData.row = Instance.new("Frame")
        switchData.row.BackgroundColor3 = CONFIG.Colors.Background
        switchData.row.Size = UDim2.new(1, 0, 0, 40)
        switchData.row.Parent = parent
        Instance.new("UICorner", switchData.row).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", switchData.row)
        stroke.Thickness = 0.8
        stroke.Color = CONFIG.Colors.Stroke
        stroke.Transparency = 0.4

        -- Create label
        local label = Instance.new("TextLabel")
        label.Parent = switchData.row
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 14
        label.TextColor3 = CONFIG.Colors.Text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Position = UDim2.new(0, 10, 0, 0)
        label.Size = UDim2.new(1, -80, 1, 0)

        -- Create switch frame
        switchData.switch = Instance.new("Frame")
        switchData.switch.Parent = switchData.row
        switchData.switch.AnchorPoint = Vector2.new(1, 0.5)
        switchData.switch.Position = UDim2.new(1, -10, 0.5, 0)
        switchData.switch.Size = UDim2.new(0, 48, 0, 22)
        switchData.switch.BackgroundColor3 = defaultState and CONFIG.Colors.SwitchOn or CONFIG.Colors.SwitchOff
        Instance.new("UICorner", switchData.switch).CornerRadius = UDim.new(0, 11)

        -- Create knob
        switchData.knob = Instance.new("Frame")
        switchData.knob.Parent = switchData.switch
        switchData.knob.Size = UDim2.new(0, 18, 0, 18)
        switchData.knob.Position = defaultState and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2)
        switchData.knob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
        Instance.new("UICorner", switchData.knob).CornerRadius = UDim.new(0, 9)

        -- Create hit button
        switchData.hit = Instance.new("TextButton")
        switchData.hit.Parent = switchData.switch
        switchData.hit.BackgroundTransparency = 1
        switchData.hit.Text = ""
        switchData.hit.Size = UDim2.new(1, 0, 1, 0)
        switchData.hit.AutoButtonColor = false
    end)
    if not success then
        warn("Failed to create switch: " .. labelText)
        return { row = nil, set = function() end, get = function() return false end }
    end

    -- Optimized setState function
    switchData.setState = function(newState)
        local success, _ = pcall(function()
            switchData.state = newState
            TweenService:Create(switchData.switch, TweenInfo.new(CONFIG.UI.AnimationSpeed, Enum.EasingStyle.Quad), {
                BackgroundColor3 = newState and CONFIG.Colors.SwitchOn or CONFIG.Colors.SwitchOff
            }):Play()
            TweenService:Create(switchData.knob, TweenInfo.new(CONFIG.UI.AnimationSpeed, Enum.EasingStyle.Quad), {
                Position = newState and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2)
            }):Play()
            if callback then task.spawn(callback, newState) end
        end)
        if not success then
            warn("Failed to set state for switch: " .. labelText)
        end
    end

    -- Optimized toggle function
    switchData.toggle = function()
        switchData.setState(not switchData.state)
    end
    
    -- Connect events
    switchData.hit.MouseButton1Click:Connect(switchData.toggle)
    switchData.hit.TouchTap:Connect(switchData.toggle)
    switchData.hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            switchData.toggle()
        end
    end)

    return { 
        row = switchData.row, 
        set = switchData.setState, 
        get = function() return switchData.state end 
    }
end

-- Number Input Creator
local function createNumberInput(parent, labelText, defaultValue, callback)
    local row, textBox
    local success, _ = pcall(function()
        row = Instance.new("Frame")
        row.BackgroundColor3 = CONFIG.Colors.Background
        row.Size = UDim2.new(1, 0, 0, 40)
        row.Parent = parent
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", row)
        stroke.Thickness = 0.8
        stroke.Color = CONFIG.Colors.Stroke
        stroke.Transparency = 0.4

        local label = Instance.new("TextLabel")
        label.Parent = row
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 14
        label.TextColor3 = CONFIG.Colors.Text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Position = UDim2.new(0, 10, 0, 0)
        label.Size = UDim2.new(1, -80, 1, 0)

        textBox = Instance.new("TextBox")
        textBox.Parent = row
        textBox.BackgroundColor3 = CONFIG.Colors.Background
        textBox.Size = UDim2.new(0, 60, 0, 24)
        textBox.Position = UDim2.new(1, -70, 0.5, -12)
        textBox.Text = tostring(defaultValue)
        textBox.Font = Enum.Font.Gotham
        textBox.TextSize = 14
        textBox.TextColor3 = CONFIG.Colors.Text
        textBox.TextXAlignment = Enum.TextXAlignment.Right
        Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 6)
        local textBoxStroke = Instance.new("UIStroke", textBox)
        textBoxStroke.Thickness = 0.8
        textBoxStroke.Color = CONFIG.Colors.Stroke
    end)
    if not success then
        warn("Failed to create number input: " .. labelText)
        return { row = nil, set = function() end, get = function() return defaultValue end }
    end

    textBox.FocusLost:Connect(function(enterPressed)
        local success, value = pcall(function()
            local num = tonumber(textBox.Text)
            if num then
                textBox.Text = tostring(num)
                if callback then callback(num) end
            else
                textBox.Text = tostring(defaultValue)
            end
        end)
        if not success then
            warn("Invalid input for: " .. labelText)
            textBox.Text = tostring(defaultValue)
        end
    end)

    return { row = row, set = function(value) textBox.Text = tostring(value) end, get = function() return tonumber(textBox.Text) or defaultValue end }
end

--=========================================================
-- Enhanced ESP System (Player ESP)
--=========================================================
_G.ESP_Enabled = false
_G.ESP_Data = {}

local function getBackpackItems(plr)
    local success, items = pcall(function()
        local result = {}
        if plr.Backpack then
            for _, item in ipairs(plr.Backpack:GetChildren()) do
                if item:IsA("Tool") or item:IsA("HopperBin") then
                    table.insert(result, item)
                end
            end
        end
        if plr.Character then
            for _, item in ipairs(plr.Character:GetChildren()) do
                if item:IsA("Tool") or item:IsA("HopperBin") then
                    table.insert(result, item)
                end
            end
        end
        local inventoryFolder = plr:FindFirstChild("Inventory") or (plr.Character and plr.Character:FindFirstChild("Inventory"))
        if inventoryFolder then
            for _, item in ipairs(inventoryFolder:GetChildren()) do
                if item:IsA("Instance") then
                    table.insert(result, item)
                end
            end
        end
        return result
    end)
    if not success then
        warn("Failed to get backpack items for player: " .. plr.Name)
        return {}
    end
    return items
end

local function createBillboardGui(plr, char)
    local success, billboard, distanceLabel, iconFrame = pcall(function()
        local gui = Instance.new("BillboardGui")
        gui.Name = "ESP_Billboard"
        gui.Adornee = char:FindFirstChild("HumanoidRootPart")
        gui.Size = UDim2.new(0, 200, 0, CONFIG.ESP.PlayerESP.ShowDistance and CONFIG.ESP.PlayerESP.ShowItems and 80 or (CONFIG.ESP.PlayerESP.ShowDistance and 50 or 30))
        gui.SizeOffset = Vector2.new(0, 0)
        gui.StudsOffset = Vector3.new(0, 3, 0)
        gui.AlwaysOnTop = true
        gui.MaxDistance = 10000
        gui.Parent = char

        -- Main container with rounded corners and background
        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(1, 0, 1, 0)
        mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        mainFrame.BackgroundTransparency = 0.1
        mainFrame.BorderSizePixel = 0
        mainFrame.Parent = gui
        
        -- Rounded corners
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = mainFrame
        
        -- Subtle border
        local border = Instance.new("UIStroke")
        border.Color = Color3.fromRGB(100, 100, 100)
        border.Thickness = 1
        border.Transparency = 0.3
        border.Parent = mainFrame

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -8, 1, -8)
        frame.Position = UDim2.new(0, 4, 0, 4)
        frame.BackgroundTransparency = 1
        frame.Parent = mainFrame

        -- Username with better styling
        local usernameLabel = Instance.new("TextLabel")
        usernameLabel.Size = UDim2.new(1, 0, CONFIG.ESP.PlayerESP.ShowDistance and 0.4 or 1, 0)
        usernameLabel.Position = UDim2.new(0, 0, 0, 0)
        usernameLabel.Text = plr.Name
        usernameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        usernameLabel.BackgroundTransparency = 1
        usernameLabel.TextScaled = true
        usernameLabel.TextSize = CONFIG.ESP.PlayerESP.TextSize
        usernameLabel.Font = Enum.Font.GothamBold
        usernameLabel.TextStrokeTransparency = 0.8
        usernameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        usernameLabel.Parent = frame

        local distLabel
        if CONFIG.ESP.PlayerESP.ShowDistance then
            distLabel = Instance.new("TextLabel")
            distLabel.Size = UDim2.new(1, 0, 0.3, 0)
            distLabel.Position = UDim2.new(0, 0, 0.4, 0)
            distLabel.Text = "Distance: Calculating..."
            distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            distLabel.BackgroundTransparency = 1
            distLabel.TextScaled = true
            distLabel.TextSize = CONFIG.ESP.PlayerESP.DistanceTextSize
            distLabel.Font = Enum.Font.Gotham
            distLabel.TextStrokeTransparency = 0.8
            distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            distLabel.Parent = frame
        end

        local iconFrame = Instance.new("Frame")
        iconFrame.Size = UDim2.new(1, 0, 0.3, 0)
        iconFrame.Position = UDim2.new(0, 0, CONFIG.ESP.PlayerESP.ShowDistance and 0.7 or 0.4, 0)
        iconFrame.BackgroundTransparency = 1
        iconFrame.Visible = CONFIG.ESP.PlayerESP.ShowItems
        iconFrame.Parent = frame

        local uiLayout = Instance.new("UIGridLayout")
        uiLayout.CellSize = UDim2.new(0, 24, 0, 24)
        uiLayout.CellPadding = UDim2.new(0, 3, 0, 3)
        uiLayout.FillDirection = Enum.FillDirection.Horizontal
        uiLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        uiLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        uiLayout.SortOrder = Enum.SortOrder.LayoutOrder
        uiLayout.Parent = iconFrame

        return gui, distLabel, iconFrame
    end)
    if not success then
        warn("Failed to create billboard GUI for player: " .. plr.Name)
        return nil, nil, nil
    end
    return billboard, distanceLabel, iconFrame
end

local function updateBillboard(plr, data)
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") or not data.billboard or not data.billboard.Adornee then
        return
    end
    local success, _ = pcall(function()
        local localPlayer = Players.LocalPlayer
        if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        local localRoot = localPlayer.Character.HumanoidRootPart
        local targetRoot = data.billboard.Adornee
        if CONFIG.ESP.PlayerESP.ShowDistance and data.distanceLabel then
            local distance = (localRoot.Position - targetRoot.Position).Magnitude
            data.distanceLabel.Text = string.format("📏 %.1f studs", distance)
        end

        if CONFIG.ESP.PlayerESP.ShowItems and data.iconFrame then
            data.iconFrame:ClearAllChildren()
            local uiLayout = Instance.new("UIGridLayout")
            uiLayout.CellSize = UDim2.new(0, 24, 0, 24)
            uiLayout.CellPadding = UDim2.new(0, 3, 0, 3)
            uiLayout.FillDirection = Enum.FillDirection.Horizontal
            uiLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            uiLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            uiLayout.SortOrder = Enum.SortOrder.LayoutOrder
            uiLayout.Parent = data.iconFrame

            local items = getBackpackItems(plr)
            for _, tool in ipairs(items) do
                local icon = Instance.new("ImageLabel")
                icon.Size = UDim2.new(0, 24, 0, 24)
                icon.BackgroundTransparency = 1
                icon.BorderSizePixel = 0
                local textureId = tool.TextureId
                if textureId == "" then
                    local handle = tool:FindFirstChild("Handle")
                    if handle then
                        local decal = handle:FindFirstChildOfClass("Decal")
                        local mesh = handle:FindFirstChildOfClass("MeshPart") or handle:FindFirstChildOfClass("SpecialMesh")
                        textureId = (decal and decal.Texture) or (mesh and mesh.TextureId) or "rbxasset://textures/ui/GuiImagePlaceholder.png"
                    else
                        textureId = "rbxasset://textures/ui/GuiImagePlaceholder.png"
                    end
                end
                icon.Image = textureId
                icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
                icon.Parent = data.iconFrame
                
                -- Rounded corners for icons
                local iconCorner = Instance.new("UICorner")
                iconCorner.CornerRadius = UDim.new(0, 4)
                iconCorner.Parent = icon
                
                local iconStroke = Instance.new("UIStroke", icon)
                iconStroke.Thickness = 0.5
                iconStroke.Color = Color3.fromRGB(0, 0, 0)
                iconStroke.Transparency = 0.3

                local tooltip = Instance.new("TextLabel")
                tooltip.Size = UDim2.new(0, 100, 0, 20)
                tooltip.Position = UDim2.new(0, 0, 1, 2)
                tooltip.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                tooltip.BackgroundTransparency = 0.4
                tooltip.Text = tool.Name
                tooltip.TextColor3 = CONFIG.Colors.Text
                tooltip.TextScaled = true
                tooltip.TextSize = 12
                tooltip.Font = Enum.Font.SourceSans
                tooltip.Visible = false
                tooltip.Parent = icon
                local tooltipStroke = Instance.new("UIStroke", tooltip)
                tooltipStroke.Thickness = 0.8
                tooltipStroke.Color = CONFIG.Colors.Stroke
                icon.MouseEnter:Connect(function()
                    tooltip.Visible = true
                end)
                icon.MouseLeave:Connect(function()
                    tooltip.Visible = false
                end)
            end
        end
    end)
    if not success then
        warn("Failed to update billboard for player: " .. plr.Name)
    end
end

local function attachHighlightToCharacter(plr, char)
     if not _G.ESP_Enabled or not char then return end
    local success, _ = pcall(function()
        local oldHighlight = char:FindFirstChildOfClass("Highlight")
        if oldHighlight then oldHighlight:Destroy() end
        local oldBillboard = char:FindFirstChild("ESP_Billboard")
        if oldBillboard then oldBillboard:Destroy() end

        local highlight = Instance.new("Highlight")
        highlight.FillTransparency = CONFIG.ESP.PlayerESP.FillTransparency
        highlight.OutlineTransparency = CONFIG.ESP.PlayerESP.OutlineTransparency
        highlight.FillColor = CONFIG.ESP.PlayerESP.HighlightColor
        highlight.OutlineColor = CONFIG.ESP.PlayerESP.HighlightColor
        highlight.Adornee = char
        highlight.Parent = char

        local billboard, distanceLabel, iconFrame = createBillboardGui(plr, char)
        if not billboard then return end

         _G.ESP_Data[plr] = _G.ESP_Data[plr] or {}
         _G.ESP_Data[plr].highlight = highlight
         _G.ESP_Data[plr].billboard = billboard
         _G.ESP_Data[plr].distanceLabel = distanceLabel
         _G.ESP_Data[plr].iconFrame = iconFrame

        local lastUpdate = 0
        _G.ESP_Data[plr].updateConn = RunService.Heartbeat:Connect(function(deltaTime)
            lastUpdate = lastUpdate + deltaTime
            if lastUpdate >= CONFIG.ESP.UpdateInterval then
                updateBillboard(plr, _G.ESP_Data[plr])
                lastUpdate = 0
            end
        end)
    end)
    if not success then
        warn("Failed to attach ESP to character: " .. plr.Name)
    end
end

local function enableESP()
     if _G.ESP_Enabled then return end
    local success, _ = pcall(function()
         _G.ESP_Enabled = true
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                local charConn = plr.CharacterAdded:Connect(function(c)
                    c:WaitForChild("HumanoidRootPart", 5)
                    attachHighlightToCharacter(plr, c)
                end)
_G.ESP_Data[plr] = _G.ESP_Data[plr] or {}
_G.ESP_Data[plr].charConn = charConn
                if plr.Character then
                    for _, part in ipairs(plr.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.Transparency >= 1 then
                            part.LocalTransparencyModifier = 0.5
                        end
                    end
                    attachHighlightToCharacter(plr, plr.Character)
                end
            end
        end
        _G.ESP_Data.playersConn = Players.PlayerAdded:Connect(function(plr)
            if plr == player then return end
            local charConn = plr.CharacterAdded:Connect(function(c)
                c:WaitForChild("HumanoidRootPart", 5)
                attachHighlightToCharacter(plr, c)
            end)
            -- Refresh plot time ESP when players join
            pcall(function()
                if refreshPlotTimeESP then
            refreshPlotTimeESP()
                end
            end)
_G.ESP_Data[plr] = _G.ESP_Data[plr] or {}
_G.ESP_Data[plr].charConn = charConn
            if plr.Character then
                for _, part in ipairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Transparency >= 1 then
                        part.LocalTransparencyModifier = 0.5
                    end
                end
                attachHighlightToCharacter(plr, plr.Character)
            end
        end)
        _G.ESP_Data.leaveConn = Players.PlayerRemoving:Connect(function(plr)
            if _G.ESP_Data[plr] then
                if _G.ESP_Data[plr].charConn then pcall(function() _G.ESP_Data[plr].charConn:Disconnect() end) end
                if _G.ESP_Data[plr].highlight then pcall(function() _G.ESP_Data[plr].highlight:Destroy() end) end
                if _G.ESP_Data[plr].billboard then pcall(function() _G.ESP_Data[plr].billboard:Destroy() end) end
                if _G.ESP_Data[plr].updateConn then pcall(function() _G.ESP_Data[plr].updateConn:Disconnect() end) end
                if plr.Character then
                    for _, part in ipairs(plr.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.LocalTransparencyModifier = 0
                        end
                    end
                end
                _G.ESP_Data[plr] = nil
            end
            -- Refresh plot time ESP when players leave
            refreshPlotTimeESP()
        end)
    end)
    if not success then
        warn("Failed to enable ESP")
        _G.ESP_Enabled = false
    end
end

local function disableESP()
    if not _G.ESP_Enabled then return end
    local success, _ = pcall(function()
        _G.ESP_Enabled = false
        if _G.ESP_Data.playersConn then
            pcall(function() _G.ESP_Data.playersConn:Disconnect() end)
            _G.ESP_Data.playersConn = nil
        end
        if _G.ESP_Data.leaveConn then
            pcall(function() _G.ESP_Data.leaveConn:Disconnect() end)
            _G.ESP_Data.leaveConn = nil
        end
        for plr, data in pairs(_G.ESP_Data or {}) do
            if typeof(plr) == "Instance" then
                if data.charConn then pcall(function() data.charConn:Disconnect() end) end
                if data.highlight then pcall(function() data.highlight:Destroy() end) end
                if data.billboard then pcall(function() data.billboard:Destroy() end) end
                if data.updateConn then pcall(function() data.updateConn:Disconnect() end) end
                if plr.Character then
                    for _, part in ipairs(plr.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.LocalTransparencyModifier = 0
                        end
                    end
                end
                _G.ESP_Data[plr] = nil
            end
        end
    end)
    if not success then
        warn("Failed to disable ESP")
    end
end

--=========================================================
-- Plot ESP System
--=========================================================
_G.PlotESP_Enabled = false
_G.PlotESP_Data = {}

local function createPlotBillboardGui(plot)
    local success, billboard, distanceLabel, ownerLabel, timeLabel = pcall(function()
        local spawnPart = plot:FindFirstChild("Spawn")
        if not spawnPart or not spawnPart:IsA("BasePart") then return nil, nil, nil, nil end

        local height = 30
        if CONFIG.ESP.PlotESP.ShowDistance then height = height + 20 end
        if CONFIG.ESP.PlotESP.ShowOwner then height = height + 30 end
        if CONFIG.ESP.PlotESP.ShowTime then height = height + 20 end

        local gui = Instance.new("BillboardGui")
        gui.Name = "PlotESP_Billboard"
        gui.Adornee = spawnPart
        gui.Size = UDim2.new(0, 200, 0, height)
        gui.SizeOffset = Vector2.new(0, 0)
        gui.StudsOffset = Vector3.new(0, 3, 0)
        gui.AlwaysOnTop = true
        gui.MaxDistance = 10000
        gui.Parent = spawnPart

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = gui

        local yOffset = 0
        local ownerLabel
        if CONFIG.ESP.PlotESP.ShowOwner then
            ownerLabel = Instance.new("TextLabel")
            ownerLabel.Size = UDim2.new(1, 0, 0.4, 0)
            ownerLabel.Position = UDim2.new(0, 0, 0, yOffset)
            ownerLabel.Text = "Owner: Loading..."
            ownerLabel.TextColor3 = CONFIG.Colors.Text
            ownerLabel.BackgroundTransparency = 1
            ownerLabel.TextScaled = true
            ownerLabel.TextSize = CONFIG.ESP.PlotESP.OwnerTextSize
            ownerLabel.Font = Enum.Font.SourceSansBold
            ownerLabel.Parent = frame
            local ownerStroke = Instance.new("UIStroke", ownerLabel)
            ownerStroke.Thickness = 0.5
            ownerStroke.Color = Color3.fromRGB(0, 0, 0)
            ownerStroke.Transparency = 0.4
            yOffset = yOffset + 0.4
        end

        local timeLabel
        if CONFIG.ESP.PlotESP.ShowTime then
            timeLabel = Instance.new("TextLabel")
            timeLabel.Size = UDim2.new(1, 0, 0.3, 0)
            timeLabel.Position = UDim2.new(0, 0, yOffset, 0)
            timeLabel.Text = "Time: Loading..."
            timeLabel.TextColor3 = CONFIG.Colors.SubText
            timeLabel.BackgroundTransparency = 1
            timeLabel.TextScaled = true
            timeLabel.TextSize = CONFIG.ESP.PlotESP.TimeTextSize
            timeLabel.Font = Enum.Font.SourceSans
            timeLabel.Parent = frame
            local timeStroke = Instance.new("UIStroke", timeLabel)
            timeStroke.Thickness = 0.5
            timeStroke.Color = Color3.fromRGB(0, 0, 0)
            timeStroke.Transparency = 0.4
            yOffset = yOffset + 0.3
        end

        local distLabel
        if CONFIG.ESP.PlotESP.ShowDistance then
            distLabel = Instance.new("TextLabel")
            distLabel.Size = UDim2.new(1, 0, 0.3, 0)
            distLabel.Position = UDim2.new(0, 0, yOffset, 0)
            distLabel.Text = "Distance: Calculating..."
            distLabel.TextColor3 = CONFIG.Colors.Text
            distLabel.BackgroundTransparency = 1
            distLabel.TextScaled = true
            distLabel.TextSize = 14
            distLabel.Font = Enum.Font.SourceSans
            distLabel.Parent = frame
            local distStroke = Instance.new("UIStroke", distLabel)
            distStroke.Thickness = 0.5
            distStroke.Color = Color3.fromRGB(0, 0, 0)
            distStroke.Transparency = 0.4
        end

        return gui, distLabel, ownerLabel, timeLabel
    end)
    if not success then
        warn("Failed to create billboard GUI for plot: " .. plot.Name)
        return nil, nil, nil, nil
    end
    return billboard, distanceLabel, ownerLabel, timeLabel
end

local function updatePlotBillboard(plot, data)
    if not data.billboard or not data.billboard.Adornee then
        return
    end
    local success, _ = pcall(function()
        local localPlayer = Players.LocalPlayer
        if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        local localRoot = localPlayer.Character.HumanoidRootPart
        local targetPart = data.billboard.Adornee
        if CONFIG.ESP.PlotESP.ShowDistance and data.distanceLabel then
            local distance = (localRoot.Position - targetPart.Position).Magnitude
            data.distanceLabel.Text = string.format("Distance: %.1f studs", distance)
        end

        if CONFIG.ESP.PlotESP.ShowOwner and data.ownerLabel then
            local owner = getPlotOwner(plot)
            data.ownerLabel.Text = owner and ("Owner: " .. owner) or "Owner: Unknown"
        end

        if CONFIG.ESP.PlotESP.ShowTime and data.timeLabel then
            local remainingTime = getRemainingTime(plot)
            data.timeLabel.Text = remainingTime and ("Time: " .. remainingTime) or "Time: N/A"
        end
    end)
    if not success then
        warn("Failed to update plot billboard for plot: " .. plot.Name)
    end
end

local function attachHighlightToPlot(plot)
    if not _G.PlotESP_Enabled or not plot then return end
    local success, _ = pcall(function()
        local oldHighlight = plot:FindFirstChildOfClass("Highlight")
        if oldHighlight then oldHighlight:Destroy() end
        local oldBillboard = plot:FindFirstChild("PlotESP_Billboard", true)
        if oldBillboard then oldBillboard:Destroy() end

        local highlight = Instance.new("Highlight")
        highlight.FillTransparency = CONFIG.ESP.PlotESP.FillTransparency
        highlight.OutlineTransparency = CONFIG.ESP.PlotESP.OutlineTransparency
        highlight.OutlineColor = CONFIG.ESP.PlotESP.HighlightColor
        highlight.Adornee = plot
        highlight.Parent = plot

        local billboard, distanceLabel, ownerLabel, timeLabel = createPlotBillboardGui(plot)
        if not billboard then return end

        _G.PlotESP_Data[plot] = _G.PlotESP_Data[plot] or {}
        _G.PlotESP_Data[plot].highlight = highlight
        _G.PlotESP_Data[plot].billboard = billboard
        _G.PlotESP_Data[plot].distanceLabel = distanceLabel
        _G.PlotESP_Data[plot].ownerLabel = ownerLabel
        _G.PlotESP_Data[plot].timeLabel = timeLabel

        local lastUpdate = 0
        _G.PlotESP_Data[plot].updateConn = RunService.Heartbeat:Connect(function(deltaTime)
            lastUpdate = lastUpdate + deltaTime
            if lastUpdate >= CONFIG.ESP.UpdateInterval then
                updatePlotBillboard(plot, _G.PlotESP_Data[plot])
                lastUpdate = 0
            end
        end)
    end)
    if not success then
        warn("Failed to attach ESP to plot: " .. plot.Name)
    end
end

local function enablePlotESP()
    if _G.PlotESP_Enabled then return end
    local success, _ = pcall(function()
        local plotsFolder = workspace:FindFirstChild("Plots")
        if not plotsFolder then return end

        _G.PlotESP_Enabled = true
        for _, plot in ipairs(plotsFolder:GetChildren()) do
            if plot:IsA("Model") then
                local plotConn = plot.AncestryChanged:Connect(function()
                    if not plot.Parent then
                        if _G.PlotESP_Data[plot] then
                            if _G.PlotESP_Data[plot].updateConn then pcall(function() _G.PlotESP_Data[plot].updateConn:Disconnect() end) end
                            if _G.PlotESP_Data[plot].highlight then pcall(function() _G.PlotESP_Data[plot].highlight:Destroy() end) end
                            if _G.PlotESP_Data[plot].billboard then pcall(function() _G.PlotESP_Data[plot].billboard:Destroy() end) end
                            _G.PlotESP_Data[plot] = nil
                        end
                    end
                end)
                _G.PlotESP_Data[plot] = _G.PlotESP_Data[plot] or {}
                _G.PlotESP_Data[plot].plotConn = plotConn
                attachHighlightToPlot(plot)
            end
        end
        _G.PlotESP_Data.plotsConn = plotsFolder.ChildAdded:Connect(function(plot)
            if plot:IsA("Model") then
                local plotConn = plot.AncestryChanged:Connect(function()
                    if not plot.Parent then
                        if _G.PlotESP_Data[plot] then
                            if _G.PlotESP_Data[plot].updateConn then pcall(function() _G.PlotESP_Data[plot].updateConn:Disconnect() end) end
                            if _G.PlotESP_Data[plot].highlight then pcall(function() _G.PlotESP_Data[plot].highlight:Destroy() end) end
                            if _G.PlotESP_Data[plot].billboard then pcall(function() _G.PlotESP_Data[plot].billboard:Destroy() end) end
                            _G.PlotESP_Data[plot] = nil
                        end
                    end
                end)
                _G.PlotESP_Data[plot] = _G.PlotESP_Data[plot] or {}
                _G.PlotESP_Data[plot].plotConn = plotConn
                task.wait(1) -- Wait for plot to fully load
                attachHighlightToPlot(plot)
            end
        end)
        _G.PlotESP_Data.plotsRemoveConn = plotsFolder.ChildRemoved:Connect(function(plot)
            if _G.PlotESP_Data[plot] then
                if _G.PlotESP_Data[plot].plotConn then pcall(function() _G.PlotESP_Data[plot].plotConn:Disconnect() end) end
                if _G.PlotESP_Data[plot].updateConn then pcall(function() _G.PlotESP_Data[plot].updateConn:Disconnect() end) end
                if _G.PlotESP_Data[plot].highlight then pcall(function() _G.PlotESP_Data[plot].highlight:Destroy() end) end
                if _G.PlotESP_Data[plot].billboard then pcall(function() _G.PlotESP_Data[plot].billboard:Destroy() end) end
                _G.PlotESP_Data[plot] = nil
            end
        end)
    end)
    if not success then
        warn("Failed to enable Plot ESP")
        _G.PlotESP_Enabled = false
    end
end

local function disablePlotESP()
    if not _G.PlotESP_Enabled then return end
    local success, _ = pcall(function()
        _G.PlotESP_Enabled = false
        if _G.PlotESP_Data.plotsConn then
            pcall(function() _G.PlotESP_Data.plotsConn:Disconnect() end)
            _G.PlotESP_Data.plotsConn = nil
        end
        if _G.PlotESP_Data.plotsRemoveConn then
            pcall(function() _G.PlotESP_Data.plotsRemoveConn:Disconnect() end)
            _G.PlotESP_Data.plotsRemoveConn = nil
        end
        for plot, data in pairs(_G.PlotESP_Data) do
            if typeof(plot) == "Instance" then
                if data.plotConn then pcall(function() data.plotConn:Disconnect() end) end
                if data.updateConn then pcall(function() data.updateConn:Disconnect() end) end
                if data.highlight then pcall(function() data.highlight:Destroy() end) end
                if data.billboard then pcall(function() data.billboard:Destroy() end) end
                _G.PlotESP_Data[plot] = nil
            end
        end
    end)
    if not success then
        warn("Failed to disable Plot ESP")
    end
end

local function enablePlotTimeESP()
    if _G.PlotTimeESP_Enabled then return end
    local success, _ = pcall(function()
        local plotsFolder = workspace:FindFirstChild("Plots")
        if not plotsFolder then
            warn("Plots folder not found")
            return
        end

        _G.PlotTimeESP_Enabled = true
        _G.PlotTimeESP_Data = {} -- Clear existing data to prevent duplicates

        for _, plot in pairs(plotsFolder:GetChildren()) do
            if plot:IsA("Model") and plot:FindFirstChild("Spawn") then
                local billboard, timeLabel = createPlotTimeBillboard(plot)
                if billboard and timeLabel then
                    _G.PlotTimeESP_Data[plot] = {
                        billboard = billboard,
                        timeLabel = timeLabel
                    }
                    local lastUpdate = 0
                    _G.PlotTimeESP_Data[plot].updateConn = RunService.Heartbeat:Connect(function(deltaTime)
                        if not _G.PlotTimeESP_Enabled or not _G.PlotTimeESP_Data[plot] then return end
                        lastUpdate = lastUpdate + deltaTime
                        if lastUpdate >= CONFIG.ESP.UpdateInterval then
                            updatePlotTimeBillboard(plot, _G.PlotTimeESP_Data[plot])
                            lastUpdate = 0
                        end
                    end)
                end
            end
        end

        -- Handle new plots
        _G.PlotTimeESP_Data.plotsConn = plotsFolder.ChildAdded:Connect(function(plot)
            if plot:IsA("Model") then
                task.wait(1) -- Wait for plot to load
                if plot:FindFirstChild("Spawn") then
                    local billboard, timeLabel = createPlotTimeBillboard(plot)
                    if billboard and timeLabel then
                        _G.PlotTimeESP_Data[plot] = {
                            billboard = billboard,
                            timeLabel = timeLabel
                        }
                        local lastUpdate = 0
                        _G.PlotTimeESP_Data[plot].updateConn = RunService.Heartbeat:Connect(function(deltaTime)
                            if not _G.PlotTimeESP_Enabled or not _G.PlotTimeESP_Data[plot] then return end
                            lastUpdate = lastUpdate + deltaTime
                            if lastUpdate >= CONFIG.ESP.UpdateInterval then
                                updatePlotTimeBillboard(plot, _G.PlotTimeESP_Data[plot])
                                lastUpdate = 0
                            end
                        end)
                    end
                end
            end
        end)
        
        -- Handle player events for plot time updates
        _G.PlotTimeESP_Data.playerAddedConn = Players.PlayerAdded:Connect(function(plr)
            -- Update all plot time billboards when a player joins
            for plot, data in pairs(_G.PlotTimeESP_Data) do
                if typeof(plot) == "Instance" and data.billboard and data.timeLabel then
                    updatePlotTimeBillboard(plot, data)
                end
            end
        end)
        
        _G.PlotTimeESP_Data.playerRemovingConn = Players.PlayerRemoving:Connect(function(plr)
            -- Update all plot time billboards when a player leaves
            for plot, data in pairs(_G.PlotTimeESP_Data) do
                if typeof(plot) == "Instance" and data.billboard and data.timeLabel then
                    updatePlotTimeBillboard(plot, data)
                end
            end
        end)

        -- Handle plot removal
        _G.PlotTimeESP_Data.plotsRemoveConn = plotsFolder.ChildRemoved:Connect(function(plot)
            if _G.PlotTimeESP_Data[plot] then
                if _G.PlotTimeESP_Data[plot].updateConn then
                    pcall(function() _G.PlotTimeESP_Data[plot].updateConn:Disconnect() end)
                end
                if _G.PlotTimeESP_Data[plot].billboard then
                    pcall(function() _G.PlotTimeESP_Data[plot].billboard:Destroy() end)
                end
                _G.PlotTimeESP_Data[plot] = nil
            end
        end)
    end)
    if not success then
        warn("Failed to enable Plot Time ESP")
        _G.PlotTimeESP_Enabled = false
    end
end

--=========================================================
-- Server Hop System
--=========================================================
local isServerHopActive = false
local serverHopThread = nil

local function getServerList()
    local success, servers = pcall(function()
        local placeId = game.PlaceId
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
        local response = _G.safeHttpGet(url)
        if not response then
            warn("❌ Failed to fetch server list")
            return {}
        end
        local parsed = HttpService:JSONDecode(response)
        local result = {}
        if type(parsed) == "table" and type(parsed.data) == "table" then
            for _, server in ipairs(parsed.data) do
                if type(server) == "table" and server.playing and server.maxPlayers and server.id and server.playing < server.maxPlayers and server.id ~= game.JobId then
                    table.insert(result, server.id)
                end
            end
        end
        return result
    end)
    if not success then
        warn("Failed to get server list")
        return {}
    end
    return servers
end

local function attemptServerHop()
    local success, _ = pcall(function()
        local serverList = getServerList()
        if #serverList > 0 then
            local target = serverList[math.random(1, #serverList)]
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, target, player)
        else
            warn("No available servers found")
        end
    end)
    if not success then
        warn("Server hop attempt failed")
    end
end

local function toggleServerHop(active)
    local success, _ = pcall(function()
        isServerHopActive = active
        if active then
            if not serverHopThread then
                serverHopThread = task.spawn(function()
                    while isServerHopActive do
                        attemptServerHop()
                        task.wait(6)
                    end
                    serverHopThread = nil
                end)
            end
        else
            isServerHopActive = false
        end
    end)
    if not success then
        warn("Failed to toggle server hop")
    end
end

--=========================================================
-- Jump Power Control
--=========================================================
local function setupJumpPowerControl(parent)
    local jumpData = {
        defaultJumpPower = 50,
        isActive = false
    }

    local jumpSwitch = createSwitch(parent, "Jump Bypass", _G.SavedToggleStates and _G.SavedToggleStates.Jump or false, function(on)
        local success, _ = pcall(function()
            jumpData.isActive = on
            if humanoid then
                humanoid.UseJumpPower = true
                humanoid.JumpPower = on and CONFIG.Movement.JumpPower or jumpData.defaultJumpPower
            end
            if on then
                -- Auto-create side toggle when enabled
                _G.createCircularToggleUI("Jump", function() return jumpSwitch.get() end, function(state) jumpSwitch.set(state) end)
            else
                -- Remove side toggle when disabled
                local existingToggle = _G.circularToggleGui:FindFirstChild("JumpToggleUI")
                if existingToggle then
                    _G.OpenCircularToggles["Jump"] = nil
                    existingToggle:Destroy()
                    _G.saveSettings()
                end
            end
        end)
        if not success then
            warn("Failed to toggle jump power")
        end
    end)

    return jumpData.isActive, jumpSwitch
end

--=========================================================
-- Speed Boost Control
--=========================================================
local function setupSpeedControl(parent)
    local speedData = {
        enabled = false,
        connections = {},
        joystickDelta = Vector2.new(0, 0),
        touchId = nil
    }

    local function enableSpeed()
        local success, _ = pcall(function()
            if speedData.enabled then return end
            humanoid, humanoidRootPart = character and character:FindFirstChildOfClass("Humanoid"), character and character:FindFirstChild("HumanoidRootPart")
            if not humanoid or not humanoidRootPart then return end
            speedData.enabled = true

            if UserInputService.TouchEnabled then
                speedData.connections.touchBegan = UserInputService.TouchStarted:Connect(function(input, gameProcessed)
                    if gameProcessed or speedData.touchId then return end
                    if input.UserInputType == Enum.UserInputType.Touch then
                        speedData.touchId = input.UserInputId
                        speedData.joystickDelta = Vector2.new(0, 0)
                    end
                end)

                speedData.connections.touchMoved = UserInputService.TouchMoved:Connect(function(input, gameProcessed)
                    if gameProcessed or input.UserInputId ~= speedData.touchId then return end
                    local touchPos = input.Position
                    local screenSize = workspace.CurrentCamera.ViewportSize
                    local normalizedPos = Vector2.new(
                        (touchPos.X / screenSize.X - 0.25) * 4,
                        (touchPos.Y / screenSize.Y - 0.5) * 2
                    )
                    speedData.joystickDelta = Vector2.new(
                        math.clamp(normalizedPos.X, -1, 1),
                        math.clamp(normalizedPos.Y, -1, 1)
                    )
                end)

                speedData.connections.touchEnded = UserInputService.TouchEnded:Connect(function(input, gameProcessed)
                    if gameProcessed or input.UserInputId ~= speedData.touchId then return end
                    speedData.touchId = nil
                    speedData.joystickDelta = Vector2.new(0, 0)
                end)
            end

            speedData.connections.move = RunService.Heartbeat:Connect(function()
                if not speedData.enabled or not humanoid or not humanoidRootPart or humanoidRootPart.Parent ~= character then return end

                local moveVector = Vector3.new(0, 0, 0)
                local camCF = workspace.CurrentCamera.CFrame

                if UserInputService.TouchEnabled and speedData.joystickDelta.Magnitude > 0.15 then
                    moveVector = camCF:VectorToWorldSpace(Vector3.new(speedData.joystickDelta.X, 0, -speedData.joystickDelta.Y))
                    moveVector = moveVector.Unit * CONFIG.Movement.Speed
                else
                    local moveX = (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0)
                    local moveZ = (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0)
                    if moveX ~= 0 or moveZ ~= 0 then
                        moveVector = (camCF.RightVector * moveX + camCF.LookVector * moveZ).Unit * CONFIG.Movement.Speed
                    end
                end

                local currentVelocity = humanoidRootPart.AssemblyLinearVelocity
                local newVelocity = Vector3.new(
                    moveVector.X ~= 0 and moveVector.X or currentVelocity.X,
                    currentVelocity.Y,
                    moveVector.Z ~= 0 and moveVector.Z or currentVelocity.Z
                )

                local flatMag = Vector3.new(newVelocity.X, 0, newVelocity.Z).Magnitude
                if flatMag > CONFIG.Movement.MaxSpeed then
                    local ratio = CONFIG.Movement.MaxSpeed / flatMag
                    newVelocity = Vector3.new(newVelocity.X * ratio, newVelocity.Y, newVelocity.Z * ratio)
                end

                humanoidRootPart.AssemblyLinearVelocity = newVelocity
            end)
        end)
        if not success then
            warn("Failed to enable speed boost")
            speedData.enabled = false
        end
    end

    local function disableSpeed()
        local success, _ = pcall(function()
            if not speedData.enabled then return end
            speedData.enabled = false
            for _, conn in pairs(speedData.connections) do
                pcall(function() conn:Disconnect() end)
            end
            speedData.connections = {}
            speedData.touchId = nil
            speedData.joystickDelta = Vector2.new(0, 0)
            if humanoidRootPart then
                humanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, humanoidRootPart.AssemblyLinearVelocity.Y, 0)
            end
        end)
        if not success then
            warn("Failed to disable speed boost")
        end
    end

    local speedSwitch = createSwitch(parent, "Speed Boost", _G.SavedToggleStates and _G.SavedToggleStates.Speed or false, function(on)
        if on then
            enableSpeed()
            -- Auto-create side toggle when enabled
            _G.createCircularToggleUI("Speed", function() return speedSwitch.get() end, function(state) speedSwitch.set(state) end)
        else
            disableSpeed()
            -- Remove side toggle when disabled
            local existingToggle = _G.circularToggleGui:FindFirstChild("SpeedToggleUI")
            if existingToggle then
                _G.OpenCircularToggles["Speed"] = nil
                existingToggle:Destroy()
                _G.saveSettings()
            end
        end
    end)

    return speedData.enabled, speedSwitch
end


--=========================================================
-- Unhittable Control
--=========================================================
local unhittableSwitch -- Global to access in CharacterAdded

local function setupUnhittableControl(parent)
    local defaultSize = Vector3.new(2, 2, 1)
    local isUnhittableActive = false
    local unhittableThread = nil

    unhittableSwitch = createSwitch(parent, "Height Bypass", false, function(on)
        local success, _ = pcall(function()
            isUnhittableActive = on
            if not humanoidRootPart then return end
            if on then
                if not unhittableThread then
                    unhittableThread = task.spawn(function()
                        while isUnhittableActive do
                            if humanoidRootPart then
                                humanoidRootPart.Size = Vector3.new(
                                    CONFIG.Movement.Unhittable.IntermediateSize.X,
                                    CONFIG.Movement.Unhittable.IntermediateSize.Y,
                                    CONFIG.Movement.Unhittable.IntermediateSize.Z
                                )
                                task.wait(0.2)
                                if not isUnhittableActive then break end
                                humanoidRootPart.Size = Vector3.new(
                                    CONFIG.Movement.Unhittable.TallSize.X,
                                    CONFIG.Movement.Unhittable.TallSize.Y,
                                    CONFIG.Movement.Unhittable.TallSize.Z
                                )
                                task.wait(2.1)
                                if not isUnhittableActive then break end
                                humanoidRootPart.Size = defaultSize
                                task.wait(1.5)
                            else
                                task.wait(0.1)
                            end
                        end
                        if humanoidRootPart then
                            humanoidRootPart.Size = defaultSize
                        end
                        unhittableThread = nil
                    end)
                end
            else
                if humanoidRootPart then
                    humanoidRootPart.Size = defaultSize
                end
                if unhittableThread then
                    task.cancel(unhittableThread)
                    unhittableThread = nil
                end
            end
        end)
        if not success then
            warn("Failed to toggle height bypass")
        end
    end)

    return isUnhittableActive, unhittableSwitch
end

--=========================================================
-- Resize Control
--=========================================================
local resizeSwitch -- Global to access in CharacterAdded

local function setupResizeControl(parent)
    local defaultSize = Vector3.new(2, 2, 1)
    local isResizeActive = false

    resizeSwitch = createSwitch(parent, "Tall like Ken", false, function(on)
        local success, _ = pcall(function()
            isResizeActive = on
            if humanoidRootPart then
                humanoidRootPart.Size = on and Vector3.new(
                    CONFIG.Movement.Resize.TargetSize.X,
                    CONFIG.Movement.Resize.TargetSize.Y,
                    CONFIG.Movement.Resize.TargetSize.Z
                ) or defaultSize
            end
        end)
        if not success then
            warn("Failed to toggle tall mode")
        end
    end)

    return isResizeActive, resizeSwitch
end

--=========================================================
-- Fling Control (Fixed Desync Logic)
--=========================================================
local flingSwitch -- Global to access in CharacterAdded

local function setupFlingControl(parent)
    local isFlingActive = false
    local desyncState = {}
    local flingConnection = nil
    local oldIndex = nil

    local function RandomNumberRange(a)
        return math.random(-a * 100, a * 100) / 100
    end

    local function enableFling()
        local success, err = pcall(function()
            if isFlingActive then return end
            -- Ensure character and components exist
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
                warn("Cannot enable fling: Character not ready")
                return
            end
            isFlingActive = true

            -- Hook __index to spoof CFrame
            oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
                if isFlingActive and not checkcaller() and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    if key == "CFrame" then
                        if self == player.Character.HumanoidRootPart then
                            return desyncState[1] or CFrame.new()
                        elseif self == player.Character.Head then
                            return desyncState[1] and (desyncState[1] + Vector3.new(0, player.Character.HumanoidRootPart.Size.Y / 2 + 0.5, 0)) or CFrame.new()
                        end
                    end
                end
                return oldIndex(self, key)
            end))

            flingConnection = RunService.Heartbeat:Connect(function()
                if isFlingActive and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    local hrp = player.Character.HumanoidRootPart
                    -- Store original state
                    desyncState[1] = hrp.CFrame
                    desyncState[2] = hrp.AssemblyLinearVelocity

                    -- Spoof CFrame and velocity
                    local spoofCFrame = desyncState[1] * CFrame.new(Vector3.new(0, 0, 0))
                    spoofCFrame = spoofCFrame * CFrame.Angles(math.rad(RandomNumberRange(180)), math.rad(RandomNumberRange(180)), math.rad(RandomNumberRange(180)))
                    hrp.CFrame = spoofCFrame
                    hrp.AssemblyLinearVelocity = Vector3.new(1, 0, 0) * 5000 -- Reduced velocity to prevent physics crashes

                    -- Wait for next frame
                    RunService.RenderStepped:Wait()

                    -- Restore original state only if character is still valid
                    if player.Character and hrp.Parent == player.Character then
                        hrp.CFrame = desyncState[1]
                        hrp.AssemblyLinearVelocity = desyncState[2]
                    end
                end
            end)
        end)
        if not success then
            warn("Failed to enable fling: " .. tostring(err))
            isFlingActive = false
            flingSwitch.set(false) -- Reset UI switch if enabling fails
        end
    end

    local function disableFling()
        local success, err = pcall(function()
            if not isFlingActive then return end
            isFlingActive = false
            if flingConnection then
                flingConnection:Disconnect()
                flingConnection = nil
            end
            if oldIndex then
                -- Restore original __index
                hookmetamethod(game, "__index", function(self, key)
                    return oldIndex(self, key)
                end)
                oldIndex = nil
            end
            desyncState = {}
            -- Ensure character state is reset
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, player.Character.HumanoidRootPart.AssemblyLinearVelocity.Y, 0)
            end
        end)
        if not success then
            warn("Failed to disable fling: " .. tostring(err))
        end
    end

    flingSwitch = createSwitch(parent, "Fling (patched)", false, function(on)
        if on then
            enableFling()
        else
            disableFling()
        end
    end)

    return isFlingActive, flingSwitch
end

-- [Ken HUB Part 2 export]
local K = _G.KenHubState
K.createSection = createSection
K.createTabButton = createTabButton
K.createSectionHeader = createSectionHeader
K.createSwitch = createSwitch
K.createNumberInput = createNumberInput
K.mainFrame = mainFrame
K.screenGui = screenGui
K.settingsContent = settingsContent
K.settingsFrame = settingsFrame
K.settingsCloseBtn = settingsCloseBtn
K.settingsBtn = settingsBtn
K.minimizeBtn = minimizeBtn
K.closeBtn = closeBtn
K.sidebar = sidebar
K.contentArea = contentArea
K.sections = sections
K.activeSection = activeSection
K.setupJumpPowerControl = setupJumpPowerControl
K.setupSpeedControl = setupSpeedControl
K.setupUnhittableControl = setupUnhittableControl
K.setupResizeControl = setupResizeControl
K.setupFlingControl = setupFlingControl
K.enableESP = enableESP
K.disableESP = disableESP
K.enablePlotESP = enablePlotESP
K.disablePlotESP = disablePlotESP

_G.KenHub_createBillboardGui = createBillboardGui
_G.KenHub_updateBillboard = updateBillboard
_G.KenHub_createSwitch = createSwitch
pcall(function() _G.KenHubStatus("Part 2/5 OK") end)
-- KenHub_P2_OK
