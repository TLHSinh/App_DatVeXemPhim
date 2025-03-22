import { createContext, useReducer } from "react";

const initialState = {
    user: JSON.parse(localStorage.getItem('user')) || null,
    role: localStorage.getItem('role') || null,
    token: localStorage.getItem('token') || null,
    isAvatarVisible: JSON.parse(localStorage.getItem('isAvatarVisible')) || false,
};

export const AuthContext = createContext(initialState);

const authReducer = (state, action) => {
    switch (action.type) {
        case 'LOGIN_START':
            return {
                user: null,
                role: null,
                token: null,
                isAvatarVisible: false,
            };

        case 'LOGIN_SUCCESS':
            localStorage.setItem('token', action.payload.token);
            localStorage.setItem('role', action.payload.role);
            localStorage.setItem('user', JSON.stringify(action.payload.user));
            localStorage.setItem('isAvatarVisible', JSON.stringify(true)); // Cập nhật trạng thái hình ảnh
            return {
                user: action.payload.user,
                token: action.payload.token,
                role: action.payload.role,
                isAvatarVisible: true,
            };

        case 'LOGOUT':
            localStorage.removeItem('token');
            localStorage.removeItem('role');
            localStorage.removeItem('user');
            localStorage.removeItem('isAvatarVisible');
            return {
                user: null,
                role: null,
                token: null,
                isAvatarVisible: false,
            };

        case 'SET_AVATAR_VISIBILITY':
            localStorage.setItem('isAvatarVisible', JSON.stringify(action.payload));
            return {
                ...state,
                isAvatarVisible: action.payload,
            };

        default:
            return state;
    }
};

export const AuthContextProvider = ({ children }) => {
    const [state, dispatch] = useReducer(authReducer, initialState);

    return (
        <AuthContext.Provider
            value={{
                user: state.user,
                token: state.token,
                role: state.role,
                isAvatarVisible: state.isAvatarVisible,
                dispatch,
            }}
        >
            {children}
        </AuthContext.Provider>
    );
};
