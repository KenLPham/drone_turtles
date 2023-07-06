import React, { useState } from 'react';
import Head from 'next/head';
import Link from 'next/link';
import { ArrowUturnLeftIcon, ArrowUturnRightIcon, ArrowDownIcon, ArrowUpIcon } from "@heroicons/react/24/solid"
import { TurtleSocket } from '../turtle/socket_server';
import { useTurtleContext } from '../contexts/TurtleContext';
import { SelectTurtleForm } from '../components/SelectTurtleForm';
import Turtle from '../turtle/turtle';
import { SelectSlotForm } from '../components/SelectSlotForm';

function ControlPage() {
  const { turtles, getTurtle } = useTurtleContext()

  const [turtle, setTurtle] = useState<Turtle | null>(null)

  return (
    <React.Fragment>
      <Head>
        <title>Controls - Turtle Console</title>
      </Head>
      <div className='flex m-4'>
        <section>
          {turtles.length}
          <SelectTurtleForm options={turtles} onSubmit={({label}) => setTurtle(getTurtle(label))} />
        </section>
          {turtle && (
            <>
        <section className='grid grid-cols-3'>
          <button type="button" onClick={async () => await turtle.forward()} className='col-start-2 bg-blue-500 p-2 hover:bg-blue-600 active:bg-blue-400'>
            <ArrowUpIcon className='h-5 w-5' />
          </button>
          <button type="button" onClick={async () => await turtle.turnLeft()} className='row-start-2 bg-blue-500 p-2 hover:bg-blue-600 active:bg-blue-400'>
            <ArrowUturnLeftIcon className='h-5 w-5' />
          </button>
          <button type="button" onClick={async () => await turtle.turnRight()} className='row-start-2 col-start-3 bg-blue-500 p-2 hover:bg-blue-600 active:bg-blue-400'>
            <ArrowUturnRightIcon className='h-5 w-5' />
          </button>
          <button type="button" onClick={async () => await turtle.back()} className='row-start-3 col-start-2 bg-blue-500 p-2 hover:bg-blue-600 active:bg-blue-400'>
            <ArrowDownIcon className='h-5 w-5' />
          </button>
        </section>
        <section>
          <SelectSlotForm onSubmit={({ slot }) => turtle.select(slot)} />
        </section>
            </>
          )}
      </div>
      <div className='mt-1 w-full flex-wrap flex justify-center'>
        <Link href='/home'>
          <a className='btn-blue'>Back</a>
        </Link>
      </div>
    </React.Fragment>
  )
}

export default ControlPage
