-- Ken HUB Part 4/5 - Desync + ESP + Bundle
-- Ken HUB Part 4/5 - Desync + ESP + Bundle
local SCRIPT_VERSION = "1.78"
local M = _G.KenHubMid
if not M or not M.CONFIG then
    error("[Ken HUB] Part 3 yuklenmedi - Loader.lua kullan")
end
local CONFIG = M.CONFIG
local player = M.player
local username = M.username
local createSwitch = M.createSwitch
local createSectionHeader = M.createSectionHeader
local createNumberInput = M.createNumberInput
local createButton = M.createButton
local mainFrame = M.mainFrame
local screenGui = M.screenGui
local settingsContent = M.settingsContent
local settingsFrame = M.settingsFrame
local settingsCloseBtn = M.settingsCloseBtn
local settingsBtn = M.settingsBtn
local minimizeBtn = M.minimizeBtn
local closeBtn = M.closeBtn
local sidebar = M.sidebar
local contentArea = M.contentArea
local sections = M.sections
local jumpSwitch = M.jumpSwitch
local speedSwitch = M.speedSwitch
local invisibilitySwitch = M.invisibilitySwitch
local unhittableSwitchInstance = M.unhittableSwitchInstance
local resizeSwitchInstance = M.resizeSwitchInstance
local flingSwitchInstance = M.flingSwitchInstance
local playerESPSwitch = M.playerESPSwitch
local plotESPSwitch = M.plotESPSwitch
local serverHopSwitch = M.serverHopSwitch
local disableESP = M.disableESP
local disablePlotESP = M.disablePlotESP
local disablePlotTimeESP = M.disablePlotTimeESP
local enablePlotTimeESP = M.enablePlotTimeESP
local disableHelicopter = M.disableHelicopter
local disableGrappleFlight = M.disableGrappleFlight
local disableInfiniteJump = M.disableInfiniteJump
local disableFloat = M.disableFloat
local disablePlatform = M.disablePlatform
local enablePlatform = M.enablePlatform
local timeSizeLabel = M.timeSizeLabel
local timeSizeFill = M.timeSizeFill
local timeSizeButton = M.timeSizeButton
local timeSizeBar = M.timeSizeBar
local playerColorButton = M.playerColorButton
local plotColorButton = M.plotColorButton
local disablePetSnipe = M.disablePetSnipe
local enablePetSnipe = M.enablePetSnipe
local petSnipeSwitch = M.petSnipeSwitch
local setInvisibility = M.setInvisibility
local findPlayerPlot = M.findPlayerPlot
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local LP = player
local playerPlot
pcall(function() playerPlot = M.getPlayerPlot() end)
local activeSection
pcall(function() activeSection = nil end)
-- Desync section UI
createSectionHeader(_G.desyncSection, "Desync Controls")
_G.mobileDesyncEnabled = false
createSwitch(_G.desyncSection, "Desync (Mobile)", false, function(on)
    pcall(function()
        _G.mobileDesyncEnabled = on
        if on then enableMobileDesync() else disableMobileDesync() end
    end)
end)

-- Plot Time ESP varsayilan kapali (startup'ta agir yuk bindirmesin)
-- Acmak icin Visual/Settings'ten toggle kullan

local isTimeSizeDragging = false
if timeSizeButton and timeSizeButton.MouseButton1Down then
    pcall(function()
        timeSizeButton.MouseButton1Down:Connect(function()
            isTimeSizeDragging = true
        end)
    end)
else
    warn("[Ken HUB] timeSizeButton bulunamadi - slider devre disi")
end

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isTimeSizeDragging = false
    end
end)

RunService.Heartbeat:Connect(function()
    if isTimeSizeDragging then
        local mouse = player:GetMouse()
        local sliderPos = timeSizeBar.AbsolutePosition.X
        local sliderWidth = timeSizeBar.AbsoluteSize.X
        local mouseX = mouse.X
        local relativeX = math.clamp((mouseX - sliderPos) / sliderWidth, 0, 1)
        local newSize = math.floor(16 + relativeX * (48 - 16))

        if newSize ~= CONFIG.ESP.PlotESP.TimeTextSize then
            CONFIG.ESP.PlotESP.TimeTextSize = newSize
            timeSizeLabel.Text = "Plot Time Text Size: " .. newSize
            timeSizeFill.Size = UDim2.new(relativeX, 0, 1, 0)
            timeSizeButton.Position = UDim2.new(relativeX, -10, 0, 0)

            if _G.PlotTimeESP_Enabled then
                disablePlotTimeESP()
                enablePlotTimeESP()
            end

            _G.saveSettings()
        end
    end
end)

--=========================================================
-- Brainrot ESP System
--=========================================================
_G.brainrotESPEnabled = false
_G.brainrotRefreshLoop = nil
_G.brainrotLastHighlighted = nil

-- Converts "$100M/s" style text into numbers
local function convertToNumber(text)
    text = text:gsub("%$", ""):gsub("/s", "") -- Remove $ and /s
    local multiplier = 1

    if text:find("K") then
        multiplier = 1e3
        text = text:gsub("K", "")
    elseif text:find("M") then
        multiplier = 1e6
        text = text:gsub("M", "")
    elseif text:find("B") then
        multiplier = 1e9
        text = text:gsub("B", "")
    elseif text:find("T") then
        multiplier = 1e12
        text = text:gsub("T", "")
    end

    local num = tonumber(text)
    return num and num * multiplier or 0
end

-- Reset a BillboardGui back to default
local function resetBillboard(billboard)
    if billboard then
        billboard.MaxDistance = 60
        billboard.Size = UDim2.new(15, 0, 5, 0)
        billboard.SizeOffset = Vector2.new(0, 0)
    end
end

-- Check if any ancestor is named "Base"
local function hasBaseParent(obj)
    local parent = obj.Parent
    while parent do
        if parent.Name == "Base" then
            return true
        end
        parent = parent.Parent
    end
    return false
end

-- Update ESP logic
local function updateBrainrotESP()
    local highestBillboard = nil
    local highestValue = 0

    -- Look through workspace for all AnimalOverhead BillboardGuis
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BillboardGui") and obj.Name == "AnimalOverhead" and hasBaseParent(obj) then
            local genLabel = obj:FindFirstChild("Generation")
            if genLabel and genLabel:IsA("TextLabel") then
                local value = convertToNumber(genLabel.Text)
                if value > highestValue then
                    highestValue = value
                    highestBillboard = obj
                end
            end
        end
    end

    -- Reset previous highlighted billboard if changed
    if _G.brainrotLastHighlighted and _G.brainrotLastHighlighted ~= highestBillboard then
        resetBillboard(_G.brainrotLastHighlighted)
    end

    -- Highlight the new highest billboard
    if highestBillboard then
        highestBillboard.MaxDistance = 100000
        highestBillboard.Size = UDim2.new(40, 0, 50, 0)
        highestBillboard.SizeOffset = Vector2.new(0.4, 1)
        _G.brainrotLastHighlighted = highestBillboard
    else
        _G.brainrotLastHighlighted = nil
    end
end

-- Enable Brainrot ESP
local function enableBrainrotESP()
    if _G.brainrotRefreshLoop then _G.brainrotRefreshLoop:Disconnect() end

    -- Run immediately when toggled on
    updateBrainrotESP()

    -- Then refresh every 2 seconds
    local lastRefresh = tick()
    _G.brainrotRefreshLoop = RunService.Heartbeat:Connect(function()
        if tick() - lastRefresh >= 2 then
            updateBrainrotESP()
            lastRefresh = tick()
        end
    end)
end

-- Disable Brainrot ESP
local function disableBrainrotESP()
    if _G.brainrotRefreshLoop then
        _G.brainrotRefreshLoop:Disconnect()
        _G.brainrotRefreshLoop = nil
    end

    -- Reset last highlighted to default
    if _G.brainrotLastHighlighted then
        resetBillboard(_G.brainrotLastHighlighted)
        _G.brainrotLastHighlighted = nil
    end
end

-- Mobile Desync Functions (moved here before toggles section)
local function enableMobileDesync()
    pcall(function()
        local a = game:GetService("Players")
        local b = game:GetService("ReplicatedStorage")
        local c = a.LocalPlayer
        local d = c:WaitForChild("Backpack")

        local f = b:WaitForChild("Packages"):WaitForChild("Net")
        local g = f:WaitForChild("RE/UseItem")
        local h = f:WaitForChild("RE/QuantumCloner/OnTeleport")

        local function executeAntiHit()
            local s = c.Character or c.CharacterAdded:Wait()
            local t = d:FindFirstChild("Quantum Cloner") or s:FindFirstChild("Quantum Cloner")
            if t and d:FindFirstChild(t.Name) then
                c.Character.Humanoid:EquipTool(t)
            end
            setfflag("WorldStepMax", -2147483648)
            task.wait(0.2)
            g:FireServer()
            task.wait(0.3)
            h:FireServer()
            
            -- Set desync flags right after clone execution
            setfflag("S2PhysicsSenderRate", "-100")
            setfflag("SimBlockLargeLocalToolWeldManipulationsThreshold", "-1")
            setfflag("MaxMissedWorldStepsRemembered", "0")
            setfflag("DebugSimPrimalStiffnessMax", "0")
            setfflag("DebugSimPrimalStiffnessMin", "0")
            setfflag("ReplicatorAnimationTrackLimitPerAnimator", "-1")
            setfflag("PhysicsSkipNonRealTimeHumanoidForceCalc2", "True")
            
            task.wait(0.7)
            setfflag("WorldStepMax", -1)
        end

        -- Execute desync immediately when enabled
        executeAntiHit()
        print("✅ Mobile Desync activated!")
    end)
end

local function disableMobileDesync()
    pcall(function()
        -- Reset desync flags to defaults
        setfflag("S2PhysicsSenderRate", "60")
        setfflag("SimBlockLargeLocalToolWeldManipulationsThreshold", "100")
        setfflag("MaxMissedWorldStepsRemembered", "1000")
        setfflag("DebugSimPrimalStiffnessMax", "100")
        setfflag("DebugSimPrimalStiffnessMin", "100")
        setfflag("ReplicatorAnimationTrackLimitPerAnimator", "10")
        setfflag("PhysicsSkipNonRealTimeHumanoidForceCalc2", "False")
        setfflag("WorldStepMax", -1)
        print("❌ Mobile Desync disabled - all flags reset!")
    end)
end

-- Create Brainrot ESP toggle in Toggles section (moved here after function definitions)
createButton(_G.togglesSection, "Toggle Brainrot ESP", function()
    _G.createCircularToggleUI("Brainrot ESP", function() return CONFIG.ESP.BrainrotESP.Enabled end, function(state)
        CONFIG.ESP.BrainrotESP.Enabled = state
        _G.saveSettings()
        if state then
            enableBrainrotESP()
        else
            disableBrainrotESP()
        end
    end)
end)

createButton(_G.togglesSection, "Toggle Mobile Desync", function()
    _G.createCircularToggleUI("Mobile Desync", function() return _G.mobileDesyncEnabled end, function(state)
        _G.mobileDesyncEnabled = state
        -- Don't save settings for mobile desync (fast flag can't be disabled)
        if state then
            enableMobileDesync()
        else
            disableMobileDesync()
        end
    end)
end)

_G.brainrotESPSwitch = createSwitch(_G.visualSection, "Brainrot ESP", CONFIG.ESP.BrainrotESP.Enabled, function(on)
    CONFIG.ESP.BrainrotESP.Enabled = on
    _G.saveSettings()
    if on then
        enableBrainrotESP()
    else
        disableBrainrotESP()
    end
end)

-- Delete Borders Button
createButton(_G.visualSection, "Delete Borders", function()
    local success, err = pcall(function()
        local borders = workspace:FindFirstChild("Map")
        if borders then
            borders = borders:FindFirstChild("Borders")
            if borders then
                borders:Destroy()
                print("✅ Successfully deleted workspace.Map.Borders!")
            else
                warn("❌ workspace.Map.Borders not found!")
            end
        else
            warn("❌ workspace.Map not found!")
        end
    end)
    
    if not success then
        warn("❌ Failed to delete borders: " .. tostring(err))
    end
end)

createButton(_G.visualSection, "Barrier Increase", function()
    local success, err = pcall(function()
        local map = workspace:FindFirstChild("Map")
        if map then
            local parts = {
                map:FindFirstChild("Part"),
                map:GetChildren()[11],
                map:GetChildren()[20]

            }
            for i, part in ipairs(parts) do
                if part and part:IsA("BasePart") then
                    part.Size = Vector3.new(part.Size.X, part.Size.Y, 13)
                    print("✅ Successfully set Z-size to 13 for part at index: " .. tostring(i))
                else
                    warn("❌ Part not found or invalid at index: " .. tostring(i))
                end
            end
        else
            warn("❌ workspace.Map not found!")
        end
    end)
    
    if not success then
        warn("❌ Failed to increase barrier sizes: " .. tostring(err))
    end
end)



--=========================================================


-- Panel baslangic (block B hata verse bile icerik gorunsun)
pcall(function()
    activeSection = "Home"
    if sections and sections.Home then
        sections.Home.Visible = true
    end
    for name, frame in pairs(sections or {}) do
        if name ~= "Home" and frame then
            frame.Visible = false
        end
    end
    local homeBtn = sidebar and sidebar:FindFirstChild("HomeButton")
    if homeBtn then
        homeBtn.BackgroundColor3 = CONFIG.Colors.Accent
    end
end)

-- [Ken HUB Part 4 export -> KenHubBundle]
_G.KenHub_CONFIG = CONFIG
_G.KenHubBundle = {
    CONFIG = CONFIG,
    player = player,
    username = username,
    createSwitch = createSwitch,
    createSectionHeader = createSectionHeader,
    createNumberInput = createNumberInput,
    createButton = createButton,
    mainFrame = mainFrame,
    screenGui = screenGui,
    settingsContent = settingsContent,
    settingsFrame = settingsFrame,
    settingsCloseBtn = settingsCloseBtn,
    settingsBtn = settingsBtn,
    minimizeBtn = minimizeBtn,
    closeBtn = closeBtn,
    sidebar = sidebar,
    contentArea = contentArea,
    sections = sections,
    jumpSwitch = jumpSwitch,
    speedSwitch = speedSwitch,
    invisibilitySwitch = invisibilitySwitch,
    unhittableSwitchInstance = unhittableSwitchInstance,
    resizeSwitchInstance = resizeSwitchInstance,
    flingSwitchInstance = flingSwitchInstance,
    playerESPSwitch = _G.playerESPSwitch,
    plotESPSwitch = _G.plotESPSwitch,
    serverHopSwitch = serverHopSwitch,
    disableESP = disableESP,
    disablePlotESP = disablePlotESP,
    disablePlotTimeESP = disablePlotTimeESP,
    disableBrainrotESP = disableBrainrotESP,
    disableMobileDesync = disableMobileDesync,
    enableMobileDesync = enableMobileDesync,
    disableHelicopter = disableHelicopter,
    disableGrappleFlight = disableGrappleFlight,
    disableInfiniteJump = disableInfiniteJump,
    disableFloat = disableFloat,
    disablePlatform = disablePlatform,
    enablePlatform = enablePlatform,
    enablePlotTimeESP = enablePlotTimeESP,
    timeSizeLabel = timeSizeLabel,
    timeSizeFill = timeSizeFill,
    timeSizeButton = timeSizeButton,
    playerColorButton = playerColorButton,
    plotColorButton = plotColorButton,
    disablePetSnipe = disablePetSnipe,
    enablePetSnipe = enablePetSnipe,
    petSnipeSwitch = petSnipeSwitch,
    setInvisibility = setInvisibility,
    findPlayerPlot = findPlayerPlot,
    getPlayerPlot = function() return playerPlot end,
    setPlayerPlot = function(v) playerPlot = v end,
    setActiveSection = function(v) activeSection = v end,
}
_G.KenHub_createSwitch = createSwitch
pcall(function() _G.KenHubStatus("Part 4/5 OK") end)

-- Ragdoll Desync System
--=========================================================
local ragdollDesyncEnabled = false
local ragdollConnections = {}

local function enableRagdollDesync()
    if ragdollDesyncEnabled then return end
    
    ragdollDesyncEnabled = true
    
    -- Anti-Ragdoll LocalScript for Roblox
    -- Neutralizes ragdoll system without getconnections, using getloadedmodules, setreadonly, and runtime countermeasures.
    -- Run early via executor or StarterPlayerScripts.

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local LocalPlayer = Players.LocalPlayer

    -- Wait for character to ensure Humanoid and parts are available
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid", 5)
    local RootPart = Character:WaitForChild("HumanoidRootPart", 5)
    local Head = Character:WaitForChild("Head", 5)
    local CurrentCamera = Workspace.CurrentCamera

    -- Debug function
    local function debugPrint(message)
        print("[Anti-Ragdoll] " .. tostring(message))
    end

    -- Step 1: Override RagDollController module using getloadedmodules
    local function overrideControllerModule()
        local Packages = ReplicatedStorage:WaitForChild("Packages", 5)
        if not Packages then
            debugPrint("Packages not found in ReplicatedStorage!")
            return
        end

        local controllerModule
        for _, module in ipairs(getloadedmodules()) do
            local success, moduleName = pcall(function()
                return module.Name
            end)
            if success and (moduleName:lower():match("ragdollcontroller") or moduleName:lower():match("ragdoll")) then
                local result
                success, result = pcall(function()
                    return require(module)
                end)
                if success and type(result) == "table" and result.ToggleControls and result.IsInRagdoll and result.Start then
                    controllerModule = result
                    debugPrint("Found RagDollController module: " .. moduleName)
                    break
                end
            end
        end

        if controllerModule then
            -- Check if table is read-only and make it writable
            if isreadonly(controllerModule) then
                setreadonly(controllerModule, false)
                debugPrint("Made controllerModule table writable")
            end

            -- Override functions
            controllerModule.ToggleControls = newcclosure(function(_, enable)
                if enable == false then
                    debugPrint("Blocked attempt to disable controls")
                    return
                end
                local success, controls = pcall(function()
                    local playerScripts = LocalPlayer:WaitForChild("PlayerScripts", 5)
                    local playerModule = require(playerScripts:WaitForChild("PlayerModule", 5))
                    return playerModule:GetControls()
                end)
                if success and controls then
                    controls:Enable()
                    debugPrint("Forced controls enabled")
                else
                    debugPrint("Failed to access PlayerModule controls")
                end
            end)

            controllerModule.IsInRagdoll = newcclosure(function()
                debugPrint("IsInRagdoll called, returning false")
                return false
            end)

            controllerModule.Start = newcclosure(function()
                debugPrint("Blocked Start function")
            end)

            -- Make table read-only again for safety
            setreadonly(controllerModule, true)
            debugPrint("RagDollController module overridden successfully")
        else
            debugPrint("Could not find RagDollController module. Falling back to runtime countermeasures.")
        end
    end

    -- Run module override
    overrideControllerModule()

    -- Step 2: Neutralize RagdollClient script and RemoteEvent
    local function neutralizeRemoteEvent()
        local Packages = ReplicatedStorage:WaitForChild("Packages", 5)
        if not Packages then
            debugPrint("Packages not found for RemoteEvent neutralization!")
            return
        end

        local ragdollFolder = Packages:WaitForChild("Ragdoll", 5)
        if not ragdollFolder then
            debugPrint("Ragdoll folder not found!")
            return
        end

        local ragdollRemote = ragdollFolder:WaitForChild("Ragdoll", 5)
        if not ragdollRemote then
            debugPrint("Ragdoll RemoteEvent not found!")
            return
        end

        -- Add a no-op connection to reduce impact (won't block existing connections)
        pcall(function()
            ragdollConnections.remoteEvent = ragdollRemote.OnClientEvent:Connect(function(arg1, arg2)
                debugPrint("Intercepted RemoteEvent call: " .. tostring(arg1) .. ", " .. tostring(arg2))
            end)
            debugPrint("Added no-op RemoteEvent connection")
        end)

        -- Disable RagdollClient script using getloadedmodules
        local foundClientScript = false
        for _, script in ipairs(getloadedmodules()) do
            local success, scriptName = pcall(function()
                return script.Name
            end)
            if success and scriptName:lower():match("ragdollclient") then
                pcall(function()
                    script.Disabled = true
                    debugPrint("Disabled RagdollClient script: " .. scriptName)
                    foundClientScript = true
                end)
            end
        end

        -- Also check PlayerScripts for RagdollClient
        for _, script in ipairs(LocalPlayer.PlayerScripts:GetChildren()) do
            if script.Name:lower():match("ragdollclient") then
                pcall(function()
                    script.Disabled = true
                    debugPrint("Disabled PlayerScripts RagdollClient script: " .. script.Name)
                    foundClientScript = true
                end)
            end
        end

        if not foundClientScript then
            debugPrint("Could not find RagdollClient script. Relying on runtime countermeasures.")
        end
    end

    -- Run RemoteEvent neutralization
    neutralizeRemoteEvent()

    -- Step 3: Runtime loop to counter ragdoll effects
    ragdollConnections.heartbeat = RunService.Heartbeat:Connect(function()
        if not (Humanoid and RootPart and Head and CurrentCamera) then
            debugPrint("Character components missing, skipping frame")
            return
        end

        -- Counter Physics state
        if Humanoid:GetState() == Enum.HumanoidStateType.Physics then
            Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            debugPrint("Forced Humanoid out of Physics state")
        end

        -- Reset camera subject
        if CurrentCamera.CameraSubject ~= Humanoid then
            CurrentCamera.CameraSubject = Humanoid
            debugPrint("Reset CameraSubject to Humanoid")
        end

        -- Ensure collisions and properties
        if not RootPart.CanCollide then
            RootPart.CanCollide = true
            debugPrint("Forced RootPart.CanCollide to true")
        end

        if not Humanoid.BreakJointsOnDeath then
            Humanoid.BreakJointsOnDeath = true
            debugPrint("Forced BreakJointsOnDeath to true")
        end

        -- Override RagdollEndTime
        local currentTime = Workspace:GetServerTimeNow()
        if LocalPlayer:GetAttribute("RagdollEndTime") and LocalPlayer:GetAttribute("RagdollEndTime") > currentTime then
            LocalPlayer:SetAttribute("RagdollEndTime", currentTime - 10)
            debugPrint("Set RagdollEndTime to past value")
        end

        -- Re-enable controls
        local success, controls = pcall(function()
            local playerScripts = LocalPlayer:WaitForChild("PlayerScripts", 5)
            local playerModule = require(playerScripts:WaitForChild("PlayerModule", 5))
            return playerModule:GetControls()
        end)
        if success and controls and not controls:IsActive() then
            controls:Enable()
            debugPrint("Re-enabled player controls")
        end
    end)

    -- Step 4: Clean up ragdoll constraints and attachments
    ragdollConnections.descendantAdded = Character.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("BallSocketConstraint") or descendant:IsA("HingeConstraint") or descendant:IsA("Attachment") then
            descendant:Destroy()
            debugPrint("Destroyed ragdoll constraint/attachment: " .. descendant.Name)
        end
    end)

    -- Step 5: Handle character respawn
    ragdollConnections.characterAdded = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        Character = newCharacter
        Humanoid = Character:WaitForChild("Humanoid", 5)
        RootPart = Character:WaitForChild("HumanoidRootPart", 5)
        Head = Character:WaitForChild("Head", 5)
        debugPrint("Character respawned, reapplied countermeasures")
    end)

    debugPrint("Anti-ragdoll script fully activated")
    print("✅ Ragdoll Desync activated!")
end

local function disableRagdollDesync()
    if not ragdollDesyncEnabled then return end
    
    ragdollDesyncEnabled = false
    
    -- Disconnect all connections
    for _, connection in pairs(ragdollConnections) do
        pcall(function() connection:Disconnect() end)
    end
    ragdollConnections = {}
    
    print("❌ Ragdoll Desync disabled!")
end

-- Add Ragdoll Desync to Movement section
local ragdollDesyncSwitch = createSwitch(_G.movementSection, "Ragdoll Desync", false, function(on)
    CONFIG.Movement.RagdollDesync = CONFIG.Movement.RagdollDesync or {}
    CONFIG.Movement.RagdollDesync.Enabled = on
    _G.saveSettings()
    if on then
        enableRagdollDesync()
    else
        disableRagdollDesync()
    end
end)

_G.enableRagdollDesync = enableRagdollDesync
_G.disableRagdollDesync = disableRagdollDesync
-- KenHub_P4_OK
