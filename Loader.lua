--[[
    Ken HUB Loader - Delta Executor icin
    GitHub'a bunu yukle, execute satirini bunu kullanacak sekilde ayarla.
]]

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LP = Players.LocalPlayer or Players.PlayerAdded:Wait()
repeat task.wait() until LP:FindFirstChild("PlayerGui")

local SCRIPT_URL = "https://raw.githubusercontent.com/vdshesap13-lgtm/Stealbrainrt/main/13.lua"

local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 7,
        })
    end)
end

local function httpGet(url)
    if syn and syn.request then
        local r = syn.request({ Url = url, Method = "GET" })
        if r and r.Body then return r.Body end
    end
    if http_request then
        local r = http_request({ Url = url, Method = "GET" })
        if r and r.Body then return r.Body end
    end
    if request then
        local r = request({ Url = url, Method = "GET" })
        if r and r.Body then return r.Body end
    end
    if game.HttpGet then
        return game:HttpGet(url)
    end
    error("HttpGet desteklenmiyor - Delta guncel mi?")
end

notify("Ken HUB", "Loader basladi...")

local body
local ok, result = pcall(function()
    return httpGet(SCRIPT_URL .. "?t=" .. tostring(os.time()))
end)

if not ok or type(result) ~= "string" or #result < 500 then
    notify("Ken HUB HATA", "Indirme basarisiz: " .. tostring(result):sub(1, 80))
    warn("[Ken HUB Loader] Download failed:", result)
    return
end

if result:find("<!DOCTYPE") or result:find("<html") then
    notify("Ken HUB HATA", "GitHub HTML dondu - repo Public mi? URL dogru mu?")
    warn("[Ken HUB Loader] Got HTML instead of Lua")
    return
end

local fn, compileErr = loadstring(result)
if not fn then
    notify("Ken HUB HATA", "Compile: " .. tostring(compileErr):sub(1, 80))
    warn("[Ken HUB Loader] Compile error:", compileErr)
    return
end

notify("Ken HUB", "Script calistiriliyor...")

local runOk, runErr = xpcall(fn, debug.traceback)
if not runOk then
    notify("Ken HUB HATA", tostring(runErr):sub(1, 100))
    warn("[Ken HUB Loader] Runtime error:\n", runErr)
else
    notify("Ken HUB", "Basariyla yuklendi!")
end
