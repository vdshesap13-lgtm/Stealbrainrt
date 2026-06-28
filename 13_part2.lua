-- Ken HUB Part 2: Ragdoll Desync only (register-safe)
local CONFIG = _G.KenHub_CONFIG
local createSwitch = _G.KenHub_createSwitch
if not CONFIG or not createSwitch then
    error("[Ken HUB] Part 1 yuklenmedi - Loader.lua kullan")
end

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
