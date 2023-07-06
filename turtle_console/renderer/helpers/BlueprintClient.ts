import { ipcRenderer } from "electron";
import { Paint } from "../pages/blueprint";
import { Vector } from "../turtle/socket_server";

export class BlueprintClient {
	static encode(canvas: Paint[][][], width: number, height: number, topLeft: Vector, bottomRight: Vector): Promise<_.Dictionary<Paint[]>> {
		const promise = new Promise<_.Dictionary<Paint[]>>((resolve, reject) => {
			ipcRenderer?.on("blueprint", (event, success, ...args) => {
				if (success) {
					resolve(args[0])
				} else {
					reject(args[0])
				}
			})
		})
		ipcRenderer?.send("blueprint", "encode", canvas, width, height, topLeft, bottomRight)
		return promise
	}
}