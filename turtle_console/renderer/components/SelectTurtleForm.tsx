import { SubmitHandler, useForm } from "react-hook-form";
import Turtle from "../turtle/turtle";

interface Props {
	options: Turtle[]
	onSubmit: SubmitHandler<Data>
}

interface Data {
	label: string
}

export const SelectTurtleForm: React.FC<Props> = ({ options, onSubmit }) => {
	const { register, handleSubmit } = useForm<Data>()

	return <form onSubmit={handleSubmit(onSubmit)}>
		<select {...register("label")}>
			{options.map((e, i) => <option key={i} value={e.label}>{e.label}</option>)}
		</select>
		<button type="submit">Submit</button>
	</form>
}

export type SelectTurtleFormData = Data
export type SelectTurtleFormProps = Props