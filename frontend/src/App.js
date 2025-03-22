import React from 'react';
import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import AdminRouter from './Routers/AdminRouter';
import { ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import { AuthContextProvider } from './context/AuthContext'; 
import Login from './Pages/Customer/Login';
import SignUp from './Pages/Customer/SignUp';

const App = () => {
  return (
    <AuthContextProvider>
      <div>
        <ToastContainer
          theme="dark"
          position="top-right"
          autoClose={3000}
          closeOnClick
          pauseOnHover={false}
        />
        <BrowserRouter>
          <Routes>
            <Route path="/" element={<Navigate to="/login" />} />
            <Route path="/admin/*" element={<AdminRouter />} />
            <Route path="/login" element={<Login />} />
            <Route path="/register" element={<SignUp />} />
          </Routes>
        </BrowserRouter>
      </div>
    </AuthContextProvider>
  );
};

export default App;
