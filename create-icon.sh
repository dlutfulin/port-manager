#!/bin/bash

# Скрипт для создания иконок для macOS приложения
# Требуется изображение 1024x1024 PNG

echo "🎨 Создание иконок для Port Manager"
echo "===================================="

# Проверяем наличие исходного файла
if [ ! -f "icon-1024.png" ]; then
    echo "⚠️  Сначала создайте файл icon-1024.png размером 1024x1024"
    echo "   Можете использовать любой графический редактор или онлайн сервис"
    echo ""
    echo "🌐 Рекомендуемые сервисы для создания иконки:"
    echo "   - https://www.canva.com"
    echo "   - https://www.figma.com" 
    echo "   - https://icon.kitchen"
    echo ""
    echo "💡 Или используйте готовую иконку из интернета"
    echo "   Просто сохраните её как icon-1024.png"
    exit 1
fi

# Создаем папку для иконок
mkdir -p assets
mkdir -p icon.iconset

# Генерируем все необходимые размеры
echo "📐 Генерация размеров иконок..."

# Размеры для iconset
sips -z 16 16     icon-1024.png --out icon.iconset/icon_16x16.png
sips -z 32 32     icon-1024.png --out icon.iconset/icon_16x16@2x.png
sips -z 32 32     icon-1024.png --out icon.iconset/icon_32x32.png
sips -z 64 64     icon-1024.png --out icon.iconset/icon_32x32@2x.png
sips -z 128 128   icon-1024.png --out icon.iconset/icon_128x128.png
sips -z 256 256   icon-1024.png --out icon.iconset/icon_128x128@2x.png
sips -z 256 256   icon-1024.png --out icon.iconset/icon_256x256.png
sips -z 512 512   icon-1024.png --out icon.iconset/icon_256x256@2x.png
sips -z 512 512   icon-1024.png --out icon.iconset/icon_512x512.png
cp icon-1024.png icon.iconset/icon_512x512@2x.png

# Создаем ICNS файл
echo "🔨 Создание ICNS файла..."
iconutil -c icns icon.iconset -o assets/icon.icns

# Создаем иконки для menubar (должны быть черно-белые для Template)
echo "🎯 Создание иконок для menubar..."

# Создаем черно-белую версию для menubar
sips -z 22 22 icon-1024.png --out temp_icon.png

# Конвертируем в черно-белую (для menubar в macOS)
# Template иконки должны быть черными на прозрачном фоне
sips -s format png temp_icon.png --out assets/IconTemplate.png
sips -z 44 44 icon-1024.png --out assets/IconTemplate@2x.png

# Убираем временные файлы
rm -rf icon.iconset
rm -f temp_icon.png

echo "✅ Иконки успешно созданы!"
echo ""
echo "📁 Созданные файлы:"
echo "   - assets/icon.icns (иконка приложения)"
echo "   - assets/IconTemplate.png (иконка для menubar)"
echo "   - assets/IconTemplate@2x.png (иконка для Retina дисплеев)"
echo ""
echo "🚀 Теперь можно собирать приложение: npm run dist"