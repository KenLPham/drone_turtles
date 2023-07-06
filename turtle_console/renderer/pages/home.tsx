import React from 'react';
import Head from 'next/head';
import Link from 'next/link';
import { CreateCanvasForm } from '../components/CreateCanvasForm';

function Home() {
  return (
    <>
      <Head>
        <title>Home - Turtle Console</title>
      </Head>
      <div className='mt-1 w-full flex-wrap flex justify-center'>
        <Link href='/control'>
          <a className='btn-blue'>Turtle Controls</a>
        </Link>
        <Link href="/blueprint">
          <a className='btn-blue'>Create Blueprint</a>
        </Link>
      </div>
    </>
  );
}

export default Home;
