import { dirname, join } from "path";
import { fileURLToPath } from "url";
import { createHash } from "crypto";
import { ipcMain } from "electron";
import Store from "electron-store"

interface Block {
	id: string
	color: string
}

class BlockDB {
	store: Store<Record<string, string>>

	public blocks(): Block[] {
		return Object.keys(this.store.store).map((id) => ({ id, color: this.store.store[id] }))
	}

	constructor() {
		this.store = new Store({ name: "blockdb" })
		console.log(this.store.path)
	}

	public addBlock({ id, color }: { id: string, color?: string }) {
		const finalColor = color ?? "#" + createHash("sha256").update(id).digest("hex").slice(0, 6) + "ff"
		this.store.set(id, finalColor)
	}

	public removeBlock(id: string) {
		this.store.delete(id)
	}

	public updateBlock({ id, color }: Block) {
		this.store.set(id, color)
	}
}

class IPCBlockDB {
	private db: BlockDB

	constructor() {
		this.db = new BlockDB()
	}

	public setup() {
		ipcMain.on("blockdb", (event, method, ...args) => {
			try {
				const result = this.db[method](...args)
				console.log(result)
				event.sender.send("blockdb", true, result)
			} catch (e: any) {
				console.error(`Failed to handle IPC request for blockdb. Reason: ${e}`)
				event.sender.send("blockdb", false)
			}
		})
	}
}

export type { Block }
export { BlockDB, IPCBlockDB }