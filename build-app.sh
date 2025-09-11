#!/bin/bash

# Скрипт для полной сборки Port Manager
# Создает универсальное приложение для Intel и Apple Silicon

echo "🚀 Сборка Port Manager для macOS"
echo "================================="

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Проверяем наличие node_modules
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}📦 Установка зависимостей...${NC}"
    npm install
fi

# Очищаем старые сборки
echo -e "${YELLOW}🧹 Очистка старых сборок...${NC}"
rm -rf dist

# Собираем приложение
echo -e "${BLUE}🔨 Сборка универсального приложения (Intel + Apple Silicon)...${NC}"
npm run dist

# Проверяем успешность сборки
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Сборка завершена успешно!${NC}"
    echo ""
    echo -e "${GREEN}📦 Созданные файлы:${NC}"
    
    # Показываем созданные файлы
    if [ -f "dist/Port Manager-1.0.0-universal.dmg" ]; then
        echo -e "  📀 DMG: dist/Port Manager-1.0.0-universal.dmg"
        echo -e "     Размер: $(du -h "dist/Port Manager-1.0.0-universal.dmg" | cut -f1)"
    fi
    
    if [ -f "dist/Port Manager-1.0.0-universal-mac.zip" ]; then
        echo -e "  📦 ZIP: dist/Port Manager-1.0.0-universal-mac.zip"
        echo -e "     Размер: $(du -h "dist/Port Manager-1.0.0-universal-mac.zip" | cut -f1)"
    fi
    
    echo ""
    echo -e "${BLUE}🎯 Что дальше:${NC}"
    echo -e "  1. ZIP-архив можно сразу отправить другим пользователям"
    echo -e "  2. Они должны разархивировать и перетащить Port Manager.app в папку Applications"
    echo -e "  3. При первом запуске нужно будет разрешить запуск через System Settings > Privacy & Security"
    echo ""
    echo -e "${YELLOW}⚠️  Важно для пользователей:${NC}"
    echo -e "  - Приложение работает на всех Mac (Intel и Apple Silicon)"
    echo -e "  - Поддерживает macOS 10.13 и выше"
    echo -e "  - При первом запуске macOS может показать предупреждение"
    echo -e "  - Нужно будет открыть через правый клик -> Open"
    
else
    echo -e "${RED}❌ Ошибка при сборке!${NC}"
    exit 1
fi