-- Ken HUB Part 3/5 - Sections + Automation
-- Ken HUB Part 3/5 - Sections + Automation
local SCRIPT_VERSION = "1.73"
local K = _G.KenHubState
if not K or not K.createSwitch or not K.createSection or not K.setupUnhittableControl then
    error("[Ken HUB] Part 2 yuklenmedi - Loader.lua kullan")
end
local CONFIG = K.CONFIG
local player = K.player
local username = K.username
local RunService = K.RunService
local TweenService = K.TweenService
local ReplicatedStorage = K.ReplicatedStorage
local ProximityPromptService = K.ProximityPromptService
local UserInputService = game:GetService("UserInputService")
local createSection = K.createSection
local createTabButton = K.createTabButton
local createSwitch = K.createSwitch
local createSectionHeader = K.createSectionHeader
local createNumberInput = K.createNumberInput
local mainFrame = K.mainFrame
local screenGui = K.screenGui
local settingsContent = K.settingsContent
local settingsFrame = K.settingsFrame
local settingsCloseBtn = K.settingsCloseBtn
local settingsBtn = K.settingsBtn
local minimizeBtn = K.minimizeBtn
local closeBtn = K.closeBtn
local sidebar = K.sidebar
local contentArea = K.contentArea
local sections = K.sections
local activeSection = K.activeSection
local findPlayerPlot = K.findPlayerPlot
local setInvisibility = K.setInvisibility
local enablePetSnipe = K.enablePetSnipe
local disablePetSnipe = K.disablePetSnipe
local playerPlot = K.playerPlot
local character = K.character
local humanoid = K.humanoid
local humanoidRootPart = K.humanoidRootPart
local setupJumpPowerControl = K.setupJumpPowerControl
local setupSpeedControl = K.setupSpeedControl
local setupUnhittableControl = K.setupUnhittableControl
local setupResizeControl = K.setupResizeControl
local setupFlingControl = K.setupFlingControl
local enableESP = K.enableESP
local disableESP = K.disableESP
local enablePlotESP = K.enablePlotESP
local disablePlotESP = K.disablePlotESP
local jumpSwitch
local speedSwitch
-- UI Sections Setup
--=========================================================
_G.homeSection = createSection("Home")
_G.movementSection = createSection("Movement")
_G.visualSection = createSection("Visual")
_G.automationSection = createSection("Automation")
_G.serverSection = createSection("Server")
_G.patchedSection = createSection("Patched")
_G.desyncSection = createSection("Desync")

-- Jump/Speed switchleri section olustuktan sonra bagla
do
    local _, js = setupJumpPowerControl(_G.movementSection)
    jumpSwitch = js
    local _, ss = setupSpeedControl(_G.movementSection)
    speedSwitch = ss
end

createTabButton("Home", "Home", "rbxassetid://6031265976")
createTabButton("Movement", "Movement", "rbxassetid://6035047409")
createTabButton("Visual", "Visual", "rbxassetid://6031280882")
createTabButton("Automation", "Automation", "rbxassetid://6031280882")
createTabButton("Patched", "Patched", "rbxassetid://6031289451")
createTabButton("Server", "Server", "rbxassetid://6031068421")
createTabButton("Desync", "Desync", "rbxassetid://6031094677")


-- Home Section
createSectionHeader(_G.homeSection, "Welcome")
local welcomeLabel = Instance.new("TextLabel")
welcomeLabel.Size = UDim2.new(1, -20, 0, 100)
welcomeLabel.BackgroundTransparency = 1
welcomeLabel.Text = "Welcome to Ken HUB v" .. SCRIPT_VERSION .. "\nBest Free Steal a Brainrot Script.\nalways updating each week! We are Ken HUB!\nJoin our community: " .. CONFIG.DiscordLink
welcomeLabel.TextColor3 = CONFIG.Colors.SubText
welcomeLabel.TextSize = 14
welcomeLabel.Font = Enum.Font.Gotham
welcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
welcomeLabel.TextYAlignment = Enum.TextYAlignment.Top
welcomeLabel.TextWrapped = true
welcomeLabel.Parent = _G.homeSection

-- Button Creator
local function createButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 40)
    button.BackgroundColor3 = CONFIG.Colors.Background
    button.Text = text
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 14
    button.TextColor3 = CONFIG.Colors.Text
    button.AutoButtonColor = false
    button.Parent = parent
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", button).Thickness = 0.8
    button.MouseButton1Click:Connect(callback)
    
    -- Mobile support - Touch events
    button.TouchTap:Connect(callback)
    
    return button
end


-- Movement Section
createSectionHeader(_G.movementSection, "Player Movement")


-- New Float System
local FLOAT_ENABLED = false
local connections = {}
local bodyVelocity = nil
local floatPart = nil
local lastJumpTime = 0
local JUMP_COOLDOWN = 0.5 -- Minimum time between jump inputs to avoid anti-cheat

local function enableFloat(character)
    local success, err = pcall(function()
        if FLOAT_ENABLED then return end

        local humanoid = character:WaitForChild("Humanoid", 5)
        local rootPart = character:WaitForChild("HumanoidRootPart", 5)
        if not humanoid or not rootPart then return end

        FLOAT_ENABLED = true

        -- Create invisible client-side part
        floatPart = Instance.new("Part")
        floatPart.Size = Vector3.new(4, 1, 4) -- Wider than character
        floatPart.Transparency = 1 -- Invisible
        floatPart.Anchored = false
        floatPart.CanCollide = false
        floatPart.Massless = true -- Reduces physics impact
        floatPart.Parent = workspace
        
        -- Weld the part to the character's root
        local weld = Instance.new("Weld")
        weld.Part0 = rootPart
        weld.Part1 = floatPart
        weld.C0 = CFrame.new(0, -3.5, 0) -- Position below character
        weld.Parent = floatPart

        -- Apply subtle downward force for slow descent
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(0, 5000, 0) -- Moderate force
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.P = 1000
        bodyVelocity.Parent = floatPart

        -- Main float logic for slow descent with improved detection
        connections.stepped = RunService.Stepped:Connect(function()
            if not FLOAT_ENABLED or not humanoid or humanoid.Health <= 0 then
                return
            end

            local isInAir = humanoid:GetState() == Enum.HumanoidStateType.Freefall
            local isJumping = humanoid:GetState() == Enum.HumanoidStateType.Jumping
            local isFalling = humanoid:GetState() == Enum.HumanoidStateType.FallingDown
            
            -- Check if player is off ground using raycast
            local raycast = workspace:Raycast(rootPart.Position, Vector3.new(0, -10, 0))
            local isOnGround = raycast ~= nil
            
            -- Apply float when: already in air, jumping, falling, or not on ground
            if isInAir or isJumping or isFalling or not isOnGround then
                local descentSpeed = CONFIG.Movement.Float.DescentSpeed or 2
                bodyVelocity.Velocity = Vector3.new(0, -descentSpeed, 0) -- Slow descent speed
            else
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        end)

        -- Cleanup connections
        connections.died = humanoid.Died:Connect(function()
            disableFloat()
        end)
        
        connections.characterRemoving = character.AncestryChanged:Connect(function(_, parent)
            if parent == nil then
                disableFloat()
            end
        end)
    end)

    if not success then
        warn("Float enable error: " .. tostring(err))
        FLOAT_ENABLED = false
    end
end

local function disableFloat()
        FLOAT_ENABLED = false
        for _, conn in pairs(connections) do
            pcall(function() conn:Disconnect() end)
        end
        connections = {}
    
    if floatPart then
        floatPart:Destroy()
        floatPart = nil
    end
end

-- Attach to current character and future spawns
player.CharacterAdded:Connect(function(newCharacter)
    disableFloat() -- Clean up old character
    task.spawn(function()
        task.wait(0.5) -- Wait for character to fully load
        if CONFIG.Movement.Float.Enabled then
            enableFloat(newCharacter) -- Apply to new character
        end
        if CONFIG.AntiKick.Enabled then
            enableAntiKick() -- Re-enable anti-kick for new character
        end
    end)
end)

-- Apply to existing character
if player.Character and CONFIG.Movement.Float.Enabled then
    task.spawn(function()
        task.wait(0.5) -- Wait for character to fully load
    enableFloat(player.Character)
    end)
end

if player.Character and CONFIG.Movement.Rise.Enabled then
    print("🚀 Initializing Platform on existing character - CONFIG.Movement.Rise.Enabled:", CONFIG.Movement.Rise.Enabled)
    task.spawn(function()
        task.wait(0.5) -- Wait for character to fully load
        enablePlatform(player.Character)
    end)
else
    print("⚠️ Platform not initialized - player.Character:", player.Character, "CONFIG.Movement.Rise.Enabled:", CONFIG.Movement.Rise.Enabled)
end


-- Note: BindToClose can only be called by server, so we'll handle cleanup differently

local floatSwitch = createSwitch(_G.movementSection, "Float", CONFIG.Movement.Float.Enabled, function(on)
    CONFIG.Movement.Float.Enabled = on
    _G.saveSettings()
    if on then
        if player.Character then
            enableFloat(player.Character)
        end
        -- Auto-create side toggle when enabled
        _G.createCircularToggleUI("Float", function() return CONFIG.Movement.Float.Enabled end, function(state)
            CONFIG.Movement.Float.Enabled = state
            _G.saveSettings()
            if state then
                if player.Character then enableFloat(player.Character) end
            else
                disableFloat()
            end
        end)
    else
        disableFloat()
        -- Remove side toggle when disabled
        local existingToggle = _G.circularToggleGui:FindFirstChild("FloatToggleUI")
        if existingToggle then
            _G.OpenCircularToggles["Float"] = nil
            existingToggle:Destroy()
            _G.saveSettings()
        end
    end
    -- ActiveFeatures removed
    _G.saveSettings()
end)


local _, unhittableSwitchInstance = setupUnhittableControl(_G.movementSection)
local _, resizeSwitchInstance = setupResizeControl(_G.movementSection)

--=========================================================
-- Helicopter System
--=========================================================
local HELICOPTER_ENABLED = false
local helicopterConnections = {}
local helicopterBodyAngularVelocity = nil

local function enableHelicopter(character)
    local success, err = pcall(function()
        if HELICOPTER_ENABLED then return end

        -- Wait for HumanoidRootPart
        local rootPart = character:WaitForChild("HumanoidRootPart", 5)
        if not rootPart then
            error("HumanoidRootPart not found in character")
        end
        if rootPart.Anchored then
            error("HumanoidRootPart is anchored, cannot apply helicopter")
        end

        HELICOPTER_ENABLED = true

        -- Create BodyAngularVelocity for rotation
        helicopterBodyAngularVelocity = Instance.new("BodyAngularVelocity")
        helicopterBodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0) -- Only rotate on Y axis
        helicopterBodyAngularVelocity.AngularVelocity = Vector3.new(0, CONFIG.Movement.Helicopter.RotationSpeed, 0)
        helicopterBodyAngularVelocity.Parent = rootPart

        -- Main helicopter loop - just rotation and fling detection
        helicopterConnections.helicopter = RunService.Heartbeat:Connect(function()
            if not HELICOPTER_ENABLED or not rootPart or rootPart.Parent ~= character then
        return
    end
    
            -- Find and fling nearby players
            for _, otherPlayer in pairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local otherRootPart = otherPlayer.Character.HumanoidRootPart
                    local distance = (otherRootPart.Position - rootPart.Position).Magnitude
                    
                    -- If close enough, fling them
                    if distance < 8 then
                        local direction = (otherRootPart.Position - rootPart.Position).Unit
                        local flingForce = direction * 100 + Vector3.new(0, 50, 0) -- Fixed power
                        
                        -- Apply fling force
                        otherRootPart.AssemblyLinearVelocity = flingForce
                    end
                end
            end
        end)

        -- Cleanup on death
        local humanoid = character:WaitForChild("Humanoid", 5)
        if humanoid then
            helicopterConnections.died = humanoid.Died:Connect(function()
                disableHelicopter()
            end)
        end
    end)
    
    if not success then
        warn("Failed to enable helicopter: " .. tostring(err))
        HELICOPTER_ENABLED = false
    end
end

local function disableHelicopter()
    local success, err = pcall(function()
        if not HELICOPTER_ENABLED then return end
        HELICOPTER_ENABLED = false
        for _, conn in pairs(helicopterConnections) do
            pcall(function() conn:Disconnect() end)
        end
        helicopterConnections = {}
        if helicopterBodyAngularVelocity then
            helicopterBodyAngularVelocity:Destroy()
            helicopterBodyAngularVelocity = nil
        end
    end)
    if not success then
        warn("Failed to disable helicopter: " .. tostring(err))
    end
end

-- Attach to current character and future spawns
player.CharacterAdded:Connect(function(newCharacter)
    pcall(function() disableHelicopter() end) -- Clean up old character
    pcall(function() disableGrappleFlight() end) -- Clean up old character
    pcall(function() disableInfiniteJump() end) -- Clean up old character
    pcall(function() disablePlatform() end) -- Clean up old character
    task.spawn(function()
        task.wait(0.1) -- Small delay to avoid race conditions
        if CONFIG.Movement.Helicopter.Enabled then
            enableHelicopter(newCharacter) -- Apply to new character
        end
        if CONFIG.Movement.GrappleFlight.Enabled then
            enableGrappleFlight() -- Apply to new character
        end
        if CONFIG.Movement.InfiniteJump.Enabled then
            enableInfiniteJump() -- Apply to new character
        end
        if CONFIG.Movement.Rise.Enabled then
            print("🔄 Enabling Platform on new character - CONFIG.Movement.Rise.Enabled:", CONFIG.Movement.Rise.Enabled)
            enablePlatform(newCharacter) -- Apply to new character
        end
    end)
end)

-- Apply to existing character if helicopter is enabled
if player.Character and CONFIG.Movement.Helicopter.Enabled then
    task.spawn(function()
        task.wait(0.1) -- Small delay to avoid race conditions
        enableHelicopter(player.Character)
    end)
end

-- Apply to existing character if grapple flight is enabled
-- Forward declarations so we can call these before their definitions below
local enableGrappleFlight
local enableInfiniteJump

if player.Character and CONFIG.Movement.GrappleFlight.Enabled then
    task.spawn(function()
        task.wait(0.1) -- Small delay to avoid race conditions
        enableGrappleFlight()
    end)
end

-- Apply to existing character if infinite jump is enabled
if player.Character and CONFIG.Movement.InfiniteJump.Enabled then
    task.spawn(function()
        task.wait(0.1) -- Small delay to avoid race conditions
        enableInfiniteJump()
    end)
end

--=========================================================
-- Grapple Flight System
--=========================================================
local grappleFlightEnabled = false
local grappleFlightConnection = nil
local grappleTool = nil
local flightPart = nil -- Track the welded part for cleanup

local function getGrappleHook()
    local backpack = player:FindFirstChild("Backpack")
    if not backpack then return nil end

    grappleTool = backpack:FindFirstChild("Grapple Hook") or backpack:FindFirstChild("GrappleHook")
    if not grappleTool then
        grappleTool = workspace:FindFirstChild("Grapple Hook") or workspace:FindFirstChild("GrappleHook")
        if grappleTool and grappleTool:IsA("Tool") then
            grappleTool.Parent = backpack
        end
    end
    return grappleTool
end

local function equipGrappleHook()
    if not getGrappleHook() then return false end
    local char = player.Character
    if not char then return false end

    local equipped = char:FindFirstChild("Grapple Hook") or char:FindFirstChild("GrappleHook")
    if equipped then
        grappleTool = equipped
        return true
    end

    if grappleTool then
        grappleTool.Parent = char
        return true
    end
    return false
end

enableGrappleFlight = function()
    if grappleFlightEnabled then return end
    grappleFlightEnabled = true

    if not equipGrappleHook() then
        warn("No Grapple Hook found!")
        grappleFlightEnabled = false
        return
    end

    local char = player.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    -- Create invisible client-side part for anti-detection (like float system)
    flightPart = Instance.new("Part")
    flightPart.Size = Vector3.new(2, 1, 2) -- Small invisible part
    flightPart.Transparency = 1 -- Invisible
    flightPart.Anchored = false
    flightPart.CanCollide = false
    flightPart.Massless = true -- Reduces physics impact
    flightPart.Parent = workspace
    
    -- Weld the part to the character's root (anti-detection technique)
    local weld = Instance.new("Weld")
    weld.Part0 = root
    weld.Part1 = flightPart
    weld.C0 = CFrame.new(0, 0, 0) -- Position at character center
    weld.Parent = flightPart

    local spd = CONFIG.Movement.GrappleFlight.Speed
    local bodyVel

    grappleFlightConnection = RunService.Heartbeat:Connect(function()
        local char = player.Character
        if not char then return end

        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end

        -- Fire grapple remote
        local net = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"))
        net:RemoteEvent("UseItem"):FireServer(0.1)

        -- Apply BodyVelocity to the welded part instead of character (anti-detection)
        if not bodyVel or not bodyVel.Parent then
            bodyVel = Instance.new("BodyVelocity")
            bodyVel.Name = "FlyVel"
            bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyVel.P = 2000
            bodyVel.Parent = flightPart -- Apply to welded part, not character
        end

        local dir = Vector3.new(0,0,0)

        -- PC Controls (Keyboard)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            dir = dir + workspace.CurrentCamera.CFrame.LookVector*spd
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            dir = dir - workspace.CurrentCamera.CFrame.LookVector*spd
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            dir = dir - workspace.CurrentCamera.CFrame.RightVector*spd
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            dir = dir + workspace.CurrentCamera.CFrame.RightVector*spd
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            dir = dir + Vector3.new(0,spd,0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            dir = dir - Vector3.new(0,spd,0)
        end

        -- Mobile Controls (Touch) - Simple and effective
        local touchEnabled = UserInputService.TouchEnabled
        if touchEnabled then
            -- Use the humanoid's MoveDirection for mobile (works with virtual joystick)
            local moveDirection = hum.MoveDirection
            if moveDirection.Magnitude > 0 then
                -- Convert move direction to world space
                local camera = workspace.CurrentCamera
                local lookVector = camera.CFrame.LookVector
                local rightVector = camera.CFrame.RightVector
                
                -- Calculate movement based on move direction
                local forward = moveDirection.Z
                local right = moveDirection.X
                local up = moveDirection.Y
                
                -- Apply movement
                if forward > 0 then
                    dir = dir + lookVector * spd * forward
                elseif forward < 0 then
                    dir = dir + lookVector * spd * forward
                end
                
                if right > 0 then
                    dir = dir + rightVector * spd * right
                elseif right < 0 then
                    dir = dir + rightVector * spd * right
                end
                
                if up > 0 then
                    dir = dir + Vector3.new(0, spd * up, 0)
                elseif up < 0 then
                    dir = dir + Vector3.new(0, spd * up, 0)
                end
            end
        end

        -- Prevent flinging by limiting velocity magnitude
        local velocityMagnitude = dir.Magnitude
        if velocityMagnitude > spd * 1.5 then
            dir = dir.Unit * (spd * 1.5) -- Cap at 1.5x speed to prevent flinging
        end

        bodyVel.Velocity = dir
        hum:ChangeState(Enum.HumanoidStateType.Physics)
    end)
end

local function disableGrappleFlight()
    if not grappleFlightEnabled then return end
    grappleFlightEnabled = false

    if grappleFlightConnection then
        grappleFlightConnection:Disconnect()
        grappleFlightConnection = nil
    end

    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")

        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end

        -- Unequip grapple hook
        local equippedGrapple = char:FindFirstChild("Grapple Hook") or char:FindFirstChild("GrappleHook")
        if equippedGrapple and equippedGrapple:IsA("Tool") then
            equippedGrapple.Parent = player:FindFirstChild("Backpack")
        end

        -- Clean up welded flight part (anti-detection cleanup)
        if flightPart then
            flightPart:Destroy()
            flightPart = nil
        end
    end
end

local grappleFlightSwitch = createSwitch(_G.movementSection, "Grapple Flight", CONFIG.Movement.GrappleFlight.Enabled, function(on)
    CONFIG.Movement.GrappleFlight.Enabled = on
    _G.saveSettings()
    if on then
        enableGrappleFlight()
        -- Auto-create side toggle when enabled
        _G.createCircularToggleUI("Grapple Flight", function() return CONFIG.Movement.GrappleFlight.Enabled end, function(state)
            CONFIG.Movement.GrappleFlight.Enabled = state
            _G.saveSettings()
            if state then
                enableGrappleFlight()
            else
                disableGrappleFlight()
            end
        end)
    else
        disableGrappleFlight()
        -- Remove side toggle when disabled
        local existingToggle = _G.circularToggleGui:FindFirstChild("Grapple FlightToggleUI")
        if existingToggle then
            _G.OpenCircularToggles["Grapple Flight"] = nil
            existingToggle:Destroy()
            _G.saveSettings()
        end
    end
    -- ActiveFeatures removed
    _G.saveSettings()
end)

--=========================================================
-- Infinite Jump System
--=========================================================
local infiniteJumpEnabled = false
local infiniteJumpConnection = nil
local infiniteJumpPart = nil
local infiniteJumpBodyVel = nil
local lastJump = 0

local function doInfiniteJump()
    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    -- Check cooldown
    if tick() - lastJump < CONFIG.Movement.InfiniteJump.Cooldown then return end
    lastJump = tick()

    -- Create welded part for anti-detection (like float system)
    if not infiniteJumpPart or not infiniteJumpPart.Parent then
        infiniteJumpPart = Instance.new("Part")
        infiniteJumpPart.Size = Vector3.new(1, 1, 1)
        infiniteJumpPart.Transparency = 1
        infiniteJumpPart.Anchored = false
        infiniteJumpPart.CanCollide = false
        infiniteJumpPart.Massless = true
        infiniteJumpPart.Parent = workspace
        
        -- Weld to character
        local weld = Instance.new("Weld")
        weld.Part0 = root
        weld.Part1 = infiniteJumpPart
        weld.C0 = CFrame.new(0, 0, 0)
        weld.Parent = infiniteJumpPart
    end

    -- Create BodyVelocity for boost (apply to welded part for anti-detection)
    local bodyVel = infiniteJumpPart:FindFirstChild("InfiniteJumpBoost") or Instance.new("BodyVelocity")
    bodyVel.Name = "InfiniteJumpBoost"
    bodyVel.MaxForce = Vector3.new(0, math.huge, 0) -- Only Y axis
    bodyVel.Velocity = Vector3.new(0, CONFIG.Movement.InfiniteJump.JumpPower, 0)
    bodyVel.P = 5000
    bodyVel.Parent = infiniteJumpPart -- Apply to welded part, not character

    -- Trigger humanoid jump
    humanoid.Jump = true
    
    -- Remove boost after short duration
    task.delay(0.1, function()
        if bodyVel and bodyVel.Parent then
            bodyVel:Destroy()
        end
        if humanoid then 
            humanoid.Jump = false 
        end
    end)
end

enableInfiniteJump = function()
    if infiniteJumpEnabled then return end
    infiniteJumpEnabled = true
    
    infiniteJumpConnection = RunService.Heartbeat:Connect(function()
        local char = player.Character
        if not char then return end
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        
        -- Check for jump input (works on both PC and mobile)
        local isJumping = false
        
        -- PC: Check for Space key
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            isJumping = true
        end
        
        -- Mobile: Check if humanoid is jumping (works with virtual jump button)
        if humanoid:GetState() == Enum.HumanoidStateType.Jumping then
            isJumping = true
        end
        
        -- Also check humanoid.Jump property (catches mobile jumps)
        if humanoid.Jump then
            isJumping = true
        end
        
        if isJumping then
            doInfiniteJump()
        end
    end)
end

local function disableInfiniteJump()
    if not infiniteJumpEnabled then return end
    infiniteJumpEnabled = false
    
    if infiniteJumpConnection then
        infiniteJumpConnection:Disconnect()
        infiniteJumpConnection = nil
    end
    
    -- Clean up BodyVelocity from welded part
    if infiniteJumpPart then
        local bodyVel = infiniteJumpPart:FindFirstChild("InfiniteJumpBoost")
        if bodyVel then
            bodyVel:Destroy()
        end
        infiniteJumpPart:Destroy()
        infiniteJumpPart = nil
    end
end

local infiniteJumpSwitch = createSwitch(_G.movementSection, "Infinite Jump", CONFIG.Movement.InfiniteJump.Enabled, function(on)
    CONFIG.Movement.InfiniteJump.Enabled = on
    _G.saveSettings()
    if on then
        enableInfiniteJump()
        -- Auto-create side toggle when enabled
        _G.createCircularToggleUI("Infinite Jump", function() return CONFIG.Movement.InfiniteJump.Enabled end, function(state)
            CONFIG.Movement.InfiniteJump.Enabled = state
            _G.saveSettings()
            if state then
                enableInfiniteJump()
            else
                disableInfiniteJump()
            end
        end)
    else
        disableInfiniteJump()
        -- Remove side toggle when disabled
        local existingToggle = _G.circularToggleGui:FindFirstChild("Infinite JumpToggleUI")
        if existingToggle then
            _G.OpenCircularToggles["Infinite Jump"] = nil
            existingToggle:Destroy()
            _G.saveSettings()
        end
    end
    -- ActiveFeatures removed
    _G.saveSettings()
end)

---=========================================================
--- Platform System (3rd Floor)
---=========================================================
local platform, connection
local platformActive, isRising = false, false

local function destroyPlatform()
    if platform then 
        platform:Destroy() 
        platform = nil 
    end
    platformActive = false 
    isRising = false
    if connection then 
        connection:Disconnect() 
        connection = nil 
    end
end

local function canRise()
    if not platform then return false end
    local origin = platform.Position + Vector3.new(0, platform.Size.Y/2, 0)
    local direction = Vector3.new(0, 2, 0)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {platform, player.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    return not workspace:Raycast(origin, direction, rayParams)
end

local function setupPlatform(character)
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Clean up on character death
    character:WaitForChild("Humanoid").Died:Connect(destroyPlatform)
end

local function enablePlatform(character)
    local success, err = pcall(function()
        if platformActive then return end
        
        local rootPart = character:WaitForChild("HumanoidRootPart")
        if not rootPart then
            warn("Failed to find HumanoidRootPart for Platform")
            return
        end
        
        platformActive = true
        
        platform = Instance.new("Part")
        platform.Size = Vector3.new(6, 0.5, 6)
        platform.Anchored = true
        platform.CanCollide = true
        platform.Transparency = 0
        platform.Material = Enum.Material.Neon
        platform.Color = Color3.fromRGB(100, 200, 255) -- Light blue to match UI
        platform.Position = rootPart.Position - Vector3.new(0, rootPart.Size.Y/2 + platform.Size.Y/2, 0)
        platform.Parent = workspace

        local faces = {Enum.NormalId.Top, Enum.NormalId.Bottom, Enum.NormalId.Left, Enum.NormalId.Right, Enum.NormalId.Front, Enum.NormalId.Back}
        for _, face in ipairs(faces) do
            local texture = Instance.new("Texture")
            texture.Texture = "rbxassetid://6731652062"
            texture.Face = face
            texture.StudsPerTileU = 4
            texture.StudsPerTileV = 4
            texture.Parent = platform
        end

        isRising = true
        connection = RunService.Heartbeat:Connect(function(dt)
            if platform and platformActive then
                local currentPos = platform.Position
                local newXZ = Vector3.new(rootPart.Position.X, currentPos.Y, rootPart.Position.Z)
                if isRising and canRise() then
                    platform.Position = newXZ + Vector3.new(0, dt * CONFIG.Movement.Rise.Speed, 0)
                else
                    isRising = false
                    platform.Position = newXZ
                end
            end
        end)
        
        -- Clean up on character death
        character:WaitForChild("Humanoid").Died:Connect(destroyPlatform)
        
        print("✅ Platform enabled")
    end)
    
    if not success then
        warn("Platform enable error: " .. tostring(err))
        destroyPlatform()
    end
end

local function disablePlatform()
    local success, err = pcall(function()
        destroyPlatform()
        print("❌ Platform disabled")
    end)
    
    if not success then
        warn("Platform disable error: " .. tostring(err))
    end
end

local platformSwitch = createSwitch(_G.movementSection, "Platform", CONFIG.Movement.Rise.Enabled, function(on)
    print("🔧 Platform switch toggled:", on)
    CONFIG.Movement.Rise.Enabled = on
    _G.saveSettings()
    _G.SavedToggleStates.Rise = on
    if on then
        if player.Character then
            print("✅ Enabling Platform on existing character")
            enablePlatform(player.Character)
        else
            print("⚠️ No character found, Platform will be enabled on next spawn")
        end
        -- Auto-create side toggle when enabled
        _G.createCircularToggleUI("Platform", function() return CONFIG.Movement.Rise.Enabled end, function(state)
            CONFIG.Movement.Rise.Enabled = state
            _G.saveSettings()
            if state then
                if player.Character then enablePlatform(player.Character) end
            else
                disablePlatform()
            end
        end)
    else
        print("❌ Disabling Platform")
        disablePlatform()
        -- Remove side toggle when disabled
        local existingToggle = _G.circularToggleGui:FindFirstChild("PlatformToggleUI")
        if existingToggle then
            _G.OpenCircularToggles["Platform"] = nil
            existingToggle:Destroy()
            _G.saveSettings()
        end
    end
    _G.saveSettings()
end)


local helicopterSwitch = createSwitch(_G.movementSection, "Helicopter", CONFIG.Movement.Helicopter.Enabled, function(on)
    CONFIG.Movement.Helicopter.Enabled = on
    _G.saveSettings()
    if on then
        if player.Character then
            enableHelicopter(player.Character)
        end
        -- Auto-create side toggle when enabled
        _G.createCircularToggleUI("Helicopter", function() return CONFIG.Movement.Helicopter.Enabled end, function(state)
            CONFIG.Movement.Helicopter.Enabled = state
            _G.saveSettings()
            if state then
                if player.Character then enableHelicopter(player.Character) end
            else
                disableHelicopter()
            end
        end)
    else
        disableHelicopter()
        -- Remove side toggle when disabled
        local existingToggle = _G.circularToggleGui:FindFirstChild("HelicopterToggleUI")
        if existingToggle then
            _G.OpenCircularToggles["Helicopter"] = nil
            existingToggle:Destroy()
            _G.saveSettings()
        end
    end
    -- ActiveFeatures removed
    _G.saveSettings()
end)


--- Fling System
createSectionHeader(_G.movementSection, "Fling System")

-- Fling variables (Global to save local registers)
_G.SelectedPlayer = nil
_G.Flinging = false
_G.FlingConnection = nil
_G.GrappleTool = nil

-- Find grapple tool function
_G.findGrapple = function()
    local backpack = player:FindFirstChild("Backpack")
    if not backpack then return nil end
    _G.GrappleTool = backpack:FindFirstChild("Grapple Hook") or backpack:FindFirstChild("GrappleHook")
    if not _G.GrappleTool then
        _G.GrappleTool = workspace:FindFirstChild("Grapple Hook") or workspace:FindFirstChild("GrappleHook")
        if _G.GrappleTool and _G.GrappleTool:IsA("Tool") then
            _G.GrappleTool.Parent = backpack
        end
    end
    return _G.GrappleTool
end

-- Equip grapple function
_G.equipGrapple = function()
    if not _G.findGrapple() then return false end
    local char = player.Character
    if not char then return false end
    local equippedTool = char:FindFirstChild("Grapple Hook") or char:FindFirstChild("GrappleHook")
    if equippedTool then
        _G.GrappleTool = equippedTool
        return true
    end
    if _G.GrappleTool then
        _G.GrappleTool.Parent = char
        return true
    end
    return false
end

-- Start fling function
_G.startFling = function()
    if _G.Flinging or not _G.SelectedPlayer then return end
    _G.Flinging = true
    
    if not _G.equipGrapple() then
        warn("Grapple not found")
        _G.Flinging = false
        return
    end

    local spin, power = 0, 220

    _G.FlingConnection = RunService.Heartbeat:Connect(function()
        local char = player.Character
        if not char or not _G.SelectedPlayer or not _G.SelectedPlayer.Character then
            return
        end

        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        local targetRoot = _G.SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetHumanoid = _G.SelectedPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid or not rootPart or not targetRoot or not targetHumanoid then return end

        local distance = (targetRoot.Position - rootPart.Position).Magnitude
        local net = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"))
        net:RemoteEvent("UseItem"):FireServer(distance / 120)

        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        targetHumanoid:ChangeState(Enum.HumanoidStateType.Physics)

        spin = spin + 12
        local offset = Vector3.new(math.sin(math.rad(spin)) * 2.5, 1.5, math.cos(math.rad(spin)) * 2.5)
        local prediction = targetRoot.Velocity * 0.3
        local targetPos = targetRoot.Position + offset + prediction
        local direction = (targetPos - rootPart.Position).Unit
        local velocity = direction * power + Vector3.new(0, 65, 0)

        local bodyVelocity = rootPart:FindFirstChild("FlightPower") or Instance.new("BodyVelocity")
        bodyVelocity.Name = "FlightPower"
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = velocity
        bodyVelocity.P = 9000
        bodyVelocity.Parent = rootPart

        local distanceTo = (targetRoot.Position - rootPart.Position).Magnitude
        if distanceTo < 7 then
            local targetBodyVelocity = targetRoot:FindFirstChild("TargetFling") or Instance.new("BodyVelocity")
            targetBodyVelocity.Name = "TargetFling"
            targetBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            targetBodyVelocity.Velocity = (targetRoot.Position - rootPart.Position).Unit * 130 + Vector3.new(0, 100, 0)
            targetBodyVelocity.P = 6500
            targetBodyVelocity.Parent = targetRoot

            local targetSpin = targetRoot:FindFirstChild("TargetSpin") or Instance.new("BodyAngularVelocity")
            targetSpin.Name = "TargetSpin"
            targetSpin.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            targetSpin.AngularVelocity = Vector3.new((math.random()-0.5)*25,(math.random()-0.5)*25,(math.random()-0.5)*25)
            targetSpin.P = 4500
            targetSpin.Parent = targetRoot
        end
    end)
end

-- Stop fling function
_G.stopFling = function()
    if not _G.Flinging then return end
    _G.Flinging = false

    if _G.FlingConnection then
        _G.FlingConnection:Disconnect()
        _G.FlingConnection = nil
    end

    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Running) end
        if rootPart then
            local bodyVelocity = rootPart:FindFirstChild("FlightPower")
            if bodyVelocity then bodyVelocity:Destroy() end
        end
    end

    if _G.SelectedPlayer and _G.SelectedPlayer.Character then
        local targetRoot = _G.SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetHumanoid = _G.SelectedPlayer.Character:FindFirstChildOfClass("Humanoid")
        if targetHumanoid then targetHumanoid:ChangeState(Enum.HumanoidStateType.Running) end
        if targetRoot then
            local targetBodyVelocity = targetRoot:FindFirstChild("TargetFling")
            if targetBodyVelocity then targetBodyVelocity:Destroy() end
            local targetSpin = targetRoot:FindFirstChild("TargetSpin")
            if targetSpin then targetSpin:Destroy() end
        end
    end
end


-- Fling toggle button with better status feedback
local flingToggleButton = nil

local function createFlingButton()
    flingToggleButton = createButton(_G.movementSection, "Fling Em", function()
        local success, err = pcall(function()
            if not flingToggleButton then return end
            
            if _G.Flinging then
                _G.stopFling()
                flingToggleButton.Text = "Fling Em"
                flingToggleButton.BackgroundColor3 = CONFIG.Colors.Background
                flingToggleButton.TextColor3 = CONFIG.Colors.Text
            else
                if not _G.SelectedPlayer then
                    warn("Please select a player first!")
                    return
                end
                _G.startFling()
                flingToggleButton.Text = "Fling Em"
                flingToggleButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255) -- Bright blue
                flingToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text for contrast
            end
        end)
        if not success then
            warn("Fling button error: " .. tostring(err))
        end
    end)
end

createFlingButton()

-- Function to update fling button status
local function updateFlingButtonStatus()
    local success, err = pcall(function()
        if not flingToggleButton then return end
        
        if _G.Flinging then
            flingToggleButton.Text = "Fling Em"
            flingToggleButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255) -- Bright blue
            flingToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text for contrast
        else
            flingToggleButton.Text = "Fling Em"
            flingToggleButton.BackgroundColor3 = CONFIG.Colors.Background
            flingToggleButton.TextColor3 = CONFIG.Colors.Text
        end
    end)
    if not success then
        warn("Update fling button status error: " .. tostring(err))
    end
end

-- Update button when player is selected
local originalPlayerSelectButton = playerSelectButton
playerSelectButton = createButton(_G.movementSection, "Select Player for Fling", function()
    local success, err = pcall(function()
        local players = Players:GetPlayers()
        local otherPlayers = {}
        for _, p in pairs(players) do
            if p ~= player then
                table.insert(otherPlayers, p)
            end
        end
        
        if #otherPlayers == 0 then
            playerSelectButton.Text = "No Players Available"
            playerSelectButton.BackgroundColor3 = CONFIG.Colors.Danger
            _G.SelectedPlayer = nil
            updateFlingButtonStatus()
        return
    end
    
    -- Create player selection UI
    local playerSelectGui = createProtectedScreenGui("PlayerSelectGui")
    
    -- Main frame (draggable)
    local selectFrame = Instance.new("Frame")
    selectFrame.Size = UDim2.new(0, 300, 0, math.min(400, 60 + (#otherPlayers * 45)))
    selectFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    selectFrame.BackgroundColor3 = CONFIG.Colors.Panel
    selectFrame.Parent = playerSelectGui
    Instance.new("UICorner", selectFrame).CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke", selectFrame)
    stroke.Thickness = 2
    stroke.Color = CONFIG.Colors.Stroke
    stroke.Transparency = 0.2
    
    -- Dragging functionality
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    local function startDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = selectFrame.Position
            stroke.Transparency = 0 -- Visual feedback
        end
    end
    
    local function updateDrag(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            selectFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
    
    local function endDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            stroke.Transparency = 0.2 -- Reset visual feedback
        end
    end
    
    -- Apply dragging to the frame
    selectFrame.InputBegan:Connect(startDrag)
    selectFrame.InputChanged:Connect(updateDrag)
    selectFrame.InputEnded:Connect(endDrag)
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -60, 0, 40)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Select Player to Fling"
    titleLabel.TextColor3 = CONFIG.Colors.Text
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = selectFrame
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 10)
    closeBtn.BackgroundColor3 = CONFIG.Colors.Danger
    closeBtn.Text = "x"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = selectFrame
    closeBtn.ZIndex = 10
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 15)
    
    -- Scroll frame for players
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 1, -60)
    scrollFrame.Position = UDim2.new(0, 10, 0, 50)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = CONFIG.Colors.Accent
    scrollFrame.Parent = selectFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = scrollFrame
    
    -- Create player buttons
    for i, targetPlayer in ipairs(otherPlayers) do
        local playerBtn = Instance.new("TextButton")
        playerBtn.Size = UDim2.new(1, -10, 0, 35)
        playerBtn.BackgroundColor3 = CONFIG.Colors.Background
        playerBtn.Text = targetPlayer.Name .. " (ID: " .. targetPlayer.UserId .. ")"
        playerBtn.TextColor3 = CONFIG.Colors.Text
        playerBtn.TextSize = 14
        playerBtn.Font = Enum.Font.Gotham
        playerBtn.AutoButtonColor = false
        playerBtn.Parent = scrollFrame
        Instance.new("UICorner", playerBtn).CornerRadius = UDim.new(0, 6)
        
        local btnStroke = Instance.new("UIStroke", playerBtn)
        btnStroke.Thickness = 1
        btnStroke.Color = CONFIG.Colors.Stroke
        btnStroke.Transparency = 0.5
        
        -- Hover effects
        playerBtn.MouseEnter:Connect(function()
            playerBtn.BackgroundColor3 = CONFIG.Colors.Accent
            btnStroke.Transparency = 0.2
        end)
        
        playerBtn.MouseLeave:Connect(function()
            playerBtn.BackgroundColor3 = CONFIG.Colors.Background
            btnStroke.Transparency = 0.5
        end)
        
        -- Selection
        playerBtn.MouseButton1Click:Connect(function()
            _G.SelectedPlayer = targetPlayer
            playerSelectButton.Text = "Selected: " .. targetPlayer.Name
            playerSelectButton.BackgroundColor3 = CONFIG.Colors.Accent
            playerSelectGui:Destroy()
            updateFlingButtonStatus() -- Update fling button status
        end)
        
        -- Mobile support for player selection
        playerBtn.TouchTap:Connect(function()
            _G.SelectedPlayer = targetPlayer
            playerSelectButton.Text = "Selected: " .. targetPlayer.Name
            playerSelectButton.BackgroundColor3 = CONFIG.Colors.Accent
            playerSelectGui:Destroy()
            updateFlingButtonStatus() -- Update fling button status
        end)
    end
    
    -- Update scroll canvas size
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end)
    
    -- Close button functionality
    closeBtn.MouseButton1Click:Connect(function()
        playerSelectGui:Destroy()
    end)
    
    -- Mobile support for close button
    closeBtn.TouchTap:Connect(function()
        playerSelectGui:Destroy()
    end)
    
    -- Click outside to close (use a frame instead of ScreenGui)
    local backgroundFrame = Instance.new("Frame")
    backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
    backgroundFrame.Position = UDim2.new(0, 0, 0, 0)
    backgroundFrame.BackgroundTransparency = 1
    backgroundFrame.Parent = playerSelectGui
    
    backgroundFrame.MouseButton1Click:Connect(function()
        playerSelectGui:Destroy()
    end)
    
    -- Mobile support for click outside to close
    backgroundFrame.TouchTap:Connect(function()
        playerSelectGui:Destroy()
    end)
    
    selectFrame.MouseButton1Click:Connect(function(input)
        input.Handled = true -- Prevent closing when clicking inside the frame
    end)
    end)
    if not success then
        warn("Player selection error: " .. tostring(err))
    end
end)


-- Visual Section
createSectionHeader(_G.visualSection, "ESP Controls")
_G.playerESPSwitch = createSwitch(_G.visualSection, "Player ESP", _G.SavedToggleStates and _G.SavedToggleStates.PlayerESP or false, function(on)
    if on then
        enableESP()
        -- Auto-create side toggle when enabled
        _G.createCircularToggleUI("Player ESP", function() return _G.ESP_Enabled end, function(state)
            if state then enableESP() else disableESP() end
        end)
    else
        disableESP()
        -- Remove side toggle when disabled
        local existingToggle = _G.circularToggleGui:FindFirstChild("Player ESPToggleUI")
        if existingToggle then
            _G.OpenCircularToggles["Player ESP"] = nil
            existingToggle:Destroy()
            _G.saveSettings()
        end
    end
    -- ActiveFeatures removed
    _G.saveSettings()
end)

_G.plotESPSwitch = createSwitch(_G.visualSection, "Plot ESP", _G.SavedToggleStates and _G.SavedToggleStates.PlotESP or false, function(on)
    if on then
        enablePlotESP()
        -- Auto-create side toggle when enabled
        _G.createCircularToggleUI("Plot ESP", function() return _G.PlotESP_Enabled end, function(state)
            if state then enablePlotESP() else disablePlotESP() end
        end)
    else
        disablePlotESP()
        -- Remove side toggle when disabled
        local existingToggle = _G.circularToggleGui:FindFirstChild("Plot ESPToggleUI")
        if existingToggle then
            _G.OpenCircularToggles["Plot ESP"] = nil
            existingToggle:Destroy()
            _G.saveSettings()
        end
    end
    -- ActiveFeatures removed
    _G.saveSettings()
end)

-- Plot Time ESP switch will be created later after functions are defined

-- Patched Section
createSectionHeader(_G.patchedSection, "Patched Features")
local invisibilitySwitch = createSwitch(_G.patchedSection, "Invisibility (patched)", _G.SavedToggleStates and _G.SavedToggleStates.Invisibility or false, function(on)
    setInvisibility(on)
    if on then
        -- Auto-create side toggle when enabled
        _G.createCircularToggleUI("Invisibility", function() return invisibilitySwitch.get() end, function(state) invisibilitySwitch.set(state) end)
    else
        -- Remove side toggle when disabled
        local existingToggle = _G.circularToggleGui:FindFirstChild("InvisibilityToggleUI")
        if existingToggle then
            _G.OpenCircularToggles["Invisibility"] = nil
            existingToggle:Destroy()
            _G.saveSettings()
        end
    end
    -- ActiveFeatures removed
    _G.saveSettings()
end)
local _, flingSwitchInstance = setupFlingControl(_G.patchedSection)


-- Server Section (Global Variables to Save Local Registers)
_G.ServerHopActive = false
_G.CurrentServerId = game.JobId

_G.getServerList = function()
    local ok, result = pcall(function()
        local response = _G.safeHttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        if not response then
            return {}
        end
        return HttpService:JSONDecode(response)
    end)
    return ok and result and result.data and result.data or {}
end

_G.joinBiggestServer = function()
    pcall(function()
        local servers = _G.getServerList()
        local biggest, maxPlayers = nil, 0
        for _, server in ipairs(servers) do
            if server.id ~= _G.CurrentServerId and server.playing and server.maxPlayers and 
               server.playing < server.maxPlayers and server.playing > maxPlayers then
                biggest, maxPlayers = server, server.playing
            end
        end
        if biggest then
            print("🔄 Joining biggest server with " .. biggest.playing .. "/" .. biggest.maxPlayers .. " players")
            TeleportService:TeleportToPlaceInstance(game.PlaceId, biggest.id, player)
        else
            game.StarterGui:SetCore("SendNotification", {Title = "Ken HUB", Text = "No available servers found!", Duration = 3})
        end
    end)
end

_G.joinSmallestServer = function()
    pcall(function()
        local servers = _G.getServerList()
        local smallest, minPlayers = nil, math.huge
        for _, server in ipairs(servers) do
            if server.id ~= _G.CurrentServerId and server.playing and server.maxPlayers and 
               server.playing < server.maxPlayers and server.playing < minPlayers then
                smallest, minPlayers = server, server.playing
            end
        end
        if smallest then
            print("🔄 Joining smallest server with " .. smallest.playing .. "/" .. smallest.maxPlayers .. " players")
            TeleportService:TeleportToPlaceInstance(game.PlaceId, smallest.id, player)
        else
            game.StarterGui:SetCore("SendNotification", {Title = "ken HUB", Text = "No available servers found!", Duration = 3})
        end
    end)
end

_G.rejoinServer = function()
    pcall(function()
        print("🔄 Rejoining current server...")
        TeleportService:TeleportToPlaceInstance(game.PlaceId, _G.CurrentServerId, player)
    end)
end

_G.toggleServerHop = function(on)
    _G.ServerHopActive = on
    if on then
        -- Start server hopping
        task.spawn(function()
            while _G.ServerHopActive do
                local success, err = pcall(function()
                    local serverList = _G.getServerList()
                    if serverList and #serverList > 0 then
                        -- Filter out current server and full servers
                        local validServers = {}
                        for _, server in ipairs(serverList) do
                            if server.id and server.id ~= _G.CurrentServerId and 
                               server.playing and server.maxPlayers and 
                               server.playing < server.maxPlayers then
                                table.insert(validServers, server)
                            end
                        end
                        
                        if #validServers > 0 then
                            local target = validServers[math.random(1, #validServers)]
                            print("🔄 Hopping to server with " .. target.playing .. "/" .. target.maxPlayers .. " players")
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, target.id, player)
                        else
                            warn("No valid servers available for hopping")
                        end
                    else
                        warn("No servers available for hopping")
                    end
                end)
                if not success then
                    warn("Server hop failed: " .. tostring(err) .. ", retrying in 10 seconds...")
                    task.wait(10) -- Wait longer on failure
                else
                    task.wait(15) -- Wait longer between successful hops
                end
            end
        end)
    end
end

createSectionHeader(_G.serverSection, "Server Options")
local serverHopSwitch = createSwitch(_G.serverSection, "Auto Server Hop", false, function(on)
    _G.toggleServerHop(on)
    -- ActiveFeatures removed
    _G.saveSettings()
end)

-- Server Buttons
createButton(_G.serverSection, "Rejoin Server", _G.rejoinServer)
createButton(_G.serverSection, "Join Biggest Server", _G.joinBiggestServer)
createButton(_G.serverSection, "Join Smallest Server", _G.joinSmallestServer)

-- Automation Section
createSectionHeader(_G.automationSection, "Pet Snipe")
local petSnipeInfo = Instance.new("TextLabel")
petSnipeInfo.Size = UDim2.new(1, -20, 0, 44)
petSnipeInfo.BackgroundTransparency = 1
petSnipeInfo.Text = "Secili rarity ve min M/s hedeflerini otomatik calip base'e getirir."
petSnipeInfo.TextColor3 = CONFIG.Colors.SubText
petSnipeInfo.TextSize = 13
petSnipeInfo.Font = Enum.Font.Gotham
petSnipeInfo.TextXAlignment = Enum.TextXAlignment.Left
petSnipeInfo.TextYAlignment = Enum.TextYAlignment.Top
petSnipeInfo.TextWrapped = true
petSnipeInfo.Parent = _G.automationSection

local petSnipeSwitch = createSwitch(_G.automationSection, "Pet Snipe", CONFIG.Automation.PetSnipe.Enabled, function(on)
    CONFIG.Automation.PetSnipe.Enabled = on
    _G.saveSettings()
    if on then enablePetSnipe() else disablePetSnipe() end
end)
_G.petSnipeSwitch = petSnipeSwitch

createSectionHeader(_G.automationSection, "Hizli Katalog Preset")
createButton(_G.automationSection, "Rare ve ustu", function() _G.applyPetSnipeMinTier("Rare") end)
createButton(_G.automationSection, "Epic ve ustu", function() _G.applyPetSnipeMinTier("Epic") end)
createButton(_G.automationSection, "Legendary ve ustu", function() _G.applyPetSnipeMinTier("Legendary") end)
createButton(_G.automationSection, "Secret ve ustu", function() _G.applyPetSnipeMinTier("Secret") end)
createButton(_G.automationSection, "Sadece Mythic+", function() _G.applyPetSnipeMinTier("Mythic") end)

createSectionHeader(_G.automationSection, "Ozel Rarity Secimi")
_G.petSnipeRaritySwitches = {}
for _, tier in ipairs(PET_TIER_ORDER) do
    local label = PET_TIER_LABELS[tier] or tier
    local sw = createSwitch(_G.automationSection, label, CONFIG.Automation.PetSnipe.Rarities[tier] == true, function(on)
        ensurePetSnipeRarities()
        CONFIG.Automation.PetSnipe.Rarities[tier] = on
        CONFIG.Automation.PetSnipe.MinTier = "Custom"
        _G.saveSettings()
    end)
    _G.petSnipeRaritySwitches[tier] = sw
end

createSectionHeader(_G.automationSection, "Min Generation Filtresi")
createSwitch(_G.automationSection, "Min M/s filtresi aktif", CONFIG.Automation.PetSnipe.UseMinGeneration ~= false, function(on)
    CONFIG.Automation.PetSnipe.UseMinGeneration = on
    _G.saveSettings()
end)
createNumberInput(_G.automationSection, "Min M/s (ornek: 100 = 100M)", (CONFIG.Automation.PetSnipe.MinGeneration or 100e6) / 1e6, function(value)
    CONFIG.Automation.PetSnipe.MinGeneration = math.clamp(value, 0, 99999) * 1e6
    _G.saveSettings()
end)


-- Brainrot ESP toggle will be created after function definitions







-- Settings Section
createSectionHeader(settingsContent, "ESP Settings")

-- Player ESP Toggles
createSwitch(settingsContent, "Show Player Distance", CONFIG.ESP.PlayerESP.ShowDistance, function(on)
    local success, _ = pcall(function()
        CONFIG.ESP.PlayerESP.ShowDistance = on
        _G.saveSettings()
        -- Recreate all player ESP billboards
        if ESP_Enabled then
            for plr, data in pairs(ESP_Data) do
                if typeof(plr) == "Instance" and data.billboard then
                    data.billboard:Destroy()
                    local newBillboard, newDistanceLabel, newIconFrame = createBillboardGui(plr, plr.Character)
                    if newBillboard then
                        data.billboard = newBillboard
                        data.distanceLabel = newDistanceLabel
                        data.iconFrame = newIconFrame
                    end
                end
            end
        end
    end)
    if not success then
        warn("Failed to update Player ESP Distance setting")
    end
end)

createSwitch(settingsContent, "Show Player Items", CONFIG.ESP.PlayerESP.ShowItems, function(on)
    local success, _ = pcall(function()
        CONFIG.ESP.PlayerESP.ShowItems = on
        _G.saveSettings()
        -- Recreate all player ESP billboards
        if ESP_Enabled then
            for plr, data in pairs(ESP_Data) do
                if typeof(plr) == "Instance" and data.billboard then
                    data.billboard:Destroy()
                    local newBillboard, newDistanceLabel, newIconFrame = createBillboardGui(plr, plr.Character)
                    if newBillboard then
                        data.billboard = newBillboard
                        data.distanceLabel = newDistanceLabel
                        data.iconFrame = newIconFrame
                    end
                end
            end
        end
    end)
    if not success then
        warn("Failed to update Player ESP Items setting")
    end
end)

-- Player ESP Color Picker
createSectionHeader(settingsContent, "Player ESP Color")
local playerColorButton = Instance.new("TextButton")
playerColorButton.Size = UDim2.new(1, 0, 0, 40)
playerColorButton.BackgroundColor3 = CONFIG.ESP.PlayerESP.HighlightColor
playerColorButton.Text = "Pick Player ESP Color"
playerColorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
playerColorButton.Font = Enum.Font.GothamBold
playerColorButton.TextSize = 16
playerColorButton.AutoButtonColor = false
playerColorButton.Parent = settingsContent
Instance.new("UICorner", playerColorButton).CornerRadius = UDim.new(0, 8)
local playerColorStroke = Instance.new("UIStroke", playerColorButton)
playerColorStroke.Thickness = 1
playerColorStroke.Color = Color3.fromRGB(255, 255, 255)
playerColorStroke.Transparency = 0.3

playerColorButton.MouseButton1Click:Connect(function()
    local success, _ = pcall(function()
        -- Simple color picker using random colors for demo
        local colors = {
            Color3.fromRGB(255, 0, 0),    -- Red
            Color3.fromRGB(0, 255, 0),    -- Green
            Color3.fromRGB(0, 0, 255),    -- Blue
            Color3.fromRGB(255, 255, 0),  -- Yellow
            Color3.fromRGB(255, 0, 255),  -- Magenta
            Color3.fromRGB(0, 255, 255),  -- Cyan
            Color3.fromRGB(255, 165, 0),  -- Orange
            Color3.fromRGB(128, 0, 128),  -- Purple
        }
        local randomColor = colors[math.random(1, #colors)]
        CONFIG.ESP.PlayerESP.HighlightColor = randomColor
        playerColorButton.BackgroundColor3 = randomColor
        _G.saveSettings()
        -- Update existing highlights with new color
        for plr, data in pairs(_G.ESP_Data) do
            if typeof(plr) == "Instance" and data.highlight and plr.Character then
                -- Update existing highlight color
                pcall(function() 
                    data.highlight.FillColor = CONFIG.ESP.PlayerESP.HighlightColor
                    data.highlight.OutlineColor = CONFIG.ESP.PlayerESP.HighlightColor
                    print("🎨 Updated Player ESP color for: " .. plr.Name)
                end)
            end
        end
        
        -- Also update any existing highlights in the character
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local existingHighlight = plr.Character:FindFirstChildOfClass("Highlight")
                if existingHighlight then
                    pcall(function()
                        existingHighlight.FillColor = CONFIG.ESP.PlayerESP.HighlightColor
                        existingHighlight.OutlineColor = CONFIG.ESP.PlayerESP.HighlightColor
                        print("🎨 Updated existing highlight color for: " .. plr.Name)
                    end)
                end
            end
        end
    end)
    if not success then
        warn("Failed to update Player ESP Color")
    end
end)

-- Plot ESP Toggles
createSectionHeader(settingsContent, "Plot ESP Settings")
createSwitch(settingsContent, "Show Plot Distance", CONFIG.ESP.PlotESP.ShowDistance, function(on)
    local success, _ = pcall(function()
        CONFIG.ESP.PlotESP.ShowDistance = on
        _G.saveSettings()
        -- Recreate all plot ESP billboards
        if _G.PlotESP_Enabled then
            for plot, data in pairs(_G.PlotESP_Data) do
                if typeof(plot) == "Instance" and data.billboard then
                    data.billboard:Destroy()
                    local newBillboard, newDistanceLabel, newOwnerLabel, newTimeLabel = createPlotBillboardGui(plot)
                    if newBillboard then
                        data.billboard = newBillboard
                        data.distanceLabel = newDistanceLabel
                        data.ownerLabel = newOwnerLabel
                        data.timeLabel = newTimeLabel
                    end
                end
            end
        end
    end)
    if not success then
        warn("Failed to update Plot ESP Distance setting")
    end
end)

createSwitch(settingsContent, "Show Plot Owner", CONFIG.ESP.PlotESP.ShowOwner, function(on)
    local success, _ = pcall(function()
        CONFIG.ESP.PlotESP.ShowOwner = on
        _G.saveSettings()
        -- Recreate all plot ESP billboards
        if _G.PlotESP_Enabled then
            for plot, data in pairs(_G.PlotESP_Data) do
                if typeof(plot) == "Instance" and data.billboard then
                    data.billboard:Destroy()
                    local newBillboard, newDistanceLabel, newOwnerLabel, newTimeLabel = createPlotBillboardGui(plot)
                    if newBillboard then
                        data.billboard = newBillboard
                        data.distanceLabel = newDistanceLabel
                        data.ownerLabel = newOwnerLabel
                        data.timeLabel = newTimeLabel
                    end
                end
            end
        end
    end)
    if not success then
        warn("Failed to update Plot ESP Owner setting")
    end
end)

createSwitch(settingsContent, "Show Plot Time", CONFIG.ESP.PlotESP.ShowTime, function(on)
    local success, _ = pcall(function()
        CONFIG.ESP.PlotESP.ShowTime = on
        _G.saveSettings()
        -- Recreate all plot ESP billboards
        if _G.PlotESP_Enabled then
            for plot, data in pairs(_G.PlotESP_Data) do
                if typeof(plot) == "Instance" and data.billboard then
                    data.billboard:Destroy()
                    local newBillboard, newDistanceLabel, newOwnerLabel, newTimeLabel = createPlotBillboardGui(plot)
                    if newBillboard then
                        data.billboard = newBillboard
                        data.distanceLabel = newDistanceLabel
                        data.ownerLabel = newOwnerLabel
                        data.timeLabel = newTimeLabel
                    end
                end
            end
        end
    end)
    if not success then
        warn("Failed to update Plot ESP Time setting")
    end
end)

-- Plot ESP Color Picker
createSectionHeader(settingsContent, "Plot ESP Color")
local plotColorButton = Instance.new("TextButton")
plotColorButton.Size = UDim2.new(1, 0, 0, 40)
plotColorButton.BackgroundColor3 = CONFIG.ESP.PlotESP.HighlightColor
plotColorButton.Text = "Pick Plot ESP Color"
plotColorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
plotColorButton.Font = Enum.Font.GothamBold
plotColorButton.TextSize = 16
plotColorButton.AutoButtonColor = false
plotColorButton.Parent = settingsContent
Instance.new("UICorner", plotColorButton).CornerRadius = UDim.new(0, 8)
local plotColorStroke = Instance.new("UIStroke", plotColorButton)
plotColorStroke.Thickness = 1
plotColorStroke.Color = Color3.fromRGB(255, 255, 255)
plotColorStroke.Transparency = 0.3

plotColorButton.MouseButton1Click:Connect(function()
    local success, _ = pcall(function()
        -- Simple color picker using random colors for demo
        local colors = {
            Color3.fromRGB(255, 0, 0),    -- Red
            Color3.fromRGB(0, 255, 0),    -- Green
            Color3.fromRGB(0, 0, 255),    -- Blue
            Color3.fromRGB(255, 255, 0),  -- Yellow
            Color3.fromRGB(255, 0, 255),  -- Magenta
            Color3.fromRGB(0, 255, 255),  -- Cyan
            Color3.fromRGB(255, 165, 0),  -- Orange
            Color3.fromRGB(128, 0, 128),  -- Purple
        }
        local randomColor = colors[math.random(1, #colors)]
        CONFIG.ESP.PlotESP.HighlightColor = randomColor
        plotColorButton.BackgroundColor3 = randomColor
        _G.saveSettings()
        -- Update existing highlights
        for plot, data in pairs(_G.PlotESP_Data) do
            if typeof(plot) == "Instance" and data.highlight then
                data.highlight.OutlineColor = CONFIG.ESP.PlotESP.HighlightColor
            end
        end
    end)
    if not success then
        warn("Failed to update Plot ESP Color")
    end
end)

-- Plot Time Size Slider
createSectionHeader(settingsContent, "Plot Time Size")
local timeSizeSlider = Instance.new("Frame")
timeSizeSlider.Size = UDim2.new(1, 0, 0, 50)
timeSizeSlider.BackgroundTransparency = 1
timeSizeSlider.Parent = settingsContent

local timeSizeLabel = Instance.new("TextLabel")
timeSizeLabel.Size = UDim2.new(1, 0, 0, 20)
timeSizeLabel.Position = UDim2.new(0, 0, 0, 0)
timeSizeLabel.BackgroundTransparency = 1
timeSizeLabel.Text = "Plot Time Text Size: " .. CONFIG.ESP.PlotESP.TimeTextSize
timeSizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timeSizeLabel.Font = Enum.Font.Gotham
timeSizeLabel.TextSize = 14
timeSizeLabel.TextXAlignment = Enum.TextXAlignment.Left
timeSizeLabel.Parent = timeSizeSlider

local timeSizeBar = Instance.new("Frame")
timeSizeBar.Size = UDim2.new(1, 0, 0, 20)
timeSizeBar.Position = UDim2.new(0, 0, 0, 25)
timeSizeBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
timeSizeBar.Parent = timeSizeSlider
Instance.new("UICorner", timeSizeBar).CornerRadius = UDim.new(0, 10)

local timeSizeFill = Instance.new("Frame")
timeSizeFill.Size = UDim2.new((CONFIG.ESP.PlotESP.TimeTextSize - 16) / (48 - 16), 0, 1, 0)
timeSizeFill.Position = UDim2.new(0, 0, 0, 0)
timeSizeFill.BackgroundColor3 = CONFIG.Colors.Accent
timeSizeFill.Parent = timeSizeBar
Instance.new("UICorner", timeSizeFill).CornerRadius = UDim.new(0, 10)

local timeSizeButton = Instance.new("TextButton")
timeSizeButton.Size = UDim2.new(0, 20, 0, 20)
local relativeX = math.clamp((CONFIG.ESP.PlotESP.TimeTextSize - 16) / (48 - 16), 0, 1)
timeSizeButton.Position = UDim2.new(relativeX, -10, 0, 0)
timeSizeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
timeSizeButton.Text = ""
timeSizeButton.AutoButtonColor = false
timeSizeButton.Parent = timeSizeBar
Instance.new("UICorner", timeSizeButton).CornerRadius = UDim.new(0, 10)

--=========================================================
-- Plot Time ESP System
--=========================================================
_G.PlotTimeESP_Enabled = false
_G.PlotTimeESP_Data = {}

local function createPlotTimeBillboard(plot)
    local success, billboard, timeLabel = pcall(function()
        local spawnPart = plot:FindFirstChild("Spawn")
        if not spawnPart or not spawnPart:IsA("BasePart") then
            warn("No valid Spawn part found in plot: " .. plot.Name)
            return nil, nil
        end

        local gui = Instance.new("BillboardGui")
        gui.Name = "PlotTimeESP_Billboard"
        gui.Adornee = spawnPart
        gui.Size = UDim2.new(0, 200, 0, 30)
        gui.SizeOffset = Vector2.new(0, 0)
        gui.StudsOffset = Vector3.new(0, 8, 0)
        gui.AlwaysOnTop = true
        gui.MaxDistance = 10000
        gui.Parent = spawnPart

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = gui

        local timeLabel = Instance.new("TextLabel")
        timeLabel.Size = UDim2.new(1, 0, 1, 0)
        timeLabel.Position = UDim2.new(0, 0, 0, 0)
        timeLabel.Text = "Time: Calculating..."
        timeLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text for better visibility
        timeLabel.BackgroundTransparency = 1
        -- Important: disable TextScaled so slider-controlled TextSize takes effect
        timeLabel.TextScaled = false
        timeLabel.TextSize = CONFIG.ESP.PlotESP.TimeTextSize
        timeLabel.Font = Enum.Font.SourceSansBold -- Bold font for cleaner look
        timeLabel.TextStrokeTransparency = 0 -- Enable text stroke
        timeLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0) -- Black border
        timeLabel.Parent = frame
        local timeStroke = Instance.new("UIStroke", timeLabel)
        timeStroke.Thickness = 1.5 -- Thicker border for better visibility
        timeStroke.Color = Color3.fromRGB(0, 0, 0) -- Black border
        timeStroke.Transparency = 0 -- No transparency for solid border

        return gui, timeLabel
    end)
    if not success then
        warn("Failed to create plot time billboard for: " .. plot.Name)
        return nil, nil
    end
    return billboard, timeLabel
end

local function updatePlotTimeBillboard(plot, data)
    if not _G.PlotTimeESP_Enabled or not plot or not data.billboard or not data.billboard.Adornee then
        return
    end
    local success, _ = pcall(function()
        if data.timeLabel then
            local timeText = getRemainingTime(plot)
            data.timeLabel.Text = timeText or "Time: Unavailable"
        end
    end)
    if not success then
        warn("Failed to update plot time billboard for: " .. plot.Name)
    end
end

local function enablePlotTimeESP()
    if _G.PlotTimeESP_Enabled then return end
    local success, _ = pcall(function()
        local plotsFolder = workspace:FindFirstChild("Plots")
        if not plotsFolder then
            warn("Plots folder not found in workspace")
            return
        end

        _G.PlotTimeESP_Enabled = true
        _G.PlotTimeESP_Data = {} -- Clear existing data

        for _, plot in ipairs(plotsFolder:GetChildren()) do
            if plot:IsA("Model") then
                local plotConn = plot.AncestryChanged:Connect(function()
                    if not plot.Parent then
                        if _G.PlotTimeESP_Data[plot] then
                            if _G.PlotTimeESP_Data[plot].updateConn then
                                pcall(function() _G.PlotTimeESP_Data[plot].updateConn:Disconnect() end)
                            end
                            if _G.PlotTimeESP_Data[plot].billboard then
                                pcall(function() _G.PlotTimeESP_Data[plot].billboard:Destroy() end)
                            end
                            _G.PlotTimeESP_Data[plot] = nil
                        end
                    end
                end)
                _G.PlotTimeESP_Data[plot] = _G.PlotTimeESP_Data[plot] or {}
                _G.PlotTimeESP_Data[plot].plotConn = plotConn

                local billboard, timeLabel = createPlotTimeBillboard(plot)
                if billboard and timeLabel then
                    _G.PlotTimeESP_Data[plot].billboard = billboard
                    _G.PlotTimeESP_Data[plot].timeLabel = timeLabel
                    local lastUpdate = 0
                    _G.PlotTimeESP_Data[plot].updateConn = RunService.Heartbeat:Connect(function(deltaTime)
                        lastUpdate = lastUpdate + deltaTime
                        if lastUpdate >= CONFIG.ESP.UpdateInterval then
                            updatePlotTimeBillboard(plot, _G.PlotTimeESP_Data[plot])
                            lastUpdate = 0
                        end
                    end)
                end
            end
        end

        _G.PlotTimeESP_Data.plotsConn = plotsFolder.ChildAdded:Connect(function(plot)
            if plot:IsA("Model") then
                local plotConn = plot.AncestryChanged:Connect(function()
                    if not plot.Parent then
                        if _G.PlotTimeESP_Data[plot] then
                            if _G.PlotTimeESP_Data[plot].updateConn then
                                pcall(function() _G.PlotTimeESP_Data[plot].updateConn:Disconnect() end)
                            end
                            if _G.PlotTimeESP_Data[plot].billboard then
                                pcall(function() _G.PlotTimeESP_Data[plot].billboard:Destroy() end)
                            end
                            _G.PlotTimeESP_Data[plot] = nil
                        end
                    end
                end)
                _G.PlotTimeESP_Data[plot] = _G.PlotTimeESP_Data[plot] or {}
                _G.PlotTimeESP_Data[plot].plotConn = plotConn
                task.wait(1) -- Wait for plot to fully load
                local billboard, timeLabel = createPlotTimeBillboard(plot)
                if billboard and timeLabel then
                    _G.PlotTimeESP_Data[plot].billboard = billboard
                    _G.PlotTimeESP_Data[plot].timeLabel = timeLabel
                    local lastUpdate = 0
                    _G.PlotTimeESP_Data[plot].updateConn = RunService.Heartbeat:Connect(function(deltaTime)
                        lastUpdate = lastUpdate + deltaTime
                        if lastUpdate >= CONFIG.ESP.UpdateInterval then
                            updatePlotTimeBillboard(plot, _G.PlotTimeESP_Data[plot])
                            lastUpdate = 0
                        end
                    end)
                end
            end
        end)

        _G.PlotTimeESP_Data.plotsRemoveConn = plotsFolder.ChildRemoved:Connect(function(plot)
            if _G.PlotTimeESP_Data[plot] then
                if _G.PlotTimeESP_Data[plot].plotConn then
                    pcall(function() _G.PlotTimeESP_Data[plot].plotConn:Disconnect() end)
                end
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
        PlotTime_G.ESP_Enabled = false
    end
end

local function refreshPlotTimeESP()
    if not _G.PlotTimeESP_Enabled then return end
    local success, _ = pcall(function()
        -- Clear existing data
        for plot, data in pairs(_G.PlotTimeESP_Data) do
            if typeof(plot) == "Instance" then
                if data.plotConn then
                    pcall(function() data.plotConn:Disconnect() end)
                end
                if data.updateConn then
                    pcall(function() data.updateConn:Disconnect() end)
                end
                if data.billboard then
                    pcall(function() data.billboard:Destroy() end)
                end
                _G.PlotTimeESP_Data[plot] = nil
            end
        end
        
        -- Recreate for all existing plots
        local plotsFolder = workspace:FindFirstChild("Plots")
        if plotsFolder then
            for _, plot in ipairs(plotsFolder:GetChildren()) do
                if plot:IsA("Model") and plot:FindFirstChild("Spawn") then
                    local plotConn = plot.AncestryChanged:Connect(function()
                        if not plot.Parent then
                            if _G.PlotTimeESP_Data[plot] then
                                if _G.PlotTimeESP_Data[plot].updateConn then
                                    pcall(function() _G.PlotTimeESP_Data[plot].updateConn:Disconnect() end)
                                end
                                if _G.PlotTimeESP_Data[plot].billboard then
                                    pcall(function() _G.PlotTimeESP_Data[plot].billboard:Destroy() end)
                                end
                                _G.PlotTimeESP_Data[plot] = nil
                            end
                        end
                    end)
                    _G.PlotTimeESP_Data[plot] = _G.PlotTimeESP_Data[plot] or {}
                    _G.PlotTimeESP_Data[plot].plotConn = plotConn

                    local billboard, timeLabel = createPlotTimeBillboard(plot)
                    if billboard and timeLabel then
                        _G.PlotTimeESP_Data[plot].billboard = billboard
                        _G.PlotTimeESP_Data[plot].timeLabel = timeLabel
                        local lastUpdate = 0
                        _G.PlotTimeESP_Data[plot].updateConn = RunService.Heartbeat:Connect(function(deltaTime)
                            lastUpdate = lastUpdate + deltaTime
                            if lastUpdate >= CONFIG.ESP.UpdateInterval then
                                updatePlotTimeBillboard(plot, _G.PlotTimeESP_Data[plot])
                                lastUpdate = 0
                            end
                        end)
                    end
                end
            end
        end
    end)
    if not success then
        warn("Failed to refresh Plot Time ESP")
    end
end

local function disablePlotTimeESP()
    if not _G.PlotTimeESP_Enabled then return end
    local success, _ = pcall(function()
        _G.PlotTimeESP_Enabled = false
        if _G.PlotTimeESP_Data.plotsConn then
            pcall(function() _G.PlotTimeESP_Data.plotsConn:Disconnect() end)
            _G.PlotTimeESP_Data.plotsConn = nil
        end
        if _G.PlotTimeESP_Data.plotsRemoveConn then
            pcall(function() _G.PlotTimeESP_Data.plotsRemoveConn:Disconnect() end)
            _G.PlotTimeESP_Data.plotsRemoveConn = nil
        end
        if _G.PlotTimeESP_Data.playerAddedConn then
            pcall(function() _G.PlotTimeESP_Data.playerAddedConn:Disconnect() end)
            _G.PlotTimeESP_Data.playerAddedConn = nil
        end
        if _G.PlotTimeESP_Data.playerRemovingConn then
            pcall(function() _G.PlotTimeESP_Data.playerRemovingConn:Disconnect() end)
            _G.PlotTimeESP_Data.playerRemovingConn = nil
        end
        for plot, data in pairs(_G.PlotTimeESP_Data) do
            if typeof(plot) == "Instance" then
                if data.plotConn then
                    pcall(function() data.plotConn:Disconnect() end)
                end
                if data.updateConn then
                    pcall(function() data.updateConn:Disconnect() end)
                end
                if data.billboard then
                    pcall(function() data.billboard:Destroy() end)
                end
                _G.PlotTimeESP_Data[plot] = nil
            end
        end
        _G.PlotTimeESP_Data = {}
    end)
    if not success then
        warn("Failed to disable Plot Time ESP")
    end
end

-- [Ken HUB Part 3 export -> KenHubMid]
_G.KenHubMid = {
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
    enablePlotTimeESP = enablePlotTimeESP,
    disableHelicopter = disableHelicopter,
    disableGrappleFlight = disableGrappleFlight,
    disableInfiniteJump = disableInfiniteJump,
    disableFloat = disableFloat,
    disablePlatform = disablePlatform,
    enablePlatform = enablePlatform,
    timeSizeLabel = timeSizeLabel,
    timeSizeFill = timeSizeFill,
    timeSizeButton = timeSizeButton,
    timeSizeBar = timeSizeBar,
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
pcall(function() _G.KenHubStatus("Part 3/5 OK") end)
