--[[
    KEN HUB LOADER v5
    5 parca: 13_p1 .. 13_p5 | v1.73+
    loadstring(game:HttpGet(".../Loader.lua?v=173&t="..os.time()))()
]]

local BASE = "https://raw.githubusercontent.com/vdshesap13-lgtm/Stealbrainrt/main/"
local PARTS = {
    { "Part 1/5", BASE .. "13_p1.lua" },
    { "Part 2/5", BASE .. "13_p2.lua" },
    { "Part 3/5", BASE .. "13_p3.lua" },
    { "Part 4/5", BASE .. "13_p4.lua" },
    { "Part 5/5", BASE .. "13_p5.lua" },
}
local MIN_VERSION = "1.73"

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

repeat task.wait() until game:IsLoaded()

local LP = Players.LocalPlayer
if not LP then LP = Players.PlayerAdded:Wait() end

local function waitPlayerGui()
    local pg = LP:FindFirstChild("PlayerGui")
    if pg then return pg end
    for _ = 1, 120 do
        pg = LP:FindFirstChild("PlayerGui")
        if pg then return pg end
        task.wait(0.5)
    end
    if gethui then
        local ok, h = pcall(gethui)
        if ok and typeof(h) == "Instance" then return h end
    end
    return nil
end

local PlayerGui = waitPlayerGui()
if not PlayerGui then
    warn("[Ken HUB] PlayerGui yok - once oyuna tam gir")
    return
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "KenHub_Loader"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 2147483647
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

local function makeCorner(i, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = i
    return c
end

local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 360, 0, 130)
Panel.Position = UDim2.new(0.5, -180, 0, 12)
Panel.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
Panel.BorderSizePixel = 0
Panel.Parent = Gui
makeCorner(Panel, 10)
local ps = Instance.new("UIStroke", Panel)
ps.Color = Color3.fromRGB(14, 144, 210)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -16, 0, 28)
Title.Position = UDim2.new(0, 8, 0, 6)
Title.BackgroundTransparency = 1
Title.Text = "Ken HUB Loader v5"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel

local Status = Instance.new("TextLabel")
Status.Name = "Status"
Status.Size = UDim2.new(1, -16, 0, 88)
Status.Position = UDim2.new(0, 8, 0, 36)
Status.BackgroundTransparency = 1
Status.Text = "Baslatiliyor..."
Status.Font = Enum.Font.Gotham
Status.TextSize = 13
Status.TextColor3 = Color3.fromRGB(200, 200, 200)
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.TextYAlignment = Enum.TextYAlignment.Top
Status.TextWrapped = true
Status.Parent = Panel

local function setStatus(msg, isError)
    Status.Text = tostring(msg)
    Status.TextColor3 = isError and Color3.fromRGB(255, 120, 120) or Color3.fromRGB(200, 200, 200)
    ps.Color = isError and Color3.fromRGB(200, 60, 60) or Color3.fromRGB(14, 144, 210)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = isError and "Ken HUB Hata" or "Ken HUB",
            Text = tostring(msg):sub(1, 120),
            Duration = 6,
        })
    end)
    warn("[Ken HUB Loader]", msg)
end

local function httpGet(url)
    local cacheBust = url .. (url:find("?") and "&" or "?") .. "v=" .. MIN_VERSION .. "&t=" .. tostring(os.time()) .. "&r=" .. tostring(math.random(100000, 999999))
    if game.HttpGet then
        local ok, body = pcall(game.HttpGet, game, cacheBust)
        if ok and type(body) == "string" then return body end
    end
    if syn and syn.request then
        local ok, r = pcall(syn.request, { Url = cacheBust, Method = "GET" })
        if ok and r and r.Body then return r.Body end
    end
    if http_request then
        local ok, r = pcall(http_request, { Url = cacheBust, Method = "GET" })
        if ok and r and r.Body then return r.Body end
    end
    if request then
        local ok, r = pcall(request, { Url = cacheBust, Method = "GET" })
        if ok and r and r.Body then return r.Body end
    end
    return nil
end

local function validatePartBody(label, body)
    if body:find("game:BindToClose") or body:find("game%.BindToClose") then
        setStatus(label .. " ESKI SURUM! GitHub'a v" .. MIN_VERSION .. " yukle.", true)
        return false
    end
    local ver = body:match('SCRIPT_VERSION%s*=%s*"([^"]+)"')
    if ver and ver < MIN_VERSION then
        setStatus(label .. " surum " .. ver .. " eski. Min " .. MIN_VERSION .. " gerekli.", true)
        return false
    end
    return true
end

local function runPart(label, url)
    setStatus(label .. " indiriliyor...")
    local body = httpGet(url)
    if not body then
        setStatus(label .. " indirilemedi.", true)
        return false
    end
    if #body < 200 then
        setStatus(label .. " cok kucuk (" .. #body .. " byte).", true)
        return false
    end
    if body:find("<!DOCTYPE") or body:find("<html") then
        setStatus(label .. " HTML dondu. Repo PUBLIC mi?", true)
        return false
    end
    if not validatePartBody(label, body) then return false end

    local ver = body:match('SCRIPT_VERSION%s*=%s*"([^"]+)"')
    setStatus(label .. " v" .. tostring(ver or "?") .. " derleniyor...")
    local fn, compileErr = loadstring(body)
    if not fn then
        setStatus("Compile (" .. label .. "): " .. tostring(compileErr):sub(1, 180), true)
        return false
    end
    setStatus(label .. " calistiriliyor...")
    local runOk, runErr = xpcall(fn, debug.traceback)
    if not runOk then
        setStatus("Runtime (" .. label .. "): " .. tostring(runErr):sub(1, 180), true)
        return false
    end
    return true
end

for _, entry in ipairs(PARTS) do
    local label, url = entry[1], entry[2]
    if not runPart(label, url) then return end
end

setStatus("Ken HUB v" .. MIN_VERSION .. " yuklendi! KH butonuna dokun.")
task.delay(5, function() pcall(function() Gui:Destroy() end) end)
