import { WebSocket, WebSocketServer } from "ws";
import { agentNames } from "../renderer/turtle/names";
import { BrowserWindow, ipcMain } from "electron";
import { Vector } from "../renderer/turtle/socket_server";

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
	
		ipcMain.on("websocket", async (event, method, ...args) => {
			try {
				const result = await this[method](...args)
				event.sender.send("websocket", true, result)
			} catch (e: any) {
				event.sender.send("websocket", false, e)
			}
		})
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

	private async calibrate(label: string): Promise<boolean> {
		const socket = this.sockets[label]
		const promise = new Promise<boolean>((resolve, reject) => {
			IPCWebSocketServer.parseMessage<boolean | string | null>(socket, (data) => {
				if (data.type === "ret") {
					if (data.body[0]) {
						resolve(true)
					} else {
						reject(data.body[1])
					}
				}
			})
		})
		socket.send(IPCWebSocketServer.evalData("tps", "calibrate"))
		return promise
	}

	private async position(label: string): Promise<Vector> {
		const socket = this.sockets[label]
		const promise = new Promise<Vector | null>((resolve, reject) => {
			IPCWebSocketServer.parseMessage<number | null>(socket, (data) => {
				if (data.type === "ret") {
					if (data.body.length === 3) {
						resolve({ x: data.body[0], y: data.body[1], z: data.body[2]})
					} else {
						reject("Failed to find position")
					}
				}
			})
		})
		socket.send(IPCWebSocketServer.evalData("gps", "locate"))
		return promise
	}

	private async forward(label: string): Promise<boolean> {
		const socket = this.sockets[label]
		const promise = new Promise<boolean>((resolve, reject) => {
			IPCWebSocketServer.parseMessage(socket, (data) => {
				if (data.type === "ret") {
					if (data.body[0]) {
						resolve(true)
					} else {
						reject(data.body[1])
					}
				}
			})
		})
		socket.send(IPCWebSocketServer.evalData("turtle", "forward"))
		return promise
	}

	private async back(label: string): Promise<boolean> {
		const socket = this.sockets[label]
		const promise = new Promise<boolean>((resolve, reject) => {
			IPCWebSocketServer.parseMessage(socket, (data) => {
				if (data.type === "ret") {
					if (data.body[0]) {
						resolve(true)
					} else {
						reject(data.body[1])
					}
				}
			})
		})
		socket.send(IPCWebSocketServer.evalData("turtle", "back"))
		return promise
	}

	private async turnLeft(label: string): Promise<boolean> {
		const socket = this.sockets[label]
		const promise = new Promise<boolean>((resolve, reject) => {
			IPCWebSocketServer.parseMessage(socket, (data) => {
				if (data.type === "ret") {
					if (data.body[0]) {
						resolve(true)
					} else {
						reject(data.body[1])
					}
				}
			})
		})
		socket.send(IPCWebSocketServer.evalData("turtle", "turnLeft"))
		return promise
	}

	private async turnRight(label: string): Promise<boolean> {
		const socket = this.sockets[label]
		const promise = new Promise<boolean>((resolve, reject) => {
			IPCWebSocketServer.parseMessage(socket, (data) => {
				if (data.type === "ret") {
					if (data.body[0]) {
						resolve(true)
					} else {
						reject(data.body[1])
					}
				}
			})
		})
		socket.send(IPCWebSocketServer.evalData("turtle", "turnRight"))
		return promise
	}

	private async goTo(label: string, pos: Vector) {
		const socket = this.sockets[label]
		const promise = new Promise<boolean>((resolve, reject) => {
			IPCWebSocketServer.parseMessage(socket, (data) => {
				if (data.type === "ret") {
					if (data.body[0]) {
						resolve(true)
					} else {
						reject(data.body[1])
					}
				}
			})
		})
		socket.send(IPCWebSocketServer.evalData("gpsmove", "goTo", [pos]))
		return promise
	}

	private async placeDown(label: string, text?: string) {
		const socket = this.sockets[label]
		const promise = new Promise<boolean>((resolve, reject) => {
			IPCWebSocketServer.parseMessage(socket, (data) => {
				if (data.type === "ret") {
					if (data.body[0]) {
						resolve(true)
					} else {
						reject(data.body[1])
					}
				}
			})
		})
		socket.send(IPCWebSocketServer.evalData("turtle", "placeDown", [text]))
		return promise
	}

	private async findItem(label: string, name: string) {
		const socket = this.sockets[label]
		const promise = new Promise<number[]>((resolve, reject) => {
			IPCWebSocketServer.parseMessage<string | number[]>(socket, (data) => {
				if (data.type === "ret") {
					if (data.body[0]) {
						resolve(data.body[0] as number[])
					} else {
						reject(data.body[1])
					}
				}
			})
		})
		socket.send(IPCWebSocketServer.evalData("tstd", "findItem", [name]))
		return promise
	}

	private async select(label: string, slot: number) {
		const socket = this.sockets[label]
		const promise = new Promise<void>((resolve, reject) => {
			IPCWebSocketServer.parseMessage<string | number[]>(socket, (data) => {
				if (data.type === "ret") {
					if (data.body[0]) {
						resolve()
					} else {
						reject(data.body[1])
					}
				}
			})
		})
		socket.send(IPCWebSocketServer.evalData("turtle", "select", [slot]))
		return promise
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