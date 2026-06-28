-- Ken HUB Part 1/5 - Bootstrap + Core
--=========================================================
-- Ken HUB v1.68 - Delta Executor optimized bootstrap
--=========================================================
local SCRIPT_VERSION = "1.76"

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer or Players.PlayerAdded:Wait()

local function KenNotify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 6,
        })
    end)
end

local PlayerGui = LP:FindFirstChild("PlayerGui")
if not PlayerGui then
    pcall(function() PlayerGui = LP:WaitForChild("PlayerGui", 60) end)
end
if not PlayerGui and gethui then
    pcall(function()
        local h = gethui()
        if typeof(h) == "Instance" then PlayerGui = h end
    end)
end
if not PlayerGui then
    warn("[Ken HUB] PlayerGui bulunamadi - once oyuna tam gir, sonra execute et")
    return
end

-- Her zaman gorunen KH acma butonu (script hata verse bile ekranda kalir)
local FabGui = Instance.new("ScreenGui")
FabGui.Name = "KenHub_FAB"
FabGui.ResetOnSpawn = false
FabGui.IgnoreGuiInset = true
FabGui.DisplayOrder = 2147483647
FabGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
FabGui.Parent = PlayerGui

local FabBtn = Instance.new("TextButton")
FabBtn.Name = "OpenKenHub"
FabBtn.Size = UDim2.new(0, 58, 0, 58)
FabBtn.Position = UDim2.new(0, 12, 0.5, -29)
FabBtn.BackgroundColor3 = Color3.fromRGB(14, 144, 210)
FabBtn.Text = "KH"
FabBtn.Font = Enum.Font.GothamBold
FabBtn.TextSize = 20
FabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FabBtn.AutoButtonColor = false
FabBtn.Parent = FabGui
Instance.new("UICorner", FabBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", FabBtn).Color = Color3.fromRGB(255, 255, 255)

_G.KenHubPanelToggle = nil
local function onFabClick()
    if _G.KenHubPanelToggle then
        _G.KenHubPanelToggle()
    else
        KenNotify("Ken HUB", "Panel henuz yuklenmedi, birkaç saniye bekle...")
    end
end
FabBtn.MouseButton1Click:Connect(onFabClick)
FabBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then onFabClick() end
end)

-- Aninda gorunen durum paneli
local BootstrapGui = Instance.new("ScreenGui")
BootstrapGui.Name = "KenHub_Bootstrap"
BootstrapGui.ResetOnSpawn = false
BootstrapGui.IgnoreGuiInset = true
BootstrapGui.DisplayOrder = 2147483646
BootstrapGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
BootstrapGui.Parent = PlayerGui

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "Status"
StatusLabel.Size = UDim2.new(0, 300, 0, 44)
StatusLabel.Position = UDim2.new(0.5, -150, 0, 8)
StatusLabel.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Text = "Ken HUB baslatiliyor..."
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 13
StatusLabel.TextWrapped = true
StatusLabel.Parent = BootstrapGui
Instance.new("UICorner", StatusLabel).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", StatusLabel).Color = Color3.fromRGB(14, 144, 210)

function _G.KenHubStatus(msg)
    StatusLabel.Text = tostring(msg)
end

function _G.KenHubError(msg)
    local err = tostring(msg)
    StatusLabel.Text = "HATA: " .. err:sub(1, 180)
    StatusLabel.BackgroundColor3 = Color3.fromRGB(90, 25, 25)
    KenNotify("Ken HUB Hata", err:sub(1, 120))
    warn("[Ken HUB ERROR]", err)
end

function _G.KenHubReady()
    pcall(function() BootstrapGui:Destroy() end)
end

KenNotify("Ken HUB", "Script yukleniyor...")
_G.KenHubStatus("Ken HUB yukleniyor...")

_G.Services = {
    Players = Players,
    RunService = game:GetService("RunService"),
    UserInputService = UserInputService,
    TweenService = game:GetService("TweenService"),
    HttpService = game:GetService("HttpService"),
    TeleportService = game:GetService("TeleportService"),
}
_G.player = LP
_G.character = LP.Character
if _G.character then
    _G.humanoid = _G.character:FindFirstChildOfClass("Humanoid")
    _G.humanoidRootPart = _G.character:FindFirstChild("HumanoidRootPart")
end

-- Executor algilama
_G.detectExecutor = function()
    if identifyexecutor then
        local ok, name = pcall(identifyexecutor)
        if ok and name then return tostring(name) end
    end
    if getgenv and getgenv().executor then return getgenv().executor end
    return "unknown"
end
_G.executor = _G.detectExecutor()
local execLower = string.lower(tostring(_G.executor))
_G.isDelta = execLower:find("delta") ~= nil
_G.isMobile = _G.isDelta
    or execLower:find("mobile") ~= nil
    or execLower:find("android") ~= nil
    or execLower:find("ios") ~= nil
    or (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled)

_G.HAS_HOOKMETAMETHOD = hookmetamethod ~= nil

-- Delta / mobil GUI parent: PlayerGui en guvenilir (acik kaynak hub standardi)
_G.getKenHubGuiParent = function()
    if PlayerGui and PlayerGui.Parent then
        return PlayerGui
    end
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and typeof(hui) == "Instance" then return hui end
    end
    if get_hidden_ui then
        local ok, hui = pcall(get_hidden_ui)
        if ok and typeof(hui) == "Instance" then return hui end
    end
    return CoreGui
end

_G.createMobileCompatibleGui = function(name)
    local gui = Instance.new("ScreenGui")
    gui.Name = name
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 999999
    gui.Enabled = true
    gui.Parent = _G.getKenHubGuiParent()
    return gui
end

_G.optimizeForMobile = function(gui)
    if not gui then return end
    pcall(function()
        gui.IgnoreGuiInset = true
        gui.ResetOnSpawn = false
        gui.DisplayOrder = 999999
    end)
end

_G.KenHubStatus("Executor: " .. tostring(_G.executor))

-- Executor Compatibility Checks
_G.checkExecutorSupport = function()
    _G.compatibility = {
        hookmetamethod = hookmetamethod ~= nil,
        getrawmetatable = getrawmetatable ~= nil,
        setrawmetatable = setrawmetatable ~= nil,
        islclosure = islclosure ~= nil,
        newcclosure = newcclosure ~= nil,
        sethiddenproperty = sethiddenproperty ~= nil,
        gethiddenproperty = gethiddenproperty ~= nil,
        getgenv = getgenv ~= nil,
        getrenv = getrenv ~= nil,
        writefile = writefile ~= nil,
        readfile = readfile ~= nil,
        isfile = isfile ~= nil,
        delfile = delfile ~= nil,
        listfiles = listfiles ~= nil,
        makefolder = makefolder ~= nil,
        isfolder = isfolder ~= nil,
        delfolder = delfolder ~= nil,
        listfolders = listfolders ~= nil,
        gethui = gethui ~= nil,
        get_hidden_ui = get_hidden_ui ~= nil,
        syn = syn ~= nil,
        http_request = http_request ~= nil,
        request = request ~= nil,
        gameHttpGet = game.HttpGet ~= nil
    }
    
    print("🔍 Executor Compatibility Check:")
    for feature, supported in pairs(_G.compatibility) do
        print("  " .. (supported and "✅" or "❌") .. " " .. feature)
    end
    
    return _G.compatibility
end

_G.EXECUTOR_SUPPORT = _G.checkExecutorSupport()

-- Safe File Operations
_G.safeWriteFile = function(path, content)
    if not _G.EXECUTOR_SUPPORT.writefile then
        warn("❌ writefile not supported on this executor")
        return false
    end
    local success, err = pcall(writefile, path, content)
    if not success then
        warn("❌ Failed to write file: " .. tostring(err))
        return false
    end
    return true
end

_G.safeReadFile = function(path)
    if not _G.EXECUTOR_SUPPORT.readfile then
        warn("❌ readfile not supported on this executor")
        return nil
    end
    local success, content = pcall(readfile, path)
    if not success then
        warn("❌ Failed to read file: " .. tostring(content))
        return nil
    end
    return content
end

_G.safeIsFile = function(path)
    if not _G.EXECUTOR_SUPPORT.isfile then
        return false
    end
    local success, exists = pcall(isfile, path)
    return success and exists
end

_G.safeMakeFolder = function(path)
    if not _G.EXECUTOR_SUPPORT.makefolder then
        warn("❌ makefolder not supported on this executor")
        return false
    end
    local success, err = pcall(makefolder, path)
    if not success then
        warn("❌ Failed to create folder: " .. tostring(err))
        return false
    end
    return true
end

-- Safe Hidden Property Operations
_G.safeSetHiddenProperty = function(instance, property, value)
    if not _G.EXECUTOR_SUPPORT.sethiddenproperty then
        warn("❌ sethiddenproperty not supported on this executor")
        return false
    end
    local success, err = pcall(sethiddenproperty, instance, property, value)
    if not success then
        warn("❌ Failed to set hidden property: " .. tostring(err))
        return false
    end
    return true
end

_G.safeGetHiddenProperty = function(instance, property)
    if not _G.EXECUTOR_SUPPORT.gethiddenproperty then
        warn("❌ gethiddenproperty not supported on this executor")
        return nil
    end
    local success, value = pcall(gethiddenproperty, instance, property)
    if not success then
        warn("❌ Failed to get hidden property: " .. tostring(value))
        return nil
    end
    return value
end

-- Safe HTTP Operations
_G.safeHttpGet = function(url)
    if _G.EXECUTOR_SUPPORT.http_request then
        local success, response = pcall(http_request, {
            Url = url,
            Method = "GET"
        })
        if success and response and response.Body then
            return response.Body
        end
    elseif _G.EXECUTOR_SUPPORT.request then
        local success, response = pcall(request, {
            Url = url,
            Method = "GET"
        })
        if success and response and response.Body then
            return response.Body
        end
    elseif _G.EXECUTOR_SUPPORT.gameHttpGet then
        local success, response = pcall(game.HttpGet, game, url)
        if success then
            return response
        end
    else
        warn("❌ No HTTP GET method available on this executor")
    end
    return nil
end

-- Anti-exploit kaldirildi (executor uyumlulugu icin)
local AE = {
    CFG = { KickEnabled = false, CrashEnabled = false, NotifyEnabled = false },
    applyPunishment = function() end,
}


--// Services (Players/CoreGui yukarida bootstrap'ta tanimli)
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local player = LP
local username = player.Name

local CONFIG = {
    Colors = {
        Background = Color3.fromRGB(18, 18, 18),
        Sidebar = Color3.fromRGB(22, 22, 22),
        Panel = Color3.fromRGB(28, 28, 28),
        Stroke = Color3.fromRGB(50, 50, 50),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(160, 160, 160),
        Accent = Color3.fromRGB(14, 144, 210),
        Hover = Color3.fromRGB(40, 40, 40),
        Danger = Color3.fromRGB(220, 70, 70),
        SwitchOff = Color3.fromRGB(70, 70, 70),
        SwitchOn = Color3.fromRGB(14, 144, 210),
        SectionHeader = Color3.fromRGB(38, 38, 38),
        ESPHighlight = Color3.fromRGB(255, 0, 0),
        PlotESPHighlight = Color3.fromRGB(0, 255, 0),
        BrainrotESPHighlight = Color3.fromRGB(0, 0, 255), -- New color for Brainrot ESP
    },
    UI = {
        CornerRadius = UDim.new(0, 10),
        AnimationSpeed = 0.2,
        FrameSize = UDim2.new(0, 580, 0, 380),
        SidebarWidth = 140,
        MinimizedSize = UDim2.new(0, 580, 0, 40),
        SettingsFrameSize = UDim2.new(0, 400, 0, 300),
        TextSize = 14,
        TitleTextSize = 18,
        HeaderTextSize = 15,
        ButtonTextSize = 14,
        -- UI State Persistence
        IsMinimized = false,
        SettingsOpen = false,
        CurrentTab = "Movement",
        ToggleKey = Enum.KeyCode.RightShift,
        InputTextSize = 14,
        Font = Enum.Font.Gotham,
        TitleFont = Enum.Font.GothamBold,
        HeaderFont = Enum.Font.GothamBold,
        ButtonFont = Enum.Font.GothamMedium,
        InputFont = Enum.Font.Gotham,
        Transparency = 0,
        BackgroundTransparency = 0,
        StrokeTransparency = 0.4,
        HoverTransparency = 0.1,
        ActiveTransparency = 0.2,
    },
    ESP = {
        UpdateInterval = 0.1,
        PlayerESP = {
            ShowDistance = true,
            ShowItems = true,
            TextSize = 18,
            DistanceTextSize = 14,
            ItemTextSize = 12,
            UsernameColor = Color3.fromRGB(255, 255, 255),
            DistanceColor = Color3.fromRGB(255, 255, 255),
            ItemColor = Color3.fromRGB(255, 255, 255),
            HighlightColor = Color3.fromRGB(255, 0, 0),
            OutlineColor = Color3.fromRGB(0, 0, 0),
            OutlineTransparency = 0.4,
            FillTransparency = 1,
        },
        PlotESP = {
            ShowDistance = true,
            ShowOwner = true,
            ShowTime = true,
            TextSize = 16,
            DistanceTextSize = 14,
            OwnerTextSize = 16,
            TimeTextSize = 14,
            OwnerColor = Color3.fromRGB(255, 255, 255),
            DistanceColor = Color3.fromRGB(255, 255, 255),
            TimeColor = Color3.fromRGB(160, 160, 160),
            HighlightColor = Color3.fromRGB(0, 255, 0),
            OutlineColor = Color3.fromRGB(0, 0, 0),
            OutlineTransparency = 0.4,
            FillTransparency = 1,
        },
        BrainrotESP = {
            Enabled = false,
            TextSize = 20,
            DistanceTextSize = 16,
            UsernameColor = Color3.fromRGB(255, 215, 0),
            DistanceColor = Color3.fromRGB(255, 255, 255),
            HighlightColor = Color3.fromRGB(0, 0, 255),
            OutlineColor = Color3.fromRGB(0, 0, 0),
            FillTransparency = 0.5,
        },
    },
    Automation = {
        PetSnipe = {
            Enabled = false,
            MinTier = "Rare",
            UseMinGeneration = true,
            MinGeneration = 100e6,
            DeliveryDelay = 2.5,
            ScanInterval = 1.5,
            StealCooldown = 4,
            Rarities = {
                common = false,
                uncommon = false,
                rare = true,
                epic = true,
                legendary = true,
                mythic = true,
                secret = true,
                celestial = true,
                divine = true,
                og = true,
                god = true,
                limited = true,
                exclusive = true,
            },
        },
    },
    Movement = {
        Speed = 43,
        MaxSpeed = 45,
        JumpPower = 73.5,
        Rise = {
            Enabled = false,
            Speed = 5,
            MaxHeight = 500,
        },
        Unhittable = {
            IntermediateSize = { X = 2, Y = 20, Z = 1 },
            TallSize = { X = 2, Y = 40, Z = 1 },
        },
        Resize = {
            TargetSize = { X = 2, Y = 10, Z = 1 },
		},
		Float = {
			Enabled = false,
			DescentSpeed = 2.5, -- Downward speed (2.5 = gentle; adjust: 1 = slower, 4 = faster)
			VelocityBlend = 1, -- Slight randomization to avoid anti-cheat detection
        },
        Helicopter = {
            Enabled = false,
            RotationSpeed = 20, -- How fast to rotate
        },
        GrappleFlight = {
            Enabled = false,
            Speed = 150, -- Flight speed
        },
        InfiniteJump = {
            Enabled = false,
            JumpPower = 42, -- Jump velocity
            Cooldown = 0.2, -- Cooldown between jumps
        },
    },
    DiscordLink = "https://discord.gg/MxtDGmvkCd",
}

_G.OpenCircularToggles = {}  -- Sigma Table

-- Settings file path
local SETTINGS_FILE = "Ken_HUB_Settings.json"

_G.saveSettings = function()
    pcall(function()
        local settings = {
            ESP = {
                PlayerESP = CONFIG.ESP.PlayerESP,
                PlotESP = CONFIG.ESP.PlotESP,
                BrainrotESP = CONFIG.ESP.BrainrotESP,
            },
            Movement = {
                Speed = CONFIG.Movement.Speed,
                MaxSpeed = CONFIG.Movement.MaxSpeed,
                JumpPower = CONFIG.Movement.JumpPower,
                Float = CONFIG.Movement.Float,
                Rise = CONFIG.Movement.Rise,
                Helicopter = CONFIG.Movement.Helicopter,
                GrappleFlight = CONFIG.Movement.GrappleFlight,
                InfiniteJump = CONFIG.Movement.InfiniteJump,
            },
            Automation = CONFIG.Automation,
            UI = CONFIG.UI,
            Colors = CONFIG.Colors,
            AntiKick = CONFIG.AntiKick,
            OpenCircularToggles = {},  -- Save open draggable toggle positions
            ToggleStates = _G.SavedToggleStates or {}  -- Save toggle states
        }
        -- Serialize OpenCircularToggles (UDim2 to table)
        for name, pos in pairs(_G.OpenCircularToggles) do
            settings.OpenCircularToggles[name] = {
                XScale = pos.X.Scale,
                XOffset = pos.X.Offset,
                YScale = pos.Y.Scale,
                YOffset = pos.Y.Offset
            }
        end
        local json = HttpService:JSONEncode(settings)
        if _G.safeWriteFile(SETTINGS_FILE, json) then
        print("💾 Settings saved successfully")
        else
            print("❌ Failed to save settings - using memory only")
        end
    end)
end

_G.loadSettings = function()
    pcall(function()
        if _G.safeIsFile("Ken_HUB_Settings.json") then
            print("📁 Loading settings from file...")
            local fileContent = _G.safeReadFile("Ken_HUB_Settings.json")
            if not fileContent then
                print("❌ Failed to read settings file - using defaults")
                return
            end
            local settings = HttpService:JSONDecode(fileContent)
            
            -- Load CONFIG values (safely, only if not nil)
            if settings.Movement then
                for key, value in pairs(settings.Movement) do
                    if CONFIG.Movement[key] and value ~= nil then
                        CONFIG.Movement[key] = value
                    end
                end
                -- Explicitly load Rise sub-properties with defaults
                if settings.Movement.Rise then
                    CONFIG.Movement.Rise.Enabled = settings.Movement.Rise.Enabled or false
                    CONFIG.Movement.Rise.Speed = settings.Movement.Rise.Speed or 5
                    CONFIG.Movement.Rise.MaxHeight = settings.Movement.Rise.MaxHeight or 500
                end
            end
            if settings.ESP then
                for key, value in pairs(settings.ESP) do
                    if CONFIG.ESP[key] and value ~= nil then
                        CONFIG.ESP[key] = value
                    end
                end
            end
            if settings.Automation and settings.Automation.PetSnipe then
                if not CONFIG.Automation then CONFIG.Automation = {} end
                if not CONFIG.Automation.PetSnipe then CONFIG.Automation.PetSnipe = {} end
                for key, value in pairs(settings.Automation.PetSnipe) do
                    if value ~= nil then
                        CONFIG.Automation.PetSnipe[key] = value
                    end
                end
            end
            if settings.Colors then
                for key, value in pairs(settings.Colors) do
                    if CONFIG.Colors[key] and value ~= nil then
                        CONFIG.Colors[key] = value
                    end
                end
            end
            if settings.UI then
                for key, value in pairs(settings.UI) do
                    if value ~= nil then
                        CONFIG.UI[key] = value
                    end
                end
            end
            if settings.AntiKick and settings.AntiKick ~= nil then
                CONFIG.AntiKick = settings.AntiKick
            end
            
            -- Load OpenCircularToggles (deserialize to UDim2)
            if settings.OpenCircularToggles then
                _G.OpenCircularToggles = {}
                for name, posTable in pairs(settings.OpenCircularToggles) do
                    _G.OpenCircularToggles[name] = UDim2.new(posTable.XScale, posTable.XOffset, posTable.YScale, posTable.YOffset)
                end
            end
            
            -- Restore toggle states
            if settings.ToggleStates then
                _G.ESP_Enabled = settings.ToggleStates.PlayerESP or false
                _G.PlotESP_Enabled = settings.ToggleStates.PlotESP or false
                _G.PlotTimeESP_Enabled = settings.ToggleStates.PlotTimeESP or true
                _G.ServerHopActive = settings.ToggleStates.ServerHop or false
                CONFIG.Movement.Float.Enabled = settings.ToggleStates.Float or false
                CONFIG.Movement.Helicopter.Enabled = settings.ToggleStates.Helicopter or false
                if not CONFIG.AntiKick then CONFIG.AntiKick = {Enabled = false} end
                CONFIG.AntiKick.Enabled = settings.ToggleStates.AntiKick or false
                
                -- Store ALL toggle states for later restoration after UI creation (optimized)
                _G.SavedToggleStates = {
                    PlayerESP = settings.ToggleStates.PlayerESP or false,
                    PlotESP = settings.ToggleStates.PlotESP or false,
                    PlotTimeESP = settings.ToggleStates.PlotTimeESP or true,
                    BrainrotESP = settings.ToggleStates.BrainrotESP or false,
                    Invisibility = settings.ToggleStates.Invisibility or false,
                    Rise = settings.ToggleStates.Rise or false,
                    ServerHop = settings.ToggleStates.ServerHop or false,
                    Jump = settings.ToggleStates.Jump or false,
                    Speed = settings.ToggleStates.Speed or false,
                    HeightBypass = settings.ToggleStates.HeightBypass or false,
                    TallMode = settings.ToggleStates.TallMode or false,
                    Fling = settings.ToggleStates.Fling or false,
                    Helicopter = settings.ToggleStates.Helicopter or false,
                    Float = settings.ToggleStates.Float or false,
                    LaserCape = settings.ToggleStates.LaserCape or false,
                    AntiKick = settings.ToggleStates.AntiKick or false,
                    RagdollDesync = settings.ToggleStates.RagdollDesync or false,
                    PetSnipe = settings.ToggleStates.PetSnipe or false
                }
            end
            print("✅ Settings loaded successfully!")
        else
            print("📁 No settings file found, using defaults")
        end
    end)
end

-- Comprehensive CONFIG validation and initialization
local function validateCONFIG()
    -- Ensure Colors table exists and has all required values
    if not CONFIG.Colors then CONFIG.Colors = {} end
    CONFIG.Colors.Background = CONFIG.Colors.Background or Color3.fromRGB(18, 18, 18)
    CONFIG.Colors.Sidebar = CONFIG.Colors.Sidebar or Color3.fromRGB(22, 22, 22)
    CONFIG.Colors.Panel = CONFIG.Colors.Panel or Color3.fromRGB(28, 28, 28)
    CONFIG.Colors.Stroke = CONFIG.Colors.Stroke or Color3.fromRGB(50, 50, 50)
    CONFIG.Colors.Text = CONFIG.Colors.Text or Color3.fromRGB(240, 240, 240)
    CONFIG.Colors.SubText = CONFIG.Colors.SubText or Color3.fromRGB(160, 160, 160)
    CONFIG.Colors.Accent = CONFIG.Colors.Accent or Color3.fromRGB(14, 144, 210)
    CONFIG.Colors.Hover = CONFIG.Colors.Hover or Color3.fromRGB(40, 40, 40)
    CONFIG.Colors.Danger = CONFIG.Colors.Danger or Color3.fromRGB(220, 70, 70)
    CONFIG.Colors.SwitchOff = CONFIG.Colors.SwitchOff or Color3.fromRGB(70, 70, 70)
    CONFIG.Colors.SwitchOn = CONFIG.Colors.SwitchOn or Color3.fromRGB(14, 144, 210)
    CONFIG.Colors.SectionHeader = CONFIG.Colors.SectionHeader or Color3.fromRGB(38, 38, 38)
    CONFIG.Colors.ESPHighlight = CONFIG.Colors.ESPHighlight or Color3.fromRGB(255, 0, 0)
    CONFIG.Colors.PlotESPHighlight = CONFIG.Colors.PlotESPHighlight or Color3.fromRGB(0, 255, 0)
    CONFIG.Colors.BrainrotESPHighlight = CONFIG.Colors.BrainrotESPHighlight or Color3.fromRGB(0, 0, 255)
    
    -- Ensure UI table exists and has all required values
    if not CONFIG.UI then CONFIG.UI = {} end
    CONFIG.UI.CornerRadius = CONFIG.UI.CornerRadius or UDim.new(0, 10)
    CONFIG.UI.AnimationSpeed = CONFIG.UI.AnimationSpeed or 0.2
    CONFIG.UI.FrameSize = CONFIG.UI.FrameSize or UDim2.new(0, 580, 0, 380)
    CONFIG.UI.SidebarWidth = CONFIG.UI.SidebarWidth or 140
    CONFIG.UI.MinimizedSize = CONFIG.UI.MinimizedSize or UDim2.new(0, 580, 0, 40)
    CONFIG.UI.SettingsFrameSize = CONFIG.UI.SettingsFrameSize or UDim2.new(0, 400, 0, 300)
    CONFIG.UI.TextSize = CONFIG.UI.TextSize or 14
    CONFIG.UI.TitleTextSize = CONFIG.UI.TitleTextSize or 18
    CONFIG.UI.HeaderTextSize = CONFIG.UI.HeaderTextSize or 15
    CONFIG.UI.ButtonTextSize = CONFIG.UI.ButtonTextSize or 14
    CONFIG.UI.IsMinimized = CONFIG.UI.IsMinimized or false
    CONFIG.UI.SettingsOpen = CONFIG.UI.SettingsOpen or false
    CONFIG.UI.CurrentTab = CONFIG.UI.CurrentTab or "Movement"
    CONFIG.UI.InputTextSize = CONFIG.UI.InputTextSize or 14
    CONFIG.UI.Font = CONFIG.UI.Font or Enum.Font.Gotham
    CONFIG.UI.TitleFont = CONFIG.UI.TitleFont or Enum.Font.GothamBold
    CONFIG.UI.HeaderFont = CONFIG.UI.HeaderFont or Enum.Font.GothamBold
    CONFIG.UI.ButtonFont = CONFIG.UI.ButtonFont or Enum.Font.GothamMedium
    CONFIG.UI.InputFont = CONFIG.UI.InputFont or Enum.Font.Gotham
    CONFIG.UI.Transparency = CONFIG.UI.Transparency or 0
    CONFIG.UI.BackgroundTransparency = CONFIG.UI.BackgroundTransparency or 0
    CONFIG.UI.StrokeTransparency = CONFIG.UI.StrokeTransparency or 0.4
    CONFIG.UI.HoverTransparency = CONFIG.UI.HoverTransparency or 0.1
    CONFIG.UI.ActiveTransparency = CONFIG.UI.ActiveTransparency or 0.2
    
    -- Ensure ESP table exists and has all required values
    if not CONFIG.ESP then CONFIG.ESP = {} end
    if not CONFIG.ESP.PlayerESP then CONFIG.ESP.PlayerESP = {} end
    CONFIG.ESP.PlayerESP.HighlightColor = CONFIG.ESP.PlayerESP.HighlightColor or Color3.fromRGB(255, 0, 0)
    CONFIG.ESP.PlayerESP.UsernameColor = CONFIG.ESP.PlayerESP.UsernameColor or Color3.fromRGB(255, 255, 255)
    CONFIG.ESP.PlayerESP.DistanceColor = CONFIG.ESP.PlayerESP.DistanceColor or Color3.fromRGB(255, 255, 255)
    CONFIG.ESP.PlayerESP.ItemColor = CONFIG.ESP.PlayerESP.ItemColor or Color3.fromRGB(255, 255, 255)
    CONFIG.ESP.PlayerESP.OutlineColor = CONFIG.ESP.PlayerESP.OutlineColor or Color3.fromRGB(0, 0, 0)
    CONFIG.ESP.PlayerESP.OutlineTransparency = CONFIG.ESP.PlayerESP.OutlineTransparency or 0.4
    CONFIG.ESP.PlayerESP.FillTransparency = CONFIG.ESP.PlayerESP.FillTransparency or 1
    
    if not CONFIG.ESP.PlotESP then CONFIG.ESP.PlotESP = {} end
    CONFIG.ESP.PlotESP.HighlightColor = CONFIG.ESP.PlotESP.HighlightColor or Color3.fromRGB(0, 255, 0)
    CONFIG.ESP.PlotESP.OwnerColor = CONFIG.ESP.PlotESP.OwnerColor or Color3.fromRGB(255, 255, 255)
    CONFIG.ESP.PlotESP.DistanceColor = CONFIG.ESP.PlotESP.DistanceColor or Color3.fromRGB(255, 255, 255)
    CONFIG.ESP.PlotESP.TimeColor = CONFIG.ESP.PlotESP.TimeColor or Color3.fromRGB(160, 160, 160)
    CONFIG.ESP.PlotESP.OutlineColor = CONFIG.ESP.PlotESP.OutlineColor or Color3.fromRGB(0, 0, 0)
    CONFIG.ESP.PlotESP.OutlineTransparency = CONFIG.ESP.PlotESP.OutlineTransparency or 0.4
    CONFIG.ESP.PlotESP.FillTransparency = CONFIG.ESP.PlotESP.FillTransparency or 1
    
    if not CONFIG.ESP.BrainrotESP then CONFIG.ESP.BrainrotESP = {} end
    CONFIG.ESP.BrainrotESP.Enabled = CONFIG.ESP.BrainrotESP.Enabled or false
    CONFIG.ESP.BrainrotESP.TextSize = CONFIG.ESP.BrainrotESP.TextSize or 20
    CONFIG.ESP.BrainrotESP.DistanceTextSize = CONFIG.ESP.BrainrotESP.DistanceTextSize or 16
    CONFIG.ESP.BrainrotESP.UsernameColor = CONFIG.ESP.BrainrotESP.UsernameColor or Color3.fromRGB(255, 215, 0)
    CONFIG.ESP.BrainrotESP.DistanceColor = CONFIG.ESP.BrainrotESP.DistanceColor or Color3.fromRGB(255, 255, 255)
    CONFIG.ESP.BrainrotESP.HighlightColor = CONFIG.ESP.BrainrotESP.HighlightColor or Color3.fromRGB(0, 0, 255)
    CONFIG.ESP.BrainrotESP.OutlineColor = CONFIG.ESP.BrainrotESP.OutlineColor or Color3.fromRGB(0, 0, 0)
    CONFIG.ESP.BrainrotESP.FillTransparency = CONFIG.ESP.BrainrotESP.FillTransparency or 0.5
    
    if not CONFIG.Automation then CONFIG.Automation = {} end
    if not CONFIG.Automation.PetSnipe then CONFIG.Automation.PetSnipe = {} end
    CONFIG.Automation.PetSnipe.Enabled = CONFIG.Automation.PetSnipe.Enabled or false
    CONFIG.Automation.PetSnipe.MinGeneration = CONFIG.Automation.PetSnipe.MinGeneration or 100e6
    CONFIG.Automation.PetSnipe.DeliveryDelay = CONFIG.Automation.PetSnipe.DeliveryDelay or 2.5
    CONFIG.Automation.PetSnipe.ScanInterval = CONFIG.Automation.PetSnipe.ScanInterval or 1.5
    CONFIG.Automation.PetSnipe.StealCooldown = CONFIG.Automation.PetSnipe.StealCooldown or 4
    CONFIG.Automation.PetSnipe.MinTier = CONFIG.Automation.PetSnipe.MinTier or "Rare"
    CONFIG.Automation.PetSnipe.UseMinGeneration = CONFIG.Automation.PetSnipe.UseMinGeneration ~= false
    if not CONFIG.Automation.PetSnipe.Rarities then
        CONFIG.Automation.PetSnipe.Rarities = {
            common = false, uncommon = false, rare = true, epic = true,
            legendary = true, mythic = true, secret = true, celestial = true,
            divine = true, og = true, god = true, limited = true, exclusive = true,
        }
    end
    
    -- Legacy: BrainrotESP yanlislikla Movement altinda kaydedilmisse tasi
    if CONFIG.Movement and CONFIG.Movement.BrainrotESP and not CONFIG.ESP.BrainrotESP.Enabled then
        for key, value in pairs(CONFIG.Movement.BrainrotESP) do
            if CONFIG.ESP.BrainrotESP[key] == nil then
                CONFIG.ESP.BrainrotESP[key] = value
            end
        end
        CONFIG.Movement.BrainrotESP = nil
    end
    
    -- Ensure Movement table exists and has all required values
    if not CONFIG.Movement then CONFIG.Movement = {} end
    if not CONFIG.Movement.Float then CONFIG.Movement.Float = {} end
    CONFIG.Movement.Float.Enabled = CONFIG.Movement.Float.Enabled or false
    CONFIG.Movement.Float.DescentSpeed = CONFIG.Movement.Float.DescentSpeed or 4
    CONFIG.Movement.Float.VelocityBlend = CONFIG.Movement.Float.VelocityBlend or 1
    
    if not CONFIG.Movement.Helicopter then CONFIG.Movement.Helicopter = {} end
    CONFIG.Movement.Helicopter.Enabled = CONFIG.Movement.Helicopter.Enabled or false
    CONFIG.Movement.Helicopter.RotationSpeed = CONFIG.Movement.Helicopter.RotationSpeed or 50
    
    if not CONFIG.Movement.GrappleFlight then CONFIG.Movement.GrappleFlight = {} end
    CONFIG.Movement.GrappleFlight.Enabled = CONFIG.Movement.GrappleFlight.Enabled or false
    CONFIG.Movement.GrappleFlight.Speed = CONFIG.Movement.GrappleFlight.Speed or 150
    
    if not CONFIG.Movement.InfiniteJump then CONFIG.Movement.InfiniteJump = {} end
    CONFIG.Movement.InfiniteJump.Enabled = CONFIG.Movement.InfiniteJump.Enabled or false
    CONFIG.Movement.InfiniteJump.JumpPower = CONFIG.Movement.InfiniteJump.JumpPower or 42
    CONFIG.Movement.InfiniteJump.Cooldown = CONFIG.Movement.InfiniteJump.Cooldown or 0.2
    
    if not CONFIG.Movement.Rise then CONFIG.Movement.Rise = {} end
    CONFIG.Movement.Rise.Enabled = CONFIG.Movement.Rise.Enabled or false
    CONFIG.Movement.Rise.Speed = CONFIG.Movement.Rise.Speed or 5
    CONFIG.Movement.Rise.MaxHeight = CONFIG.Movement.Rise.MaxHeight or 500
    
end

-- Initialize CONFIG defaults before loading
validateCONFIG()

-- Load settings on startup
_G.loadSettings()

-- Re-validate CONFIG after loading to ensure no corruption
validateCONFIG()

-- Function to save UI state and ALL toggle states
_G.saveUIState = function()
    pcall(function()
        -- Initialize SavedToggleStates if not exists
        if not _G.SavedToggleStates then
            _G.SavedToggleStates = {}
        end
        
        -- Save ALL toggle states (optimized with table lookup to reduce local variables)
        local switchMap = {
            PlayerESP = playerESPSwitch,
            PlotESP = plotESPSwitch,
            BrainrotESP = brainrotESPSwitch,
            Invisibility = invisibilitySwitch,
            Jump = jumpSwitch,
            Speed = speedSwitch,
            HeightBypass = unhittableSwitchInstance,
            TallMode = resizeSwitchInstance,
            Fling = flingSwitchInstance,
            Helicopter = helicopterSwitch,
            GrappleFlight = grappleFlightSwitch,
            InfiniteJump = infiniteJumpSwitch,
            Float = floatSwitch,
            Rise = platformSwitch,
            AntiKick = antiKickSwitch,
            LaserCape = originalLaserCapeSwitch,
            RagdollDesync = ragdollDesyncSwitch,
            ServerHop = serverHopSwitch,
            PetSnipe = petSnipeSwitch
        }
        
        -- Global ESP switches (override local ones if they exist)
        if _G.playerESPSwitch and _G.playerESPSwitch.get then
            switchMap.PlayerESP = _G.playerESPSwitch
        end
        if _G.plotESPSwitch and _G.plotESPSwitch.get then
            switchMap.PlotESP = _G.plotESPSwitch
        end
        
        for stateName, switch in pairs(switchMap) do
            if switch and switch.get then
                _G.SavedToggleStates[stateName] = switch.get()
                if stateName == "Rise" then
                    print("💾 Saving Platform state:", switch.get())
                end
            elseif stateName == "Rise" then
            print("⚠️ Platform switch not found for saving")
        end
        end
        
        -- Save UI state
        if mainFrame then
            CONFIG.UI.IsMinimized = isMinimized or false
        end
        if settingsFrame then
            CONFIG.UI.SettingsOpen = settingsFrame.Visible or false
        end
        CONFIG.UI.CurrentTab = activeSection or "Movement"
        
        _G.saveSettings()
    end)
end
-- Duplicate function removed - using the second createCircularToggleUI function

_G.applyLoadedToggleStates = function()
    pcall(function()
        -- Add a short delay to ensure all switches are initialized (fix for re-execute timing)
        task.wait(0.5)
        
        print("🔄 Restoring toggle states...")
        print("📁 SavedToggleStates exists:", _G.SavedToggleStates ~= nil)
        
            -- Map toggle names to their actual get/set handlers so reopened toggles still function correctly
            local function resolveToggleHandlers(name)
                if name == "Speed" then
                    return function() return speedSwitch and speedSwitch.get and speedSwitch.get() or false end,
                           function(state) if speedSwitch and speedSwitch.set then speedSwitch.set(state) end end
                elseif name == "Jump" then
                    return function() return jumpSwitch and jumpSwitch.get and jumpSwitch.get() or false end,
                           function(state) if jumpSwitch and jumpSwitch.set then jumpSwitch.set(state) end end
                elseif name == "Float" then
                    return function() return CONFIG.Movement.Float.Enabled end,
                           function(state) CONFIG.Movement.Float.Enabled = state; _G.saveSettings(); if state and player.Character then enableFloat(player.Character) end end
            elseif name == "Rise" or name == "Platform" then
                    return function() return CONFIG.Movement.Rise.Enabled end,
                       function(state) CONFIG.Movement.Rise.Enabled = state; _G.saveSettings(); if state and player.Character then enablePlatform(player.Character) end end
                elseif name == "Helicopter" then
                    return function() return CONFIG.Movement.Helicopter.Enabled end,
                           function(state) CONFIG.Movement.Helicopter.Enabled = state; _G.saveSettings(); if state and player.Character then enableHelicopter(player.Character) end end
                elseif name == "Invisibility" then
                    return function() return invisibilitySwitch and invisibilitySwitch.get and invisibilitySwitch.get() or false end,
                           function(state) if invisibilitySwitch and invisibilitySwitch.set then invisibilitySwitch.set(state) end end
                elseif name == "Player ESP" then
                    return function() return _G.ESP_Enabled end,
                           function(state) if state then enableESP() else disableESP() end end
                elseif name == "Plot ESP" then
                    return function() return _G.PlotESP_Enabled end,
                           function(state) if state then enablePlotESP() else disablePlotESP() end end
                elseif name == "Grapple Flight" then
                    return function() return CONFIG.Movement.GrappleFlight.Enabled end,
                           function(state) CONFIG.Movement.GrappleFlight.Enabled = state; _G.saveSettings(); if state and player.Character then enableGrappleFlight(player.Character) end end
                elseif name == "Infinite Jump" then
                    return function() return CONFIG.Movement.InfiniteJump.Enabled end,
                           function(state) CONFIG.Movement.InfiniteJump.Enabled = state; _G.saveSettings(); if state and player.Character then enableInfiniteJump(player.Character) end end
                elseif name == "Brainrot ESP" then
                    return function() return CONFIG.ESP.BrainrotESP.Enabled end,
                           function(state) CONFIG.ESP.BrainrotESP.Enabled = state; _G.saveSettings(); if state then enableBrainrotESP() else disableBrainrotESP() end end
                elseif name == "Mobile Desync" then
                    return function() return _G.mobileDesyncEnabled end,
                           function(state) _G.mobileDesyncEnabled = state end
                elseif name == "Pet Snipe" then
                    return function() return CONFIG.Automation.PetSnipe.Enabled end,
                           function(state) CONFIG.Automation.PetSnipe.Enabled = state; _G.saveSettings(); if state then enablePetSnipe() else disablePetSnipe() end end
                end
                -- Default no-op handlers
                return function() return false end, function(_) end
            end

        if _G.SavedToggleStates then
            print("📁 Found saved toggle states:", _G.SavedToggleStates)
            
            -- Optimized toggle restoration with table lookup
            local restoreMap = {
                PlayerESP = {switch = playerESPSwitch, name = "Player ESP"},
                PlotESP = {switch = plotESPSwitch, name = "Plot ESP"},
                BrainrotESP = {switch = brainrotESPSwitch, name = "Brainrot ESP"},
                Invisibility = {switch = invisibilitySwitch, name = "Invisibility"},
                Jump = {switch = jumpSwitch, name = "Jump"},
                Speed = {switch = speedSwitch, name = "Speed"},
                HeightBypass = {switch = unhittableSwitchInstance, name = "Height Bypass"},
                TallMode = {switch = resizeSwitchInstance, name = "Tall Mode"},
                Fling = {switch = flingSwitchInstance, name = "Fling"},
                Rise = {switch = platformSwitch, name = "Platform"},
                Helicopter = {switch = helicopterSwitch, name = "Helicopter"},
                GrappleFlight = {switch = grappleFlightSwitch, name = "Grapple Flight"},
                InfiniteJump = {switch = infiniteJumpSwitch, name = "Infinite Jump"},
                Float = {switch = floatSwitch, name = "Float"},
                AntiKick = {switch = antiKickSwitch, name = "Anti-Kick"},
                LaserCape = {switch = originalLaserCapeSwitch, name = "Laser Cape"},
                RagdollDesync = {switch = ragdollDesyncSwitch, name = "Ragdoll Desync"},
                ServerHop = {switch = serverHopSwitch, name = "Server Hop"},
                PetSnipe = {switch = petSnipeSwitch, name = "Pet Snipe"}
            }
            
            -- Global ESP switches (override local ones if they exist)
            if _G.playerESPSwitch and _G.playerESPSwitch.set then
                restoreMap.PlayerESP = {switch = _G.playerESPSwitch, name = "Player ESP"}
            end
            if _G.plotESPSwitch and _G.plotESPSwitch.set then
                restoreMap.PlotESP = {switch = _G.plotESPSwitch, name = "Plot ESP"}
            end
            
            -- Set switches to their saved states AND create side toggles
            for stateName, data in pairs(restoreMap) do
                if data.switch and data.switch.set and _G.SavedToggleStates[stateName] then
                    print("✅ Setting " .. data.name .. " to enabled")
                    data.switch.set(true)
                    
                    -- Create side toggle for enabled switches
                    local getHandler, setHandler = resolveToggleHandlers(data.name)
                    if getHandler and setHandler then
                        pcall(function()
                            _G.createCircularToggleUI(data.name, getHandler, setHandler)
                            print("🎯 Created side toggle for: " .. data.name)
                        end)
                    end
                end
            end
        else
            print("❌ No saved toggle states found")
        end
        print("✅ Toggle restoration complete!")
        
        -- Restore UI state
        if CONFIG.UI.IsMinimized and mainFrame then
            mainFrame.Size = CONFIG.UI.MinimizedSize
            isMinimized = true
        end
        if CONFIG.UI.SettingsOpen and settingsFrame then
            settingsFrame.Visible = true
        end
        if CONFIG.UI.CurrentTab and sections[CONFIG.UI.CurrentTab] then
            activeSection = CONFIG.UI.CurrentTab
            for name, section in pairs(sections) do
                section.Visible = (name == CONFIG.UI.CurrentTab)
            end
            -- Update sidebar button colors
            for _, button in pairs(sidebar:GetChildren()) do
                if button:IsA("TextButton") and button.Name:match("Button$") then
                    local sectionName = button.Name:gsub("Button", "")
                    if sectionName == CONFIG.UI.CurrentTab then
                        button.BackgroundColor3 = CONFIG.Colors.Accent
                    else
                        button.BackgroundColor3 = CONFIG.Colors.Sidebar
                    end
                end
                end
            end

            -- Initialize other features after toggles are recreated. Wrap in pcalls to avoid aborting this thread.
        task.delay(2.0, function() -- Increased delay to ensure character is fully ready
            print("🔄 Reinitializing enabled features...")
            
            -- Wait for character to be fully loaded
            if not player.Character then
                print("⏳ Waiting for character to spawn...")
                player.CharacterAdded:Wait()
            end
            
            task.wait(1.0) -- Additional wait for character to be ready
            
            pcall(function()
                if _G.ESP_Enabled then 
                    print("🔄 Reinitializing Player ESP...")
                    enableESP() 
                    
                    -- Refresh Player ESP colors
                    task.wait(0.5)
                    for plr, data in pairs(_G.ESP_Data) do
                        if typeof(plr) == "Instance" and data.highlight and plr.Character then
                            pcall(function() 
                                data.highlight.FillColor = CONFIG.ESP.PlayerESP.HighlightColor
                                data.highlight.OutlineColor = CONFIG.ESP.PlayerESP.HighlightColor
                                print("🎨 Refreshed Player ESP color for: " .. plr.Name)
                            end)
                        end
                    end
                end
            end)
            
            pcall(function()
                if _G.PlotESP_Enabled then 
                    print("🔄 Reinitializing Plot ESP...")
                    enablePlotESP() 
                end
            end)
            
            pcall(function()
                if _G.PlotTimeESP_Enabled then 
                    print("🔄 Reinitializing Plot Time ESP...")
                    enablePlotTimeESP() 
                end
            end)
            
            pcall(function()
                if CONFIG.ESP.BrainrotESP.Enabled then 
                    print("🔄 Reinitializing Brainrot ESP...")
                    enableBrainrotESP() 
                end
            end)
            
            pcall(function()
                if CONFIG.Automation.PetSnipe.Enabled then
                    print("🔄 Reinitializing Pet Snipe...")
                    enablePetSnipe()
                end
            end)
            
            pcall(function()
                if _G.ServerHopActive then 
                    print("🔄 Reinitializing Server Hop...")
                    _G.toggleServerHop(true) 
                end
            end)
            
            pcall(function()
                if CONFIG.Movement.Float.Enabled and player.Character then 
                    print("🔄 Reinitializing Float...")
                    enableFloat(player.Character) 
                end
            end)
            
            pcall(function()
                if CONFIG.Movement.Helicopter.Enabled and player.Character then 
                    print("🔄 Reinitializing Helicopter...")
                    enableHelicopter(player.Character) 
                end
            end)
            
            pcall(function()
                if CONFIG.AntiKick.Enabled then 
                    print("🔄 Reinitializing Anti-Kick...")
                    enableAntiKick() 
                end
            end)
            
            pcall(function()
                if _G.mobileDesyncEnabled then 
                    print("🔄 Reinitializing Mobile Desync...")
                    enableMobileDesync() 
                end
            end)
            
                -- Re-enable movement features
            pcall(function()
                if _G.SavedToggleStates.Rise and player.Character then 
                    print("🔄 Reinitializing Platform...")
                    enablePlatform(player.Character) 
                end
            end)
            
            pcall(function()
                if _G.SavedToggleStates.Jump and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                    print("🔄 Reinitializing Jump Power...")
                    local hum = player.Character:FindFirstChildOfClass("Humanoid")
                    hum.UseJumpPower = true
                    hum.JumpPower = CONFIG.Movement.JumpPower
                end
            end)
            
            pcall(function()
                if _G.SavedToggleStates.Speed and player.Character then 
                    print("🔄 Reinitializing Speed...")
                    enableSpeed(player.Character) 
                end
            end)
            
            pcall(function()
                if _G.SavedToggleStates.Invisibility and player.Character then 
                    print("🔄 Reinitializing Invisibility...")
                    task.wait(0.5) -- Wait for character to be ready
                    setInvisibility(true) 
                end
            end)
            
            pcall(function()
                if _G.SavedToggleStates.HeightBypass and player.Character then 
                    print("🔄 Reinitializing Height Bypass...")
                    enableHeightBypass(player.Character) 
                end
            end)
            
            pcall(function()
                if _G.SavedToggleStates.TallMode and player.Character then 
                    print("🔄 Reinitializing Tall Mode...")
                    enableTallMode(player.Character) 
                end
            end)
            
            pcall(function()
                if _G.SavedToggleStates.Fling and player.Character then 
                    print("🔄 Reinitializing Fling...")
                    enableFling(player.Character) 
                end
            end)
            
            pcall(function()
                if _G.SavedToggleStates.GrappleFlight and player.Character then 
                    print("🔄 Reinitializing Grapple Flight...")
                    enableGrappleFlight(player.Character) 
                end
            end)
            
            pcall(function()
                if _G.SavedToggleStates.InfiniteJump and player.Character then 
                    print("🔄 Reinitializing Infinite Jump...")
                    enableInfiniteJump(player.Character) 
                end
            end)
            
            pcall(function()
                if _G.SavedToggleStates.LaserCape and player.Character then 
                    print("🔄 Reinitializing Laser Cape...")
                    enableLaserCape(player.Character) 
                end
            end)
            
            pcall(function()
                if _G.SavedToggleStates.RagdollDesync and player.Character then 
                    print("🔄 Reinitializing Ragdoll Desync...")
                    enableRagdollDesync(player.Character) 
                end
            end)
            
            print("✅ Feature reinitialization complete!")
        end)
        end)
end

--=========================================================
-- Safe UI Parent
--=========================================================
local function getSafeUiParent()
    return _G.getKenHubGuiParent()
end

local function parentScreenGui(gui)
    if not gui then return false end
    gui.Parent = _G.getKenHubGuiParent()
    return gui.Parent ~= nil
end

-- Helper function to create protected ScreenGui
local function createProtectedScreenGui(name, displayOrder)
    _G.screenGui = _G.createMobileCompatibleGui(name)
    if not _G.screenGui then
        _G.screenGui = Instance.new("ScreenGui")
        _G.screenGui.Name = name
        _G.screenGui.ResetOnSpawn = false
        _G.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        parentScreenGui(_G.screenGui)
    end
    _G.screenGui.DisplayOrder = displayOrder or 999999
    _G.screenGui.Enabled = true
    _G.optimizeForMobile(_G.screenGui)
    return _G.screenGui
end

-- Helper function to protect individual GUI elements (Delta'da syn.protect_gui yok)
local function protectGuiElement(element)
    pcall(function()
        if element and element.SetAttribute then
            element:SetAttribute("Protected", true)
        end
    end)
end

--=========================================================
-- UI Configuration
--=========================================================
local namePrefix = "KenHub_"

--=========================================================
-- Character Essentials (GUI'yi bloklamamak icin bekleme yok)
--=========================================================
local character = player.Character
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid", 10)
    humanoidRootPart = char:WaitForChild("HumanoidRootPart", 10)
end)

-- Packages and Events
local UseItemEvent
local success, result = pcall(function()
    local packages = ReplicatedStorage:WaitForChild("Packages", 5)
    if packages then
        UseItemEvent = packages:FindFirstChild("Net") and packages.Net:FindFirstChild("RE/UseItem")
    end
    return UseItemEvent
end)
if not success or not result then
    warn("Failed to load packages or UseItemEvent: unsupported or missing")
end

--=========================================================
-- Helper Functions
--=========================================================
local function findPlayerPlot()
    local success, plot = pcall(function()
        local plotsFolder = workspace:FindFirstChild("Plots")
        if not plotsFolder then return nil end
        for _, p in ipairs(plotsFolder:GetChildren()) do
            local yourBase = p:FindFirstChild("YourBase", true)
            if yourBase and (yourBase:IsA("GuiObject") or yourBase:IsA("BillboardGui")) and yourBase.Enabled then
                return p
            end
        end
        for _, p in ipairs(plotsFolder:GetChildren()) do
            local plotSign = p:FindFirstChild("PlotSign")
            if plotSign then
                local surfaceGui = plotSign:FindFirstChild("SurfaceGui")
                local frame = surfaceGui and surfaceGui:FindFirstChild("Frame")
                local textLabel = frame and frame:FindFirstChild("TextLabel")
                if textLabel and textLabel:IsA("TextLabel") and string.find(textLabel.Text, username, 1, true) then
                    return p
                end
            end
        end
        return nil
    end)
    if not success or not plot then
        warn("Could not find player plot: unsupported or error occurred")
        return nil
    end
    return plot
end
local playerPlot = findPlayerPlot()

local function getPlotOwner(plot)
    local success, owner = pcall(function()
        local plotSign = plot:FindFirstChild("PlotSign")
        if not plotSign then return nil end
        local surfaceGui = plotSign:FindFirstChild("SurfaceGui")
        local frame = surfaceGui and surfaceGui:FindFirstChild("Frame")
        local textLabel = frame and frame:FindFirstChild("TextLabel")
        if textLabel and textLabel:IsA("TextLabel") then
            return textLabel.Text
        end
        return nil
    end)
    if not success then
        return nil
    end
    return owner
end

local function getRemainingTime(plot)
    local success, timeText = pcall(function()
        -- Try the original path first
        local purchases = plot:FindFirstChild("Purchases")
        if purchases then
            local plotBlock = purchases:FindFirstChild("PlotBlock")
            if plotBlock then
                local main = plotBlock:FindFirstChild("Main")
                if main then
                    local billboardGui = main:FindFirstChild("BillboardGui")
                    if billboardGui then
                        local remainingTime = billboardGui:FindFirstChild("RemainingTime")
                        if remainingTime and remainingTime:IsA("TextLabel") then
                            return remainingTime.Text
                        end
                    end
                end
            end
        end

        -- Fallback: Search for BillboardGui in other locations
        local billboardGui = plot:FindFirstChild("BillboardGui", true) -- Recursive search
        if billboardGui then
            local remainingTime = billboardGui:FindFirstChild("RemainingTime")
            if remainingTime and remainingTime:IsA("TextLabel") then
                return remainingTime.Text
            end
        end

        -- Fallback: Check for time in StringValue or IntValue
        for _, obj in ipairs(plot:GetDescendants()) do
            if obj:IsA("StringValue") and obj.Name:lower():match("time") then
                return obj.Value
            elseif obj:IsA("IntValue") and obj.Name:lower():match("time") then
                return tostring(obj.Value) .. "s"
            end
        end

        -- If nothing is found, return a clear message
        return "Time: Unavailable"
    end)
    
    if not success then
        warn("Failed to get remaining time for plot: " .. plot.Name .. " - Error: " .. tostring(timeText))
        return "Time: Error"
    end
    
    return timeText or "Time: Unavailable"
end

--=========================================================
-- Pet Snipe System (configurable rarity catalog)
--=========================================================
local PET_TIER_ORDER = {
    "common", "uncommon", "rare", "epic", "legendary", "mythic",
    "secret", "celestial", "divine", "og", "god", "limited", "exclusive",
}
local PET_TIER_LABELS = {
    common = "Common", uncommon = "Uncommon", rare = "Rare", epic = "Epic",
    legendary = "Legendary", mythic = "Mythic", secret = "Secret",
    celestial = "Celestial", divine = "Divine", og = "OG", god = "God",
    limited = "Limited", exclusive = "Exclusive",
}
local PET_TIER_RANK = {}
for i, tier in ipairs(PET_TIER_ORDER) do
    PET_TIER_RANK[tier] = i
end

local function ensurePetSnipeRarities()
    if not CONFIG.Automation then CONFIG.Automation = {} end
    if not CONFIG.Automation.PetSnipe then CONFIG.Automation.PetSnipe = {} end
    if not CONFIG.Automation.PetSnipe.Rarities then
        CONFIG.Automation.PetSnipe.Rarities = {}
    end
    for _, tier in ipairs(PET_TIER_ORDER) do
        if CONFIG.Automation.PetSnipe.Rarities[tier] == nil then
            CONFIG.Automation.PetSnipe.Rarities[tier] = PET_TIER_RANK[tier] >= (PET_TIER_RANK.rare or 3)
        end
    end
end

function _G.applyPetSnipeMinTier(minTier)
    ensurePetSnipeRarities()
    local rank = PET_TIER_RANK[string.lower(tostring(minTier or "rare"))] or PET_TIER_RANK.rare
    for i, tier in ipairs(PET_TIER_ORDER) do
        CONFIG.Automation.PetSnipe.Rarities[tier] = i >= rank
    end
    CONFIG.Automation.PetSnipe.MinTier = minTier or "Rare"
    if _G.petSnipeRaritySwitches then
        for tier, sw in pairs(_G.petSnipeRaritySwitches) do
            if sw and sw.set then
                sw.set(CONFIG.Automation.PetSnipe.Rarities[tier] == true)
            end
        end
    end
    pcall(function() _G.saveSettings() end)
end

ensurePetSnipeRarities()
if CONFIG.Automation.PetSnipe.MinTier and CONFIG.Automation.PetSnipe.MinTier ~= "Custom" then
    local saved = CONFIG.Automation.PetSnipe.Rarities
    local hasAny = false
    for _, tier in ipairs(PET_TIER_ORDER) do
        if saved[tier] then hasAny = true break end
    end
    if not hasAny then
        _G.applyPetSnipeMinTier(CONFIG.Automation.PetSnipe.MinTier)
    end
end

local DeliveryStealRemote

local function getDeliveryStealRemote()
    if DeliveryStealRemote and DeliveryStealRemote.Parent then
        return DeliveryStealRemote
    end
    pcall(function()
        local net = ReplicatedStorage:WaitForChild("Packages", 8):WaitForChild("Net", 8)
        DeliveryStealRemote = net:FindFirstChild("RE/StealService/DeliverySteal")
            or net:WaitForChild("RE/StealService/DeliverySteal", 5)
    end)
    return DeliveryStealRemote
end

getDeliveryStealRemote()

_G.petSnipeState = {
    enabled = false,
    busy = false,
    thread = nil,
    connections = {},
}

local function parsePetGeneration(text)
    if _G.parseGen then
        return _G.parseGen(text)
    end
    if not text then return 0 end
    text = text:gsub("%$", ""):gsub("/[sS]", ""):gsub(",", "")
    local num = tonumber(text:match("^[%d%.]+")) or 0
    local suffix = text:match("[%a]+")
    local multipliers = {K = 1e3, M = 1e6, B = 1e9, T = 1e12, Qa = 1e15, Qi = 1e18}
    if suffix and multipliers[suffix] then
        return num * multipliers[suffix]
    end
    return num
end

local function isOwnPlot(plot)
    if not plot then return false end
    if plot == playerPlot then return true end
    local yourBase = plot:FindFirstChild("YourBase", true)
    if yourBase and (yourBase:IsA("GuiObject") or yourBase:IsA("BillboardGui")) then
        local enabled = pcall(function() return yourBase.Enabled end) and yourBase.Enabled
        if enabled then return true end
    end
    local owner = getPlotOwner(plot)
    if not owner then return false end
    owner = owner:gsub("[''']s%s*$", ""):gsub("%s+$", "")
    return string.lower(owner) == string.lower(username)
end

local function getPetTierFromOverhead(overhead)
    if not overhead then return nil, 0 end
    local rarityLabel = overhead:FindFirstChild("Rarity") or overhead:FindFirstChild("Mutation")
    if not rarityLabel or not rarityLabel:IsA("TextLabel") then return nil, 0 end
    local text = string.lower(rarityLabel.Text)
    for i = #PET_TIER_ORDER, 1, -1 do
        local tier = PET_TIER_ORDER[i]
        if string.find(text, tier, 1, true) then
            return tier, i
        end
    end
    return nil, 0
end

local function isSnipeTargetPet(overhead)
    if not overhead or not overhead:IsA("BillboardGui") then return false end
    ensurePetSnipeRarities()

    local tier, tierRank = getPetTierFromOverhead(overhead)
    if tier and CONFIG.Automation.PetSnipe.Rarities[tier] then
        return true
    end

    if CONFIG.Automation.PetSnipe.UseMinGeneration ~= false then
        local genLabel = overhead:FindFirstChild("Generation")
        if genLabel and genLabel:IsA("TextLabel") then
            local minGen = CONFIG.Automation.PetSnipe.MinGeneration or 100e6
            if parsePetGeneration(genLabel.Text) >= minGen then
                return true
            end
        end
    end

    return false
end

local function getPodiumFromOverhead(overhead)
    local node = overhead and overhead.Parent
    while node and node ~= workspace do
        if node.Parent and node.Parent.Name == "AnimalPodiums" then
            return node
        end
        node = node.Parent
    end
    return nil
end

local function getPodiumStealPrompt(podium)
    if not podium then return nil end
    local ok, prompt = pcall(function()
        local base = podium:FindFirstChild("Base")
        local spawn = base and base:FindFirstChild("Spawn")
        local attach = spawn and spawn:FindFirstChild("PromptAttachment")
        return attach and attach:FindFirstChildWhichIsA("ProximityPrompt")
    end)
    if ok and prompt then return prompt end
    for _, obj in ipairs(podium:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            return obj
        end
    end
    return nil
end

local function getPodiumStandPart(podium)
    if not podium then return nil end
    local base = podium:FindFirstChild("Base")
    local spawn = base and base:FindFirstChild("Spawn")
    if spawn and spawn:IsA("BasePart") then return spawn end
    return podium:FindFirstChildWhichIsA("BasePart", true)
end

local function getPetModelFromOverhead(overhead)
    local displayName = overhead:FindFirstChild("DisplayName")
    if displayName and displayName:IsA("TextLabel") then
        local parent = overhead.Parent
        for _ = 1, 4 do
            parent = parent and parent.Parent
        end
        for i = 0, 2 do
            local candidate = parent
            for _ = 1, i do
                candidate = candidate and candidate.Parent
            end
            if candidate then
                local child = candidate:FindFirstChild(displayName.Text)
                if child then return child end
            end
        end
    end

    local current = overhead.Parent
    while current and current ~= workspace do
        if current:IsA("Model") and current:FindFirstChildWhichIsA("BasePart", true) then
            return current
        end
        current = current.Parent
    end
    return nil
end

local function getCharacterRoot()
    local char = player.Character
    if not char then return nil, nil end
    return char, char:FindFirstChild("HumanoidRootPart")
end

local function teleportCharacterTo(targetCFrame)
    local _, hrp = getCharacterRoot()
    if hrp and targetCFrame then
        hrp.CFrame = targetCFrame
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
end

local function getBaseDeliveryCFrame(plot)
    if not plot then return nil end

    local hitbox = plot:FindFirstChild("DeliveryHitbox", true)
    if hitbox and hitbox:IsA("BasePart") then
        return hitbox.CFrame + Vector3.new(0, 2, 0)
    end

    local spawn = plot:FindFirstChild("Spawn", true)
    if spawn then
        if spawn:IsA("BasePart") then
            return spawn.CFrame + Vector3.new(0, 3.5, 0)
        end
        local ok, pivot = pcall(function() return spawn:GetPivot() end)
        if ok and pivot then
            return pivot + Vector3.new(0, 3.5, 0)
        end
    end

    local podiums = plot:FindFirstChild("AnimalPodiums")
    local firstPodium = podiums and podiums:FindFirstChild("1")
    if firstPodium then
        local ok, pivot = pcall(function() return firstPodium:GetPivot() end)
        if ok and pivot then
            return pivot + Vector3.new(0, 3.5, 0)
        end
    end

    local ok, pivot = pcall(function() return plot:GetPivot() end)
    if ok and pivot then
        return pivot + Vector3.new(0, 5, 0)
    end
    return nil
end

local function fireStealPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return false end
    local ok = pcall(function()
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = math.max(prompt.MaxActivationDistance, 20)
        if fireproximityprompt then
            fireproximityprompt(prompt, 1)
            task.wait(0.08)
            fireproximityprompt(prompt, 0)
        else
            prompt:InputHoldBegin()
            task.wait(0.25)
            prompt:InputHoldEnd()
        end
    end)
    return ok
end

local function isCarryingPetModel(model, hrp)
    if not model or not hrp then return false end
    if model:IsA("Model") then
        local root = model:FindFirstChild("RootPart") or model:FindFirstChildWhichIsA("BasePart")
        if root then
            for _, w in ipairs(root:GetDescendants()) do
                if w:IsA("WeldConstraint") and w.Part0 == hrp then
                    return true
                end
            end
            for _, w in ipairs(model:GetDescendants()) do
                if w:IsA("WeldConstraint") and w.Part0 == hrp then
                    return true
                end
            end
        end
    end
    return false
end

local function isCarryingStolenPet()
    local _, hrp = getCharacterRoot()
    if not hrp then return false end

    for _, child in ipairs(workspace:GetChildren()) do
        if child ~= hrp.Parent and isCarryingPetModel(child, hrp) then
            return true, child
        end
    end

    for _, obj in ipairs(hrp:GetDescendants()) do
        if obj:IsA("WeldConstraint") and obj.Part0 == hrp and obj.Part1 then
            local parent = obj.Part1.Parent
            if parent and parent ~= hrp.Parent and parent:IsA("Model") then
                return true, parent
            end
        end
    end
    return false
end

local function waitForCarryingPet(timeout)
    local deadline = tick() + timeout
    while tick() < deadline and _G.petSnipeState.enabled do
        local carrying, model = isCarryingStolenPet()
        if carrying then return true, model end
        task.wait(0.05)
    end
    return false
end

local function deliverStolenPetToBase()
    playerPlot = findPlayerPlot() or playerPlot
    if not playerPlot then
        warn("[Pet Snipe] Kendi plot bulunamadi.")
        return false
    end

    local deliveryCFrame = getBaseDeliveryCFrame(playerPlot)
    if deliveryCFrame then
        teleportCharacterTo(deliveryCFrame)
    end

    local delay = (CONFIG.Automation and CONFIG.Automation.PetSnipe and CONFIG.Automation.PetSnipe.DeliveryDelay) or 2.5
    task.wait(delay)

    local remote = getDeliveryStealRemote()
    if remote then
        pcall(function() remote:FireServer() end)
        print("[Pet Snipe] Pet base'e teslim edildi.")
        return true
    end
    warn("[Pet Snipe] DeliverySteal remote bulunamadi.")
    return false
end

local function scanBestSnipeTarget()
    local plotsFolder = workspace:FindFirstChild("Plots")
    if not plotsFolder then return nil end

    local bestScore, bestPodium, bestPlot, bestName, bestValue, bestTier = -1, nil, nil, nil, 0, 0

    for _, plot in ipairs(plotsFolder:GetChildren()) do
        if not isOwnPlot(plot) then
            for _, obj in ipairs(plot:GetDescendants()) do
                if obj.Name == "AnimalOverhead" and obj:IsA("BillboardGui") and isSnipeTargetPet(obj) then
                    local genLabel = obj:FindFirstChild("Generation")
                    local value = genLabel and parsePetGeneration(genLabel.Text) or 0
                    local _, tierRank = getPetTierFromOverhead(obj)
                    local podium = getPodiumFromOverhead(obj)
                    local prompt = getPodiumStealPrompt(podium)
                    if podium and prompt then
                        local score = value + (tierRank * 1e12)
                        if score > bestScore then
                            bestScore = score
                            bestPodium = podium
                            bestPlot = plot
                            bestValue = value
                            bestTier = tierRank
                            local nameLabel = obj:FindFirstChild("DisplayName")
                            bestName = nameLabel and nameLabel.Text or podium.Name
                        end
                    end
                end
            end
        end
    end

    return bestPodium, bestPlot, bestValue, bestName
end

local function attemptPetSteal(podium, petName)
    local _, hrp = getCharacterRoot()
    if not hrp or not podium or not podium.Parent then return false end

    local prompt = getPodiumStealPrompt(podium)
    if not prompt then
        warn("[Pet Snipe] Podium prompt yok: " .. tostring(petName))
        return false
    end

    local standPart = getPodiumStandPart(podium)
    if standPart then
        teleportCharacterTo(standPart.CFrame * CFrame.new(0, 0, 3))
    end
    task.wait(0.4)

    for _ = 1, 5 do
        fireStealPrompt(prompt)
        task.wait(0.35)
        if isCarryingStolenPet() then
            return true
        end
    end

    return waitForCarryingPet(8)
end

local function onWorkspacePetAttached(child)
    if not _G.petSnipeState.enabled or _G.petSnipeState.busy then return end

    task.spawn(function()
        local _, hrp = getCharacterRoot()
        if not hrp then return end

        local function tryDeliver()
            if isCarryingStolenPet() then
                _G.petSnipeState.busy = true
                deliverStolenPetToBase()
                task.wait((CONFIG.Automation and CONFIG.Automation.PetSnipe and CONFIG.Automation.PetSnipe.StealCooldown) or 4)
                _G.petSnipeState.busy = false
                return true
            end
            return false
        end

        if tryDeliver() then return end

        for _ = 1, 30 do
            if tryDeliver() then break end
            task.wait(0.1)
        end
    end)
end

local function petSnipeLoop()
    local noTargetTicks = 0
    while _G.petSnipeState.enabled do
        if not _G.petSnipeState.busy then
            local podium, targetPlot, value, petName = scanBestSnipeTarget()
            if podium then
                noTargetTicks = 0
                _G.petSnipeState.busy = true
                print(string.format("[Pet Snipe] Hedef: %s ($%s/s) plot=%s", tostring(petName), tostring(value), tostring(targetPlot and targetPlot.Name)))
                local ok, stolen = pcall(function()
                    return attemptPetSteal(podium, petName)
                end)
                if ok and stolen then
                    deliverStolenPetToBase()
                    task.wait((CONFIG.Automation and CONFIG.Automation.PetSnipe and CONFIG.Automation.PetSnipe.StealCooldown) or 4)
                elseif not ok then
                    warn("[Pet Snipe] Calma hatasi: " .. tostring(stolen))
                end
                _G.petSnipeState.busy = false
            else
                noTargetTicks = noTargetTicks + 1
                if noTargetTicks == 5 then
                    print("[Pet Snipe] Hedef araniyor... (katalog/min M/s kontrol et)")
                    noTargetTicks = 0
                end
            end
        end
        task.wait((CONFIG.Automation and CONFIG.Automation.PetSnipe and CONFIG.Automation.PetSnipe.ScanInterval) or 1.5)
    end
end

function enablePetSnipe()
    if _G.petSnipeState.enabled then return end
    _G.petSnipeState.enabled = true
    CONFIG.Automation.PetSnipe.Enabled = true
    playerPlot = findPlayerPlot() or playerPlot
    getDeliveryStealRemote()

    table.insert(_G.petSnipeState.connections, workspace.ChildAdded:Connect(onWorkspacePetAttached))

    if _G.petSnipeState.thread then
        task.cancel(_G.petSnipeState.thread)
    end
    _G.petSnipeState.thread = task.spawn(petSnipeLoop)
    print("[Pet Snipe] Aktif | Katalog: " .. tostring(CONFIG.Automation.PetSnipe.MinTier or "Custom"))
end

function disablePetSnipe()
    _G.petSnipeState.enabled = false
    CONFIG.Automation.PetSnipe.Enabled = false
    _G.petSnipeState.busy = false

    for _, conn in ipairs(_G.petSnipeState.connections) do
        pcall(function() conn:Disconnect() end)
    end
    _G.petSnipeState.connections = {}

    if _G.petSnipeState.thread then
        pcall(function() task.cancel(_G.petSnipeState.thread) end)
        _G.petSnipeState.thread = nil
    end
    print("[Pet Snipe] Kapatildi.")
end

local function setInvisibility(on)
    local success, _ = pcall(function()
        local currentCharacter = player.Character or character
        if not currentCharacter or not currentCharacter:FindFirstChild("Humanoid") then 
            print("❌ No character found for invisibility")
            return 
        end
        
        print("🔄 " .. (on and "Enabling" or "Disabling") .. " invisibility for character: " .. currentCharacter.Name)
        
        if on then
            for _, v in pairs(currentCharacter:GetChildren()) do
                if v:IsA("BasePart") then
                    _G.safeSetHiddenProperty(v, "NetworkIsSleeping", true)
                end
            end
            _G.safeSetHiddenProperty(currentCharacter.Humanoid, "OverrideDefaultCollisions", true)
            replicatesignal(currentCharacter.Humanoid.ServerBreakJoints)
            
            -- Add visual feedback
            for _, part in pairs(currentCharacter:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0.5 -- Make slightly transparent for visual feedback
                end
            end
            
            print("✅ Invisibility enabled - player should be transparent")
        else
            for _, v in pairs(currentCharacter:GetChildren()) do
                if v:IsA("BasePart") then
                    _G.safeSetHiddenProperty(v, "NetworkIsSleeping", false)
                end
            end
            _G.safeSetHiddenProperty(currentCharacter.Humanoid, "OverrideDefaultCollisions", false)
            
            -- Remove visual feedback
            for _, part in pairs(currentCharacter:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0 -- Make fully visible
                end
            end
            
            print("❌ Invisibility disabled - player should be visible")
        end
    end)
    if not success then
        warn("Failed to " .. (on and "enable" or "disable") .. " invisibility")
    end
end


--=========================================================
-- UI Setup: Cleaner Tabbed Navigation with Sidebar
--=========================================================


-- Circular Toggle UI System
_G.circularToggleGui = createProtectedScreenGui("CircularToggleUI")
protectGuiElement(_G.circularToggleGui)

-- Function to create toggle UI (rectangular with switch)
_G.createCircularToggleUI = function(toggleName, getState, setState)
    -- Check if toggle already exists and destroy it
    local existingToggle = _G.circularToggleGui:FindFirstChild(toggleName .. "ToggleUI")
    if existingToggle then
        existingToggle:Destroy()
    end
    
    -- Optimized toggle data structure to reduce local variables
    local toggleData = {
        frame = Instance.new("TextButton"),
        dragging = false,
        dragStart = nil,
        startPos = nil
    }
    
    -- Setup main frame
    toggleData.frame.Name = toggleName .. "ToggleUI"
    toggleData.frame.Size = UDim2.new(0, 220, 0, 70)
    -- Use saved position if available, otherwise position on right side
    local savedPosition = _G.OpenCircularToggles[toggleName]
    if not savedPosition then
        -- Calculate position on right side, stacked vertically
        local toggleCount = 0
        for name, _ in pairs(_G.OpenCircularToggles) do
            toggleCount = toggleCount + 1
        end
        savedPosition = UDim2.new(1, -230, 0, 10 + (toggleCount * 80))
    end
    toggleData.frame.Position = savedPosition
    toggleData.frame.BackgroundColor3 = CONFIG.Colors.Panel
    toggleData.frame.Text = ""
    toggleData.frame.AutoButtonColor = false
    toggleData.frame.Parent = _G.circularToggleGui
    Instance.new("UICorner", toggleData.frame).CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", toggleData.frame)
    stroke.Thickness = 2
    stroke.Color = CONFIG.Colors.Stroke
    stroke.Transparency = 0.2
    
    -- Create UI elements
    local elements = {
        dragHandle = Instance.new("TextButton"),
        closeBtn = Instance.new("TextButton"),
        titleLabel = Instance.new("TextLabel"),
        switchFrame = Instance.new("TextButton"),
        knob = Instance.new("Frame")
    }
    
    -- Setup drag handle
    elements.dragHandle.Size = UDim2.new(1, -70, 1, 0)
    elements.dragHandle.Position = UDim2.new(0, 0, 0, 0)
    elements.dragHandle.BackgroundTransparency = 1
    elements.dragHandle.Text = ""
    elements.dragHandle.AutoButtonColor = false
    elements.dragHandle.Parent = toggleData.frame
    
    -- Setup close button
    elements.closeBtn.Size = UDim2.new(0, 30, 0, 30)
    elements.closeBtn.Position = UDim2.new(1, -35, 0, 5)
    elements.closeBtn.BackgroundColor3 = CONFIG.Colors.Danger
    elements.closeBtn.Text = "x"
    elements.closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    elements.closeBtn.TextSize = 16
    elements.closeBtn.Font = Enum.Font.GothamBold
    elements.closeBtn.AutoButtonColor = false
    elements.closeBtn.Parent = toggleData.frame
    elements.closeBtn.ZIndex = 10
    Instance.new("UICorner", elements.closeBtn).CornerRadius = UDim.new(0, 15)
    
    -- Setup title label
    elements.titleLabel.Size = UDim2.new(1, -180, 0, 25)
    elements.titleLabel.Position = UDim2.new(0, 12, 0, 8)
    elements.titleLabel.BackgroundTransparency = 1
    elements.titleLabel.Text = toggleName
    elements.titleLabel.TextColor3 = CONFIG.Colors.Text
    elements.titleLabel.TextSize = 16
    elements.titleLabel.Font = Enum.Font.GothamBold
    elements.titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    elements.titleLabel.Parent = toggleData.frame
    
    -- Setup toggle switch
    elements.switchFrame.Size = UDim2.new(0, 60, 0, 30)
    elements.switchFrame.Position = UDim2.new(0, 100, 0.5, -15)
    elements.switchFrame.BackgroundColor3 = getState() and CONFIG.Colors.SwitchOn or CONFIG.Colors.SwitchOff
    elements.switchFrame.Text = ""
    elements.switchFrame.AutoButtonColor = false
    elements.switchFrame.Parent = toggleData.frame
    Instance.new("UICorner", elements.switchFrame).CornerRadius = UDim.new(0, 15)
    
    -- Setup knob
    elements.knob.Size = UDim2.new(0, 24, 0, 24)
    elements.knob.Position = UDim2.new(0, getState() and 30 or 3, 0, 3)
    elements.knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    elements.knob.Parent = elements.switchFrame
    Instance.new("UICorner", elements.knob).CornerRadius = UDim.new(0, 12)
    
    -- Optimized dragging functionality
    local function startDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local inputPos = input.Position
            
            -- Check if clicking on close button or toggle switch (optimized collision detection)
            local closeBtnPos = elements.closeBtn.AbsolutePosition
            local closeBtnSize = elements.closeBtn.AbsoluteSize
            local switchPos = elements.switchFrame.AbsolutePosition
            local switchSize = elements.switchFrame.AbsoluteSize
            
            if (inputPos.X >= closeBtnPos.X and inputPos.X <= closeBtnPos.X + closeBtnSize.X and
                inputPos.Y >= closeBtnPos.Y and inputPos.Y <= closeBtnPos.Y + closeBtnSize.Y) or
               (inputPos.X >= switchPos.X and inputPos.X <= switchPos.X + switchSize.X and
                inputPos.Y >= switchPos.Y and inputPos.Y <= switchPos.Y + switchSize.Y) then
                return -- Don't start drag if clicking close button or toggle switch
            end
            
            -- Start drag
            toggleData.dragging = true
            toggleData.dragStart = input.Position
            toggleData.startPos = toggleData.frame.Position
            stroke.Transparency = 0 -- Visual feedback
        end
    end
    
    local function updateDrag(input)
        if toggleData.dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - toggleData.dragStart
            toggleData.frame.Position = UDim2.new(toggleData.startPos.X.Scale, toggleData.startPos.X.Offset + delta.X, toggleData.startPos.Y.Scale, toggleData.startPos.Y.Offset + delta.Y)
        end
    end
    
    local function endDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            toggleData.dragging = false
            stroke.Transparency = 0.2 -- Reset visual feedback
            _G.OpenCircularToggles[toggleName] = toggleData.frame.Position
            _G.saveSettings() -- Save position
        end
    end
    
    -- Connect drag events
    elements.dragHandle.InputBegan:Connect(startDrag)
    elements.dragHandle.InputChanged:Connect(updateDrag)
    elements.dragHandle.InputEnded:Connect(endDrag)
    
    -- Optimized switch functions
    local function updateSwitch()
        local currentState = getState()
        elements.switchFrame.BackgroundColor3 = currentState and CONFIG.Colors.SwitchOn or CONFIG.Colors.SwitchOff
        elements.knob.Position = UDim2.new(0, currentState and 30 or 3, 0, 3)
    end
    
    local function toggleSwitch()
        local newState = not getState()
        setState(newState)
        updateSwitch()
    end
    
    local function closeToggle()
        _G.OpenCircularToggles[toggleName] = nil
        _G.saveSettings()
        toggleData.frame:Destroy()
    end
    
    -- Connect switch events
    elements.switchFrame.MouseButton1Click:Connect(toggleSwitch)
    elements.switchFrame.TouchTap:Connect(toggleSwitch)
    elements.switchFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            toggleSwitch()
        end
    end)
    
    -- Connect close button events
    elements.closeBtn.MouseButton1Click:Connect(closeToggle)
    elements.closeBtn.TouchTap:Connect(closeToggle)
    
    -- Additional mobile support with InputBegan
    elements.closeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            closeToggle()
        end
    end)
    
    -- Save the initial position when toggle is created (only if not already saved)
    if not _G.OpenCircularToggles[toggleName] then
        _G.OpenCircularToggles[toggleName] = toggleData.frame.Position
        _G.saveSettings()
    end
    
    return toggleData.frame
end

-- [Ken HUB Part 1 export]
_G.KenHubState = {
    SCRIPT_VERSION = SCRIPT_VERSION,
    CONFIG = CONFIG,
    player = player,
    username = username,
    RunService = RunService,
    TweenService = TweenService,
    ProximityPromptService = ProximityPromptService,
    ReplicatedStorage = ReplicatedStorage,
    HttpService = HttpService,
    TeleportService = TeleportService,
    AE = AE,
    createProtectedScreenGui = createProtectedScreenGui,
    protectGuiElement = protectGuiElement,
    namePrefix = namePrefix,
    findPlayerPlot = findPlayerPlot,
    setInvisibility = setInvisibility,
    enablePetSnipe = enablePetSnipe,
    disablePetSnipe = disablePetSnipe,
    playerPlot = playerPlot,
    character = character,
    humanoid = humanoid,
    humanoidRootPart = humanoidRootPart,
}

-- [Ken HUB Part 1 global API for other parts]
_G.PET_TIER_ORDER = PET_TIER_ORDER
_G.PET_TIER_LABELS = PET_TIER_LABELS
_G.PET_TIER_RANK = PET_TIER_RANK
_G.ensurePetSnipeRarities = ensurePetSnipeRarities
_G.getPlotOwner = getPlotOwner
_G.getRemainingTime = getRemainingTime


-- [Ken HUB global API exports]
_G.KenHub = _G.KenHub or {}
_G.KenHub.PET_TIER_ORDER = PET_TIER_ORDER
_G.KenHub.PET_TIER_LABELS = PET_TIER_LABELS
_G.KenHub.PET_TIER_RANK = PET_TIER_RANK
_G.PET_TIER_ORDER = PET_TIER_ORDER
_G.PET_TIER_LABELS = PET_TIER_LABELS
_G.PET_TIER_RANK = PET_TIER_RANK
_G.ensurePetSnipeRarities = ensurePetSnipeRarities
_G.getPlotOwner = getPlotOwner
_G.getRemainingTime = getRemainingTime
_G.applyPetSnipeMinTier = _G.applyPetSnipeMinTier or function() end

_G.KenHub_CONFIG = CONFIG
pcall(function() _G.KenHubStatus("Part 1/5 OK") end)
-- KenHub_P1_OK
