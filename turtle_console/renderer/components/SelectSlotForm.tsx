import { SubmitHandler, useForm } from "react-hook-form"

interface Props {
	onSubmit: SubmitHandler<Data>
}

interface Data {
	slot: number
}

export const SelectSlotForm: React.FC<Props> = ({ onSubmit }) => {
	const { register, handleSubmit } = useForm<Data>()

	return <form onSubmit={handleSubmit(onSubmit)}>
		<input className="bg-slate-800 rounded-md p-1" {...register("slot", { valueAsNumber: true })} type="number" required />
		<button type="submit">Select</button>
	</form>
}

export type SelectSlotFormData = Data