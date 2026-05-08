local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

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
-- WINDOW SETUP
-- =============================================
local Window = Fluent:CreateWindow({
    Title = "WKWKHUB | Grow A Garden",
    SubTitle = "by doyyy",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- =============================================
-- TABS
-- =============================================
local Tabs = {
    About = Window:AddTab({ Title = "About", Icon = "info" }),
    Loadout = Window:AddTab({ Title = "Loadout", Icon = "refresh-cw" })
}

-- =============================================
-- TAB: ABOUT
-- =============================================
Tabs.About:AddParagraph({
    Title = "WKWKHUB | Grow A Garden",
    Content = "Fitur:\n🔄 Auto Loadout Rotation\n   - Rotasi otomatis antar loadout pet"
})

Tabs.About:AddParagraph({
    Title = "⚠️ NOTE",
    Content = "Jika setelah klik Loadout 2 malah pindah ke Loadout 3, atau sebaliknya, itu BUKAN BUG dari script ini melainkan bug game."
})

Tabs.About:AddButton({
    Title = "Copy Discord Invite",
    Description = "Salin link discord ke clipboard",
    Callback = function()
        setclipboard("https://discord.gg/9hdXwZZXW9")
        Fluent:Notify({
            Title = "WKWKHUB",
            Content = "Discord invite copied!",
            Duration = 3
        })
    end
})

-- =============================================
-- FUNCTIONS
-- =============================================
local function getLoadoutFrame(number)
    local success, result = pcall(function()
        return PlayerGui.ActivePetUI.Frame.Main.PetLoadout.Main.ButtonHolder["PET_LOADOUT_" .. tostring(number)]
    end)
    return success and result or nil
end

local function clickLoadout(number)
    local frame = getLoadoutFrame(number)
    local sensor = frame and frame:FindFirstChild("SENSOR", true)
    if not sensor then return false end
    
    pcall(function()
        firesignal(sensor.MouseButton1Click)
        firesignal(sensor.Activated)
    end)
    return true
end

local function startRotation()
    while rotationActive do
        clickLoadout(targetLoadout)
        task.wait(currentDelay)

        if not rotationActive then break end

        clickLoadout(startLoadout)
        task.wait(currentDelay)
    end
end

-- =============================================
-- TAB: LOADOUT (SETTINGS)
-- =============================================
Tabs.Loadout:AddSection("Rotation Settings")

local DropdownStart = Tabs.Loadout:AddDropdown("StartLoadout", {
    Title = "Start Loadout",
    Values = {"1", "2", "3", "4", "5", "6"},
    Multi = false,
    Default = "1",
    Callback = function(Value)
        startLoadout = Value
    end
})

local DropdownTarget = Tabs.Loadout:AddDropdown("TargetLoadout", {
    Title = "Target Loadout",
    Values = {"1", "2", "3", "4", "5", "6"},
    Multi = false,
    Default = "3",
    Callback = function(Value)
        targetLoadout = Value
    end
})

local DelayInput = Tabs.Loadout:AddInput("DelayInput", {
    Title = "Rotation Delay (detik)",
    Default = "5",
    Placeholder = "1-9999",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 0.1 then
            currentDelay = num
        end
    end
})

Tabs.Loadout:AddSection("Control")

local ToggleRotation = Tabs.Loadout:AddToggle("ToggleRotation", {
    Title = "Enable Rotation", 
    Default = false,
    Callback = function(Value)
        rotationActive = Value
        if Value then
            task.spawn(startRotation)
        end
    end
})

-- =============================================
-- STATUS PARAGRAPH
-- =============================================
local StatusParagraph = Tabs.Loadout:AddParagraph({
    Title = "Rotation Status",
    Content = "🔴 OFF"
})

task.spawn(function()
    while task.wait(1) do
        local statusText = (rotationActive and "🟢 ON" or "🔴 OFF")
        StatusParagraph:SetTitle("Status: " .. statusText)
        StatusParagraph:SetDesc(
            string.format("Path: %s ➔ %s\nDelay: %ss", startLoadout, targetLoadout, tostring(currentDelay))
        )
    end
end)

-- Finish Setup
Window:SelectTab(1)
Fluent:Notify({
    Title = "WKWKHUB",
    Content = "Grow A Garden Script Loaded",
    Duration = 5
})

print("WKWKHUB | Fluent UI Loaded")
