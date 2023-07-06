import { ipcMain } from "electron";
import { Paint } from "../renderer/pages/blueprint";
import { Vector } from "../renderer/turtle/socket_server";
import _ from "lodash";

export class IPCBlueprintController {
	constructor () {}

	public setup() {
		ipcMain.on("blueprint", async (event, method, ...args) => {
			try {
				const result = await this[method](...args)
				event.sender.send("blueprint", true, result)
			} catch (e: any) {
				event.sender.send("blueprint", false, e)
			}
		})
	}

	public encode(canvas: Paint[][][], width: number, height: number, topLeft: Vector, bottomRight: Vector) {
		var layer = canvas[0]

		const dx = topLeft.x - bottomRight.x
		const dz = topLeft.z - bottomRight.z

		if (dx > 0 && dz > 0) {
			for (let i = 0; i < width; i++) {
				for (let j = 0; j < height; j++) {
					layer[i][j].position.x = topLeft.x + i
					layer[i][j].position.z = topLeft.z - j
					layer[i][j].position.y = topLeft.y
				}
			}
		}

		const tasks = layer.flat()
			// ? only go to places where the turtle needs to place blocks
			// todo: use air space to send miner turtles?
			.filter(({ block: { id } }) => id !== "minecraft:air")
		
		// ? group tasks by block
		const blockTasks = _.groupBy(tasks, (e) => e.block.id)

		return blockTasks
	}
}