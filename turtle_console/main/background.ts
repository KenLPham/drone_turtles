import { app, ipcMain } from 'electron';
import serve from 'electron-serve';
import { createWindow } from './helpers';
import { IPCWebSocketServer } from './IPCWebSocketServer';
import { IPCBlockDB } from './BlockDB';
import { IPCBlueprintController } from './IPCBlueprintController';

const isProd: boolean = process.env.NODE_ENV === 'production';
const socketServer = new IPCWebSocketServer()
const blockDB = new IPCBlockDB()
const blueprintController = new IPCBlueprintController()

if (isProd) {
  serve({ directory: 'app' });
} else {
  app.setPath('userData', `${app.getPath('userData')} (development)`);
}

(async () => {
  await app.whenReady();

  
  // ? setup UI
  const mainWindow = createWindow('main', {
    width: 1280,
    height: 900,
  });
  
  if (isProd) {
    await mainWindow.loadURL('app://./home.html');
  } else {
    const port = process.argv[2];
    await mainWindow.loadURL(`http://localhost:${port}/home`);
  }

  // ? setup IPC tunnels
  socketServer.setup(mainWindow)
  blockDB.setup()
  blueprintController.setup()
})();

app.on('window-all-closed', () => {
  app.quit();
});
