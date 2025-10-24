-- Модуль для управления картой и чанками
local map = {}
local json = require("json")
local config = require("assets.config")

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

-- Таблица для хранения сгенерированных чанков, ключ "x_y"
map.chunks = {}

-- Таблица для хранения цветов пикселей чанков для миникарты
map.chunkColors = {}

-- Группа для мини-карты
map.minimapGroup = nil

-- Функция для генерации чанка по координатам cx, cy
function map.generateChunk(cx, cy, chunkGroup, CHUNK_SIZE, PIXEL_SIZE, CHUNK_PIXEL_SIZE, noise, hslToRgb)
    local chunkKey = cx .. "_" .. cy
    if map.chunks[chunkKey] then return end  -- Если чанк уже сгенерирован, пропускаем

    local group = display.newGroup()
    chunkGroup:insert(group)
    group.x = cx * CHUNK_PIXEL_SIZE
    group.y = cy * CHUNK_PIXEL_SIZE

    local colors = {}  -- Таблица для хранения цветов пикселей чанка

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

            -- Сохраняем цвет для миникарты
            table.insert(colors, {r = r, g = g, b = b})
        end
    end

    map.chunks[chunkKey] = group
    map.chunkColors[chunkKey] = colors  -- Сохраняем цвета чанка
    map.updateMinimap(cx, cy)  -- Обновляем мини-карту
end

-- Функция для проверки и генерации новых чанков при перемещении
function map.checkAndGenerateChunks(chunkGroup, screenW, screenH, CHUNK_PIXEL_SIZE, zoom, generateChunkFunc)
    -- Вычисляем видимый диапазон чанков с учётом зума
    local left = math.floor((-chunkGroup.x) / (CHUNK_PIXEL_SIZE * zoom)) - 1
    local right = math.floor((-chunkGroup.x + screenW) / (CHUNK_PIXEL_SIZE * zoom)) + 1
    local top = math.floor((-chunkGroup.y) / (CHUNK_PIXEL_SIZE * zoom)) - 1
    local bottom = math.floor((-chunkGroup.y + screenH) / (CHUNK_PIXEL_SIZE * zoom)) + 1

    for i = left, right do
        for j = top, bottom do
            generateChunkFunc(i, j)
        end
    end
end

-- Функция для сохранения карты (список загруженных чанков)
function map.saveMap(filename)
    local file = io.open(filename, "w")
    if file then
        for key, _ in pairs(map.chunks) do
            file:write(key .. "\n")
        end
        file:close()
    end
end

-- Функция для загрузки карты (список загруженных чанков)
function map.loadMap(filename)
    local loadedChunks = {}
    local file = io.open(filename, "r")
    if file then
        for line in file:lines() do
            loadedChunks[line] = true
        end
        file:close()
    end
    return loadedChunks
end

-- Функция для сохранения цветов чанков в JSON (выборочно)
function map.saveChunkColors(filename)
    if not config.logging.enabled or not config.logging.showSaveLoad then return end

    local filePath = system.pathForFile(filename, system.DocumentsDirectory)
    local file = io.open(filePath, "r")
    local existingData = {}
    if file then
        local content = file:read("*a")
        file:close()
        existingData = json.decode(content) or {}
    end

    -- Обновляем только измененные чанки
    local updated = false
    for key, colors in pairs(map.chunkColors) do
        if not existingData[key] or json.encode(existingData[key]) ~= json.encode(colors) then
            existingData[key] = colors
            updated = true
        end
    end

    if updated then
        file = io.open(filePath, "w")
        if file then
            local data = json.encode(existingData)
            file:write(data)
            file:close()
            print("Saved updated chunk colors to " .. filename)
        else
            print("Failed to save chunk colors to " .. filename)
        end
    else
        print("No changes to save for chunk colors")
    end
end

-- Функция для загрузки цветов чанков из JSON
function map.loadChunkColors(filename)
    local filePath = system.pathForFile(filename, system.DocumentsDirectory)
    local file = io.open(filePath, "r")
    if file then
        local data = file:read("*a")
        file:close()
        local truncatedData = data:sub(1, 64) .. (#data > 64 and "..." or "")
        print("Raw JSON data from " .. filename .. ": " .. truncatedData)
        local decoded = json.decode(data)
        if decoded then
            map.chunkColors = decoded
            print("Loaded chunk colors from " .. filename)
        else
            print("Failed to decode JSON from " .. filename .. " (possibly empty or invalid)")
        end
    else
        print("Failed to open " .. filename .. " for reading")
    end
end

-- Функция для загрузки сохраненных чанков и обновления миникарты
function map.loadSavedChunks()
    map.loadChunkColors("chunkColors.json")
    local chunkCount = 0
    for _ in pairs(map.chunkColors) do chunkCount = chunkCount + 1 end
    if config.logging.enabled and config.logging.showChunkCount then
        print("Loaded chunk colors: " .. chunkCount .. " chunks")
    end
    -- Обновляем миникарту для всех сохраненных чанков
    for key, colors in pairs(map.chunkColors) do
        local cx, cy = key:match("(-?%d+)_(-?%d+)")
        cx = tonumber(cx)
        cy = tonumber(cy)
        if config.logging.enabled and config.logging.showMinimapDrawing then
            print("Updating minimap for chunk: " .. key)
        end
        map.updateMinimap(cx, cy)
    end
end

-- Функция для создания мини-карты
function map.createMinimap(screenW, screenH)
    if not config.minimap.enabled then return end

    map.minimapGroup = display.newGroup()
    map.minimapGroup.x = config.minimap.x
    map.minimapGroup.y = config.minimap.y

    -- Фон мини-карты
    local bg = display.newRect(map.minimapGroup, 0, 0, config.minimap.width, config.minimap.height)
    bg:setFillColor(config.minimap.backgroundColor[1], config.minimap.backgroundColor[2], config.minimap.backgroundColor[3], config.minimap.backgroundColor[4])
    bg.strokeWidth = config.minimap.borderWidth
    bg:setStrokeColor(config.minimap.borderColor[1], config.minimap.borderColor[2], config.minimap.borderColor[3])

    -- Делаем мини-карту кликабельной
    bg:addEventListener("tap", function()
        map.showLoadedChunks()
    end)

    -- Текст для мини-карты ниже поля
    local text = display.newText(display.getCurrentStage(), "Наведи мышку", config.minimap.x + config.minimap.width / 2, config.minimap.y + config.minimap.height + 20, native.systemFont, config.minimap.textSize)
    text:setFillColor(config.minimap.textColor[1], config.minimap.textColor[2], config.minimap.textColor[3])

    -- Обработчик мышки для обновления текста
    local function updateText(event)
        if event.phase == "moved" or event.phase == "began" then
            local localX = event.x - map.minimapGroup.x
            local localY = event.y - map.minimapGroup.y
            -- Проверяем, находится ли курсор внутри миникарты
            if localX >= 0 and localX <= config.minimap.width and localY >= 0 and localY <= config.minimap.height then
                local cx = math.floor((localX - config.minimap.offsetX) / (16 * config.minimap.scale))
                local cy = math.floor((localY - config.minimap.offsetY) / (16 * config.minimap.scale))
                text.text = "Чанк: " .. cx .. "," .. cy .. " Коорд: " .. math.floor(localX) .. "," .. math.floor(localY)
            else
                text.text = "Наведи мышку"
            end
        end
        return true
    end

    bg:addEventListener("touch", updateText)

    -- Загрузка сохраненных чанков из JSON
    map.loadSavedChunks()
end

-- Функция для обновления вида миникарты (очистка и перерисовка чанков вокруг позиции)
function map.updateMinimapView(panX, panY, zoom)
    if not map.minimapGroup then return end

    -- Очистить миникарту, оставив фон и текст
    for i = map.minimapGroup.numChildren, 1, -1 do
        local child = map.minimapGroup[i]
        if child ~= map.minimapGroup[1] then  -- Предполагаем, что фон - первый ребенок
            child:removeSelf()
        end
    end

    -- Вычислить центр на основе panX, panY
    local CHUNK_PIXEL_SIZE = 64  -- 16*4
    local cx_center = math.floor(-panX / CHUNK_PIXEL_SIZE)
    local cy_center = math.floor(-panY / CHUNK_PIXEL_SIZE)

    -- Радиус 5 чанков
    local radius = 5
    for i = cx_center - radius, cx_center + radius do
        for j = cy_center - radius, cy_center + radius do
            map.updateMinimap(i, j)
        end
    end

    -- Добавить маркер позиции (красный квадрат в центре)
    local marker = display.newRect(map.minimapGroup, config.minimap.width / 2, config.minimap.height / 2, 4, 4)
    marker:setFillColor(1, 0, 0)  -- Красный
end

-- Функция для обновления мини-карты (рисование мини-версии чанка)
function map.updateMinimap(cx, cy)
    if not map.minimapGroup then
        print("Minimap group not found, skipping update for chunk " .. cx .. "_" .. cy)
        return
    end

    local colors = map.chunkColors[cx .. "_" .. cy]
    if not colors then
        print("No colors found for chunk " .. cx .. "_" .. cy)
        return
    end

    if config.logging.enabled and config.logging.showMinimapDrawing then
        print("Drawing minimap for chunk " .. cx .. "_" .. cy .. " with " .. #colors .. " pixels")
    end

    local scale = config.minimap.scale  -- Масштаб для миникарты
    local chunkSize = 16  -- Размер чанка в пикселях

    local drawnPixels = 0
    for idx, color in ipairs(colors) do
        local i = (idx - 1) % chunkSize
        local j = math.floor((idx - 1) / chunkSize)
        local x = (cx * chunkSize + i) * scale + config.minimap.offsetX
        local y = (cy * chunkSize + j) * scale + config.minimap.offsetY

        if x >= 0 and x <= config.minimap.width and y >= 0 and y <= config.minimap.height then
            local rect = display.newRect(map.minimapGroup, x, y, scale, scale)
            -- Желтый цвет с примесями для миникарты
            local hue = 60  -- Желтый
            local saturation = 0.8
            local lightness = 0.5 + (color.r / 255 - 0.5) * 0.4  -- Вариация яркости на основе сохраненного цвета
            local r, g, b = hslToRgb(hue, saturation, lightness)
            rect:setFillColor(r / 255, g / 255, b / 255)
            drawnPixels = drawnPixels + 1
        end
    end
    if config.logging.enabled and config.logging.showMinimapDrawing then
        print("Drawn " .. drawnPixels .. " pixels for chunk " .. cx .. "_" .. cy)
    end
end

-- Функция для показа списка загруженных чанков
function map.showLoadedChunks()
    local chunksList = ""
    for key, _ in pairs(map.chunks) do
        chunksList = chunksList .. key .. "\n"
    end
    print("Загруженные чанки:\n" .. chunksList)
    -- Можно добавить отображение на экране, но для простоты - в консоль
end

return map
