import { Route, Routes } from 'react-router-dom';
import Dashboard from '../Pages/Admin/Dashboard/Dashboard';
import KhachHang from '../Pages/Admin/List/DSKhachHang';
import BacSi from '../Pages/Admin/List/DSBacSi';
import Lichhen from '../Pages/Admin/List/DSLichhen';
import Thuoc from '../Pages/Admin/List/DSThuocVatTu';
import AdminLayout from '../Layouts/AdminLayout/AdminLayout';
import ThemKhachHang from '../Pages/Admin/Create/ThemKhachHang';
import ThemBacSi from '../Pages/Admin/Create/ThemBacSi';
import ThemLichHen from '../Pages/Admin/Create/ThemLichHen';
import ChinhSuaKhachHang from '../Pages/Admin/Update/ChinhSuaKhachHang';
import ThemThuocVatTu from '../Pages/Admin/Create/ThemThuocVatTu';
import ChinhSuaThuocVatTu from '../Pages/Admin/Update/ChinhSuaThuocVatTu';
import ChinhSuaBacSi from '../Pages/Admin/Update/ChinhSuaBacSi';
import ChiTietBacSi from '../Pages/Admin/Details/CTBacSi';
import ChiTietThuocVatTu from '../Pages/Admin/Details/CTThuocVatTu';
import ChiTietKhachHang from '../Pages/Admin/Details/CTKhachHang';
import ChinhSuaAdmin from '../Pages/Admin/Update/ChinhSuaAdmin';



const AdminRouter = () => (
    <Routes>
      <Route element={<AdminLayout />}>
        <Route path="dashboard" element={<Dashboard/>} />
        <Route path="danhsachkhachhang" element={<KhachHang/>} />
        <Route path="danhsachbacsi" element={<BacSi/>} />
        <Route path="danhsachthuocvattu" element={<Thuoc/>} />
        <Route path="danhsachlichhen" element={<Lichhen/>} />
        <Route path="themkhachhang" element={<ThemKhachHang/>} />
        <Route path="thembacsi" element={<ThemBacSi/>} />
        <Route path="themlichhen" element={<ThemLichHen/>} />
        <Route path="themthuocvattu" element={<ThemThuocVatTu/>} />
        <Route path="chinhsuakhachhang/:id" element={<ChinhSuaKhachHang/>} />
        <Route path="chinhsuabacsi/:id" element={<ChinhSuaBacSi/>} />
        <Route path="chinhsuathuocvattu/:id" element={<ChinhSuaThuocVatTu/>} />
        <Route path="chitietbacsi/:id" element={<ChiTietBacSi/>} />
        <Route path="chitietkhachhang/:id" element={<ChiTietKhachHang/>} />
        <Route path="chitietthuocvattu/:id" element={<ChiTietThuocVatTu/>} />
        <Route path="chinhsuaadmin" element={<ChinhSuaAdmin/>} />
      </Route>
    </Routes>
);

export default AdminRouter;
