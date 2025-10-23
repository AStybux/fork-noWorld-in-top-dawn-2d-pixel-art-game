-- Этот код генерирует цветной шум Перлина в Solar2D (Corona SDK).
-- Шум генерируется по чанкам для оптимизации производительности.
-- Используются кнопки для перемещения по карте шума.

local widget = require("widget")
local display = require("display")

-- Константы
local CHUNK_SIZE = 16  -- Размер чанка в точках шума
local PIXEL_SIZE = 4   -- Размер одного пикселя (квадрата) на экране
local CHUNK_PIXEL_SIZE = CHUNK_SIZE * PIXEL_SIZE  -- Размер чанка в пикселях
local screenW = display.contentWidth
local screenH = display.contentHeight

-- Группа для хранения чанков
local chunkGroup = display.newGroup()

-- Таблица для хранения сгенерированных чанков, ключ "x_y"
local chunks = {}

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
            local noise = math.noise(nx * 0.05, ny * 0.05)  -- Масштабируем шум для разнообразия
            -- Преобразуем шум в цвет: hue на основе значения шума
            local hue = ((noise + 1) / 2) * 360  -- От -1 до 1 -> 0 до 360
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
    -- Вычисляем видимый диапазон чанков
    local left = math.floor((-chunkGroup.x) / CHUNK_PIXEL_SIZE) - 1
    local right = math.floor((-chunkGroup.x + screenW) / CHUNK_PIXEL_SIZE) + 1
    local top = math.floor((-chunkGroup.y) / CHUNK_PIXEL_SIZE) - 1
    local bottom = math.floor((-chunkGroup.y + screenH) / CHUNK_PIXEL_SIZE) + 1

    for i = left, right do
        for j = top, bottom do
            generateChunk(i, j)
        end
    end
end

-- Кнопки для перемещения
local upBtn = widget.newButton{
    label = "Вверх",
    onRelease = function()
        chunkGroup.y = chunkGroup.y + CHUNK_PIXEL_SIZE
        checkAndGenerateChunks()
    end
}
upBtn.x = screenW / 2
upBtn.y = screenH - 100

local downBtn = widget.newButton{
    label = "Вниз",
    onRelease = function()
        chunkGroup.y = chunkGroup.y - CHUNK_PIXEL_SIZE
        checkAndGenerateChunks()
    end
}
downBtn.x = screenW / 2
downBtn.y = screenH - 50

local leftBtn = widget.newButton{
    label = "Влево",
    onRelease = function()
        chunkGroup.x = chunkGroup.x + CHUNK_PIXEL_SIZE
        checkAndGenerateChunks()
    end
}
leftBtn.x = 100
leftBtn.y = screenH / 2

local rightBtn = widget.newButton{
    label = "Вправо",
    onRelease = function()
        chunkGroup.x = chunkGroup.x - CHUNK_PIXEL_SIZE
        checkAndGenerateChunks()
    end
}
rightBtn.x = screenW - 100
rightBtn.y = screenH / 2
