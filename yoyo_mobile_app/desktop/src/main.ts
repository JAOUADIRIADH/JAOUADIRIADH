import { app, BrowserWindow } from 'electron';
import path from 'path';

const createWindow = () => {
  const mainWindow = new BrowserWindow({
    width: 1200,
    height: 800
  });

  const indexPath = path.join(__dirname, '../../frontend/dist/index.html');
  mainWindow.loadFile(indexPath).catch(() => {
    mainWindow.loadURL('http://localhost:5173');
  });
};

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});
