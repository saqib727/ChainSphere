import React from 'react';
import ReactDOM from 'react-dom/client';
import './styles/index.scss';
import App from './App';
import { Provider } from "react-redux";
import { createStore, applyMiddleware, compose } from "redux";
import thunk from "redux-thunk";
import rootReducer from "./store";
// import {chainspherProvider} from './context/chainspherProvider'
import {
  BrowserRouter as Router
} from "react-router-dom";

const composeEnhancer =
  (window.__REDUX_DEVTOOLS_EXTENSION__ &&
    window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__) ||
  compose;

const store = createStore(rootReducer, composeEnhancer(applyMiddleware(thunk)));


const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <Router>
  <Provider store={store}>

  <React.StrictMode>
    {/* <chainspherPro÷vider> */}
    <App />
    {/* </chainspherProvider> */}
  </React.StrictMode>
  </Provider>
  </Router>

);
