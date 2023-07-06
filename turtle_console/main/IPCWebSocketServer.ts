import { WebSocket, WebSocketServer } from "ws";
import { agentNames } from "../renderer/turtle/names";
import { BrowserWindow, ipcMain } from "electron";

export interface SocketResponse<T, O = any> {
	type: "ret"
	body: T[]
	origin: O
}

export class IPCWebSocketServer {
	private socketServer: WebSocketServer
	private sockets: { [key: string]: WebSocket }

	constructor() {
		this.socketServer = new WebSocketServer({
			port: 25567,
		})
		this.sockets = {}
	}
	
	public setup(window: BrowserWindow) {
		this.socketServer.on("connection", async (socket) => {
			var label = await this.computerLabel(socket)
			if (!!!label) {
				label = agentNames[Math.floor(Math.random() * agentNames.length)]
				await this.setComputerLabel(socket, label)
			}
			this.sockets[label] = socket
			window.webContents.send("websocket", "connection", label)
		})

		// setInterval(() => {
		// 	console.log("checking for closed connections")
		// 	for (const label of Object.keys(this.sockets)) {
		// 		const socket = this.sockets[label]
		// 		if (socket.readyState === socket.CLOSED) {
		// 			console.log(label, "is closed")
		// 			window.webContents.send("websocket", "closed", label)
		// 		}
		// 	}
		// }, 5000)

		ipcMain.handle("websocket", async (event, module, method, label, ...args) => {
			const socket = this.sockets[label]

			const promise = this.promiseFor(socket)
			socket.send(IPCWebSocketServer.evalData(module, method, args))
			return promise
		})
	}

	public tearDown() {
	}

	private async computerLabel(socket: WebSocket): Promise<string | null> {
		const promise = new Promise<string | null>((resolve, reject) => {
			socket.once("message", (dataString, isBinary) => {
				const data: SocketResponse<string> = JSON.parse(dataString.toString())
				if (data.type === "ret") {
					if (data.body.length === 1) {
						resolve(data.body[0])
					} else {
						resolve(null)
					}
				}
			})
		})
		socket.send(IPCWebSocketServer.evalData("os", "computerLabel"))

		return promise
	}

	private async setComputerLabel(socket: WebSocket, label: string) {
		socket.send(IPCWebSocketServer.evalData("os", "setComputerLabel", [label]))
	}

	private promiseFor<T = any>(socket: WebSocket): Promise<T[]> {
		return new Promise<T[]>((resolve) => {
			IPCWebSocketServer.parseMessage<T>(socket, (data) => {
				if (data.type === "ret") {
					if (!Array.isArray(data.body)) {
						data.body = []
					}
					resolve(data.body)
				}
			})
		})
	}

	public static evalData(module: string, method: string, args: any[] = []) {
		return JSON.stringify({ type: "eval", module, method, args })
	}

	public static parseMessage<T, O = any>(socket: WebSocket, handler: (data: SocketResponse<T, O>) => void) {
		socket.once("message", (dataString, isBinary) => {
			let data: SocketResponse<T, O> = JSON.parse(dataString.toString())
			// ? if body isn't array, it is an empty obj so just replace it with an empty array
			if (!Array.isArray(data.body)) {
				data.body = []
			}
			console.log(data)
			handler(data)
		})
	}
}