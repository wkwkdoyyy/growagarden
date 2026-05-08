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
-- MOBILE TOGGLE BUTTON (Agar menu tidak hilang)
-- =============================================
local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "WKWK_MobileToggle"
ScreenGui.Parent = (game:GetService("CoreGui") or game:GetService("Players").LocalPlayer.PlayerGui)
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 0, 150)
ToggleButton.Position = UDim2.new(0.12, 0, 0.15, 0)
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "W" -- Inisial WKWKHUB
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 24
ToggleButton.Draggable = true -- Bisa digeser di mobile

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    Window:Minimize()
end)

-- =============================================
-- TABS
-- =============================================
local Tabs = {
    About = Window:AddTab({ Title = "About", Icon = "info" }),
    Loadout = Window:AddTab({ Title = "Loadout", Icon = "refresh-cw" })
}

-- =============================================
-- FUNCTIONS (Logika Auto Loadout)
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
-- TAB: ABOUT
-- =============================================
Tabs.About:AddParagraph({
    Title = "WKWKHUB | Grow A Garden",
    Content = "Script by doyyy\n\nFitur:\n🔄 Auto Loadout Rotation"
})

Tabs.About:AddButton({
    Title = "Copy Discord Invite",
    Callback = function()
        setclipboard("https://discord.gg/9hdXwZZXW9")
        Fluent:Notify({ Title = "WKWKHUB", Content = "Discord invite copied!", Duration = 3 })
    end
})

Tabs.About:AddButton({
    Title = "Self Destruct",
    Description = "Menghapus UI dan Tombol Melayang",
    Callback = function()
        ScreenGui:Destroy()
        Window:Destroy()
    end
})

-- =============================================
-- TAB: LOADOUT
-- =============================================
Tabs.Loadout:AddSection("Rotation Settings")

Tabs.Loadout:AddDropdown("StartLoadout", {
    Title = "Start Loadout",
    Values = {"1", "2", "3", "4", "5", "6"},
    Default = "1",
    Callback = function(Value) startLoadout = Value end
})

Tabs.Loadout:AddDropdown("TargetLoadout", {
    Title = "Target Loadout",
    Values = {"1", "2", "3", "4", "5", "6"},
    Default = "3",
    Callback = function(Value) targetLoadout = Value end
})

Tabs.Loadout:AddInput("DelayInput", {
    Title = "Rotation Delay (detik)",
    Default = "5",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 0.1 then currentDelay = num end
    end
})

Tabs.Loadout:AddSection("Control")

Tabs.Loadout:AddToggle("ToggleRotation", {
    Title = "Enable Rotation", 
    Default = false,
    Callback = function(Value)
        rotationActive = Value
        if Value then
            task.spawn(startRotation)
        end
    end
})

local StatusParagraph = Tabs.Loadout:AddParagraph({
    Title = "Rotation Status",
    Content = "🔴 OFF"
})

-- Update status secara real-time
task.spawn(function()
    while task.wait(1) do
        if not Window then break end
        local statusText = (rotationActive and "🟢 ON" or "🔴 OFF")
        StatusParagraph:SetTitle("Status: " .. statusText)
        StatusParagraph:SetDesc(string.format("Path: %s ➔ %s\nDelay: %ss", startLoadout, targetLoadout, tostring(currentDelay)))
    end
end)

Window:SelectTab(1)
Fluent:Notify({ Title = "WKWKHUB", Content = "Script Loaded", Duration = 5 })
