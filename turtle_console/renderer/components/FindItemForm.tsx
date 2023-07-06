import React, { useState } from "react"
import { SubmitHandler, useForm } from "react-hook-form"
import Turtle from "../turtle/turtle"

interface Props {
	turtle: Turtle
}

interface Data {
	itemName: string
}

export const FindItemForm: React.FC<Props> = ({ turtle }) => {
	const { register, handleSubmit } = useForm<Data>()

	const [slots, setSlots] = useState<number[]>([])
	const onSubmit: SubmitHandler<Data> = async ({ itemName }) => {
		const s = await turtle.findItem(itemName)
		setSlots(s)
	}

	return <div>
		<form onSubmit={handleSubmit(onSubmit)}>
			<input className="bg-slate-800 rounded-md p-1" {...register("itemName")} type="text" required />
			<button type="submit">Find</button>
		</form>
		<pre>
			{JSON.stringify(slots)}
		</pre>
		</div>
}

export type FindItemFormProps = Props
export type FindItemFormData = Data