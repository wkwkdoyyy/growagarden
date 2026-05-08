local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Data Requirements
local seeds = require(RS.Data.SeedData)
local gears = require(RS.Data.GearData)
local remotetobuytheseeds = RS.GameEvents.BuySeedStock
local remotetobuythegear = RS.GameEvents.BuyGearStock
local seedshopui = PlayerGui:WaitForChild("Seed_Shop").Frame.ScrollingFrame
local gearshopui = PlayerGui:WaitForChild("Gear_Shop").Frame.ScrollingFrame

-- =============================================
-- VARIABLES
-- =============================================
local rotationActive = false
local autoBuySeeds = false
local autoBuyGear = false
local currentDelay = 5
local startLoadout = "1"
local targetLoadout = "3"

-- Stock Tracking Variables
local availableSeeds = {}
local availableGears = {}

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
-- MOBILE TOGGLE BUTTON
-- =============================================
local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "WKWK_MobileToggle"
ScreenGui.Parent = (game:GetService("CoreGui") or PlayerGui)
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 0, 150)
ToggleButton.Position = UDim2.new(0.12, 0, 0.15, 0)
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Text = "W"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 24
ToggleButton.Draggable = true
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    Window:Minimize()
end)

-- =============================================
-- FUNCTIONS: SHOP LOGIC
-- =============================================
local function getStock(item, uiContainer)
    local frame = uiContainer:FindFirstChild(item)
    if frame then
        local mainFrame = frame:FindFirstChild("Main_Frame")
        local stockText = mainFrame and mainFrame:FindFirstChild("Stock_Text")
        if stockText then
            local count = tonumber(stockText.Text:match("X(%d+) Stock"))
            return count or 0
        end
    end
    return 0
end

local function updateStockLists()
    availableSeeds = {}
    availableGears = {}
    
    for name, _ in pairs(seeds) do
        local s = getStock(name, seedshopui)
        if s > 0 then table.insert(availableSeeds, name .. " (x" .. s .. ")") end
    end
    
    for name, _ in pairs(gears) do
        local g = getStock(name, gearshopui)
        if g > 0 then table.insert(availableGears, name .. " (x" .. g .. ")") end
    end
end

local function processAutoBuy()
    while task.wait(1) do
        updateStockLists()
        
        if autoBuySeeds and #availableSeeds > 0 then
            for name, _ in pairs(seeds) do
                local stock = getStock(name, seedshopui)
                if stock > 0 then
                    for i = 1, stock do
                        if not autoBuySeeds then break end
                        remotetobuytheseeds:FireServer(name)
                        task.wait(0.1)
                    end
                end
            end
        end

        if autoBuyGear and #availableGears > 0 then
            for name, _ in pairs(gears) do
                local stock = getStock(name, gearshopui)
                if stock > 0 then
                    for i = 1, stock do
                        if not autoBuyGear then break end
                        remotetobuythegear:FireServer(name)
                        task.wait(0.1)
                    end
                end
            end
        end
    end
end
task.spawn(processAutoBuy)

-- =============================================
-- FUNCTIONS: LOADOUT LOGIC
-- =============================================
local function clickLoadout(number)
    local success, frame = pcall(function()
        return PlayerGui.ActivePetUI.Frame.Main.PetLoadout.Main.ButtonHolder["PET_LOADOUT_" .. tostring(number)]
    end)
    if success and frame then
        local sensor = frame:FindFirstChild("SENSOR", true)
        if sensor then
            firesignal(sensor.MouseButton1Click)
            firesignal(sensor.Activated)
        end
    end
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
-- TABS SETUP
-- =============================================
local Tabs = {
    About = Window:AddTab({ Title = "About", Icon = "info" }),
    Loadout = Window:AddTab({ Title = "Loadout", Icon = "refresh-cw" }),
    Shop = Window:AddTab({ Title = "Auto Shop", Icon = "shopping-cart" })
}

Tabs.About:AddButton({
    Title = "Self Destruct",
    Callback = function() ScreenGui:Destroy() Window:Destroy() end
})

-- TAB: LOADOUT
Tabs.Loadout:AddSection("Rotation Settings")
Tabs.Loadout:AddDropdown("StartL", { Title = "Start Loadout", Values = {"1","2","3","4","5","6"}, Default = "1", Callback = function(V) startLoadout = V end })
Tabs.Loadout:AddDropdown("TargetL", { Title = "Target Loadout", Values = {"1","2","3","4","5","6"}, Default = "3", Callback = function(V) targetLoadout = V end })
Tabs.Loadout:AddInput("Dly", { Title = "Delay (s)", Default = "5", Numeric = true, Finished = true, Callback = function(V) currentDelay = tonumber(V) or 5 end })
Tabs.Loadout:AddToggle("RotTog", { Title = "Enable Rotation", Default = false, Callback = function(V) rotationActive = V if V then task.spawn(startRotation) end end })

-- TAB: SHOP
Tabs.Shop:AddSection("Auto Purchase")
Tabs.Shop:AddToggle("BuyS", { Title = "Auto Buy Seeds", Default = false, Callback = function(V) autoBuySeeds = V end })
Tabs.Shop:AddToggle("BuyG", { Title = "Auto Buy Gear", Default = false, Callback = function(V) autoBuyGear = V end })

-- =============================================
-- STATUS UPDATE (UI FEEDBACK WITH NAMES)
-- =============================================
local StatusParagraph = Tabs.Loadout:AddParagraph({
    Title = "System Monitoring",
    Content = "Loading stock data..."
})

task.spawn(function()
    while task.wait(1) do
        if not Window then break end
        
        local seedList = #availableSeeds > 0 and table.concat(availableSeeds, ", ") or "No Stock"
        local gearList = #availableGears > 0 and table.concat(availableGears, ", ") or "No Stock"
        
        local fullInfo = string.format(
            "🌱 **Seeds In Stock:**\n%s\n\n🔧 **Gears In Stock:**\n%s\n\n-------------------\n🔄 **Rotation:** %s ➔ %s (%ss)",
            seedList,
            gearList,
            startLoadout,
            targetLoadout,
            tostring(currentDelay)
        )
        
        StatusParagraph:SetTitle("Loadout: " .. (rotationActive and "🟢 ACTIVE" or "🔴 OFF"))
        StatusParagraph:SetDesc(fullInfo)
    end
end)

Window:SelectTab(1)
