Сгенерируй все размеры иконок
bashchmod +x create-icon.sh
./create-icon.sh
3️⃣ Собери приложение
bashchmod +x build-app.sh
./build-app.sh
Или вручную:
bashnpm run dist
4️⃣ Готовые файлы будут в папке dist/

Port Manager-1.0.0-universal-mac.zip - это то, что нужно отправить другу!
Port Manager-1.0.0-universal.dmg - альтернативный формат установки

✅ Совместимость:

✅ Работает на ВСЕХ Mac: Intel и Apple Silicon (M1, M2, M3, M3 Pro, M3 Max, M4...)
✅ macOS 10.13+ (High Sierra и выше)
✅ Универсальная сборка - один файл для всех процессоров

📨 Как отправить другу:

Отправь файл dist/Port Manager-1.0.0-universal-mac.zip
Твой друг должен:

Разархивировать ZIP
Перетащить Port Manager.app в папку Applications
При первом запуске: правый клик → "Open" (обход Gatekeeper)
Или зайти в System Settings → Privacy & Security и разрешить запуск



🎨 Как поменять иконку:

Создай новую иконку 1024x1024 PNG
Сохрани как icon-1024.png
Запусти ./create-icon.sh
Пересобери приложение ./build-app.sh

🔒 Если macOS блокирует запуск:
Скажи другу сделать одно из:

Правый клик на приложении → Open → Open (подтвердить)
Или: System Settings → Privacy & Security → найти Port Manager → Open Anyway

💡 Дополнительные настройки:
Если хочешь изменить имя приложения, измени в package.json:
json"productName": "Port Killer Pro",  // например
Приложение полностью готово для распространения! 🚀