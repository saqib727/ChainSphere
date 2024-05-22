import React from 'react';
import ReactDOM from 'react-dom/client';
import './styles/index.scss';
import App from './App';
// import {chainspherProvider} from './context/chainspherProvider'

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    {/* <chainspherPro÷vider> */}
    <App />
    {/* </chainspherProvider> */}
  </React.StrictMode>
);
