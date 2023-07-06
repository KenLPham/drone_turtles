import { useForm, SubmitHandler } from "react-hook-form"

// todo: validate form with yup https://github.com/react-hook-form/resolvers#quickstart

interface Props {
	onSubmit: SubmitHandler<Data>
}

interface Data {
	gridSize: { x: number, z: number }
	startingPos: { x: number, y: number, z: number }
}

export const CreateCanvasForm: React.FC<Props> = ({ onSubmit }) => {
	const { register, handleSubmit } = useForm<Data>()

	return <form onSubmit={handleSubmit(onSubmit)}>
		<input {...register("gridSize.x")} defaultValue={50} type="number" required />
		<input {...register("gridSize.z")} defaultValue={50} type="number" required />

		<input type="submit" />
	</form>
}

export type CreateCanvasFormData = Data
export type CreateCanvasFormProps = Props