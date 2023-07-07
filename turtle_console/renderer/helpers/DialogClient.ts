import { ipcRenderer } from "electron";

export class DialogClient {
	public static async saveDialog(type: "json", data: any): Promise<[boolean, string]> {
		return await ipcRenderer.invoke("dialog", "save", type, data)
	}

	public static async openDialog<T = object>(types: ["json"]): Promise<[true, T] | [false, string]> {
		return await ipcRenderer.invoke("dialog", "open", types)
	}
}