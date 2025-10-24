-- Этот код генерирует цветной шум Перлина в Solar2D (Corona SDK).
-- Шум генерируется по чанкам для оптимизации производительности.
-- Используются кнопки для перемещения по карте шума.

local widget = require("widget")
local display = require("display")
local json = require("json")  -- Добавлено для сохранения JSON
local lfs = require("lfs")    -- Добавлено для работы с файловой системой
local config = require("assets.config")  -- Загрузка конфигурации

-- Константы
local screenW = display.contentWidth
local screenH = display.contentHeight

-- Функция для вычисления значений из конфига
local function getValue(expr)
    if type(expr) == "number" then return expr end
    local env = {screenW = screenW, screenH = screenH}
    local func = loadstring("return " .. expr)
    setfenv(func, env)
    return func()
end

-- Переменные состояния
local state = "menu"  -- "menu", "settings", "game"
local controlMode = "arrows"  -- "arrows" или "mouse"
local zoom = 1  -- Текущий зум

-- Группы для сцен
local menuGroup = display.newGroup()
local settingsGroup = display.newGroup()
local gameGroup = display.newGroup()

-- Функция для очистки экрана
local function clearScreen()
    for i = display.getCurrentStage().numChildren, 1, -1 do
        display.getCurrentStage()[i]:removeSelf()
    end
end

-- Функция создания меню
function createMenu()
    clearScreen()
    state = "menu"

    -- Фон экрана
    display.setDefault("background", config.ui.background.color[1], config.ui.background.color[2], config.ui.background.color[3])

    local title = display.newText(config.ui.menu.title.text, getValue(config.ui.menu.title.x), getValue(config.ui.menu.title.y), config.ui.menu.title.font, config.ui.menu.title.size)
    title:setFillColor(config.ui.menu.title.color[1], config.ui.menu.title.color[2], config.ui.menu.title.color[3])

    local playBtn = widget.newButton{
        label = config.ui.menu.playBtn.label,
        onRelease = function()
            startGame(true)
        end,
        shape = config.ui.menu.playBtn.shape,
        width = config.ui.menu.playBtn.width,
        height = config.ui.menu.playBtn.height,
        fillColor = config.ui.menu.playBtn.fillColor,
        strokeWidth = config.ui.menu.playBtn.strokeWidth,
        strokeColor = config.ui.menu.playBtn.strokeColor,
        labelColor = config.ui.menu.playBtn.labelColor,
        fontSize = config.ui.menu.playBtn.fontSize
    }
    playBtn.x = getValue(config.ui.menu.playBtn.x)
    playBtn.y = getValue(config.ui.menu.playBtn.y)

    local pluginsBtn = widget.newButton{
        label = config.ui.menu.pluginsBtn.label,
        onRelease = function()
            createPlugins()
        end,
        shape = config.ui.menu.pluginsBtn.shape,
        width = config.ui.menu.pluginsBtn.width,
        height = config.ui.menu.pluginsBtn.height,
        fillColor = config.ui.menu.pluginsBtn.fillColor,
        strokeWidth = config.ui.menu.pluginsBtn.strokeWidth,
        strokeColor = config.ui.menu.pluginsBtn.strokeColor,
        labelColor = config.ui.menu.pluginsBtn.labelColor,
        fontSize = config.ui.menu.pluginsBtn.fontSize
    }
    pluginsBtn.x = getValue(config.ui.menu.pluginsBtn.x)
    pluginsBtn.y = getValue(config.ui.menu.pluginsBtn.y)

    local settingsBtn = widget.newButton{
        label = config.ui.menu.settingsBtn.label,
        onRelease = function()
            createSettings()
        end,
        shape = config.ui.menu.settingsBtn.shape,
        width = config.ui.menu.settingsBtn.width,
        height = config.ui.menu.settingsBtn.height,
        fillColor = config.ui.menu.settingsBtn.fillColor,
        strokeWidth = config.ui.menu.settingsBtn.strokeWidth,
        strokeColor = config.ui.menu.settingsBtn.strokeColor,
        labelColor = config.ui.menu.settingsBtn.labelColor,
        fontSize = config.ui.menu.settingsBtn.fontSize
    }
    settingsBtn.x = getValue(config.ui.menu.settingsBtn.x)
    settingsBtn.y = getValue(config.ui.menu.settingsBtn.y)
end

-- Функция создания меню плагинов
function createPlugins()
    clearScreen()
    state = "plugins"

    local title = display.newText(config.ui.plugins.title.text, getValue(config.ui.plugins.title.x), getValue(config.ui.plugins.title.y), config.ui.plugins.title.font, config.ui.plugins.title.size)
    title:setFillColor(unpack(config.ui.plugins.title.color))

    local minimapBtn = widget.newButton{
        label = config.ui.plugins.minimapBtn.label,
        onRelease = function()
            -- Заглушка
        end,
        shape = config.ui.plugins.minimapBtn.shape,
        width = config.ui.plugins.minimapBtn.width,
        height = config.ui.plugins.minimapBtn.height,
        fillColor = config.ui.plugins.minimapBtn.fillColor,
        strokeWidth = config.ui.plugins.minimapBtn.strokeWidth,
        strokeColor = config.ui.plugins.minimapBtn.strokeColor,
        labelColor = config.ui.plugins.minimapBtn.labelColor,
        fontSize = config.ui.plugins.minimapBtn.fontSize
    }
    minimapBtn.x = getValue(config.ui.plugins.minimapBtn.x)
    minimapBtn.y = getValue(config.ui.plugins.minimapBtn.y)

    local backBtn = widget.newButton{
        label = config.ui.plugins.backBtn.label,
        onRelease = function()
            createMenu()
        end,
        shape = config.ui.plugins.backBtn.shape,
        width = config.ui.plugins.backBtn.width,
        height = config.ui.plugins.backBtn.height,
        fillColor = config.ui.plugins.backBtn.fillColor,
        strokeWidth = config.ui.plugins.backBtn.strokeWidth,
        strokeColor = config.ui.plugins.backBtn.strokeColor,
        labelColor = config.ui.plugins.backBtn.labelColor,
        fontSize = config.ui.plugins.backBtn.fontSize
    }
    backBtn.x = getValue(config.ui.plugins.backBtn.x)
    backBtn.y = getValue(config.ui.plugins.backBtn.y)
end

-- Функция создания настроек
function createSettings()
    clearScreen()
    state = "settings"

    local title = display.newText(config.ui.settings.title.text, getValue(config.ui.settings.title.x), getValue(config.ui.settings.title.y), config.ui.settings.title.font, config.ui.settings.title.size)
    title:setFillColor(unpack(config.ui.settings.title.color))

    local controlLabel = display.newText(config.ui.settings.controlLabel.text, getValue(config.ui.settings.controlLabel.x), getValue(config.ui.settings.controlLabel.y), config.ui.settings.controlLabel.font, config.ui.settings.controlLabel.size)
    controlLabel:setFillColor(unpack(config.ui.settings.controlLabel.color))

    local arrowsBtn = widget.newButton{
        label = config.ui.settings.arrowsBtn.label,
        onRelease = function()
            controlMode = "arrows"
            createMenu()
        end,
        shape = config.ui.settings.arrowsBtn.shape,
        width = config.ui.settings.arrowsBtn.width,
        height = config.ui.settings.arrowsBtn.height,
        fillColor = config.ui.settings.arrowsBtn.fillColor,
        strokeWidth = config.ui.settings.arrowsBtn.strokeWidth,
        strokeColor = config.ui.settings.arrowsBtn.strokeColor,
        labelColor = config.ui.settings.arrowsBtn.labelColor,
        fontSize = config.ui.settings.arrowsBtn.fontSize
    }
    arrowsBtn.x = getValue(config.ui.settings.arrowsBtn.x)
    arrowsBtn.y = getValue(config.ui.settings.arrowsBtn.y)

    local mouseBtn = widget.newButton{
        label = config.ui.settings.mouseBtn.label,
        onRelease = function()
            controlMode = "mouse"
            createMenu()
        end,
        shape = config.ui.settings.mouseBtn.shape,
        width = config.ui.settings.mouseBtn.width,
        height = config.ui.settings.mouseBtn.height,
        fillColor = config.ui.settings.mouseBtn.fillColor,
        strokeWidth = config.ui.settings.mouseBtn.strokeWidth,
        strokeColor = config.ui.settings.mouseBtn.strokeColor,
        labelColor = config.ui.settings.mouseBtn.labelColor,
        fontSize = config.ui.settings.mouseBtn.fontSize
    }
    mouseBtn.x = getValue(config.ui.settings.mouseBtn.x)
    mouseBtn.y = getValue(config.ui.settings.mouseBtn.y)

    local backBtn = widget.newButton{
        label = config.ui.settings.backBtn.label,
        onRelease = function()
            createMenu()
        end,
        shape = config.ui.settings.backBtn.shape,
        width = config.ui.settings.backBtn.width,
        height = config.ui.settings.backBtn.height,
        fillColor = config.ui.settings.backBtn.fillColor,
        strokeWidth = config.ui.settings.backBtn.strokeWidth,
        strokeColor = config.ui.settings.backBtn.strokeColor,
        labelColor = config.ui.settings.backBtn.labelColor,
        fontSize = config.ui.settings.backBtn.fontSize
    }
    backBtn.x = getValue(config.ui.settings.backBtn.x)
    backBtn.y = getValue(config.ui.settings.backBtn.y)
end

-- Функция запуска игры
function startGame(withMinimap)
    clearScreen()
    state = "game"

    -- Импорт модуля map
    local map = require("assets.map")

    -- Очистка старых чанков
    map.chunks = {}
    map.chunkColors = {}
    if map.minimapGroup then
        map.minimapGroup:removeSelf()
        map.minimapGroup = nil
    end

    -- Загрузка сохраненного состояния игры
    local gameState = {}
    local gameStatePath = system.pathForFile("gameState.json", system.DocumentsDirectory)
    if gameStatePath then
        local file = io.open(gameStatePath, "r")
        if file then
            local content = file:read("*a")
            file:close()
            gameState = json.decode(content) or {}
            print("Game state loaded: zoom=" .. (gameState.zoom or "nil") .. ", seed=" .. (gameState.seed or "nil") .. ", panX=" .. (gameState.panX or "nil") .. ", panY=" .. (gameState.panY or "nil"))
        else
            print("Failed to open gameState.json for reading")
        end
    else
        print("gameState.json path not found")
    end
    zoom = gameState.zoom or 1

    -- Константы игры
    local CHUNK_SIZE = 16  -- Размер чанка в точках шума
    local PIXEL_SIZE = 4   -- Размер одного пикселя (квадрата) на экране
    local CHUNK_PIXEL_SIZE = CHUNK_SIZE * PIXEL_SIZE  -- Размер чанка в пикселях
    local currentPanX = gameState.panX or 0  -- Текущая позиция для миникарты
    local currentPanY = gameState.panY or 0  -- Текущая позиция для миникарты

    -- Группа для хранения чанков
    local chunkGroup = display.newGroup()
    display.getCurrentStage():insert(chunkGroup)
    chunkGroup.x = currentPanX
    chunkGroup.y = currentPanY
    chunkGroup.xScale = zoom
    chunkGroup.yScale = zoom

    -- Seed для шума (для детерминированной генерации)
    local seed = gameState.seed or math.random(1, 1000000)

    -- Реализация шума Перлина с seed
    local p = {}
    math.randomseed(seed)
    for i = 0, 255 do
        p[i] = i
    end
    for i = 255, 1, -1 do
        local j = math.random(0, i)
        p[i], p[j] = p[j], p[i]
    end
    for i = 0, 255 do
        p[i + 256] = p[i]
    end

    local function fade(t)
        return t * t * t * (t * (t * 6 - 15) + 10)
    end

    local function lerp(a, b, t)
        return a + t * (b - a)
    end

    local function grad(hash, x, y)
        local h = hash % 4
        if h == 0 then return x + y
        elseif h == 1 then return -x + y
        elseif h == 2 then return x - y
        else return -x - y end
    end

    local function noise(x, y)
        local xi = math.floor(x) % 256
        local yi = math.floor(y) % 256
        local xf = x - math.floor(x)
        local yf = y - math.floor(y)
        local u = fade(xf)
        local v = fade(yf)
        local aa = p[p[xi] + yi]
        local ab = p[p[xi] + yi + 1]
        local ba = p[p[xi + 1] + yi]
        local bb = p[p[xi + 1] + yi + 1]
        local x1 = lerp(grad(aa, xf, yf), grad(ba, xf - 1, yf), u)
        local x2 = lerp(grad(ab, xf, yf - 1), grad(bb, xf - 1, yf - 1), u)
        return lerp(x1, x2, v)
    end

    -- Функция для преобразования HSL в RGB
    local function hslToRgb(h, s, l)
        local c = (1 - math.abs(2 * l - 1)) * s
        local x = c * (1 - math.abs((h / 60) % 2 - 1))
        local m = l - c / 2
        local r, g, b
        if h < 60 then
            r, g, b = c, x, 0
        elseif h < 120 then
            r, g, b = x, c, 0
        elseif h < 180 then
            r, g, b = 0, c, x
        elseif h < 240 then
            r, g, b = 0, x, c
        elseif h < 300 then
            r, g, b = x, 0, c
        else
            r, g, b = c, 0, x
        end
        return math.floor((r + m) * 255), math.floor((g + m) * 255), math.floor((b + m) * 255)
    end

    -- Функция для генерации чанка по координатам cx, cy
    local function generateChunk(cx, cy)
        map.generateChunk(cx, cy, chunkGroup, CHUNK_SIZE, PIXEL_SIZE, CHUNK_PIXEL_SIZE, noise, hslToRgb)
    end

    -- Генерация начальных чанков вокруг центра (0,0)
    for i = -2, 2 do
        for j = -2, 2 do
            generateChunk(i, j)
        end
    end

    -- Функция для проверки и генерации новых чанков при перемещении
    local function checkAndGenerateChunks()
        map.checkAndGenerateChunks(chunkGroup, screenW, screenH, CHUNK_PIXEL_SIZE, zoom, generateChunk)
    end

    local function updateZoom()
        chunkGroup.xScale = zoom
        chunkGroup.yScale = zoom
        checkAndGenerateChunks()
        if withMinimap then
            map.updateMinimapView(currentPanX, currentPanY, zoom)
        end
    end

    -- Создание миникарты, если withMinimap
    if withMinimap then
        map.createMinimap(screenW, screenH)
        display.getCurrentStage():insert(map.minimapGroup)
        -- Принудительно обновляем миникарту после вставки в сцену
        timer.performWithDelay(100, function()
            for key, colors in pairs(map.chunkColors) do
                local cx, cy = key:match("(-?%d+)_(-?%d+)")
                cx = tonumber(cx)
                cy = tonumber(cy)
                map.updateMinimap(cx, cy)
            end
        end)
    end

    -- Сохранение цветов чанков и состояния игры при выходе из игры
    Runtime:addEventListener("system", function(event)
        if event.type == "applicationExit" then
            map.saveChunkColors("chunkColors.json")
            -- Сохранение состояния игры
            local gameStateToSave = {
                zoom = zoom,
                seed = seed,
                panX = currentPanX,
                panY = currentPanY
            }
            local gameStatePath = system.pathForFile("gameState.json", system.DocumentsDirectory)
            local file = io.open(gameStatePath, "w")
            if file then
                file:write(json.encode(gameStateToSave))
                file:close()
                print("Saved game state: zoom=" .. zoom .. ", seed=" .. seed .. ", panX=" .. currentPanX .. ", panY=" .. currentPanY)
            else
                print("Failed to save game state")
            end
        end
    end)

    -- Кнопки для зума
    local zoomInBtn = widget.newButton{
        label = config.ui.game.zoomInBtn.label,
        onRelease = function()
            zoom = zoom * 1.2
            updateZoom()
        end,
        shape = config.ui.game.zoomInBtn.shape,
        width = config.ui.game.zoomInBtn.width,
        height = config.ui.game.zoomInBtn.height,
        fillColor = config.ui.game.zoomInBtn.fillColor,
        strokeWidth = config.ui.game.zoomInBtn.strokeWidth,
        strokeColor = config.ui.game.zoomInBtn.strokeColor,
        labelColor = config.ui.game.zoomInBtn.labelColor,
        fontSize = config.ui.game.zoomInBtn.fontSize
    }
    zoomInBtn.x = getValue(config.ui.game.zoomInBtn.x)
    zoomInBtn.y = getValue(config.ui.game.zoomInBtn.y)

    local zoomOutBtn = widget.newButton{
        label = config.ui.game.zoomOutBtn.label,
        onRelease = function()
            zoom = zoom / 1.2
            updateZoom()
        end,
        shape = config.ui.game.zoomOutBtn.shape,
        width = config.ui.game.zoomOutBtn.width,
        height = config.ui.game.zoomOutBtn.height,
        fillColor = config.ui.game.zoomOutBtn.fillColor,
        strokeWidth = config.ui.game.zoomOutBtn.strokeWidth,
        strokeColor = config.ui.game.zoomOutBtn.strokeColor,
        labelColor = config.ui.game.zoomOutBtn.labelColor,
        fontSize = config.ui.game.zoomOutBtn.fontSize
    }
    zoomOutBtn.x = getValue(config.ui.game.zoomOutBtn.x)
    zoomOutBtn.y = getValue(config.ui.game.zoomOutBtn.y)

    local upBtn, downBtn, leftBtn, rightBtn
    if controlMode == "arrows" then
        upBtn = widget.newButton{
            label = config.ui.game.upBtn.label,
            onRelease = function()
                chunkGroup.y = chunkGroup.y + CHUNK_PIXEL_SIZE
                currentPanY = currentPanY + CHUNK_PIXEL_SIZE
                checkAndGenerateChunks()
                if withMinimap then
                    map.updateMinimapView(currentPanX, currentPanY, zoom)
                end
            end,
            shape = config.ui.game.upBtn.shape,
            width = config.ui.game.upBtn.width,
            height = config.ui.game.upBtn.height,
            fillColor = config.ui.game.upBtn.fillColor,
            strokeWidth = config.ui.game.upBtn.strokeWidth,
            strokeColor = config.ui.game.upBtn.strokeColor,
            labelColor = config.ui.game.upBtn.labelColor,
            fontSize = config.ui.game.upBtn.fontSize
        }
        upBtn.x = getValue(config.ui.game.upBtn.x)
        upBtn.y = getValue(config.ui.game.upBtn.y)

        downBtn = widget.newButton{
            label = config.ui.game.downBtn.label,
            onRelease = function()
                chunkGroup.y = chunkGroup.y - CHUNK_PIXEL_SIZE
                currentPanY = currentPanY - CHUNK_PIXEL_SIZE
                checkAndGenerateChunks()
                if withMinimap then
                    map.updateMinimapView(currentPanX, currentPanY, zoom)
                end
            end,
            shape = config.ui.game.downBtn.shape,
            width = config.ui.game.downBtn.width,
            height = config.ui.game.downBtn.height,
            fillColor = config.ui.game.downBtn.fillColor,
            strokeWidth = config.ui.game.downBtn.strokeWidth,
            strokeColor = config.ui.game.downBtn.strokeColor,
            labelColor = config.ui.game.downBtn.labelColor,
            fontSize = config.ui.game.downBtn.fontSize
        }
        downBtn.x = getValue(config.ui.game.downBtn.x)
        downBtn.y = getValue(config.ui.game.downBtn.y)

        leftBtn = widget.newButton{
            label = config.ui.game.leftBtn.label,
            onRelease = function()
                chunkGroup.x = chunkGroup.x + CHUNK_PIXEL_SIZE
                currentPanX = currentPanX + CHUNK_PIXEL_SIZE
                checkAndGenerateChunks()
                if withMinimap then
                    map.updateMinimapView(currentPanX, currentPanY, zoom)
                end
            end,
            shape = config.ui.game.leftBtn.shape,
            width = config.ui.game.leftBtn.width,
            height = config.ui.game.leftBtn.height,
            fillColor = config.ui.game.leftBtn.fillColor,
            strokeWidth = config.ui.game.leftBtn.strokeWidth,
            strokeColor = config.ui.game.leftBtn.strokeColor,
            labelColor = config.ui.game.leftBtn.labelColor,
            fontSize = config.ui.game.leftBtn.fontSize
        }
        leftBtn.x = getValue(config.ui.game.leftBtn.x)
        leftBtn.y = getValue(config.ui.game.leftBtn.y)

        rightBtn = widget.newButton{
            label = config.ui.game.rightBtn.label,
            onRelease = function()
                chunkGroup.x = chunkGroup.x - CHUNK_PIXEL_SIZE
                currentPanX = currentPanX - CHUNK_PIXEL_SIZE
                checkAndGenerateChunks()
                if withMinimap then
                    map.updateMinimapView(currentPanX, currentPanY, zoom)
                end
            end,
            shape = config.ui.game.rightBtn.shape,
            width = config.ui.game.rightBtn.width,
            height = config.ui.game.rightBtn.height,
            fillColor = config.ui.game.rightBtn.fillColor,
            strokeWidth = config.ui.game.rightBtn.strokeWidth,
            strokeColor = config.ui.game.rightBtn.strokeColor,
            labelColor = config.ui.game.rightBtn.labelColor,
            fontSize = config.ui.game.rightBtn.fontSize
        }
        rightBtn.x = getValue(config.ui.game.rightBtn.x)
        rightBtn.y = getValue(config.ui.game.rightBtn.y)
    end

    local isDragging = false
    local startX, startY

    local function touchHandler(event)
        if event.phase == "began" then
            isDragging = true
            startX = event.x
            startY = event.y
            display.getCurrentStage():setFocus(event.target)
        elseif event.phase == "moved" and isDragging then
            local deltaX = event.x - startX
            local deltaY = event.y - startY
            chunkGroup.x = chunkGroup.x + deltaX
            chunkGroup.y = chunkGroup.y + deltaY
            currentPanX = currentPanX + deltaX
            currentPanY = currentPanY + deltaY
            startX = event.x
            startY = event.y
            checkAndGenerateChunks()
            if withMinimap then
                map.updateMinimapView(currentPanX, currentPanY, zoom)
            end
        elseif event.phase == "ended" or event.phase == "cancelled" then
            isDragging = false
            display.getCurrentStage():setFocus(nil)
        end
        return true
    end

    if controlMode == "mouse" then
        chunkGroup:addEventListener("touch", touchHandler)
    end

    local menuBtn = widget.newButton{
        label = config.ui.game.menuBtn.label,
        onRelease = function()
            -- Сохранение перед выходом в меню
            map.saveChunkColors("chunkColors.json")
            local gameStateToSave = {
                zoom = zoom,
                seed = seed,
                panX = currentPanX,
                panY = currentPanY
            }
            local gameStatePath = system.pathForFile("gameState.json", system.DocumentsDirectory)
            local file = io.open(gameStatePath, "w")
            if file then
                file:write(json.encode(gameStateToSave))
                file:close()
                print("Saved game state on menu exit: zoom=" .. zoom .. ", seed=" .. seed .. ", panX=" .. currentPanX .. ", panY=" .. currentPanY)
            else
                print("Failed to save game state on menu exit")
            end
            createMenu()
        end,
        shape = config.ui.game.menuBtn.shape,
        width = config.ui.game.menuBtn.width,
        height = config.ui.game.menuBtn.height,
        fillColor = config.ui.game.menuBtn.fillColor,
        strokeWidth = config.ui.game.menuBtn.strokeWidth,
        strokeColor = config.ui.game.menuBtn.strokeColor,
        labelColor = config.ui.game.menuBtn.labelColor,
        fontSize = config.ui.game.menuBtn.fontSize
    }
    menuBtn.x = getValue(config.ui.game.menuBtn.x)
    menuBtn.y = getValue(config.ui.game.menuBtn.y)
end

-- Запуск меню при старте
createMenu()