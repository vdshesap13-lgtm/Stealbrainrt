-- Ken HUB Part 5/5 - Init + Cleanup
-- Ken HUB Part 5/5 - Init + Cleanup
local SCRIPT_VERSION = "1.76"
local B = _G.KenHubBundle
if not B or not B.mainFrame or not B.createSwitch then
    _G.KenHubError("Part 4 export eksik - Loader ile 5 parcayi sirayla yukle")
    return
end
local CONFIG = B.CONFIG
local player = B.player
local username = B.username
local createSwitch = B.createSwitch
local createSectionHeader = B.createSectionHeader
local createNumberInput = B.createNumberInput
local mainFrame = B.mainFrame
local screenGui = B.screenGui
local settingsContent = B.settingsContent
local settingsFrame = B.settingsFrame
local settingsCloseBtn = B.settingsCloseBtn
local settingsBtn = B.settingsBtn
local minimizeBtn = B.minimizeBtn
local closeBtn = B.closeBtn
local sidebar = B.sidebar
local contentArea = B.contentArea
local sections = B.sections
local jumpSwitch = B.jumpSwitch
local speedSwitch = B.speedSwitch
local invisibilitySwitch = B.invisibilitySwitch
local unhittableSwitchInstance = B.unhittableSwitchInstance
local resizeSwitchInstance = B.resizeSwitchInstance
local flingSwitchInstance = B.flingSwitchInstance
local playerESPSwitch = B.playerESPSwitch
local plotESPSwitch = B.plotESPSwitch
local serverHopSwitch = B.serverHopSwitch
local disableESP = B.disableESP
local disablePlotESP = B.disablePlotESP
local disablePlotTimeESP = B.disablePlotTimeESP
local disableBrainrotESP = B.disableBrainrotESP
local disableMobileDesync = B.disableMobileDesync
local enableMobileDesync = B.enableMobileDesync
local disableHelicopter = B.disableHelicopter
local disableGrappleFlight = B.disableGrappleFlight
local disableInfiniteJump = B.disableInfiniteJump
local disableFloat = B.disableFloat
local disablePlatform = B.disablePlatform
local enablePlatform = B.enablePlatform
local enablePlotTimeESP = B.enablePlotTimeESP
local timeSizeLabel = B.timeSizeLabel
local timeSizeFill = B.timeSizeFill
local timeSizeButton = B.timeSizeButton
local playerColorButton = B.playerColorButton
local plotColorButton = B.plotColorButton
local disablePetSnipe = B.disablePetSnipe
local enablePetSnipe = B.enablePetSnipe
local petSnipeSwitch = B.petSnipeSwitch
local setInvisibility = B.setInvisibility
local findPlayerPlot = B.findPlayerPlot
local playerPlot = B.getPlayerPlot and B.getPlayerPlot() or nil
local activeSection = "Home"
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = player
local Workspace = workspace
local function KenNotify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = 6 })
    end)
end

createSectionHeader(settingsContent, "Movement Settings")

-- Float Speed Control
createNumberInput(settingsContent, "Float Descent Speed", CONFIG.Movement.Float.DescentSpeed, function(value)
    local success, _ = pcall(function()
        CONFIG.Movement.Float.DescentSpeed = math.clamp(value, 0.01, 5)
        _G.saveSettings()
    end)
    if not success then
        warn("Failed to update Float Descent Speed")
    end
end)

-- Helicopter Control
createNumberInput(settingsContent, "Helicopter Rotation Speed", CONFIG.Movement.Helicopter.RotationSpeed, function(value)
    local success, _ = pcall(function()
        CONFIG.Movement.Helicopter.RotationSpeed = math.clamp(value, 1, 100)
        _G.saveSettings()
    end)
    if not success then
        warn("Failed to update Helicopter Rotation Speed")
    end
end)
createNumberInput(settingsContent, "Grapple Flight Speed", CONFIG.Movement.GrappleFlight.Speed, function(value)
    local success, _ = pcall(function()
        CONFIG.Movement.GrappleFlight.Speed = math.clamp(value, 50, 500)
        _G.saveSettings()
    end)
    if not success then
        warn("Failed to update Grapple Flight Speed")
    end
end)
createNumberInput(settingsContent, "Infinite Jump Power", CONFIG.Movement.InfiniteJump.JumpPower, function(value)
    local success, _ = pcall(function()
        CONFIG.Movement.InfiniteJump.JumpPower = math.clamp(value, 20, 100)
        _G.saveSettings()
    end)
    if not success then
        warn("Failed to update Infinite Jump Power")
    end
end)
createNumberInput(settingsContent, "Infinite Jump Cooldown", CONFIG.Movement.InfiniteJump.Cooldown, function(value)
    local success, _ = pcall(function()
        CONFIG.Movement.InfiniteJump.Cooldown = math.clamp(value, 0.1, 1.0)
        _G.saveSettings()
    end)
    if not success then
        warn("Failed to update Infinite Jump Cooldown")
    end
end)

-- Rise Settings Controls
createNumberInput(settingsContent, "Rise speed", CONFIG.Movement.Rise.Speed, function(value)
    local success, _ = pcall(function()
        CONFIG.Movement.Rise.Speed = math.clamp(value, 1, 50)
        _G.saveSettings()
        -- Update velocity if Rise is currently active
        if RISE_ENABLED and riseBodyVelocity then
            riseBodyVelocity.Velocity = Vector3.new(0, CONFIG.Movement.Rise.Speed, 0)
        end
    end)
    if not success then
        warn("Failed to update Rise Speed")
    end
end)

createNumberInput(settingsContent, "Rise Max Height", CONFIG.Movement.Rise.MaxHeight, function(value)
    local success, _ = pcall(function()
        CONFIG.Movement.Rise.MaxHeight = math.clamp(value, 10, 2000)
        _G.saveSettings()
    end)
    if not success then
        warn("Failed to update Rise Max Height")
    end
end)

-- Reset Settings Button
createSectionHeader(settingsContent, "Reset Settings")
local resetSettingsButton = Instance.new("TextButton")
resetSettingsButton.Size = UDim2.new(1, 0, 0, 40)
resetSettingsButton.BackgroundColor3 = CONFIG.Colors.Danger
resetSettingsButton.Text = "Reset All Settings"
resetSettingsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetSettingsButton.Font = Enum.Font.GothamBold
resetSettingsButton.TextSize = 16
resetSettingsButton.AutoButtonColor = false
resetSettingsButton.Parent = settingsContent
Instance.new("UICorner", resetSettingsButton).CornerRadius = UDim.new(0, 8)
local resetStroke = Instance.new("UIStroke", resetSettingsButton)
resetStroke.Thickness = 1
resetStroke.Color = CONFIG.Colors.Danger
resetStroke.Transparency = 0.3

resetSettingsButton.MouseButton1Click:Connect(function()
    local success, _ = pcall(function()
        -- Reset all settings to defaults
        CONFIG.ESP.PlayerESP.HighlightColor = Color3.fromRGB(255, 0, 0)
        CONFIG.ESP.PlotESP.HighlightColor = Color3.fromRGB(0, 255, 0)
        CONFIG.ESP.PlotESP.TimeTextSize = 14
        CONFIG.Movement.Unhittable = {
            IntermediateSize = { X = 2, Y = 20, Z = 1 },
            TallSize = { X = 2, Y = 40, Z = 1 },
        }
        CONFIG.Movement.Resize = {
            TargetSize = { X = 2, Y = 10, Z = 1 },
        }
        CONFIG.Movement.Helicopter = {
            Enabled = false,
            RotationSpeed = 20,
        }
        _G.saveSettings()
        
        -- Update color picker buttons
        playerColorButton.BackgroundColor3 = CONFIG.ESP.PlayerESP.HighlightColor
        plotColorButton.BackgroundColor3 = CONFIG.ESP.PlotESP.HighlightColor
        
        -- Update slider
        timeSizeLabel.Text = "Plot Time Text Size: " .. CONFIG.ESP.PlotESP.TimeTextSize
        local relativeX = math.clamp((CONFIG.ESP.PlotESP.TimeTextSize - 16) / (48 - 16), 0, 1)
        timeSizeFill.Size = UDim2.new(relativeX, 0, 1, 0)
        timeSizeButton.Position = UDim2.new(relativeX, -10, 0, 0)
        
        -- Update existing ESP
        for plr, data in pairs(_G.ESP_Data) do
            if typeof(plr) == "Instance" and data.highlight then
                data.highlight.OutlineColor = CONFIG.ESP.PlayerESP.HighlightColor
            end
        end
        for plot, data in pairs(_G.PlotESP_Data) do
            if typeof(plot) == "Instance" and data.highlight then
                data.highlight.OutlineColor = CONFIG.ESP.PlotESP.HighlightColor
            end
            if typeof(plot) == "Instance" and data.timeLabel then
                data.timeLabel.TextSize = CONFIG.ESP.PlotESP.TimeTextSize
            end
        end
        -- Settings reset to defaults
    end)
    if not success then
        warn("Failed to reset settings")
    end
end)

--=========================================================
-- Laser Cape Auto-Fire System (UPDATED - Only works when you own the item)
--=========================================================
local isLaserCapeFiring = false
local laserCapeThread = nil
local laserCapeCheckConnection = nil

local function playerHasLaserCape()
    -- Check if player has Laser Cape in backpack or equipped
    if not player then return false end
    
    local success, hasCape = pcall(function()
        -- Check backpack
        if player.Backpack then
            local capeInBackpack = player.Backpack:FindFirstChild("Laser Cape")
            if capeInBackpack then return true end
        end
        
        -- Check character
        if player.Character then
            local capeEquipped = player.Character:FindFirstChild("Laser Cape")
            if capeEquipped then return true end
        end
        
        -- Check inventory (if applicable)
        local inventory = player:FindFirstChild("Inventory")
        if inventory then
            for _, item in ipairs(inventory:GetChildren()) do
                if item.Name == "Laser Cape" or (item:IsA("StringValue") and item.Value == "Laser Cape") then
                    return true
                end
            end
        end
        
        return false
    end)
    
    if not success then
        warn("Failed to check for Laser Cape")
        return false
    end
    
    return hasCape
end

local function findClosestHumanoidRootParts(maxDistance)
    local rootParts = {}
    
    if not player.Character then return rootParts end
    
    local playerRoot = player.Character:FindFirstChild("HumanoidRootPart")
    if not playerRoot then return rootParts end
    
    -- Get all players except yourself
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local humanoidRootPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local distance = (playerRoot.Position - humanoidRootPart.Position).Magnitude
                if distance <= maxDistance then
                    table.insert(rootParts, {
                        part = humanoidRootPart,
                        distance = distance,
                        player = otherPlayer
                    })
                end
            end
        end
    end
    
    -- Sort by distance (closest first)
    table.sort(rootParts, function(a, b)
        return a.distance < b.distance
    end)
    
    return rootParts
end

local function useLaserCapeOnTarget(targetRootPart)
    if not player.Character then 
        warn("No character found")
        return false 
    end
    
    -- Check if player actually has the laser cape
    if not playerHasLaserCape() then
        warn("Player does not own Laser Cape")
        return false
    end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not humanoidRootPart then 
        warn("Humanoid or HumanoidRootPart not found")
        return false 
    end
    
    local laserCape = player.Backpack:FindFirstChild("Laser Cape") or player.Character:FindFirstChild("Laser Cape")
    if not laserCape then 
        warn("Laser Cape not found")
        return false 
    end
    
    -- Equip the laser cape if not already equipped
    if laserCape.Parent ~= player.Character then
        humanoid:EquipTool(laserCape)
        task.wait(0.1) -- Wait for equip animation
    end
    
    -- Use the Laser Cape on the target HumanoidRootPart
    if UseItemEvent then
        local success, err = pcall(function()
            UseItemEvent:FireServer(targetRootPart.Position, targetRootPart)
        end)
        if success then
            return true
        else
            warn("Failed to fire UseItemEvent: " .. tostring(err))
            return false
        end
    else
        warn("UseItemEvent not found")
        return false
    end
end

local function fireOnClosestHumanoids()
    -- Only fire if player has laser cape
    if not playerHasLaserCape() then
        warn("Cannot fire Laser Cape - player does not own it")
        if isLaserCapeFiring and laserCapeSwitch then
            laserCapeSwitch.set(false) -- Auto-disable if player doesn't have cape
        end
        return
    end
    
    local maxDistance = 50 -- Maximum distance to target
    local closestRootParts = findClosestHumanoidRootParts(maxDistance)
    
    if #closestRootParts == 0 then
        warn("No humanoid root parts found nearby")
        return
    end
    
    -- Always fire on the closest target (first in the sorted list)
    local closestTarget = closestRootParts[1]
    -- Firing Laser Cape at target
    useLaserCapeOnTarget(closestTarget.part)
end

local function enableLaserCape()
    if isLaserCapeFiring then return end
    
    -- Check if player has laser cape before enabling
    if not playerHasLaserCape() then
        warn("Cannot enable Laser Cape Auto-Fire - player does not own Laser Cape")
        if laserCapeSwitch then laserCapeSwitch.set(false) end
        return
    end
    
    isLaserCapeFiring = true
    -- Laser Cape Auto-Fire enabled
    
    if not laserCapeThread then
        laserCapeThread = task.spawn(function()
            while isLaserCapeFiring do
                if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    -- Re-check if player still has laser cape
                    if playerHasLaserCape() then
                        fireOnClosestHumanoids()
                    else
                        warn("Player lost Laser Cape, disabling auto-fire")
                        isLaserCapeFiring = false
                        if laserCapeSwitch then laserCapeSwitch.set(false) end
                        break
                    end
                else
                    warn("Player character not available or dead")
                    isLaserCapeFiring = false
                    if laserCapeSwitch then laserCapeSwitch.set(false) end
                    break
                end
                task.wait(0.5) -- Wait between shots
            end
            laserCapeThread = nil
        end)
    end
    
    -- Set up periodic checking for laser cape acquisition/loss
    if not laserCapeCheckConnection then
        laserCapeCheckConnection = RunService.Heartbeat:Connect(function()
            if isLaserCapeFiring and not playerHasLaserCape() then
                warn("Player lost Laser Cape, disabling auto-fire")
                isLaserCapeFiring = false
                if laserCapeSwitch then laserCapeSwitch.set(false) end
                if laserCapeCheckConnection then
                    laserCapeCheckConnection:Disconnect()
                    laserCapeCheckConnection = nil
                end
            end
        end)
    end
end

local function disableLaserCape()
    if not isLaserCapeFiring then return end
    isLaserCapeFiring = false
    -- Laser Cape Auto-Fire disabled
    
    if laserCapeThread then
        task.cancel(laserCapeThread)
        laserCapeThread = nil
    end
    
    if laserCapeCheckConnection then
        laserCapeCheckConnection:Disconnect()
        laserCapeCheckConnection = nil
    end
end

-- Update the laser cape switch to check if player has the cape
local originalLaserCapeSwitch = createSwitch(_G.movementSection, "Laser Cape Auto-Fire", false, function(on)
    if on then
        -- Only enable if player has laser cape
        if playerHasLaserCape() then
            enableLaserCape()
        else
            warn("Cannot enable Laser Cape Auto-Fire - player does not own Laser Cape")
            if laserCapeSwitch then laserCapeSwitch.set(false) end
        end
    else
        disableLaserCape()
    end
end)

-- Create a reference to the switch for other functions to use
_G.laserCapeSwitch = originalLaserCapeSwitch

--=========================================================
-- Button Interactions
--=========================================================
settingsBtn.MouseButton1Click:Connect(function()
    local success, _ = pcall(function()
        settingsFrame.Visible = not settingsFrame.Visible
    end)
    if not success then
        warn("Failed to toggle settings frame visibility")
    end
end)

settingsCloseBtn.MouseButton1Click:Connect(function()
    local success, _ = pcall(function()
        settingsFrame.Visible = false
    end)
    if not success then
        warn("Failed to close settings frame")
    end
end)

local isMinimized = false
local isGuiHidden = false

local function getMainPanelSize()
    if isMinimized then
        if _G.isMobile or _G.isDelta then
            return UDim2.new(0.94, 0, 0, 40)
        end
        return CONFIG.UI.MinimizedSize
    end
    if _G.isMobile or _G.isDelta then
        return UDim2.new(0.94, 0, 0.78, 0)
    end
    return CONFIG.UI.FrameSize
end

local function setMainGuiVisible(visible)
    isGuiHidden = not visible
    if mainFrame then
        mainFrame.Visible = visible
    end
    if screenGui then
        screenGui.Enabled = visible
    end
    if not visible and settingsFrame then
        settingsFrame.Visible = false
    end
    if sidebar then sidebar.Visible = visible and not isMinimized end
    if contentArea then contentArea.Visible = visible and not isMinimized end
    if visible then
        mainFrame.Size = getMainPanelSize()
        if _G.isMobile or _G.isDelta then
            mainFrame.Position = UDim2.new(0.03, 0, 0.08, 0)
        end
        sidebar.Visible = not isMinimized
        contentArea.Visible = not isMinimized
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local toggleKey = CONFIG.UI.ToggleKey or Enum.KeyCode.RightShift
    if input.KeyCode == toggleKey or input.KeyCode == Enum.KeyCode.Insert then
        setMainGuiVisible(isGuiHidden)
    end
end)

_G.KenHubPanelToggle = function()
    setMainGuiVisible(isGuiHidden)
end

minimizeBtn.MouseButton1Click:Connect(function()
    local success, _ = pcall(function()
        isMinimized = not isMinimized
        mainFrame.Size = getMainPanelSize()
        sidebar.Visible = not isMinimized
        contentArea.Visible = not isMinimized
        minimizeBtn.Text = isMinimized and "+" or "−"
    end)
    if not success then
        warn("Failed to toggle minimize state")
    end
end)

local function hideKenHubPanel()
    setMainGuiVisible(false)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Ken HUB",
            Text = (_G.isDelta or _G.isMobile) and "Panel gizlendi. KH butonuna dokun." or "Panel gizlendi. RightShift veya Insert ile ac.",
            Duration = 3,
        })
    end)
end

local function bindClose(btn)
    if not btn then return end
    pcall(function() btn.MouseButton1Click:Connect(hideKenHubPanel) end)
    pcall(function() btn.TouchTap:Connect(hideKenHubPanel) end)
end
bindClose(closeBtn)

--=========================================================
-- Character Respawn Handling
--=========================================================
player.CharacterAdded:Connect(function(newCharacter)
    local success, _ = pcall(function()
        character = newCharacter
        humanoid = newCharacter:WaitForChild("Humanoid", 5)
        humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart", 5)

        -- Reapply active settings
        if jumpSwitch and jumpSwitch.get then
        if jumpSwitch.get() then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = CONFIG.Movement.JumpPower
            end
        end

        if speedSwitch and speedSwitch.get and speedSwitch.set then
        if speedSwitch.get() then
            speedSwitch.set(false) -- Disable and re-enable to reset connections
            speedSwitch.set(true)
            end
        end

        if invisibilitySwitch and invisibilitySwitch.get then
        if invisibilitySwitch.get() then
                task.wait(0.5) -- Wait for character to be ready
            setInvisibility(true)
            end
        end

        if unhittableSwitchInstance and unhittableSwitchInstance.get and unhittableSwitchInstance.set then
        if unhittableSwitchInstance.get() then
            unhittableSwitchInstance.set(false)
            unhittableSwitchInstance.set(true)
            end
        end

        if resizeSwitchInstance and resizeSwitchInstance.get and resizeSwitchInstance.set then
        if resizeSwitchInstance.get() then
            resizeSwitchInstance.set(false)
            resizeSwitchInstance.set(true)
            end
        end

        if flingSwitchInstance and flingSwitchInstance.get and flingSwitchInstance.set then
        if flingSwitchInstance.get() then
            flingSwitchInstance.set(false)
            flingSwitchInstance.set(true)
            end
        end
        
        if originalLaserCapeSwitch and originalLaserCapeSwitch.get then
        if originalLaserCapeSwitch.get() then
                pcall(function() disableLaserCape() end)
                pcall(function() enableLaserCape() end)
            end
        end

        if CONFIG.Movement.GrappleFlight.Enabled then
            pcall(function() disableGrappleFlight() end)
            pcall(function() enableGrappleFlight() end)
        end

        if CONFIG.Movement.InfiniteJump.Enabled then
            pcall(function() disableInfiniteJump() end)
            pcall(function() enableInfiniteJump() end)
        end

        -- Re-enable Rise if enabled (with loaded settings)
        if CONFIG.Movement.Rise.Enabled then
            pcall(function() disablePlatform() end)
            if player.Character then
                pcall(function() enablePlatform(player.Character) end)
            end
        end
        
        -- Re-enable Float if enabled
        if CONFIG.Movement.Float.Enabled then
            pcall(function() disableFloat() end)
            pcall(function() enableFloat(newCharacter) end)
        end
        
        -- Re-enable Helicopter if enabled
        if CONFIG.Movement.Helicopter.Enabled then
            pcall(function() disableHelicopter() end)
            pcall(function() enableHelicopter(newCharacter) end)
        end
        
        -- Re-enable Mobile Desync if enabled
        if _G.mobileDesyncEnabled then
            pcall(function() disableMobileDesync() end)
            pcall(function() enableMobileDesync() end)
        end
        
        -- Re-enable Ragdoll Desync if enabled
        if CONFIG.Desync.RagdollDesync.Enabled then
            pcall(function() (_G.disableRagdollDesync or function() end)() end)
            pcall(function() enableRagdollDesync(newCharacter) end)
        end

        -- Reattach ESP if enabled
        if _G.ESP_Enabled then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    attachHighlightToCharacter(plr, plr.Character)
                end
            end
        end
        
        -- Re-enable Plot ESP if enabled
        if _G.PlotESP_Enabled then
            pcall(function() disablePlotESP() end)
            pcall(function() enablePlotESP() end)
        end
        
        -- Re-enable Plot Time ESP if enabled
        if _G.PlotTimeESP_Enabled then
            pcall(function() disablePlotTimeESP() end)
            pcall(function() enablePlotTimeESP() end)
        end
        
        -- Re-enable Brainrot ESP if enabled
        if CONFIG.ESP.BrainrotESP.Enabled then
            pcall(function() disableBrainrotESP() end)
            pcall(function() enableBrainrotESP() end)
        end
        
        -- Re-enable Anti-Kick if enabled
        if CONFIG.AntiKick.Enabled then
            pcall(function() disableAntiKick() end)
            pcall(function() enableAntiKick() end)
        end
    end)
    if not success then
        warn("Failed to handle character respawn")
    end
end)

--=========================================================
-- Initial Setup
--=========================================================
local function initialize()
    local success, _ = pcall(function()
        -- Set default section
        B.setActiveSection("Home")
        local sectionNames = {}
        for name, _ in pairs(sections) do
            table.insert(sectionNames, name)
        end
        -- Debug info removed for clean console
        sections.Home.Visible = true
        sidebar:FindFirstChild("HomeButton").BackgroundColor3 = CONFIG.Colors.Accent
        -- ActiveFeatures removed
        
        -- Toggle states will be restored at the end of the script

        -- Ensure plot is rechecked periodically
        task.spawn(function()
            while true do
                if not B.getPlayerPlot() or not B.getPlayerPlot().Parent then
                    B.setPlayerPlot(findPlayerPlot())
                end
                task.wait(2)
            end
        end)
        
        -- Save UI state periodically
        task.spawn(function()
            while true do
                _G.saveUIState()
                task.wait(2) -- Save UI state every 2 seconds
            end
        end)
    end)
    if not success then
        warn("Failed to initialize UI")
    end
end

local initOk, initErr = xpcall(initialize, debug.traceback)
if not initOk then
    pcall(function() _G.KenHubError(initErr) end)
else
    pcall(function() _G.KenHubReady() end)
    pcall(function()
        KenNotify("Ken HUB v" .. SCRIPT_VERSION, (_G.isDelta or _G.isMobile)
            and "Yuklendi! Sol alttaki KH butonuna dokun"
            or "Yuklendi! RightShift veya Insert = panel")
    end)
    print("[Ken HUB] Panel hazir | Executor:", _G.executor)
end

task.delay(4, function()
    if not _G.KenHubMainFrame or not _G.KenHubMainFrame.Parent then
        _G.KenHubError("Panel olusmadi. Loader.lua kullan ve F8 konsolunu kontrol et.")
    end
end)

--=========================================================
-- Client cleanup (executor/local only)
--=========================================================
local function kenHubCleanup()
    pcall(function()
        if _G.ESP_Enabled then disableESP() end
        if _G.PlotESP_Enabled then disablePlotESP() end
        if _G.toggleServerHop then _G.toggleServerHop(false) end
        if jumpSwitch and jumpSwitch.get and jumpSwitch.set and jumpSwitch.get() then
            jumpSwitch.set(false)
        end
        if speedSwitch and speedSwitch.get and speedSwitch.set and speedSwitch.get() then
            speedSwitch.set(false)
        end
        if invisibilitySwitch and invisibilitySwitch.get and invisibilitySwitch.get() then
            setInvisibility(false)
        end
        if unhittableSwitchInstance and unhittableSwitchInstance.get and unhittableSwitchInstance.set and unhittableSwitchInstance.get() then
            unhittableSwitchInstance.set(false)
        end
        if resizeSwitchInstance and resizeSwitchInstance.get and resizeSwitchInstance.set and resizeSwitchInstance.get() then
            resizeSwitchInstance.set(false)
        end
        if flingSwitchInstance and flingSwitchInstance.get and flingSwitchInstance.set and flingSwitchInstance.get() then
            flingSwitchInstance.set(false)
        end
        if isLaserCapeFiring then disableLaserCape() end
        if _G.mobileDesyncEnabled then disableMobileDesync() end
        if CONFIG.Movement.RagdollDesync and CONFIG.Movement.RagdollDesync.Enabled then
            (_G.disableRagdollDesync or function() end)()
        end
        if CONFIG.ESP.BrainrotESP.Enabled then disableBrainrotESP() end
        if CONFIG.Automation.PetSnipe.Enabled then disablePetSnipe() end
    end)
end

_G.KenHubCleanup = kenHubCleanup

pcall(function()
    player.AncestryChanged:Connect(function(_, parent)
        if not parent then kenHubCleanup() end
    end)
end)

-- ===== ULTRA-COMPACT ESP =====
_G.ESP = {suffixes={K=1e3,M=1e6,B=1e9,T=1e12,Qa=1e15,Qi=1e18},current={overhead=nil,modelHighlight=nil,partHighlight=nil,maxVal=-1,owner=nil},playerHighlights={}}

function _G.parseGen(text)
    if not text then return 0 end
    text = text:match("^%$(.+)") or text
    text = text:gsub("/S$", ""):gsub(",", "")
    local num = tonumber(text:match("^[%d%.]+")) or 0
    local suffix = text:match("[%a]+")
    return suffix and _G.ESP.suffixes[suffix] and num * _G.ESP.suffixes[suffix] or num
end

function _G.clearVisuals()
    if _G.ESP.current.modelHighlight then _G.ESP.current.modelHighlight:Destroy() _G.ESP.current.modelHighlight = nil end
    if _G.ESP.current.partHighlight then _G.ESP.current.partHighlight:Destroy() _G.ESP.current.partHighlight = nil end
end

function _G.updateHighest()
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return end
    _G.clearVisuals()
    local bestVal, bestOverhead, bestOwner = -1, nil, nil
    for _, plot in ipairs(plots:GetChildren()) do
        if plot:IsA("Model") or plot:IsA("Folder") then
            local plotBest = -1
            for _, obj in ipairs(plot:GetDescendants()) do
                if obj.Name == "AnimalOverhead" and obj:IsA("BillboardGui") then
                    local gen = obj:FindFirstChild("Generation")
                    if gen and gen:IsA("TextLabel") then
                        local val = _G.parseGen(gen.Text)
                        if val > plotBest then plotBest, bestOverhead = val, obj end
                    end
                end
            end
            if bestOverhead and plotBest > bestVal then
                local sign = plot:FindFirstChild("PlotSign", true)
                local label = sign and sign:FindFirstChildWhichIsA("TextLabel", true)
                local owner = label and label.Text:gsub("[''']s$", ""):gsub("%s+$", "")
                if owner and string.lower(owner) ~= string.lower(player.Name) then
                    bestVal, bestOwner = plotBest, owner
                end
            end
        end
    end
    if not bestOverhead then return end
    _G.ESP.current.overhead, _G.ESP.current.maxVal, _G.ESP.current.owner = bestOverhead, bestVal, bestOwner
    local displayName = bestOverhead:FindFirstChild("DisplayName")
    if not displayName then return end
    local parent = bestOverhead.Parent
    for _=1,4 do parent = parent and parent.Parent end
    local target = nil
    for i=0,2 do
        local candidate = parent
        for _=1,i do candidate = candidate and candidate.Parent end
        if candidate then
            local child = candidate:FindFirstChild(displayName.Text)
            if child then target = child break end
        end
    end
    if not target then return end
    local highlight = Instance.new("Highlight")
    highlight.Adornee, highlight.FillTransparency, highlight.FillColor = target, 0.75, Color3.fromRGB(255,0,0)
    highlight.OutlineTransparency, highlight.OutlineColor = 0, Color3.fromRGB(255,0,0)
    highlight.Parent = target
    _G.ESP.current.modelHighlight = highlight
    local part = target:IsA("BasePart") and target or target:FindFirstChildWhichIsA("BasePart", true)
    if part then
        local partHighlight = Instance.new("Highlight")
        partHighlight.Adornee, partHighlight.FillTransparency, partHighlight.FillColor = part, 0.75, Color3.fromRGB(255,0,0)
        partHighlight.OutlineTransparency, partHighlight.OutlineColor = 0, Color3.fromRGB(255,0,0)
        partHighlight.Parent = Workspace
        _G.ESP.current.partHighlight = partHighlight
    end
end

task.spawn(function()
    while true do
        if CONFIG.ESP.BrainrotESP.Enabled then
            _G.updateHighest()
        else
            _G.clearVisuals()
        end
        task.wait(2)
    end
end)

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= player and plr.Character then
        local highlight = Instance.new("Highlight")
        highlight.Adornee, highlight.FillColor = plr.Character, Color3.fromRGB(173, 216, 230)
        highlight.FillTransparency, highlight.OutlineTransparency = 0.75, 0
        highlight.OutlineColor, highlight.Parent = Color3.fromRGB(173, 216, 230), plr.Character
        _G.ESP.playerHighlights[plr] = highlight
    end
end

-- Test save system on startup
task.spawn(function()
task.wait(2)
pcall(function()
_G.saveUIState()
end)
end)

-- Periodic Settings Save System (Every 3 seconds)
task.spawn(function()
    while true do
        task.wait(3)
        pcall(function()
        _G.saveUIState()
        end)
    end
end)

--- Restore toggle states after ALL switches are created
task.spawn(function()
task.wait(1)
pcall(function()
_G.applyLoadedToggleStates()
end)
end)

-- Save current UI state to ensure persistent toggles are saved
task.spawn(function()
task.wait(1.5)
pcall(function()
_G.saveUIState()
end)
end)

pcall(function() _G.KenHubStatus("Part 5/5 OK - Ken HUB hazir!") end)
pcall(function() _G.KenHubReady() end)
-- KenHub_P5_OK
