-- Cole esse script PRIMEIRO no Delta para ver os RemoteEvents do jogo
-- Vai printar no console todos os remotes disponiveis

local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("=== REMOTES ENCONTRADOS ===")

local function scan(parent, path)
    for _, obj in ipairs(parent:GetChildren()) do
        local fullPath = path .. "." .. obj.Name
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("BindableEvent") then
            print("[" .. obj.ClassName .. "] " .. fullPath)
        end
        -- Entra em pastas e modelos
        if obj:IsA("Folder") or obj:IsA("Model") or obj:IsA("Configuration") then
            scan(obj, fullPath)
        end
    end
end

scan(ReplicatedStorage, "ReplicatedStorage")

-- Tambem escaneia workspace
print("=== WORKSPACE ===")
scan(workspace, "workspace")

print("=== FIM DO SCAN ===")
