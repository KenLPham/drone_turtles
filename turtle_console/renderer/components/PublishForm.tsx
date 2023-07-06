import { SubmitHandler, useForm } from "react-hook-form";
import { Vector } from "../turtle/socket_server";

interface Props {
	onSubmit: SubmitHandler<Data>
}

interface Data {
	topLeft: Vector
	bottomRight: Vector
}

export const PublishForm: React.FC<Props> = ({ onSubmit }) => {
	const { register, handleSubmit } = useForm<Data>()

	return <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col">
		<label>Top Left Coordinates</label>
		<span className="flex flex-row gap-1">
			<label>X</label>
			<input className="bg-slate-800 rounded-md p-1" {...register("topLeft.x", { valueAsNumber: true })} defaultValue={-116} type="number" required />
			<label>Y</label>
			<input className="bg-slate-800 rounded-md p-1" {...register("topLeft.y", { valueAsNumber: true })} defaultValue={63} type="number" required />
			<label>Z</label>
			<input className="bg-slate-800 rounded-md p-1" {...register("topLeft.z", { valueAsNumber: true })} defaultValue={259} type="number" required />
		</span>
		<label>Bottom Right Coordinates</label>
		<span className="flex flex-row gap-1">
			<label>X</label>
			<input className="bg-slate-800 rounded-md p-1" {...register("bottomRight.x", { valueAsNumber: true })} defaultValue={-120} type="number" required />
			<label>Y</label>
			<input className="bg-slate-800 rounded-md p-1" {...register("bottomRight.y", { valueAsNumber: true })} defaultValue={63} type="number" required />
			<label>Z</label>
			<input className="bg-slate-800 rounded-md p-1" {...register("bottomRight.z", { valueAsNumber: true })} defaultValue={255} type="number" required />
		</span>

		<input type="submit" />
	</form>
}

export type PublishFormData = Data
export type PublishFormProps = Props