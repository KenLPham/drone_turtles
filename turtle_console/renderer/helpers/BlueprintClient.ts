import { ipcRenderer } from "electron";
import { Paint, Vector } from "../pages/blueprint";

export class BlueprintClient {
	static async encode(canvas: Paint[][][], width: number, height: number, topLeft: Vector, bottomRight: Vector): Promise<[boolean, _.Dictionary<Paint[]>]> {
		return await ipcRenderer.invoke("blueprint", "encode", canvas, width, height, topLeft, bottomRight)
	}
}