--[[
    ULTIMATE MINING TYCOON - ESP AVANÇADO (RARE ITEMS ONLY)
    Desenvolvido para: Delta Executor & Outros
    Foco: Minérios de Alto Valor, Gemas e Itens Especiais.
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- CONFIGURAÇÕES DE CORES
local COLORS = {
    LEGENDARY = Color3.fromRGB(255, 0, 255), -- Magenta (Unobtainium, Painite)
    MYTHIC = Color3.fromRGB(255, 255, 0),    -- Amarelo (Rhodium, Musgravite)
    RARE = Color3.fromRGB(0, 255, 255),      -- Ciano (Adamantium, Diamond)
    UNCOMMON = Color3.fromRGB(0, 255, 0),    -- Verde (Plutonium, Gold)
    SPECIAL = Color3.fromRGB(255, 165, 0)    -- Laranja (Master Cube, Arkenstone)
}

-- TABELA DE ITENS ALVO E SUAS CATEGORIAS
local TARGET_ITEMS = {
    -- MINÉRIOS LENDÁRIOS / MÍTICOS
    ["Unobtainium Ore"] = {color = COLORS.LEGENDARY, label = "💎 UNOBTAINIUM ($30k)"},
    ["Rhodium Ore"] = {color = COLORS.MYTHIC, label = "✨ RHODIUM ($15k)"},
    ["Adamantium Ore"] = {color = COLORS.RARE, label = "⚔️ ADAMANTIUM ($4.5k)"},
    ["Iridium Ore"] = {color = COLORS.RARE, label = "🔘 IRIDIUM ($3.7k)"},
    ["Thorium Ore"] = {color = COLORS.RARE, label = "☢️ THORIUM ($3.2k)"},
    ["Mithril Ore"] = {color = COLORS.RARE, label = "💠 MITHRIL ($2k)"},
    ["Palladium Ore"] = {color = COLORS.UNCOMMON, label = "⚪ PALLADIUM ($1.2k)"},
    ["Plutonium Ore"] = {color = COLORS.UNCOMMON, label = "💚 PLUTONIUM ($1k)"},
    
    -- GEMAS
    ["Painite"] = {color = COLORS.LEGENDARY, label = "🔥 PAINITE ($12k)"},
    ["Musgravite"] = {color = COLORS.MYTHIC, label = "💜 MUSGRAVITE ($5.8k)"},
    ["Grandidierite"] = {color = COLORS.RARE, label = "🧪 GRANDIDIERITE ($4.5k)"},
    ["Zultanite"] = {color = COLORS.RARE, label = "🍂 ZULTANITE ($2.3k)"},
    ["Poudretteite"] = {color = COLORS.RARE, label = "🌸 POUDRETTEITE ($1.7k)"},
    ["Diamond"] = {color = COLORS.RARE, label = "💎 DIAMOND ($1.5k)"},
    
    -- ITENS ESPECIAIS
    ["The Master Cube"] = {color = COLORS.SPECIAL, label = "⭐ THE MASTER CUBE"},
    ["OrbOfDestiny"] = {color = COLORS.SPECIAL, label = "🔮 ORB OF DESTINY"},
    ["Arkenstone"] = {color = COLORS.SPECIAL, label = "👑 ARKENSTONE"}
}

local activeESPs = {}

-- FUNÇÃO PARA CRIAR ESP
local function CreateESP(part)
    if activeESPs[part] then return end
    
    local itemData = TARGET_ITEMS[part.Name]
    if not itemData then return end

    -- Criar BillboardGui para o Nome
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "UMT_ESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.Adornee = part
    billboard.MaxDistance = 5000 -- Distância máxima de visão
    
    local label = Instance.new("TextLabel")
    label.Parent = billboard
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = itemData.label
    label.TextColor3 = itemData.color
    label.TextStrokeTransparency = 0
    label.TextSize = 14
    label.Font = Enum.Font.SourceSansBold
    
    -- Criar Highlight (Efeito de Brilho/Raio-X)
    local highlight = Instance.new("Highlight")
    highlight.Name = "UMT_Highlight"
    highlight.Adornee = part
    highlight.FillColor = itemData.color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    billboard.Parent = part
    highlight.Parent = part
    
    activeESPs[part] = {billboard, highlight}
end

-- FUNÇÃO PARA REMOVER ESP
local function RemoveESP(part)
    if activeESPs[part] then
        for _, obj in pairs(activeESPs[part]) do
            obj:Destroy()
        end
        activeESPs[part] = nil
    end
end

-- SCANNER INICIAL E MONITORAMENTO
local function StartESP()
    -- Scan inicial
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and TARGET_ITEMS[obj.Name] then
            CreateESP(obj)
        end
    end
    
    -- Monitorar novos objetos que aparecem (spawn)
    workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("BasePart") then
            -- Pequeno delay para garantir que o nome foi definido pelo jogo
            task.wait(0.1)
            if TARGET_ITEMS[obj.Name] then
                CreateESP(obj)
            end
        end
    end)
    
    -- Monitorar objetos removidos
    workspace.DescendantRemoving:Connect(function(obj)
        RemoveESP(obj)
    end)
end

-- INTERFACE SIMPLIFICADA (BOTÃO ÍCONE)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UMT_ESP_GUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainButton = Instance.new("TextButton")
mainButton.Size = UDim2.new(0, 50, 0, 50)
mainButton.Position = UDim2.new(0, 10, 0.5, -25)
mainButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainButton.BorderSizePixel = 2
mainButton.Text = "⛏️"
mainButton.TextSize = 30
mainButton.TextColor3 = Color3.new(1, 1, 1)
mainButton.Draggable = true
mainButton.Active = true
mainButton.Parent = screenGui

-- Arredondar botão
local corner = Instance.new("UICorner")
corner.CornerRadius = Box.new(0, 25)
corner.Parent = mainButton

local espEnabled = false
mainButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        mainButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        StartESP()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "UMT ESP",
            Text = "ESP de Itens Raros ATIVADO!",
            Duration = 3
        })
    else
        mainButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        for part, _ in pairs(activeESPs) do
            RemoveESP(part)
        end
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "UMT ESP",
            Text = "ESP DESATIVADO!",
            Duration = 3
        })
    end
end)

print("Ultimate Mining Tycoon Rare ESP Carregado!")
