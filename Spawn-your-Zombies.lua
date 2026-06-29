-- ELITE HUB | АВТОФАРМ 
local player = game.Players.LocalPlayer
local print = function(msg) warn("[ELITE HUB] " .. tostring(msg)) end

-- ========================================
-- ЗАГРУЗКА RAYFIELD
-- ========================================
if not game:IsLoaded() then game.Loaded:Wait() end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
if not Rayfield then
    print("❌ Rayfield не загружен!")
    return
end

print("✅ Rayfield загружен!")

-- ========================================
-- НАСТРОЙКИ
-- ========================================
local settings = {
    enabled = false,
    speed = 0.3,
    target = "Все"
}

local myTeam = nil              -- текущая команда
local isWaitingForTeam = false  -- флаг: ждём определения команды

-- ========================================
-- ОБЪЕКТЫ
-- ========================================
local lobbySpawn = workspace:FindFirstChild("LobbySpawn")
local redSpawn = workspace:FindFirstChild("RedSpawn")
local blueSpawn = workspace:FindFirstChild("BlueSpawn")
local redBlock = workspace:FindFirstChild("BlockPile") and workspace.BlockPile:FindFirstChild("Red")
local blueBlock = workspace:FindFirstChild("BlockPile") and workspace.BlockPile:FindFirstChild("Blue")
local teamBase = workspace:FindFirstChild("TeamBase")

-- ========================================
-- ПОЛУЧЕНИЕ КНОПОК
-- ========================================
local function getTargetButtons(color)
    if not teamBase then return {} end
    local prefix = (color == "Red") and "RedBase" or "BlueBase"
    local allButtons = {}
    for _, child in ipairs(teamBase:GetChildren()) do
        if string.find(child.Name, prefix) then
            table.insert(allButtons, child)
        end
    end
    if settings.target == "Все" then
        return allButtons
    end
    local suffixMap = {
        ["Слабый"] = "Left",
        ["Обычный"] = "Center",
        ["Титановый"] = "Right"
    }
    local suffix = suffixMap[settings.target]
    if not suffix then return allButtons end
    local filtered = {}
    for _, btn in ipairs(allButtons) do
        if string.find(btn.Name, suffix) then
            table.insert(filtered, btn)
        end
    end
    return filtered
end

-- ========================================
-- ОПРЕДЕЛЕНИЕ МЕСТОПОЛОЖЕНИЯ
-- ========================================
local function isInLobby()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    local pos = root.Position
    if lobbySpawn and (pos - lobbySpawn.Position).Magnitude < 60 then
        return true
    end
    return false
end

local function getTeamByPosition()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local pos = root.Position
    
    for _, btn in ipairs(getTargetButtons("Red")) do
        if (pos - btn.Position).Magnitude < 80 then
            return "Red"
        end
    end
    for _, btn in ipairs(getTargetButtons("Blue")) do
        if (pos - btn.Position).Magnitude < 80 then
            return "Blue"
        end
    end
    if redSpawn and (pos - redSpawn.Position).Magnitude < 40 then
        return "Red"
    end
    if blueSpawn and (pos - blueSpawn.Position).Magnitude < 40 then
        return "Blue"
    end
    return nil
end

-- ========================================
-- ФУНКЦИЯ ОПРЕДЕЛЕНИЯ КОМАНДЫ (С ОЖИДАНИЕМ)
-- ========================================
local function determineTeam()
    if isInLobby() then
        -- В лобби — команда не определена, ждём
        if myTeam then
            print("[ELITE HUB] ⏸ В ЛОББИ, СБРАСЫВАЮ КОМАНДУ")
            myTeam = nil
        end
        isWaitingForTeam = true
        return nil
    end
    
    -- Если не в лобби — проверяем позицию
    local team = getTeamByPosition()
    if team then
        if not myTeam or myTeam ~= team then
            myTeam = team
            isWaitingForTeam = false
            print("[ELITE HUB] 🔄 КОМАНДА ОПРЕДЕЛЕНА: " .. team)
        end
        return team
    else
        -- На карте, но не на базе (возможно, спавнится)
        if not isWaitingForTeam then
            print("[ELITE HUB] ⏳ ОЖИДАНИЕ ПОЯВЛЕНИЯ НА БАЗЕ...")
            isWaitingForTeam = true
        end
        return nil
    end
end

-- ========================================
-- ОСТАЛЬНЫЕ ФУНКЦИИ
-- ========================================
local function teleportTo(target)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root and target then
        local cf
        if typeof(target) == "Vector3" then
            cf = CFrame.new(target)
        else
            cf = target.CFrame
        end
        root.CFrame = cf + Vector3.new(0, 2.5, 0)
        return true
    end
    return false
end

local function farm(color)
    local block = (color == "Red") and redBlock or blueBlock
    local bases = getTargetButtons(color)
    if not block or #bases == 0 then return end
    for _, base in ipairs(bases) do
        if not settings.enabled then return end
        teleportTo(block)
        task.wait(settings.speed)
        teleportTo(base)
        task.wait(settings.speed)
    end
end

-- ========================================
-- АВТОФАРМ
-- ========================================
local autoFarmLoop = nil

function startAutoFarm()
    if autoFarmLoop then return end
    
    autoFarmLoop = task.spawn(function()
        print("[ELITE HUB] 🔥 ЗАПУСК АВТОФАРМА...")
        print("[ELITE HUB] 🎯 ЦЕЛЬ: " .. settings.target)
        print("[ELITE HUB] 📌 ОЖИДАНИЕ ОПРЕДЕЛЕНИЯ КОМАНДЫ...")
        
        local cycle = 0
        local waitCounter = 0
        
        while settings.enabled do
            -- ОПРЕДЕЛЯЕМ КОМАНДУ
            local team = determineTeam()
            
            -- Если команда НЕ определена — НЕ ТЕЛЕПОРТИРУЕМ, просто ждём
            if not myTeam then
                waitCounter = waitCounter + 1
                if waitCounter % 5 == 0 then
                    if isInLobby() then
                        print("[ELITE HUB] ⏸ В ЛОББИ, ЖДУ ВЫХОДА...")
                    else
                        print("[ELITE HUB] ⏳ ОПРЕДЕЛЕНИЕ КОМАНДЫ...")
                    end
                end
                task.wait(0.5)
                continue
            end
            waitCounter = 0
            
            -- Если мы в лобби (но команда всё ещё есть — сбросим её)
            if isInLobby() then
                print("[ELITE HUB] ⏸ В ЛОББИ, СБРАСЫВАЮ КОМАНДУ")
                myTeam = nil
                isWaitingForTeam = true
                task.wait(0.5)
                continue
            end
            
            -- ФАРМИМ (только если команда определена и мы не в лобби)
            cycle = cycle + 1
            print("[ELITE HUB] ════════════════════════════")
            print("[ELITE HUB] 🔄 ЦИКЛ " .. cycle .. " | " .. myTeam .. " | Цель: " .. settings.target)
            
            print("[ELITE HUB] ⛏ ФАРМ...")
            farm(myTeam)
            
            task.wait(0.5)
        end
        
        print("[ELITE HUB] ⏹ АВТОФАРМ ОСТАНОВЛЕН!")
        autoFarmLoop = nil
    end)
end

function stopAutoFarm()
    if autoFarmLoop then
        autoFarmLoop = nil
        task.wait(0.5)
        print("[ELITE HUB] ⏹ АВТОФАРМ ОСТАНОВЛЕН!")
    end
end

-- ========================================
-- GUI
-- ========================================
local Window = Rayfield:CreateWindow({
    Name = "🔥 ELITE HUB | АВТОФАРМ",
    Icon = 0,
    LoadingTitle = "Загрузка ELITE HUB...",
    LoadingSubtitle = "by ELITE_HUB",
    Theme = "Default",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "EliteHubConfig",
        FileName = "AutoFarmSettings"
    }
})

local MainTab = Window:CreateTab("⚡ Основное", 0)
MainTab:CreateSection("Управление")

MainTab:CreateToggle({
    Name = "Включить автофарм",
    CurrentValue = false,
    Flag = "FarmToggle",
    Callback = function(Value)
        settings.enabled = Value
        if Value then
            print("[ELITE HUB] 🔥 АВТОФАРМ ВКЛЮЧЁН!")
            startAutoFarm()
        else
            print("[ELITE HUB] ⏹ АВТОФАРМ ВЫКЛЮЧЁН!")
            stopAutoFarm()
        end
    end
})

MainTab:CreateSlider({
    Name = "Скорость телепортации",
    Range = {0.05, 1},
    Increment = 0.05,
    Suffix = "s",
    CurrentValue = 0.3,
    Flag = "SpeedSlider",
    Callback = function(Value)
        settings.speed = Value
        print("[ELITE HUB] Скорость: " .. Value .. " сек")
    end
})

local TargetTab = Window:CreateTab("🎯 Выбор цели", 1)
TargetTab:CreateSection("Тип зомби")
TargetTab:CreateDropdown({
    Name = "Выберите цель",
    Options = {"Все", "Слабый (4 блока)", "Обычный (5 блоков)", "Титановый (7 блоков)"},
    CurrentOption = {"Все"},
    MultipleOptions = false,
    Flag = "TargetDropdown",
    Callback = function(Options)
        local Option = Options[1]
        if Option == "Все" then
            settings.target = "Все"
        elseif Option == "Слабый (4 блока)" then
            settings.target = "Слабый"
        elseif Option == "Обычный (5 блоков)" then
            settings.target = "Обычный"
        elseif Option == "Титановый (7 блоков)" then
            settings.target = "Титановый"
        end
        print("[ELITE HUB] 🎯 Выбрана цель: " .. settings.target)
    end
})

local InfoTab = Window:CreateTab("📊 Информация", 2)
InfoTab:CreateSection("О скрипте")
InfoTab:CreateLabel("🔥 ELITE HUB v7.0")
InfoTab:CreateLabel("📌 Автор: ELITE_HUB")
InfoTab:CreateLabel("🎮 Игра: Spawn your Zombies")
InfoTab:CreateLabel("🔄 Команда определяется при выходе из лобби (без телепортации)")

-- ========================================
-- ЗАПУСК
-- ========================================
print("[ELITE HUB] 🔥 GUI ЗАГРУЖЕН!")
print("[ELITE HUB] 📌 СКРИПТ НЕ ТЕЛЕПОРТИРУЕТ, ПОКА НЕ ОПРЕДЕЛИТ КОМАНДУ")
print("[ELITE HUB] 📌 ВЫЙДИ ИЗ ЛОББИ — КОМАНДА ОПРЕДЕЛИТСЯ АВТОМАТИЧЕСКИ")

-- Первое определение
task.wait(1)
determineTeam()
