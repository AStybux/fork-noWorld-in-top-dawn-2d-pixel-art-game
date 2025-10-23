-- Этот код генерирует цветной шум Перлина в Solar2D (Corona SDK).
-- Шум генерируется по чанкам для оптимизации производительности.
-- Используются кнопки для перемещения по карте шума.

local widget = require("widget")
local display = require("display")

-- Константы
local screenW = display.contentWidth
local screenH = display.contentHeight

-- Переменные состояния
local state = "menu"  -- "menu", "settings", "game"
local controlMode = "arrows"  -- "arrows" или "mouse"

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

    local title = display.newText("Меню", screenW / 2, screenH / 4, native.systemFont, 40)
    title:setFillColor(1, 1, 1)

    local playBtn = widget.newButton{
        label = "Ого",
        onRelease = function()
            startGame()
        end
    }
    playBtn.x = screenW / 2
    playBtn.y = screenH / 2 - 50

    local settingsBtn = widget.newButton{
        label = "Настройки",
        onRelease = function()
            createSettings()
        end
    }
    settingsBtn.x = screenW / 2
    settingsBtn.y = screenH / 2 + 50
end

-- Функция создания настроек
function createSettings()
    clearScreen()
    state = "settings"

    local title = display.newText("Настройки", screenW / 2, screenH / 4, native.systemFont, 40)
    title:setFillColor(1, 1, 1)

    local controlLabel = display.newText("Управление картой:", screenW / 2, screenH / 2 - 100, native.systemFont, 30)
    controlLabel:setFillColor(1, 1, 1)

    local arrowsBtn = widget.newButton{
        label = "Стрелки",
        onRelease = function()
            controlMode = "arrows"
            createMenu()
        end
    }
    arrowsBtn.x = screenW / 2 - 100
    arrowsBtn.y = screenH / 2

    local mouseBtn = widget.newButton{
        label = "Мышь",
        onRelease = function()
            controlMode = "mouse"
            createMenu()
        end
    }
    mouseBtn.x = screenW / 2 + 100
    mouseBtn.y = screenH / 2

    local backBtn = widget.newButton{
        label = "Назад",
        onRelease = function()
            createMenu()
        end
    }
    backBtn.x = screenW / 2
    backBtn.y = screenH - 100
end

-- Функция запуска игры
function startGame()
    clearScreen()
    state = "game"

    -- Константы игры
    local CHUNK_SIZE = 16  -- Размер чанка в точках шума
    local PIXEL_SIZE = 4   -- Размер одного пикселя (квадрата) на экране
    local CHUNK_PIXEL_SIZE = CHUNK_SIZE * PIXEL_SIZE  -- Размер чанка в пикселях
    local zoom = 1  -- Текущий зум
    local panX = 0  -- Смещение по X
    local panY = 0  -- Смещение по Y

    -- Группа для хранения чанков
    local chunkGroup = display.newGroup()
    chunkGroup.x = panX
    chunkGroup.y = panY
    chunkGroup.xScale = zoom
    chunkGroup.yScale = zoom

    -- Таблица для хранения сгенерированных чанков, ключ "x_y"
    local chunks = {}

    -- Реализация шума Перлина
    local p = {}
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
        local chunkKey = cx .. "_" .. cy
        if chunks[chunkKey] then return end  -- Если чанк уже сгенерирован, пропускаем

        local group = display.newGroup()
        chunkGroup:insert(group)
        group.x = cx * CHUNK_PIXEL_SIZE
        group.y = cy * CHUNK_PIXEL_SIZE

        for i = 0, CHUNK_SIZE - 1 do
            for j = 0, CHUNK_SIZE - 1 do
                local nx = cx * CHUNK_SIZE + i
                local ny = cy * CHUNK_SIZE + j
                local noiseVal = noise(nx * 0.05, ny * 0.05)  -- Масштабируем шум для разнообразия
                -- Преобразуем шум в цвет: hue на основе значения шума
                local hue = ((noiseVal + 1) / 2) * 360  -- От -1 до 1 -> 0 до 360
                local r, g, b = hslToRgb(hue, 0.7, 0.5)  -- Насыщенность и яркость фиксированы
                local rect = display.newRect(group, i * PIXEL_SIZE, j * PIXEL_SIZE, PIXEL_SIZE, PIXEL_SIZE)
                rect:setFillColor(r / 255, g / 255, b / 255)
            end
        end

        chunks[chunkKey] = group
    end

    -- Генерация начальных чанков вокруг центра (0,0)
    for i = -2, 2 do
        for j = -2, 2 do
            generateChunk(i, j)
        end
    end

    -- Функция для проверки и генерации новых чанков при перемещении
    local function checkAndGenerateChunks()
        -- Вычисляем видимый диапазон чанков с учётом зума
        local left = math.floor((-chunkGroup.x) / (CHUNK_PIXEL_SIZE * zoom)) - 1
        local right = math.floor((-chunkGroup.x + screenW) / (CHUNK_PIXEL_SIZE * zoom)) + 1
        local top = math.floor((-chunkGroup.y) / (CHUNK_PIXEL_SIZE * zoom)) - 1
        local bottom = math.floor((-chunkGroup.y + screenH) / (CHUNK_PIXEL_SIZE * zoom)) + 1

        for i = left, right do
            for j = top, bottom do
                generateChunk(i, j)
            end
        end
    end

    -- Функция для обновления зума всех чанков
    local function updateZoom()
        chunkGroup.xScale = zoom
        chunkGroup.yScale = zoom
        checkAndGenerateChunks()
    end

    -- Кнопки для зума
    local zoomInBtn = widget.newButton{
        label = "+",
        onRelease = function()
            zoom = zoom * 1.2
            updateZoom()
        end
    }
    zoomInBtn.x = screenW / 2 + 50
    zoomInBtn.y = screenH - 50

    local zoomOutBtn = widget.newButton{
        label = "-",
        onRelease = function()
            zoom = zoom / 1.2
            updateZoom()
        end
    }
    zoomOutBtn.x = screenW / 2 - 50
    zoomOutBtn.y = screenH - 50

    -- Кнопки для перемещения (только если controlMode == "arrows")
    local upBtn, downBtn, leftBtn, rightBtn
    if controlMode == "arrows" then
        upBtn = widget.newButton{
            label = "Вверх",
            onRelease = function()
                chunkGroup.y = chunkGroup.y + CHUNK_PIXEL_SIZE
                checkAndGenerateChunks()
            end
        }
        upBtn.x = screenW / 2
        upBtn.y = screenH - 100

        downBtn = widget.newButton{
            label = "Вниз",
            onRelease = function()
                chunkGroup.y = chunkGroup.y - CHUNK_PIXEL_SIZE
                checkAndGenerateChunks()
            end
        }
        downBtn.x = screenW / 2
        downBtn.y = screenH - 50

        leftBtn = widget.newButton{
            label = "Влево",
            onRelease = function()
                chunkGroup.x = chunkGroup.x + CHUNK_PIXEL_SIZE
                checkAndGenerateChunks()
            end
        }
        leftBtn.x = 100
        leftBtn.y = screenH / 2

        rightBtn = widget.newButton{
            label = "Вправо",
            onRelease = function()
                chunkGroup.x = chunkGroup.x - CHUNK_PIXEL_SIZE
                checkAndGenerateChunks()
            end
        }
        rightBtn.x = screenW - 100
        rightBtn.y = screenH / 2
    end

    -- Переменные для перетаскивания (только если controlMode == "mouse")
    local isDragging = false
    local startX, startY

    -- Функция для обработки касаний (перетаскивание)
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
            startX = event.x
            startY = event.y
            checkAndGenerateChunks()
        elseif event.phase == "ended" or event.phase == "cancelled" then
            isDragging = false
            display.getCurrentStage():setFocus(nil)
        end
        return true
    end

    -- Добавляем слушатель касаний к группе чанков (только если controlMode == "mouse")
    if controlMode == "mouse" then
        chunkGroup:addEventListener("touch", touchHandler)
    end

    -- Кнопка выхода в меню
    local menuBtn = widget.newButton{
        label = "Меню",
        onRelease = function()
            createMenu()
        end
    }
    menuBtn.x = screenW - 100
    menuBtn.y = 50
end

-- Запуск меню при старте
createMenu()
