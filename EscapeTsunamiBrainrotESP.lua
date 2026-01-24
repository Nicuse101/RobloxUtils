-- Brainrot ESP Module
local BrainrotESP = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Initialize getgenv().ESP if it doesn't exist
getgenv().ESP = getgenv().ESP or {
    Enabled = true,
    Rarity = {
        Common = true,
        Rare = true,
        Epic = true,
        Legendary = true,
        Mythic = true
    },
    Colors = {
        Common = Color3.fromRGB(255, 255, 255),
        Rare = Color3.fromRGB(0, 170, 255),
        Epic = Color3.fromRGB(170, 0, 255),
        Legendary = Color3.fromRGB(255, 170, 0),
        Mythic = Color3.fromRGB(255, 0, 127)
    }
}

-- Store ESP objects for cleanup
local ESPObjects = {}
local initialized = false

-- Function to create ESP for a brainrot
local function createESP(brainrot, rarity)
    if not brainrot:IsA("BasePart") and not brainrot:IsA("Model") then return end
    
    -- Get the main part (either the part itself or model's PrimaryPart)
    local mainPart = brainrot:IsA("Model") and brainrot.PrimaryPart or brainrot
    if not mainPart then
        -- If no PrimaryPart, find first BasePart in model
        if brainrot:IsA("Model") then
            for _, child in pairs(brainrot:GetDescendants()) do
                if child:IsA("BasePart") then
                    mainPart = child
                    break
                end
            end
        end
    end
    
    if not mainPart then return end
    
    -- Create Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "BrainrotESP_Highlight"
    highlight.Adornee = brainrot:IsA("Model") and brainrot or mainPart
    highlight.FillColor = getgenv().ESP.Colors[rarity] or Color3.fromRGB(255, 255, 255)
    highlight.OutlineColor = getgenv().ESP.Colors[rarity] or Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = brainrot:IsA("Model") and brainrot or mainPart
    
    -- Create BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BrainrotESP_Billboard"
    billboard.Adornee = mainPart
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = math.huge
    
    -- Create Frame for background (fully transparent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Parent = billboard
    
    -- Create TextLabel for information
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = getgenv().ESP.Colors[rarity] or Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 16
    textLabel.TextYAlignment = Enum.TextYAlignment.Center
    textLabel.TextWrapped = true
    textLabel.Parent = frame
    
    billboard.Parent = mainPart
    
    -- Function to update text
    local function updateText()
        local name = brainrot:GetAttribute("Name") or "Unknown"
        local level = brainrot:GetAttribute("Level") or "N/A"
        local timeLeft = brainrot:GetAttribute("TimeLeft") or 0
        
        -- Format time
        local minutes = math.floor(timeLeft / 60)
        local seconds = math.floor(timeLeft % 60)
        local timeString = string.format("%02d:%02d", minutes, seconds)
        
        textLabel.Text = string.format("Time Left: %s | Name: %s | Level: %s", 
            timeString,
            name, 
            tostring(level)
        )
    end
    
    -- Initial update
    updateText()
    
    -- Update text periodically
    local connection = RunService.RenderStepped:Connect(function()
        if brainrot and brainrot.Parent then
            updateText()
        end
    end)
    
    -- Store references for cleanup
    ESPObjects[brainrot] = {
        highlight = highlight,
        billboard = billboard,
        connection = connection
    }
end

-- Function to remove ESP from a brainrot
local function removeESP(brainrot)
    if ESPObjects[brainrot] then
        if ESPObjects[brainrot].highlight then
            ESPObjects[brainrot].highlight:Destroy()
        end
        if ESPObjects[brainrot].billboard then
            ESPObjects[brainrot].billboard:Destroy()
        end
        if ESPObjects[brainrot].connection then
            ESPObjects[brainrot].connection:Disconnect()
        end
        ESPObjects[brainrot] = nil
    end
end

-- Function to handle brainrot added to a rarity folder
local function onBrainrotAdded(brainrot, rarity)
    if getgenv().ESP.Enabled and getgenv().ESP.Rarity[rarity] then
        createESP(brainrot, rarity)
    end
end

-- Function to handle brainrot removed from a rarity folder
local function onBrainrotRemoved(brainrot)
    removeESP(brainrot)
end

-- Function to handle rarity folder added
local function onRarityFolderAdded(rarityFolder)
    local rarity = rarityFolder.Name
    
    -- Handle existing brainrots
    for _, brainrot in pairs(rarityFolder:GetChildren()) do
        onBrainrotAdded(brainrot, rarity)
    end
    
    -- Listen for new brainrots
    rarityFolder.ChildAdded:Connect(function(brainrot)
        onBrainrotAdded(brainrot, rarity)
    end)
    
    -- Listen for removed brainrots
    rarityFolder.ChildRemoved:Connect(function(brainrot)
        onBrainrotRemoved(brainrot)
    end)
end

-- Function to initialize ESP
function BrainrotESP:Init()
    if initialized then
        warn("BrainrotESP already initialized!")
        return
    end
    
    local activeBrainrots = Workspace:FindFirstChild("ActiveBrainrots")
    
    if not activeBrainrots then
        warn("ActiveBrainrots folder not found in Workspace!")
        return
    end
    
    -- Handle existing rarity folders
    for _, rarityFolder in pairs(activeBrainrots:GetChildren()) do
        if rarityFolder:IsA("Folder") then
            onRarityFolderAdded(rarityFolder)
        end
    end
    
    -- Listen for new rarity folders
    activeBrainrots.ChildAdded:Connect(function(rarityFolder)
        if rarityFolder:IsA("Folder") then
            onRarityFolderAdded(rarityFolder)
        end
    end)
    
    initialized = true
    print("Brainrot ESP Module Initialized!")
end

-- Function to refresh all ESP based on settings
function BrainrotESP:Refresh()
    -- Clear all existing ESP
    for brainrot, _ in pairs(ESPObjects) do
        removeESP(brainrot)
    end
    
    -- Reinitialize
    local activeBrainrots = Workspace:FindFirstChild("ActiveBrainrots")
    if activeBrainrots then
        for _, rarityFolder in pairs(activeBrainrots:GetChildren()) do
            if rarityFolder:IsA("Folder") then
                local rarity = rarityFolder.Name
                for _, brainrot in pairs(rarityFolder:GetChildren()) do
                    onBrainrotAdded(brainrot, rarity)
                end
            end
        end
    end
end

-- Function to enable ESP
function BrainrotESP:Enable()
    getgenv().ESP.Enabled = true
    self:Refresh()
end

-- Function to disable ESP
function BrainrotESP:Disable()
    getgenv().ESP.Enabled = false
    self:Refresh()
end

-- Function to toggle a specific rarity
function BrainrotESP:ToggleRarity(rarity, enabled)
    if getgenv().ESP.Rarity[rarity] ~= nil then
        getgenv().ESP.Rarity[rarity] = enabled
        self:Refresh()
    else
        warn("Rarity '" .. rarity .. "' does not exist!")
    end
end

-- Function to set color for a rarity
function BrainrotESP:SetRarityColor(rarity, color)
    if getgenv().ESP.Colors[rarity] then
        getgenv().ESP.Colors[rarity] = color
        self:Refresh()
    else
        warn("Rarity '" .. rarity .. "' does not exist!")
    end
end

-- Function to destroy all ESP
function BrainrotESP:Destroy()
    for brainrot, _ in pairs(ESPObjects) do
        removeESP(brainrot)
    end
    initialized = false
    print("Brainrot ESP Module Destroyed!")
end

return BrainrotESP
