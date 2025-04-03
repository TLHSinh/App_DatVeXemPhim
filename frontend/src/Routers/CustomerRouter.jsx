import { Route, Routes } from "react-router-dom";
import Login from "../Pages/Customer/Login";
import CustomerLayout from "../Layouts/CustomerLayout";
import SignUp from "../Pages/Customer/SignUp";

const CustomerRoutes = () => (
  <Routes>
    <Route element={<CustomerLayout />}>
      <Route path="login" element={<Login />} />
      <Route path="register" element={<SignUp />} />
    </Route>
  </Routes>
);

export default CustomerRoutes;
