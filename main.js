const { app, BrowserWindow, ipcMain, Menu, Tray, nativeImage } = require('electron');
const { menubar } = require('menubar');
const path = require('path');
const { exec } = require('child_process');
const os = require('os');

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
      
      lines.forEach(line => {
        const parts = line.split(' ');
        if (parts.length >= 2) {
          const pid = parts[0];
          const address = parts[1];
          
          // Извлекаем порт из адреса (формат: *:3000 или 127.0.0.1:3000)
          const portMatch = address.match(/:(\d+)$/);
          if (portMatch) {
            const port = portMatch[1];
            
            // Получаем имя процесса
            exec(`ps -p ${pid} -o comm=`, (err, processName) => {
              const name = processName ? processName.trim().split('/').pop() : 'Unknown';
              ports.push({
                pid: pid,
                port: port,
                process: name,
                address: address.includes('*') ? `localhost:${port}` : address
              });
            });
          }
        }
      });
      
      // Даем время на получение имен процессов
      setTimeout(() => {
        // Сортируем по порту
        ports.sort((a, b) => parseInt(a.port) - parseInt(b.port));
        resolve(ports);
      }, 100);
    });
  });
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

// Создаем menubar приложение
const mb = menubar({
  dir: __dirname,
  index: `file://${path.join(__dirname, 'index.html')}`,
  icon: path.join(__dirname, 'assets', 'IconTemplate.png'),
  tooltip: 'Port Manager',
  browserWindow: {
    width: 400,
    height: 500,
    resizable: false,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    }
  },
  preloadWindow: true,
  showOnAllWorkspaces: false,
  showDockIcon: false
});

mb.on('ready', () => {
  console.log('Menubar app is ready');
  
  // Обновляем список портов при открытии
  mb.on('show', () => {
    mb.window.webContents.send('refresh-ports');
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
    return { success: true };
  } catch (error) {
    return { success: false, error: error.message };
  }
});

ipcMain.on('quit-app', () => {
  app.quit();
});

// Предотвращаем закрытие приложения при закрытии всех окон
app.on('window-all-closed', () => {
  // На macOS приложения обычно остаются активными даже после закрытия всех окон
  if (process.platform !== 'darwin') {
    app.quit();
  }
});