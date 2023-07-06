import { WebSocket, WebSocketServer } from "ws"
import { agentNames } from "./names"
import Turtle from "./turtle"
import electron from "electron"

const ipcRenderer = electron.ipcRenderer || null

export interface Vector {
	x: number
	y: number
	z: number
}

export class TurtleSocket {
	public turtles: Turtle[]

	constructor() {
		this.turtles = []
	}

	public setup() {
		ipcRenderer.on("websocket", async (event, ...args) => {
			switch (args[0]) {
				case "connection": {
					const label = args[1]
					const turtle = new Turtle(label)
					this.turtles.push(turtle)
			
					try {
						await turtle.calibrate()
					} catch(e: any) {
						console.error(`${turtle.label} failed to calibrate. Reason: ${e}`)
					}
				}
				default:
					break
			}
		})
	}
}
