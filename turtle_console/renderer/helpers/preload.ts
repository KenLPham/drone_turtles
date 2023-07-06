import { contextBridge, ipcRenderer } from "electron";

contextBridge.exposeInMainWorld("blockdb", {

})

contextBridge.exposeInMainWorld("turtle", {
	calibrate: async (label: string) => ipcRenderer.invoke("websocket", "tps", "calibrate", label)
})