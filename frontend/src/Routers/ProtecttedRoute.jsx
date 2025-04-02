import { useContext } from "react";
import { Navigate } from "react-router-dom";
import { AuthContext } from "../context/AuthContext";

const ProtectedRoute = ({ children, allowedRoles }) => {
    const { token, role } = useContext(AuthContext);

    // Log để kiểm tra token và role khi vào ProtectedRoute
    console.log("Token:", token);
    console.log("Role:", role);

    // Kiểm tra token và role để quyết định xem có truy cập được không
    if (!token || !allowedRoles.includes(role)) {
        return <Navigate to='/login' replace={true} />;
    }

    return children;
};

export default ProtectedRoute;
