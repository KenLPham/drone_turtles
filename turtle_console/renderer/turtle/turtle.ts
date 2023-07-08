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

	// ? Movement

	public async goTo(pos: Vector): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "gpsmove", "goTo", this.label, pos)
	}
	
	public async forward(): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "forward", this.label)
	}

	public async back(): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "back", this.label)
	}

	public async turnLeft(): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "turnLeft", this.label)
	}

	public async turnRight(): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "turnRight", this.label)
	}

	public async up(): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "up", this.label)
	}

	public async down(): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "down", this.label)
	}

	// ? Dig

	public async dig(side?: "left" | "right"): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "dig", this.label, side)
	}

	public async digUp(side?: "left" | "right"): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "digUp", this.label, side)
	}

	public async digDown(side?: "left" | "right"): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "digDown", this.label, side)
	}

	// ? Place

	public async place(text?: string): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "place", this.label, text)
	}

	public async placeDown(text?: string): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "placeDown", this.label, text)
	}

	public async placeUp(text?: string): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "placeUp", this.label, text)
	}

	// ? Drop

	public async drop(count?: number): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "drop", this.label, count)
	}
	
	public async dropDown(count?: number): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "dropDown", this.label, count)
	}
	
	public async dropUp(count?: number): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "dropUp", this.label, count)
	}
	
	// ? Inventory
	
	public async findItem(name: string): Promise<number[]> {
		const [ slots ] = await ipcRenderer.invoke("websocket", "tstd", "findItem", this.label, name)
		return Array.isArray(slots) ? slots : []
	}
	
	public async select(slot: number): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "select", this.label, slot)
	}
	
	public async getItemCount(slot?: number): Promise<number> {
		const [ itemCount ] = await ipcRenderer.invoke("websocket", "turtle", "getItemCount", this.label, slot)
		return itemCount
	}
	
	public async getItemSpace(slot?: number): Promise<number> {
		const [ spaceLeft ] = await ipcRenderer.invoke("websocket", "turtle", "getItemSpace", this.label, slot)
		return spaceLeft
	}
	
	public async compareTo(slot: number): Promise<boolean> {
		const [ isEqual ] = await ipcRenderer.invoke("websocket", "turtle", "compareTo", this.label, slot)
		return isEqual
	}

	public async transferTo(slot: number, count?: number): Promise<boolean> {
		const [ success ] = await ipcRenderer.invoke("websocket", "turtle", "transferTo", this.label, slot, count)
		return success
	}

	public async getSelectedSlot(): Promise<number> {
		const [slot] = await ipcRenderer.invoke("websocket", "turtle", "getSelectedSlot", this.label)
		return slot
	}

	public async getItemDetail(slot?: number, detailed?: boolean): Promise<object | null> {
		const [ details ] = await ipcRenderer.invoke("websocket", "turtle", "getItemDetail", this.label, slot, detailed)
		return details
	}

	// ? Detect

	public async detect(): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "detect", this.label)
	}

	public async detectDown(): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "detectDown", this.label)
	}

	public async detectUp(): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "detectUp", this.label)
	}

	// ? Compare

	public async compare(): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "compare", this.label)
	}

	public async compareDown(): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "compareDown", this.label)
	}

	public async compareUp(): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "compareUp", this.label)
	}

	// ? Attack

	public async attack(side?: number): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "attack", this.label, side)
	}

	public async attackDown(side?: number): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "attackDown", this.label, side)
	}

	public async attackUp(side?: number): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "attackUp", this.label, side)
	}

	// ? Suck

	public async suck(count?: number): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "suck", this.label, count)
	}

	public async suckDown(count?: number): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "suckDown", this.label, count)
	}

	public async suckUp(count?: number): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "suckUp", this.label, count)
	}

	// ? Fuel

	public async getFuelLevel(): Promise<number | "unlimited"> {
		return await ipcRenderer.invoke("websocket", "turtle", "getFuelLevel", this.label)
	}

	public async refuel(count?: number): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "refuel", this.label, count)
	}

	public async getFuelLimit(): Promise<number | "unlimited"> {
		return await ipcRenderer.invoke("websocket", "turtle", "getFuelLimit", this.label)
	}

	// ? Equip

	public async equipLeft(): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "equipLeft", this.label)
	}

	public async equipRight(): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "equipRight", this.label)
	}

	// ? Inspect

	public async inspect(): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "inspect", this.label)
	}

	public async inspectDown(): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "inspectDown", this.label)
	}

	public async inspectUp(): Promise<[true] | [false, string]> {
		return await ipcRenderer.invoke("websocket", "turtle", "inspectUp", this.label)
	}
}

export default Turtle