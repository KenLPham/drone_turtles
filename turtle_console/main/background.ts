import { app, dialog, ipcMain } from 'electron';
import serve from 'electron-serve';
import { createWindow } from './helpers';
import { IPCWebSocketServer } from './IPCWebSocketServer';
import { IPCBlockDB } from './BlockDB';
import { IPCBlueprintController } from './IPCBlueprintController';
import fs from "fs/promises"

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
    width: 1600,
    height: 900,
  });
  
  if (isProd) {
    await mainWindow.loadURL('app://./home.html');
  } else {
    const port = process.argv[2];
    await mainWindow.loadURL(`http://localhost:${port}/home`);
    mainWindow.webContents.openDevTools();
  }

  // ? setup IPC tunnels
  socketServer.setup(mainWindow)
  blockDB.setup()
  blueprintController.setup()
})();

app.on('window-all-closed', () => {
  app.quit();
});

ipcMain.handle("dialog", async (event, method, ...args) => {
  switch (method) {
    case "save": {
      const [type, data] = args
      const { canceled, filePath } = await dialog.showSaveDialog({
        defaultPath: `blueprint.${type}`
      })

      if (!canceled && !!filePath) {
        try {
          await fs.writeFile(filePath, JSON.stringify(data))
          return [true, filePath]
        } catch (e: any) {
          return [false, e]
        }
      }
      break
    }
    case "open": {
      const [ types ] = args
      const { canceled, filePaths } = await dialog.showOpenDialog({ properties: [ "openFile" ], filters: [ { name: "Allowed Extensions", extensions: types } ] } )

      if (!canceled && !!filePaths) {
        try {
          const filePath = filePaths[0]
          const data = await fs.readFile(filePath)
          return [true, JSON.parse(data.toString())]
        } catch (e: any) {
          return [false, e]
        }
      }

      break
    }
    default: {
      return [false, "Unsupported method"]
    }
  }
  return [false, "Request canceled."]
})