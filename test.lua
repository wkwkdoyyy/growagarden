-- =============================================
-- WKWKHUB | GROW A GARDEN
-- LOADOUT ROTATION
-- =============================================

-- [!] NOTE:
-- Jika setelah klik Loadout 2 malah pindah ke Loadout 3,
-- atau sebaliknya, itu BUKAN BUG dari script ini.
-- Itu adalah bug dari game Grow A Garden sendiri
-- yang kadang salah mapping nomor loadout.
-- =============================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- =============================================
-- VARIABLES
-- =============================================

local rotationActive = false
local currentDelay = 5
local startLoadout = "1"
local targetLoadout = "3"

-- =============================================
-- RAYFIELD
-- =============================================

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "WKWKHUB | Grow A Garden",
    Icon = 97296381694913,
    LoadingTitle = "WKWKHUB Loading...",
    LoadingSubtitle = "Grow A Garden",
    Theme = "Amethyst",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "WKWKHUB-GAG"
    },
    Discord = {
        Enabled = true,
        Invite = "discord.gg/9hdXwZZXW9",
        RememberJoins = true
    },
    KeySystem = false,
})

Rayfield:Notify({
    Title = "WKWKHUB",
    Content = "Grow A Garden Script Loaded",
    Duration = 6,
})

-- =============================================
-- TAB 1: ABOUT
-- =============================================

local aboutTab = Window:CreateTab("ℹ️ About", nil)

aboutTab:CreateParagraph({
    Title = "WKWKHUB | Grow A Garden",
    Content = [[
Script by doyyy

Fitur:
🔄 Auto Loadout Rotation
   - Rotasi otomatis antar loadout pet
]]
})

aboutTab:CreateParagraph({
    Title = "⚠️ NOTE",
    Content = [[
Jika setelah klik Loadout 2 malah pindah ke Loadout 3, atau sebaliknya, itu BUKAN BUG dari script ini.

Itu adalah bug dari game Grow A Garden sendiri yang salah mapping nomor loadout.
]]
})

aboutTab:CreateSection("🔗 Links")

aboutTab:CreateButton({
    Name = "Copy Discord Invite",
    Callback = function()
        setclipboard("https://discord.gg/9hdXwZZXW9")
        Rayfield:Notify({
            Title = "WKWKHUB",
            Content = "Discord invite copied!",
            Duration = 3,
        })
    end,
})

-- =============================================
-- TAB 2: AUTO LOADOUT
-- =============================================

local loadoutTab = Window:CreateTab("🔄 Loadout", nil)

-- =============================================
-- LOADOUT FUNCTIONS
-- =============================================

local function getLoadoutFrame(number)
    local success, result = pcall(function()
        return PlayerGui.ActivePetUI.Frame.Main.PetLoadout.Main.ButtonHolder["PET_LOADOUT_" .. tostring(number)]
    end)
    if success then return result end
    return nil
end

local function getSensor(number)
    local frame = getLoadoutFrame(number)
    if not frame then return nil end
    return frame:FindFirstChild("SENSOR", true)
end

local function clickLoadout(number)
    local sensor = getSensor(number)
    if not sensor then return false end
    
    local success = pcall(function()
        firesignal(sensor.MouseButton1Click)
        firesignal(sensor.Activated)
    end)
    return success
end

local function startRotation()
    local startNum = tonumber(startLoadout)
    local targetNum = tonumber(targetLoadout)

    while rotationActive do
        clickLoadout(targetNum)
        task.wait(currentDelay)

        if not rotationActive then break end

        clickLoadout(startNum)
        task.wait(currentDelay)
    end
end

-- =============================================
-- LOADOUT UI
-- =============================================

loadoutTab:CreateSection("🔄 Rotation Settings")

loadoutTab:CreateDropdown({
    Name = "Start Loadout",
    Options = {"1", "2", "3", "4", "5", "6"},
    CurrentOption = {"1"},
    MultipleOptions = false,
    Callback = function(opt)
        startLoadout = opt[1]
    end
})

loadoutTab:CreateDropdown({
    Name = "Target Loadout",
    Options = {"1", "2", "3", "4", "5", "6"},
    CurrentOption = {"2"},
    MultipleOptions = false,
    Callback = function(opt)
        targetLoadout = opt[1]
    end
})

loadoutTab:CreateInput({
    Name = "Rotation Delay (detik)",
    CurrentValue = "5",
    PlaceholderText = "1-9999",
    RemoveTextAfterFocusLost = false,
    Flag = "DelayInput",
    Callback = function(Text)
        local num = tonumber(Text)
        if num and num >= 1 then
            currentDelay = num
        end
    end,
})

loadoutTab:CreateSection("🎮 Control")

loadoutTab:CreateToggle({
    Name = "Enable Rotation",
    CurrentValue = false,
    Callback = function(val)
        rotationActive = val
        if val then
            task.spawn(startRotation)
        end
    end
})

-- =============================================
-- STATUS
-- =============================================

loadoutTab:CreateSection("📊 Status")

local rotationStatus = loadoutTab:CreateParagraph({
    Title = "Rotation Status",
    Content = "OFF"
})

task.spawn(function()
    while true do
        pcall(function()
            rotationStatus:Set({
                Title = "Rotation Status",
                Content = (rotationActive and "🟢 ON" or "🔴 OFF")
                    .. "\n" .. startLoadout .. " -> " .. targetLoadout
                    .. "\nDelay: " .. tostring(currentDelay) .. "s"
            })
        end)
        task.wait(1)
    end
end)

print("WKWKHUB | Grow A Garden Loaded")