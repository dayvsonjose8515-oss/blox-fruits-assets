--[[
    SCRIPT DE VARREDURA COMPLETA (VERSÃO ESPECIAL PARA DELTA)
    Usa a função 'request' do Delta para evitar erros de segurança.
    Versão aprimorada com GUI simplificada e Webhook original restaurado.
--]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CONFIGURAÇÕES
local WEBHOOK_URL = "https://discord.com/api/webhooks/1485489864681062454/vUfOgzM3of2mQeDjWKe0b2dcElZkA2eQJYmVJF5Z1ebDyVoXzsZOGNoUujZve0XPgvkZ"

local objetosDetectados = {}

-- 1. FUNÇÃO PARA ENVIAR RELATÓRIO AO DISCORD (USANDO DELTA REQUEST)
local function EnviarRelatorioDiscord()
    if WEBHOOK_URL == "" then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Erro de Configuração",
            Text = "O Webhook URL não está configurado!",
            Duration = 7
        })
        return
    end

    local listaNomes = ""
    for nome, qtd in pairs(objetosDetectados) do
        listaNomes = listaNomes .. "- **" .. nome .. "**: " .. qtd .. " unidades\n"
        if #listaNomes > 1800 then break end
    end
    
    if listaNomes == "" then
        listaNomes = "Nenhum objeto detectado no Workspace."
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
            print("✅ Relatório enviado ao Discord!")
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
        warn("❌ Função 'request' não encontrada.")
    end
end

-- 2. FUNÇÃO PARA REALIZAR A VARREDURA
local function RealizarVarredura()
    objetosDetectados = {}
    local totalItens = 0
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Varredura Iniciada",
        Text = "Escaneando o mapa...",
        Duration = 3
    })
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsA("Terrain") and not obj:IsA("Folder") and not obj:IsA("Model") then
            if not obj:IsDescendantOf(player.Character) and obj.Name ~= "Baseplate" then
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
    return totalItens
end

-- 3. CRIAR INTERFACE (GUI) SIMPLIFICADA
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaScannerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 80)
frame.Position = UDim2.new(0.5, -90, 0.5, -40)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 2
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.Text = "DELTA SCANNER"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Parent = frame

local btnScanAndSend = Instance.new("TextButton")
btnScanAndSend.Name = "ScanAndSend"
btnScanAndSend.Text = "Escanear e Enviar"
btnScanAndSend.Size = UDim2.new(0.9, 0, 0, 35)
btnScanAndSend.Position = UDim2.new(0.05, 0, 0.4, 0)
btnScanAndSend.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
btnScanAndSend.TextColor3 = Color3.new(1, 1, 1)
btnScanAndSend.Parent = frame

btnScanAndSend.MouseButton1Click:Connect(function()
    RealizarVarredura()
    EnviarRelatorioDiscord()
end)

print("Script Delta Scanner Carregado!")
