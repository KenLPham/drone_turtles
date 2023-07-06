import React, { ProviderProps, useContext, useEffect, useState } from "react"
import { TurtleSocket } from "../turtle/socket_server"
import Turtle from "../turtle/turtle"
import { ipcRenderer } from "electron"

interface Props extends Pick<ProviderProps<any>, "children"> {
	// socketServer: TurtleSocket
}
interface TurtleContextValue {
	turtles: Turtle[]
	getTurtle: (label: string) => Turtle
}

const stub: TurtleContextValue = {
	turtles: [],
	getTurtle: () => {throw new Error("stub")}
}
const TurtleContext = React.createContext(stub)

const TurtleContextProvider: React.FC<Props> = ({ ...props }) => {
	const [turtles, setTurtles] = useState<Turtle[]>([])

	const getTurtle = (label: string) => {
		return turtles.find((turtle) => turtle.label === label)
	}

	useEffect(() => {
		ipcRenderer?.on("websocket", async (event, ...args) => {
			switch (args[0]) {
				case "connection": {
					const label = args[1]
					const turtle = new Turtle(label)
					setTurtles((turtles) => turtles.concat(turtle))
			
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
	}, [])

	return <TurtleContext.Provider value={{
		turtles,
		getTurtle
	}} {...props} />
}

const useTurtleContext = () => {
	const context = useContext(TurtleContext)
	if (!context) {
		throw new Error("TurtleContext cannot be found.")
	}
	return context
}

export type { Props, TurtleContextValue }
export { TurtleContext, TurtleContextProvider, useTurtleContext }