const { app, BrowserWindow, ipcMain, Menu, Tray, nativeImage, screen, globalShortcut, Notification } = require('electron');
const { menubar } = require('menubar');
const path = require('path');
const { exec } = require('child_process');
const os = require('os');

// Хранилище для последних портов (для уведомлений)
let lastPorts = [];
let autoRefreshInterval = null;

// Функция для получения занятых портов
function getActivePorts() {
  return new Promise((resolve, reject) => {
    // Команда для macOS чтобы получить список процессов с портами
    const command = "lsof -iTCP -sTCP:LISTEN -P -n | grep -E ':[0-9]+' | awk '{print $2, $9}' | sort -u";
    
    exec(command, (error, stdout, stderr) => {
      if (error) {
        console.error('Error getting ports:', error);
        resolve([]);
        return;
      }
      
      const lines = stdout.trim().split('\n').filter(line => line);
      const ports = [];
      const processPromises = [];
      
      lines.forEach(line => {
        const parts = line.split(' ');
        if (parts.length >= 2) {
          const pid = parts[0];
          const address = parts[1];
          
          // Извлекаем порт из адреса (формат: *:3000 или 127.0.0.1:3000)
          const portMatch = address.match(/:(\d+)$/);
          if (portMatch) {
            const port = portMatch[1];
            
            // Создаем промис для получения имени процесса
            const processPromise = new Promise((resolveProcess) => {
              exec(`ps -p ${pid} -o comm=`, (err, processName) => {
                const name = processName ? processName.trim().split('/').pop() : 'Unknown';
                resolveProcess({
                  pid: pid,
                  port: port,
                  process: name,
                  address: address.includes('*') ? `localhost:${port}` : address
                });
              });
            });
            
            processPromises.push(processPromise);
          }
        }
      });
      
      // Ждем все промисы
      Promise.all(processPromises).then(ports => {
        // Сортируем по порту
        ports.sort((a, b) => parseInt(a.port) - parseInt(b.port));
        
        // Проверяем новые порты для уведомлений
        checkNewPorts(ports);
        
        resolve(ports);
      });
    });
  });
}

// Функция для проверки новых портов
function checkNewPorts(currentPorts) {
  if (lastPorts.length > 0) {
    const lastPortNumbers = lastPorts.map(p => p.port);
    const newPorts = currentPorts.filter(p => !lastPortNumbers.includes(p.port));
    
    // Показываем уведомление о новых портах
    newPorts.forEach(port => {
      if (Notification.isSupported()) {
        const notification = new Notification({
          title: 'Новый порт активен',
          body: `${port.process} запущен на ${port.address}`,
          icon: path.join(__dirname, 'assets', 'icon.png'),
          silent: true
        });
        notification.show();
      }
    });
  }
  lastPorts = currentPorts;
}

// Функция для убийства процесса
function killProcess(pid) {
  return new Promise((resolve, reject) => {
    exec(`kill -9 ${pid}`, (error, stdout, stderr) => {
      if (error) {
        console.error('Error killing process:', error);
        reject(error);
        return;
      }
      resolve(true);
    });
  });
}

// Функция для копирования в буфер обмена
function copyToClipboard(text) {
  const { clipboard } = require('electron');
  clipboard.writeText(text);
}

// Создаем menubar приложение с улучшенными настройками
const mb = menubar({
  dir: __dirname,
  index: `file://${path.join(__dirname, 'index.html')}`,
  icon: path.join(__dirname, 'assets', 'IconTemplate.png'),
  tooltip: 'Lutfulin Port Manager',
  browserWindow: {
    width: 400,
    height: 500,
    resizable: false,
    movable: false,
    minimizable: false,
    maximizable: false,
    closable: true,
    alwaysOnTop: true,
    fullscreenable: false,
    skipTaskbar: true,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
      backgroundThrottling: false
    },
    // Визуальные улучшения
    transparent: false,
    hasShadow: true,
    vibrancy: 'popover', // Эффект размытия для macOS
    visualEffectState: 'active'
  },
  preloadWindow: true,
  showOnAllWorkspaces: true, // Изменено для показа на всех пространствах
  showDockIcon: false
});

mb.on('ready', () => {
  console.log('Lutfulin Port Manager is ready');
  
  // Устанавливаем позицию окна относительно иконки в трее
  mb.on('after-create-window', () => {
    // Делаем окно всегда поверх других при открытии
    mb.window.setAlwaysOnTop(true, 'floating');
    mb.window.setVisibleOnAllWorkspaces(true);
    
    // Отключаем переход между пространствами
    mb.window.setCollectionBehavior(
      mb.window.getCollectionBehavior() | 1 << 6 // NSWindowCollectionBehaviorStationary
    );
  });
  
  // Обновляем список портов при открытии
  mb.on('show', () => {
    if (mb.window) {
      // Получаем текущую позицию мыши
      const point = screen.getCursorScreenPoint();
      const currentDisplay = screen.getDisplayNearestPoint(point);
      
      // Позиционируем окно правильно
      const windowBounds = mb.window.getBounds();
      const trayBounds = mb.tray.getBounds();
      
      // Вычисляем позицию окна
      let x = Math.round(trayBounds.x + (trayBounds.width / 2) - (windowBounds.width / 2));
      let y = Math.round(trayBounds.y + trayBounds.height);
      
      // Проверяем, чтобы окно не выходило за границы экрана
      if (x + windowBounds.width > currentDisplay.bounds.x + currentDisplay.bounds.width) {
        x = currentDisplay.bounds.x + currentDisplay.bounds.width - windowBounds.width;
      }
      
      mb.window.setPosition(x, y, false);
      mb.window.webContents.send('refresh-ports');
      
      // Фокусируемся на окне
      mb.window.focus();
    }
  });
  
  // Запускаем авто-обновление портов каждые 5 секунд
  autoRefreshInterval = setInterval(async () => {
    if (!mb.window || !mb.window.isVisible()) {
      await getActivePorts(); // Обновляем в фоне для уведомлений
    }
  }, 5000);
  
  // Регистрируем глобальную горячую клавишу
  globalShortcut.register('CommandOrControl+Shift+P', () => {
    if (mb.window.isVisible()) {
      mb.hideWindow();
    } else {
      mb.showWindow();
    }
  });
});

// IPC handlers
ipcMain.handle('get-ports', async () => {
  try {
    const ports = await getActivePorts();
    return ports;
  } catch (error) {
    console.error('Error in get-ports:', error);
    return [];
  }
});

ipcMain.handle('kill-process', async (event, pid) => {
  try {
    await killProcess(pid);
    
    // Показываем уведомление об успешном завершении
    if (Notification.isSupported()) {
      const notification = new Notification({
        title: 'Процесс завершен',
        body: `Процесс с PID ${pid} успешно завершен`,
        icon: path.join(__dirname, 'assets', 'icon.png'),
        silent: true
      });
      notification.show();
    }
    
    return { success: true };
  } catch (error) {
    return { success: false, error: error.message };
  }
});

ipcMain.handle('copy-to-clipboard', async (event, text) => {
  copyToClipboard(text);
  return { success: true };
});

ipcMain.handle('open-in-browser', async (event, port) => {
  const { shell } = require('electron');
  shell.openExternal(`http://localhost:${port}`);
  return { success: true };
});

ipcMain.on('quit-app', () => {
  if (autoRefreshInterval) {
    clearInterval(autoRefreshInterval);
  }
  globalShortcut.unregisterAll();
  app.quit();
});

// Предотвращаем закрытие приложения при закрытии всех окон
app.on('window-all-closed', () => {
  // На macOS приложения обычно остаются активными даже после закрытия всех окон
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

ipcMain.on('hide-window', () => {
  if (mb.window && mb.window.isVisible()) {
    mb.hideWindow();
  }
});


// Очищаем горячие клавиши при выходе
app.on('will-quit', () => {
  globalShortcut.unregisterAll();
  if (autoRefreshInterval) {
    clearInterval(autoRefreshInterval);
  }
});