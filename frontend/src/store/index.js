import { combineReducers } from 'redux'
import { authReducer } from "./reducers/authReducer";
import { mobileMenuReducer } from './reducers/mobileMenuReducer';

const rootReducer = combineReducers({
    auth: authReducer,
    mobileMenu: mobileMenuReducer,
});

export default rootReducer
