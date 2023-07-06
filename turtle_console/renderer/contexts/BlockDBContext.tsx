import { ipcRenderer } from "electron";
import React, { useContext, useEffect, useState } from "react";
import { ProviderProps } from "react";

interface Block {
	id: string
	color: string
}

interface Props extends Pick<ProviderProps<any>, "children"> {

}

interface BlockDBContextValue {
	blocks: Block[]
	addBlock: (block: { id: string, color?: string }) => any
	removeBlock: (id: string) => any
	updateBlock: (block: Block) => any
}

const funcStub = () => { throw new Error("stub") }
const defaultValue: BlockDBContextValue = {
	blocks: [],
	addBlock: funcStub,
	removeBlock: funcStub,
	updateBlock: funcStub
}
const BlockDBContext = React.createContext(defaultValue)

const BlockDBContextProvider: React.FC<Props> = ({ ...props }) => {
	const [blocks, setBlocks] = useState<Block[]>([])

	useEffect(() => {
		readBlocks()
	}, [])

	const readBlocks = async () => {
		const promise = new Promise<Block[]>((resolve, reject) => {
			ipcRenderer?.on("blockdb", (event, success, ...args) => {
				if (success) {
					resolve(args[0])
				} else {
					resolve([])
				}
			})
		})
		ipcRenderer?.send("blockdb", "blocks")
		const blocks = await promise
		setBlocks(blocks)
	}

	const addBlock = async (block: { id: string, color?: string }) => {
		const promise = new Promise<void>((resolve, reject) => {
			ipcRenderer?.on("blockdb", (event, success, ...args) => {
				if (success) {
					resolve()
				} else {
					reject()
				}
			})
		})
		ipcRenderer?.send("blockdb", "addBlock", block)

		await promise
		await readBlocks()
	}

	const removeBlock = async (id: string) => {
		const promise = new Promise<void>((resolve, reject) => {
			ipcRenderer?.on("blockdb", (event, success, ...args) => {
				if (success) {
					resolve()
				} else {
					reject()
				}
			})
		})
		ipcRenderer?.send("blockdb", "removeBlock", id)
		await promise
		await readBlocks()
	}

	const updateBlock = async (block: Block) => {
		const promise = new Promise<void>((resolve, reject) => {
			ipcRenderer?.on("blockdb", (event, success, ...args) => {
				if (success) { 
					resolve()
				} else {
					reject()
				}
			})
		})
		ipcRenderer?.send("blockdb", "updateBlock", block)
		await promise
		await readBlocks()
	}

	return <BlockDBContext.Provider value={{
		blocks,
		addBlock,
		removeBlock,
		updateBlock
	}} {...props}></BlockDBContext.Provider>
}

const useBlockDB = () => {
	const context = useContext(BlockDBContext)
	if (!context) {
		throw new Error("BlockDBContext cannot be found.")
	}
	return context
}

export type { Props, BlockDBContextValue }
export { BlockDBContext, BlockDBContextProvider, useBlockDB }