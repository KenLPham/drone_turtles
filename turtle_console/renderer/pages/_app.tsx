import React, { useEffect } from 'react';
import type { AppProps } from 'next/app';

import '../styles/globals.css';
import { TurtleContextProvider } from '../contexts/TurtleContext';
import { TurtleSocket } from '../turtle/socket_server';
import { BlockDBContextProvider } from '../contexts/BlockDBContext';

function MyApp({ Component, pageProps }: AppProps) {
  return (<BlockDBContextProvider>
    <TurtleContextProvider>
      <Component {...pageProps} />
    </TurtleContextProvider>
  </BlockDBContextProvider>)
  
}

export default MyApp
