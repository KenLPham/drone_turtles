import { WebSocket } from "ws"
import { TurtleSocket, Vector } from "./socket_server"
import { ipcRenderer } from "electron"

class Turtle {
	public label: string
	private calibrated: boolean

	public get position(): Promise<Vector> {
		const promise = new Promise<Vector>((resolve, reject) => {
			ipcRenderer?.on("websocket", (event, ...args) => {
				if (args.length === 1) {
					resolve(args[0])
				} else {
					reject("Failed to locate turtle")
				}
			})
		})
		// this.socket.send(TurtleSocket.evalData("gps", "locate"))
		ipcRenderer?.send("websocket", "position")

		return promise
	}

	constructor(label: string) {
		this.label = label
		this.calibrated = false
	}

	public async calibrate(): Promise<boolean> {
		const promise = new Promise<boolean>((resolve, reject) => {
			ipcRenderer?.on("websocket", (event, ...args) => {
				if (args[0]) {
					resolve(true)
					this.calibrated = true
				} else {
					reject(args[1])
				}
			})
		})
		ipcRenderer?.send("websocket", "calibrate", this.label)
		return promise
	}

	public async goTo(pos: Vector) {
		const promise = new Promise<void>((resolve, reject) => {
			ipcRenderer?.on("websocket", (event, success, ...args) => {
				if (success) {
					resolve()
				} else {
					reject(args[0])
				}
			})
		})
		ipcRenderer?.send("websocket", "goTo", this.label, pos)
		return promise
	}
	
	public async forward(): Promise<void> {
		const promise = new Promise<void>((resolve, reject) => {
			ipcRenderer?.on("websocket", (event, success, ...args) => {
				if (success) {
					resolve()
				} else {
					reject(args[0])
				}
			})
		})
		ipcRenderer?.send("websocket", "forward", this.label)
		return promise
	}

	public async back(): Promise<void> {
		const promise = new Promise<void>((resolve, reject) => {
			ipcRenderer?.on("websocket", (event, success, ...args) => {
				if (success) {
					resolve()
				} else {
					reject(args[0])
				}
			})
		})
		ipcRenderer?.send("websocket", "back", this.label)
		return promise
	}

	public async turnLeft(): Promise<void> {
		const promise = new Promise<void>((resolve, reject) => {
			ipcRenderer?.on("websocket", (event, success, ...args) => {
				if (success) {
					resolve()
				} else {
					reject(args[0])
				}
			})
		})
		ipcRenderer?.send("websocket", "turnLeft", this.label)
		return promise
	}

	public async turnRight(): Promise<void> {
		const promise = new Promise<void>((resolve, reject) => {
			ipcRenderer?.on("websocket", (event, success, ...args) => {
				if (success) {
					resolve()
				} else {
					reject(args[0])
				}
			})
		})
		ipcRenderer?.send("websocket", "turnRight", this.label)
		return promise
	}

	public async placeDown(): Promise<void> {
		const promise = new Promise<void>((resolve, reject) => {
			ipcRenderer?.on("websocket", (event, success, ...args) => {
				if (success) {
					resolve()
				} else {
					reject(args[0])
				}
			})
		})
		ipcRenderer?.send("websocket", "placeDown", this.label)
		return promise
	}

	public async findItem(name: string): Promise<number[]> {
		const promise = new Promise<number[]>((resolve, reject) => {
			ipcRenderer?.on("websocket", (event, success, ...args) => {
				if (success) {
					resolve(args[0])
				} else {
					reject(args[0])
				}
			})
		})
		ipcRenderer?.send("websocket", "findItem", this.label, name)
		return promise
	}

	public async select(slot: number) {

	}

	public static evalData() {
		return JSON.stringify({ })
	}
}

export default Turtle