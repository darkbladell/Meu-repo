-- ============================================
-- TB DUELS - LOADER COM FALLBACK
-- ============================================

local FONTES = {
    "https://raw.githubusercontent.com/darkbladell/Meu-repo/main/tb_duels.lua",
}

local carregado = false
local ultimoErro = nil

for i, url in ipairs(FONTES) do
    print("[TB] Tentando fonte " .. i .. ": " .. url)
    local sucesso, resultado = pcall(function()
        return game:HttpGet(url, true)
    end)

    if sucesso and resultado and #resultado > 100 then
        local ok, err = pcall(function()
            loadstring(resultado)()
        end)
        if ok then
            print("[TB] ✅ Carregado da fonte " .. i)
            carregado = true
            break
        else
            ultimoErro = err
            warn("[TB] ❌ Erro ao executar: " .. tostring(err))
        end
    else
        ultimoErro = resultado
        warn("[TB] ❌ Falha ao baixar fonte " .. i)
    end
end

if not carregado then
    warn("[TB] Todas as fontes falharam! Erro: " .. tostring(ultimoErro))
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "TB Duels",
        Text = "Falha ao carregar script.",
        Duration = 5,
    })
end
