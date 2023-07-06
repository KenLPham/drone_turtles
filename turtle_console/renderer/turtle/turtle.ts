import { WebSocket } from "ws"
import { ipcRenderer } from "electron"
import { Vector } from "../pages/blueprint"

class Turtle {
	public label: string
	private calibrated: boolean

	public get position(): Promise<Vector> {
		return new Promise(async (resolve) => {
			const [x, y, z] = await ipcRenderer.invoke("websocket", "gps", "locate", this.label)
			resolve({ x, y, z })
		})
	}

	constructor(label: string) {
		this.label = label
		this.calibrated = false
	}

	public async calibrate(): Promise<boolean> {
		const result = await ipcRenderer.invoke("websocket", "tps", "calibrate", this.label)
		return result[0]
	}

	public async goTo(pos: Vector): Promise<void> {
		const [success, reason] = await ipcRenderer.invoke("websocket", "gpsmove", "goTo", this.label, pos)
		if (!success) {
			console.error("Failed to goTo", pos, ". Reason:", reason)
		}
	}
	
	public async forward(): Promise<boolean> {
		const [success, reason] = await ipcRenderer.invoke("websocket", "turtle", "forward", this.label)
		if (!success) {
			console.error("Failed to move forward. Reason:", reason)
		}
		return success
	}

	public async back(): Promise<boolean> {
		const [success, reason] = await ipcRenderer.invoke("websocket", "turtle", "back", this.label)
		if (!success) {
			console.error("Failed to move back. Reason:", reason)
		}
		return success
	}

	public async turnLeft(): Promise<boolean> {
		const [success, reason] = await ipcRenderer.invoke("websocket", "turtle", "turnLeft", this.label)
		if (!success) {
			console.error("Failed to turn left. Reason:", reason)
		}
		return success
	}

	public async turnRight(): Promise<boolean> {
		const [success, reason] = await ipcRenderer.invoke("websocket", "turtle", "turnRight", this.label)
		if (!success) {
			console.error("Failed to turn right. Reason:", reason)
		}
		return success
	}

	public async place(): Promise<boolean> {
		const [success, reason] = await ipcRenderer.invoke("websocket", "turtle", "place", this.label)
		if (!success) {
			console.error("Failed to place. Reason:", reason)
		}
		return success
	}

	public async placeDown(): Promise<boolean> {
		const [success, reason] = await ipcRenderer.invoke("websocket", "turtle", "placeDown", this.label)
		if (!success) {
			console.error("Failed to place below. Reason:", reason)
		}
		return success
	}

	public async placeUp(): Promise<boolean> {
		const [success, reason] = await ipcRenderer.invoke("websocket", "turtle", "placeUp", this.label)
		if (!success) {
			console.error("Failed to place above. Reason:", reason)
		}
		return success
	}

	public async findItem(name: string): Promise<number[]> {
		const [ slots ] = await ipcRenderer.invoke("websocket", "tstd", "findItem", this.label, name)
		return Array.isArray(slots) ? slots : []
	}

	public async select(slot: number): Promise<boolean> {
		const [success, reason] = await ipcRenderer.invoke("websocket", "turtle", "select", this.label, slot)
		if (!success) {
			console.error("Failed to place. Reason:", reason)
		}
		return success
	}
}

export default Turtle