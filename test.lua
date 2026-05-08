local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Data & Remotes
local seeds = require(RS.Data.SeedData)
local gears = require(RS.Data.GearData)
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

local availableSeeds = {}
local availableGears = {}

-- =============================================
-- WINDOW SETUP (MOBILE OPTIMIZED)
-- =============================================
local Window = Fluent:CreateWindow({
    Title = "WKWKHUB | Grow A Garden",
    SubTitle = "by doyyy",
    TabWidth = 110, 
    Size = UDim2.fromOffset(470, 380), 
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
ToggleButton.Position = UDim2.new(0.1, 0, 0.15, 0)
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Text = "W"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 20
ToggleButton.Draggable = true
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    Window:Minimize()
end)

-- =============================================
-- FUNCTIONS: FULL SCANNER LOGIC
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

local function scanAndClickSeed(seedName)
    local seedFolder = seedshopui:FindFirstChild(seedName)
    if not seedFolder then return end

    warn("--- SCANNING OBJECTS FOR: " .. seedName .. " ---")
    local clickableFound = false
    
    -- Menjelajah SEMUA objek di dalam folder benih
    for _, obj in ipairs(seedFolder:GetDescendants()) do
        -- Cetak nama setiap objek yang ditemukan agar kita tahu strukturnya
        print("Found: " .. obj.Name .. " | Class: " .. obj.ClassName)
        
        -- Kriteria objek yang bisa diklik
        if obj:IsA("GuiButton") or obj.Name == "SENSOR" or obj.Name == "Sheckles_Buy" then
            pcall(function()
                firesignal(obj.MouseButton1Click)
                firesignal(obj.Activated)
            end)
            clickableFound = true
            warn(">>> CLICKED: " .. obj.Name .. " (" .. obj.ClassName .. ")")
        end
    end
    
    if not clickableFound then
        warn("No clickable objects found for " .. seedName)
    end
end

local function clickLoadout(number)
    pcall(function()
        local frame = PlayerGui.ActivePetUI.Frame.Main.PetLoadout.Main.ButtonHolder["PET_LOADOUT_" .. tostring(number)]
        local sensor = frame:FindFirstChild("SENSOR", true)
        if sensor then
            firesignal(sensor.MouseButton1Click)
            firesignal(sensor.Activated)
        end
    end)
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

-- =============================================
-- MAIN LOOPS
-- =============================================
task.spawn(function()
    while task.wait(0.5) do
        updateStockLists()
        if autoBuySeeds then
            for name, _ in pairs(seeds) do
                if getStock(name, seedshopui) > 0 then 
                    scanAndClickSeed(name)
                    task.wait(0.5) -- Jeda lebih lama agar tidak spam console
                end
            end
        end
        if autoBuyGear then
            for name, _ in pairs(gears) do
                if getStock(name, gearshopui) > 0 then 
                    remotetobuythegear:FireServer(name) 
                    task.wait(0.1) 
                end
            end
        end
    end
end)

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
    Info = Window:AddTab({ Title = "Info", Icon = "info" }),
    Loadout = Window:AddTab({ Title = "Loadout", Icon = "refresh-cw" }),
    Shop = Window:AddTab({ Title = "Auto Shop", Icon = "shopping-cart" })
}

-- TAB: INFO
Tabs.Info:AddParagraph({ Title = "WKWKHUB | Grow A Garden", Content = "Script by doyyy" })
Tabs.Info:AddParagraph({ Title = "Fitur", Content = "🔄 Auto Loadout Rotation\n🛒 Auto Buy All Seeds & Gear" })
Tabs.Info:AddParagraph({ Title = "⚠️ NOTE", Content = "Kalo mau pilih loudout 2, pilih loudout 3. dan sebaliknya, bug mapping dari GAG!" })
Tabs.Info:AddButton({ Title = "Copy Discord Invite", Callback = function() setclipboard("https://discord.gg/9hdXwZZXW9") end })
Tabs.Info:AddButton({ Title = "Self Destruct", Callback = function() ScreenGui:Destroy() Window:Destroy() end })

-- TAB: LOADOUT
Tabs.Loadout:AddSection("Rotation Settings")
Tabs.Loadout:AddDropdown("StartL", { Title = "Start Loadout", Values = {"1","2","3","4","5","6"}, Default = "1", Callback = function(V) startLoadout = V end })
Tabs.Loadout:AddDropdown("TargetL", { Title = "Target Loadout", Values = {"1","2","3","4","5","6"}, Default = "3", Callback = function(V) targetLoadout = V end })
Tabs.Loadout:AddInput("Dly", { Title = "Delay (s)", Default = "5", Numeric = true, Finished = true, Callback = function(V) currentDelay = tonumber(V) or 5 end })
Tabs.Loadout:AddToggle("RotTog", { Title = "Enable Rotation", Default = false, Callback = function(V) rotationActive = V if V then task.spawn(startRotation) end end })
local LoadoutStatusPara = Tabs.Loadout:AddParagraph({ Title = "Status", Content = "🔴 OFF" })

-- TAB: SHOP
Tabs.Shop:AddSection("Auto Purchase")
Tabs.Shop:AddToggle("BuyS", { Title = "Auto Buy Seeds (Full Scanner)", Default = false, Callback = function(V) autoBuySeeds = V end })
Tabs.Shop:AddToggle("BuyG", { Title = "Auto Buy Gear (Remote)", Default = false, Callback = function(V) autoBuyGear = V end })
Tabs.Shop:AddSection("Monitoring")
local StockParagraph = Tabs.Shop:AddParagraph({ Title = "Stock List", Content = "Scanning..." })

-- =============================================
-- REAL-TIME UPDATER
-- =============================================
task.spawn(function()
    while task.wait(1) do
        if not Window then break end
        LoadoutStatusPara:SetTitle("Loadout: " .. (rotationActive and "🟢 ACTIVE" or "🔴 OFF"))
        LoadoutStatusPara:SetDesc(string.format("Path: %s ➔ %s (%ss)", startLoadout, targetLoadout, tostring(currentDelay)))
        
        local sList = #availableSeeds > 0 and table.concat(availableSeeds, ", ") or "None"
        local gList = #availableGears > 0 and table.concat(availableGears, ", ") or "None"
        StockParagraph:SetDesc(string.format("🌱 **Seeds:** %s\n\n🔧 **Gears:** %s", sList, gList))
    end
end)

Window:SelectTab(1)
