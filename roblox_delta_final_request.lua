--[[
    SCRIPT DE VARREDURA COMPLETA (VERSÃO ESPECIAL PARA DELTA)
    Usa a função 'request' do Delta para evitar erros de segurança.
--]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CONFIGURAÇÕES
local WEBHOOK_URL = "https://discord.com/api/webhooks/1485489864681062454/vUfOgzM3of2mQeDjWKe0b2dcElZkA2eQJYmVJF5Z1ebDyVoXzsZOGNoUujZve0XPgvkZ"

local objetosDetectados = {}
local posicaoBase = nil
local posicaoCaverna = nil

-- 1. FUNÇÃO PARA ENVIAR RELATÓRIO AO DISCORD (USANDO DELTA REQUEST)
local function EnviarRelatorioDiscord()
    local listaNomes = ""
    for nome, qtd in pairs(objetosDetectados) do
        listaNomes = listaNomes .. "- **" .. nome .. "**: " .. qtd .. " unidades\n"
        if #listaNomes > 1800 then break end
    end
    
    if listaNomes == "" then
        listaNomes = "Nenhum objeto detectado. Clique em 'Escanear Mapa Todo' primeiro!"
    end

    local data = {
        ["content"] = "",
        ["embeds"] = {{
            ["title"] = "🌍 Varredura Completa do Mapa - Roblox",
            ["description"] = "Aqui estão todos os objetos encontrados no Workspace:\n\n" .. listaNomes,
            ["color"] = 16711680,
            ["footer"] = {
                ["text"] = "Enviado via Delta Executor | " .. os.date("%X")
            }
        }}
    }

    -- Tenta usar a função 'request' ou 'http_request' do Delta
    local requestFunc = (syn and syn.request) or (http and http.request) or http_request or request
    
    if requestFunc then
        local success, response = pcall(function()
            return requestFunc({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode(data)
            })
        end)
        
        if success then
            print("✅ Relatório enviado ao Discord via Delta Request!")
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Discord Webhook",
                Text = "Relatório enviado com sucesso!",
                Duration = 5
            })
            objetosDetectados = {}
        else
            warn("❌ Erro no Delta Request: " .. tostring(response))
        end
    else
        warn("❌ Função 'request' não encontrada no Delta. Verifique se o executor está atualizado.")
    end
end

-- 2. CRIAR INTERFACE (GUI)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaScannerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 280)
frame.Position = UDim2.new(0.5, -110, 0.5, -140)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 2
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "DELTA FULL SCANNER"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Parent = frame

local function CriarBotao(nome, texto, pos, cor)
    local btn = Instance.new("TextButton")
    btn.Name = nome
    btn.Text = texto
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = pos
    btn.BackgroundColor3 = cor
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = frame
    return btn
end

local btnScanAll = CriarBotao("ScanAll", "Escanear Mapa Todo", UDim2.new(0.05, 0, 0.15, 0), Color3.fromRGB(100, 0, 150))
local btnSaveBase = CriarBotao("SaveBase", "Marcar Base", UDim2.new(0.05, 0, 0.30, 0), Color3.fromRGB(0, 100, 200))
local btnGoBase = CriarBotao("GoBase", "Ir para Base", UDim2.new(0.05, 0, 0.42, 0), Color3.fromRGB(0, 120, 255))
local btnSaveCave = CriarBotao("SaveCave", "Marcar Caverna", UDim2.new(0.05, 0, 0.57, 0), Color3.fromRGB(150, 50, 0))
local btnGoCave = CriarBotao("GoCave", "Ir para Caverna", UDim2.new(0.05, 0, 0.69, 0), Color3.fromRGB(200, 70, 0))
local btnDiscord = CriarBotao("Discord", "Enviar para Discord", UDim2.new(0.05, 0, 0.85, 0), Color3.fromRGB(114, 137, 218))

btnScanAll.MouseButton1Click:Connect(function()
    objetosDetectados = {}
    local totalItens = 0
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if not obj:IsDescendantOf(player.Character) and obj.Name ~= "Baseplate" and obj.Name ~= "Terrain" then
                objetosDetectados[obj.Name] = (objetosDetectados[obj.Name] or 0) + 1
                totalItens = totalItens + 1
            end
        end
    end
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Varredura Concluída",
        Text = "Encontrados " .. totalItens .. " objetos!",
        Duration = 5
    })
end)

btnSaveBase.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        posicaoBase = player.Character.HumanoidRootPart.CFrame
    end
end)

btnGoBase.MouseButton1Click:Connect(function()
    if posicaoBase and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = posicaoBase
    end
end)

btnSaveCave.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        posicaoCaverna = player.Character.HumanoidRootPart.CFrame
    end
end)

btnGoCave.MouseButton1Click:Connect(function()
    if posicaoCaverna and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = posicaoCaverna
    end
end)

btnDiscord.MouseButton1Click:Connect(function()
    EnviarRelatorioDiscord()
end)

print("Script Delta Final Carregado!")
