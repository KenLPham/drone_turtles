import { createHash } from "crypto"
import { SubmitHandler, useForm } from "react-hook-form"
import { useBlockDB } from "../contexts/BlockDBContext"

interface Props {

}

interface Data {
	id: string
	color: string
}

export const AddBlockForm: React.FC<Props> = () => {
	const { getValues, register, handleSubmit } = useForm<Data>()
	const { addBlock } = useBlockDB()

	const onSubmit: SubmitHandler<Data> = (block) => {
		addBlock(block)
	}

	return <form onSubmit={handleSubmit(onSubmit)} className="m-2 flex gap-2">
		<input className="bg-slate-800 rounded-md p-1" {...register("id")} type="text" defaultValue={""} required  />
		<input className="bg-slate-800 rounded-md p-1" {...register("color")} type="color" defaultValue={"#" + createHash("sha256").update(getValues().id ?? "").digest("hex").slice(0, 6) + "ff"} required />

		<input type="submit" className="btn-blue" />
	</form>
}

export type AddBlockFormData = Data
export type AddBlockFormProps = Props