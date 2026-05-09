local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local seeds = require(RS.Data.SeedData)
local gears = require(RS.Data.GearData)
local remotetobuythegear = RS.GameEvents.BuyGearStock
local seedshopui = PlayerGui:WaitForChild("Seed_Shop").Frame.ScrollingFrame
local gearshopui = PlayerGui:WaitForChild("Gear_Shop").Frame.ScrollingFrame

local rotationActive = false
local autoBuySeeds = false
local autoBuyGear = false
local currentDelay = 5
local startLoadout = "1"
local targetLoadout = "3"

local Window = Fluent:CreateWindow({
    Title = "WKWKHUB",
    SubTitle = "Grow A Garden",
    TabWidth = 100, 
    Size = UDim2.fromOffset(480, 400), 
    Theme = "Darker",
})

local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")

ScreenGui.Name = "WKWK_MobileToggle"
ScreenGui.Parent = (game:GetService("CoreGui") or PlayerGui)
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Position = UDim2.new(0.1, 0, 0.15, 0)
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Text = "W"
ToggleButton.TextColor3 = Color3.fromRGB(170, 85, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 22
ToggleButton.Draggable = true
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = ToggleButton
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(170, 85, 255)
UIStroke.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function() Window:Minimize() end)

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

local function buySeedUI(seedName)
    pcall(function()
        local itemFolder = seedshopui:FindFirstChild(seedName)
        if itemFolder then
            local sheckles = itemFolder:FindFirstChild("Sheckles_Buy", true)
            if sheckles then
                firesignal(sheckles.MouseButton1Click)
                firesignal(sheckles.Activated)
            end
            local mainFrame = itemFolder:FindFirstChild("Main_Frame", true)
            if mainFrame then
                firesignal(mainFrame.MouseButton1Click)
                firesignal(mainFrame.Activated)
            end
        end
    end)
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

local Tabs = {
    Info = Window:AddTab({ Title = "Info", Icon = "info" }),
    Loadout = Window:AddTab({ Title = "Loadout", Icon = "refresh-cw" }),
    Shop = Window:AddTab({ Title = "Shop", Icon = "shopping-cart" })
}

Tabs.Info:AddParagraph({ Title = "👋 Welcome to WKWKHUB", Content = "Developed by doyyy" })
Tabs.Info:AddParagraph({ Title = "⚠️ GAG Game Bug Note", Content = "Kalo mau pilih loadout 2, pilih loadout 3. Dan sebaliknya. Bug mapping dari GAG!" })
Tabs.Info:AddButton({ Title = "Copy Discord Link", Callback = function() setclipboard("https://discord.gg/9hdXwZZXW9") end })

local L_Config = Tabs.Loadout:AddSection("Rotation Configuration")
L_Config:AddDropdown("StartL", { Title = "Primary Loadout", Values = {"1","2","3","4","5","6"}, Default = "1", Callback = function(V) startLoadout = V end })
L_Config:AddDropdown("TargetL", { Title = "Secondary Loadout", Values = {"1","2","3","4","5","6"}, Default = "3", Callback = function(V) targetLoadout = V end })
L_Config:AddInput("Dly", { Title = "Rotation Interval (s)", Default = "5", Numeric = true, Finished = true, Callback = function(V) currentDelay = tonumber(V) or 5 end })

local L_Status = Tabs.Loadout:AddSection("Execution")
L_Status:AddToggle("RotTog", { 
    Title = "Auto Rotation Switcher", 
    Default = false, 
    Callback = function(V) 
        rotationActive = V 
        if V then 
            task.spawn(function()
                while rotationActive do
                    clickLoadout(startLoadout)
                    task.wait(currentDelay)
                    if not rotationActive then break end
                    clickLoadout(targetLoadout)
                    task.wait(currentDelay)
                end
            end) 
        end 
    end 
})

local RotationStatusPara = L_Status:AddParagraph({ Title = "Current Status", Content = "🔴 OFF" })

local S_Automation = Tabs.Shop:AddSection("Automation Settings")
S_Automation:AddToggle("BuyS", { Title = "Auto Purchase Seeds", Default = false, Callback = function(V) autoBuySeeds = V end })
S_Automation:AddToggle("BuyG", { Title = "Auto Purchase Gear", Default = false, Callback = function(V) autoBuyGear = V end })

local S_Monitor = Tabs.Shop:AddSection("Monitor")
local StockParagraph = S_Monitor:AddParagraph({ Title = "Analyzing Stock...", Content = "Waiting..." })

task.spawn(function()
    while task.wait(0.3) do
        if not Window then break end
        
        if rotationActive then
            RotationStatusPara:SetTitle("Current Status: 🟢 ACTIVE")
            RotationStatusPara:SetDesc("🔄 Rotating: Loadout " .. startLoadout .. " ➔ " .. targetLoadout)
        else
            RotationStatusPara:SetTitle("Current Status: 🔴 OFF")
            RotationStatusPara:SetDesc("Switcher is currently idle.")
        end

        local currentStockText = ""
        
        for name, _ in pairs(seeds) do
            local s = getStock(name, seedshopui)
            if s > 0 then 
                currentStockText = currentStockText .. "🌱 " .. name .. " (x" .. s .. ")\n"
                if autoBuySeeds then buySeedUI(name) end
            end
        end
        
        for name, _ in pairs(gears) do
            local g = getStock(name, gearshopui)
            if g > 0 then 
                currentStockText = currentStockText .. "🔧 " .. name .. " (x" .. g .. ")\n"
                if autoBuyGear then remotetobuythegear:FireServer(name) end
            end
        end

        StockParagraph:SetTitle("Current Stock Status")
        StockParagraph:SetDesc(currentStockText ~= "" and currentStockText or "No items in stock.")
    end
end)

Window:SelectTab(1)
