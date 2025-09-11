#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Установка Port Manager для macOS${NC}"
echo "======================================="

# Проверяем, что мы на macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ Это приложение предназначено только для macOS${NC}"
    exit 1
fi

# Проверяем наличие Node.js
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}⚠️  Node.js не установлен. Установка через Homebrew...${NC}"
    
    # Проверяем Homebrew
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}Установка Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    brew install node
fi

echo -e "${GREEN}✓ Node.js установлен: $(node -v)${NC}"

# Создаем структуру проекта
echo -e "${YELLOW}📁 Создание структуры проекта...${NC}"

PROJECT_DIR="port-manager-menubar"
mkdir -p $PROJECT_DIR/assets

cd $PROJECT_DIR

# Создаем иконку для трея (простая SVG иконка)
echo -e "${YELLOW}🎨 Создание иконки...${NC}"

cat > assets/icon.svg << 'EOF'
<svg width="22" height="22" viewBox="0 0 22 22" xmlns="http://www.w3.org/2000/svg">
  <rect x="2" y="2" width="18" height="18" rx="4" fill="#667eea"/>
  <circle cx="7" cy="7" r="2" fill="#fff"/>
  <circle cx="15" cy="7" r="2" fill="#fff"/>
  <circle cx="7" cy="15" r="2" fill="#fff"/>
  <circle cx="15" cy="15" r="2" fill="#fff"/>
</svg>
EOF

# Конвертируем SVG в PNG (требуется для Electron)
# Используем простой подход - создаем базовый PNG файл
cat > create_icon.js << 'EOF'
const fs = require('fs');
const { createCanvas } = require('canvas');

// Простая иконка 22x22 для menubar (Template icon для macOS)
const canvas = createCanvas(22, 22);
const ctx = canvas.getContext('2d');

// Рисуем простую иконку портов
ctx.fillStyle = '#000000';
ctx.fillRect(4, 4, 4, 4);
ctx.fillRect(14, 4, 4, 4);
ctx.fillRect(4, 14, 4, 4);
ctx.fillRect(14, 14, 4, 4);

// Сохраняем как IconTemplate.png (macOS автоматически адаптирует цвета)
const buffer = canvas.toBuffer('image/png');
fs.writeFileSync('assets/IconTemplate.png', buffer);
fs.writeFileSync('assets/IconTemplate@2x.png', buffer);

console.log('✓ Иконки созданы');
EOF

# Альтернативный способ - создаем простую PNG иконку через base64
echo -e "${YELLOW}🎨 Создание PNG иконки...${NC}"

# Base64 encoded 22x22 PNG icon
echo "iVBORw0KGgoAAAANSUhEUgAAABYAAAAWCAYAAADEtGw7AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAA7AAAAOwBeShxvQAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAADMSURBVDiN7ZQxDoMwDEV/UjtUXIALcAEuwAW4QG/ABbgAF2Bm6NCFgVWqmk5Igw0SQ5F4khe/+PlZlmMDfxIDkAMFUAElkFnxJTAHNoACngkcSQpgCyyAKZAE8PeBLbACZpLavuAxsAZmkqoBfi2plDSTVAGb0N4HXAF9YGjlrsaA0coDhoCnxoCJ9R96tPZOD7T9i2MM+C3pJulgrf2TJKmWdJS0l7STVFvxo6Szfafuasd9w523cGAIeGKMecZmPhljNv/APwZ/ASq5MSL8jigFAAAAAElFTkSuQmCC" | base64 -d > assets/IconTemplate.png
echo "iVBORw0KGgoAAAANSUhEUgAAACwAAAAsCAYAAAAehFoBAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAABdgAAAXYBPSH7nAAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAGcSURBVFiF7ZnPTsMwDMa/pN1gCMGEhHiA8QA8AA/AA/AAPIDbDnDjxIkDB3aAEGJM/Jm2HLo6bdO0STvBBJ9kKXHs5mfHduwUOA4DMAYwBDAA0Hd5XQATAAsAMwCRSJgByAFMAawBZJamW4Rlv1MABwBmAPr/IC/SBTCV+VcAjgD0/kFeZAzgEkBfRAkArH5ZVsQCCBX5hwoWKT8VsQCaRPyLBRCKKAEQ1bWSJEniSJJkr+Ka/YrrOhLMTSQ4N5Hg3ESCM10L5iaC0zSNkySJsiw77SYJksfjMatisixL0zRN8jyPAbysArKCsywriqJTy3MFAFmWZVEUBbe2HI9KCjZKzqTg19Jy6Qq+Kdo38jwvrMOu4EsbrKmqqvQN+J1YLpd6S2maJj8bfN2AQE1MzPN8AeDLtFO2223Vn8/ndgMCNcnn87npwRVFUanPZjO7AYGaDIdDU7eXYLFY6DZ8C7lcrqk+mUzsBgRqks/nsyjKfOqn0yn7DRaLxeI8CIKrfr9/GwRB5HLNLOB7x0EQXB8vNEH+ALH7LzOEjgJUAAAAAElFTkSuQmCC" | base64 -d > assets/IconTemplate@2x.png

echo -e "${GREEN}✓ Иконки созданы${NC}"

# Копируем файлы из артефактов
echo -e "${YELLOW}📝 Создание файлов проекта...${NC}"

# Тут нужно будет вручную скопировать содержимое артефактов выше
echo -e "${RED}⚠️  Теперь необходимо:${NC}"
echo "1. Скопировать содержимое package.json из артефакта выше"
echo "2. Скопировать содержимое main.js из артефакта выше"
echo "3. Скопировать содержимое index.html из артефакта выше"
echo ""
echo -e "${YELLOW}После копирования файлов выполните:${NC}"
echo ""
echo "cd $PROJECT_DIR"
echo "npm install"
echo "npm start"
echo ""
echo -e "${GREEN}Для создания .app файла:${NC}"
echo "npm run dist"
echo ""
echo -e "${GREEN}✨ Готово! Port Manager будет доступен в трее macOS${NC}"