-- Конфигурационный файл для игры
-- Содержит настройки для логов, миникарты и UI элементов

local config = {}

-- Настройки логов
config.logging = {
    enabled = true,  -- Включить логирование
    level = "info",  -- Уровень логирования: "debug", "info", "warning", "error"
    showChunkCount = true,  -- Показывать количество загруженных чанков
    showMinimapDrawing = true,  -- Показывать логи рисования миникарты
    showSaveLoad = true  -- Показывать логи сохранения/загрузки
}

-- Настройки миникарты
config.minimap = {
    enabled = 1,  -- Включить миникарту
    width = 200,  -- Ширина миникарты
    height = 200,  -- Высота миникарты
    x = 0,  -- Позиция X
    y = 0,  -- Позиция Y
    scale = 0.5,  -- Масштаб пикселей карты на миникарте
    offsetX = 0,  -- Смещение по X для центрирования
    offsetY = 0,  -- Смещение по Y для центрирования
    backgroundColor = {0, 0, 0, 0.5},  -- Цвет фона (RGBA)
    borderColor = {1, 1, 1},  -- Цвет рамки (RGB)
    borderWidth = 2,  -- Толщина рамки
    textColor = {1, 1, 1},  -- Цвет текста
    textSize = 16,  -- Размер текста
    text = "Мини-карта"  -- Текст на миникарте
}

-- Настройки UI элементов
config.ui = {
    -- Фон экрана
    background = {
        color = {0, 0, 0}  -- Черный фон
    },
    -- Меню
    menu = {
        title = {
            text = "Меню",
            x = "screenW / 2",
            y = "screenH / 8",
            font = "native.systemFont",
            size = 40,
            color = {1, 1, 1}
        },
        playBtn = {
            label = "Ого",
            x = "screenW / 2",
            y = "screenH / 2 - 100",
            width = 200,
            height = 50,
            shape = "roundedRect",
            fillColor = {default = {0, 0.5, 0}, over = {0, 0.7, 0}},
            strokeWidth = 2,
            strokeColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            labelColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            fontSize = 20
        },
        pluginsBtn = {
            label = "Плагины",
            x = "screenW / 2",
            y = "screenH / 2",
            width = 200,
            height = 50,
            shape = "roundedRect",
            fillColor = {default = {0, 0, 0.5}, over = {0, 0, 0.7}},
            strokeWidth = 2,
            strokeColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            labelColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            fontSize = 20
        },
        settingsBtn = {
            label = "Настройки",
            x = "screenW / 2",
            y = "screenH / 2 + 100",
            width = 200,
            height = 50,
            shape = "roundedRect",
            fillColor = {default = {0.5, 0.5, 0}, over = {0.7, 0.7, 0}},
            strokeWidth = 2,
            strokeColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            labelColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            fontSize = 20
        }
    },
    -- Плагины
    plugins = {
        title = {
            text = "Плагины",
            x = "screenW / 2",
            y = "screenH / 4",
            font = "native.systemFont",
            size = 40,
            color = {1, 1, 1}
        },
        minimapBtn = {
            label = "Миникарта",
            x = "screenW / 2",
            y = "screenH / 2",
            width = 200,
            height = 50,
            shape = "roundedRect",
            fillColor = {default = {0, 0.5, 0}, over = {0, 0.7, 0}},
            strokeWidth = 2,
            strokeColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            labelColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            fontSize = 20
        },
        backBtn = {
            label = "Назад",
            x = "screenW / 2",
            y = "screenH - 100",
            width = 200,
            height = 50,
            shape = "roundedRect",
            fillColor = {default = {0.5, 0, 0}, over = {0.7, 0, 0}},
            strokeWidth = 2,
            strokeColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            labelColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            fontSize = 20
        }
    },
    -- Настройки
    settings = {
        title = {
            text = "Настройки",
            x = "screenW / 2",
            y = "screenH / 4",
            font = "native.systemFont",
            size = 40,
            color = {1, 1, 1}
        },
        controlLabel = {
            text = "Управление картой:",
            x = "screenW / 2",
            y = "screenH / 2 - 75",
            font = "native.systemFont",
            size = 30,
            color = {1, 1, 1}
        },
        arrowsBtn = {
            label = "Стрелки",
            x = "screenW / 2 - 100",
            y = "screenH / 2",
            width = 150,
            height = 50,
            shape = "roundedRect",
            fillColor = {default = {0.5, 0.5, 0.5}, over = {0.7, 0.7, 0.7}},
            strokeWidth = 2,
            strokeColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            labelColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            fontSize = 20
        },
        mouseBtn = {
            label = "Мышь",
            x = "screenW / 2 + 100",
            y = "screenH / 2",
            width = 150,
            height = 50,
            shape = "roundedRect",
            fillColor = {default = {0.5, 0.5, 0.5}, over = {0.7, 0.7, 0.7}},
            strokeWidth = 2,
            strokeColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            labelColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            fontSize = 20
        },
        backBtn = {
            label = "Назад",
            x = "screenW / 2",
            y = "screenH - 100",
            width = 150,
            height = 50,
            shape = "roundedRect",
            fillColor = {default = {0.5, 0, 0}, over = {0.7, 0, 0}},
            strokeWidth = 2,
            strokeColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            labelColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            fontSize = 20
        }
    },
    -- Игра
    game = {
        zoomInBtn = {
            label = "+",
            x = "screenW - 50",
            y = "screenH - 50",
            width = 50,
            height = 50,
            shape = "roundedRect",
            fillColor = {default = {0.5, 0.5, 0.5}, over = {0.7, 0.7, 0.7}},
            strokeWidth = 2,
            strokeColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            labelColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            fontSize = 20
        },
        zoomOutBtn = {
            label = "-",
            x = 50,
            y = "screenH - 50",
            width = 50,
            height = 50,
            shape = "roundedRect",
            fillColor = {default = {0.5, 0.5, 0.5}, over = {0.7, 0.7, 0.7}},
            strokeWidth = 2,
            strokeColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            labelColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            fontSize = 20
        },
        upBtn = {
            label = "Вверх",
            x = "screenW / 2",
            y = "screenH - 100",
            width = 100,
            height = 50,
            shape = "roundedRect",
            fillColor = {default = {0.5, 0.5, 0.5}, over = {0.7, 0.7, 0.7}},
            strokeWidth = 2,
            strokeColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            labelColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            fontSize = 20
        },
        downBtn = {
            label = "Вниз",
            x = "screenW / 2",
            y = "screenH - 50",
            width = 100,
            height = 50,
            shape = "roundedRect",
            fillColor = {default = {0.5, 0.5, 0.5}, over = {0.7, 0.7, 0.7}},
            strokeWidth = 2,
            strokeColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            labelColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            fontSize = 20
        },
        leftBtn = {
            label = "Влево",
            x = 100,
            y = "screenH / 2",
            width = 100,
            height = 50,
            shape = "roundedRect",
            fillColor = {default = {0.5, 0.5, 0.5}, over = {0.7, 0.7, 0.7}},
            strokeWidth = 2,
            strokeColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            labelColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            fontSize = 20
        },
        rightBtn = {
            label = "Вправо",
            x = "screenW - 100",
            y = "screenH / 2",
            width = 100,
            height = 50,
            shape = "roundedRect",
            fillColor = {default = {0.5, 0.5, 0.5}, over = {0.7, 0.7, 0.7}},
            strokeWidth = 2,
            strokeColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            labelColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            fontSize = 20
        },
        menuBtn = {
            label = "Меню",
            x = "screenW - 100",
            y = 50,
            width = 100,
            height = 50,
            shape = "roundedRect",
            fillColor = {default = {0.5, 0, 0}, over = {0.7, 0, 0}},
            strokeWidth = 2,
            strokeColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            labelColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            fontSize = 20
        }
    }
}

return config
