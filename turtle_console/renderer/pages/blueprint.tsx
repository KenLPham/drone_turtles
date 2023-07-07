import { NextPage } from "next";
import Head from "next/head";
import { MouseEventHandler, useState } from "react";
import _ from "lodash"
import { AddBlockForm } from "../components/AddBlockForm";
import { useBlockDB } from "../contexts/BlockDBContext";
import { DocumentDuplicateIcon, PlusIcon, TrashIcon } from "@heroicons/react/24/solid";
import classNames from "../helpers/classNames";
import { PublishForm, PublishFormData } from "../components/PublishForm";
import { useTurtleContext } from "../contexts/TurtleContext";
import { BlueprintClient } from "../helpers/BlueprintClient";
import Link from "next/link";
import { Block } from "../../main/BlockDB"

function sleep(ms: number) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

export interface Vector {
	x: number
	y: number
	z: number
}

export interface Paint {
	position: Vector
	block: Block
}

const Blueprint: NextPage = () => {
	const w = 52
	const h = 54

	const { turtles } = useTurtleContext()
	const { blocks } = useBlockDB()
	const eraseColor = blocks.find((e) => e.id.includes("minecraft:air")) ?? { id: "minecraft:air", color: "#ffffff" }

	const [color, setColor] = useState<Block>(blocks[0] ?? { id: "minecraft:stone", color: "#000000" })
	const [canvas, setCanvas] = useState<Paint[][][]>(
		[_.chunk(
			Array(w * h).fill(
				{ position: { x: 0, y: 0, z: 0 }, block: eraseColor }
			).map((e) => _.cloneDeep(e)),
			w
		)]
	)

	const [brushActive, setBrushActive] = useState(false)
	const [brushType, setBrushType] = useState<"draw" | "erase">("draw")
	const [selectedLayer, setLayer] = useState(0)

	const clickOnPoint = (x: number, y: number) => {
		// canvas[layer][y][x]
		setCanvas((c) => {
			const copy = _.cloneDeep(c)
			copy[selectedLayer][y][x].block = brushType === "erase" ? eraseColor : color
			return copy
		})
	}

	const handleMouseDown: MouseEventHandler = (event) => {
		if (event.button === 0) { // left
			setBrushType("draw")
		} else if (event.button === 2) { // right
			setBrushType("erase")
		}
		setBrushActive(true)
	}

	const addLayer = (layer?: number) => {
		setCanvas((c) => {
			return c.concat([ layer !== undefined ? _.cloneDeep(c[layer]) : _.chunk(
				Array(w * h).fill(
					{ position: { x: 0, y: 0, z: 0 }, block: eraseColor }
				).map((e) => _.cloneDeep(e)),
				w
			)])
		})
	}

	const removeLayer = (layer: number) => {
		if (layer === selectedLayer) setLayer(0)
		setCanvas((c) => {
			return c.filter((_, i) => i !== layer)
		})
	}

	const buildBlueprint = async ({ topLeft, bottomRight }: PublishFormData) => {
		const [success, tasks] = await BlueprintClient.encode(canvas, w, h, topLeft, bottomRight)
		if (success) {
			const organizedTasks = Object.values(tasks).flat().sort((a, b) => {
				if (a.position.y > b.position.y) {
					return 1
				} else if (a.position.y < b.position.y) {
					return -1
				} else if (a.position.y == b.position.y) {
					if (a.position.x > b.position.y) {
						return 1
					} else if (a.position.x < b.position.x) {
						return -1
					} else if (a.position.x == b.position.x) {
						if (a.position.z > b.position.z) {
							return 1
						} else if (a.position.z < b.position.z) {
							return -1
						}
					}
				}
				return 0
			})
			console.log(organizedTasks)

			if (turtles.length > 0) {
				const turtle = turtles[0]
				// todo: loop through block tasks and check for any prepared turtles.

				for (const task of organizedTasks) {
					task.position.y += 1
					await turtle.goTo(task.position)
					var slots = await turtle.findItem(task.block.id)
					if (slots.length === 0) {
						while (slots.length == 0) {
							await sleep(2000)
							slots = await turtle.findItem(task.block.id)
						}
					} else {
						await turtle.select(slots[0])
						await turtle.placeDown()
					}
				}
			}
		} else {
			console.error(tasks)
		}
	}

	return (
		<>
			<Head>
				<title>Blueprint - Turtle Console</title>
			</Head>
			<main
				className="flex"
				onMouseDown={handleMouseDown}
				onMouseUp={() => setBrushActive(false)}
			>
				<section>
					<div
						className="grid border-t border-l border-gray-500"
						style={{
							gridTemplateColumns: `repeat(${w}, minmax(0, 1fr))`,
							gridTemplateRows: `repeat(${h}, minmax(0, 1fr))`
						}}
					>
						{canvas[selectedLayer].flatMap(
							(row, i) => row.map(
								(paint, j) => <button
									type="button"
									key={`${i},${j}`}
									className="w-4 h-4 border-b border-r border-gray-500"
									style={{ backgroundColor: paint.block.color }}
									onMouseOver={() => brushActive && clickOnPoint(j, i)}
									onClick={() => clickOnPoint(j, i)}
								/>
							)
						)}
					</div>
				</section>
				<section className="p-2">
					<div>
						<h2>Pick Block</h2>
						<ul>
							{blocks.map((e, i) => (
								<li key={i}>
									<button
										type="button"
										onClick={() => setColor(e)}
										className={classNames(color.id === e.id && "")}
									>
										<span className="flex items-center gap-2">
											<div style={{backgroundColor: e.color}} className="w-4 h-4 border border-white" />
											{e.id}
										</span>
									</button>
								</li>))}
						</ul>
						<AddBlockForm />
					</div>
					<div className="max-w-md">
						<h2>Layers</h2>
						<ul className="flex overflow-x-scroll gap-2">
							{canvas.map((e, i) => (<li
								key={i}
								className={classNames(
									"p-2 rounded-md hover:bg-slate-800 active:bg-slate-700",
									selectedLayer === i && "border border-white"
								)}
								onClick={() => setLayer(i)}
							>
								<span>
									<div
										className="grid border-t border-l border-gray-500 aspect-square"
										style={{
											gridTemplateColumns: `repeat(${w}, minmax(0, 1fr))`,
											gridTemplateRows: `repeat(${h}, minmax(0, 1fr))`
										}}
									>
										{(i > selectedLayer - 3 && i < selectedLayer + 3) && e.flatMap(
											(row, i) => row.map(
												(paint, j) => <div
													key={`${i},${j}`}
													className="w-[0.1rem] h-[0.1rem]"
													style={{ backgroundColor: paint.block.color }}
												/>
										))}
									</div>
									<h3>Layer{i + 1}</h3>
									<span className="flex gap-2 justify-center">
										<button type="button" onClick={() => removeLayer(i)} hidden={i === 0}>
											<TrashIcon className="w-4 h-4" />
										</button>
										<button type="button" onClick={() => addLayer(i)}>
											<DocumentDuplicateIcon className="w-4 h-4" />
										</button>
									</span>
								</span>
							</li>))}
						</ul>
						<span>
							<button type="button" className="btn-blue" onClick={() => addLayer()}>
								<PlusIcon className="w-5 h-5" />
							</button>
						</span>
					</div>
				</section>
				<section className="p-2">
					<PublishForm onSubmit={buildBlueprint} />
				</section>
				<Link href="/home">
					<a className="btn-blue">Back</a>
				</Link>
			</main>
		</>
	)
}

export default Blueprint