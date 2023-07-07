import { ipcMain } from "electron";
import { Paint, Vector } from "../renderer/pages/blueprint";
import _ from "lodash";

export class IPCBlueprintController {
	constructor () {}

	public setup() {
		ipcMain.handle("blueprint", async (event, method, ...args) => {
			try {
				const result = await this[method](...args)
				return [true, result]
			} catch (e: any) {
				return [false, e]
			}
		})
	}

	public async encode(canvas: Paint[][][], width: number, height: number, topLeft: Vector, bottomRight: Vector) {
		const dx = topLeft.x - bottomRight.x
		const dz = topLeft.z - bottomRight.z

		for (let k = 0; k < canvas.length; k++) {
			// todo: this can be simplified
			if (dx > 0 && dz > 0) {
				for (let i = 0; i < width; i++) {
					for (let j = 0; j < height; j++) { // -z = height; -x = width
						canvas[k][j][i].position.x = topLeft.x - i
						canvas[k][j][i].position.z = topLeft.z - j
						canvas[k][j][i].position.y = topLeft.y + k
					}
				}
			} else if (dx > 0 && dz < 0) {
				for (let i = 0; i < width; i++) {
					for (let j = 0; j < height; j++) {
						canvas[k][j][i].position.x = topLeft.x - i
						canvas[k][j][i].position.z = topLeft.z + j
						canvas[k][j][i].position.y = topLeft.y + k
					}
				}
			} else if (dx < 0 && dz < 0) {
				for (let i = 0; i < width; i++) {
					for (let j = 0; j < height; j++) {
						canvas[k][j][i].position.x = topLeft.x + j
						canvas[k][j][i].position.z = topLeft.z + i
						canvas[k][j][i].position.y = topLeft.y + k
					}
				}
			} else if (dx < 0 && dz > 0) {
				for (let i = 0; i < width; i++) {
					for (let j = 0; j < height; j++) {
						canvas[k][j][i].position.x = topLeft.x + i
						canvas[k][j][i].position.z = topLeft.z - j
						canvas[k][j][i].position.y = topLeft.y + k
					}
				}
			}
		}


		const tasks = canvas.flat(2)
			// ? only go to places where the turtle needs to place blocks
			// todo: use air space to send miner turtles?
			.filter(({ block: { id } }) => id !== "minecraft:air")
		
		// ? group tasks by block
		const blockTasks = _.groupBy(tasks, (e) => e.block.id)

		return blockTasks
	}
}