import { Route, Routes } from "react-router-dom";
import Dashboard from "../Pages/Admin/Dashboard/Dashboard";
import KhachHang from "../Pages/Admin/List/DSKhachHang";
import BacSi from "../Pages/Admin/List/DSBacSi";
import Lichhen from "../Pages/Admin/List/DSLichhen";
import Thuoc from "../Pages/Admin/List/DSThuocVatTu";
import AdminLayout from "../Layouts/AdminLayout/AdminLayout";
import ThemKhachHang from "../Pages/Admin/Create/ThemKhachHang";
import ThemBacSi from "../Pages/Admin/Create/ThemBacSi";
import ThemLichHen from "../Pages/Admin/Create/ThemLichHen";
import ChinhSuaKhachHang from "../Pages/Admin/Update/ChinhSuaKhachHang";
import ThemThuocVatTu from "../Pages/Admin/Create/ThemThuocVatTu";
import ChinhSuaThuocVatTu from "../Pages/Admin/Update/ChinhSuaThuocVatTu";
import ChinhSuaBacSi from "../Pages/Admin/Update/ChinhSuaBacSi";
import ChiTietBacSi from "../Pages/Admin/Details/CTBacSi";
import ChiTietThuocVatTu from "../Pages/Admin/Details/CTThuocVatTu";
import ChiTietKhachHang from "../Pages/Admin/Details/CTKhachHang";

import ListMovies from "../Pages/Admin/Movie/ListMovie";
import ListUser from "../Pages/Admin/Users/ListUser";
import ListEmployees from "../Pages/Admin/Employee/ListEmployees";
import ListCinema from "../Pages/Admin/Cinema/ListCinema";
import ListRoom from "../Pages/Admin/Room/ListRoom";
import ListSeat from "../Pages/Admin/Seat/ListSeat";
import ListSchedule from "../Pages/Admin/Schedule/ListSchedule";

import DetailUser from "../Pages/Admin/Users/DetailUser";
import DetailEmployees from "../Pages/Admin/Employee/DetailEmployee";
import DetailMovies from "../Pages/Admin/Movie/DetailMovie";

import UpdateUser from "../Pages/Admin/Users/UpdateUser";
import UpdateEmployees from "../Pages/Admin/Employee/UpdateEmployee";
import UpdateMovie from "../Pages/Admin/Movie/UpdateMovie";

import CreateUser from "../Pages/Admin/Users/CreateUser";
import CreateMovie from "../Pages/Admin/Movie/CreateMovie";
import CreateScheduleMovie from "../Pages/Admin/Schedule/createScheduleForMovie";

const AdminRouter = () => (
  <Routes>
    <Route element={<AdminLayout />}>
      <Route path="dashboard" element={<Dashboard />} />
      <Route path="danhsachkhachhang" element={<KhachHang />} />
      <Route path="danhsachbacsi" element={<BacSi />} />
      <Route path="danhsachlichhen" element={<Lichhen />} />
      <Route path="themkhachhang" element={<ThemKhachHang />} />
      <Route path="thembacsi" element={<ThemBacSi />} />
      <Route path="themlichhen" element={<ThemLichHen />} />
      <Route path="themthuocvattu" element={<ThemThuocVatTu />} />
      <Route path="chinhsuakhachhang/:id" element={<ChinhSuaKhachHang />} />
      <Route path="chinhsuabacsi/:id" element={<ChinhSuaBacSi />} />
      <Route path="chinhsuathuocvattu/:id" element={<ChinhSuaThuocVatTu />} />
      <Route path="chitietbacsi/:id" element={<ChiTietBacSi />} />
      <Route path="chitietkhachhang/:id" element={<ChiTietKhachHang />} />
      <Route path="chitietthuocvattu/:id" element={<ChiTietThuocVatTu />} />

      {/* list */}
      <Route path="ListMovies" element={<ListMovies />} />
      <Route path="ListUsers" element={<ListUser />} />
      <Route path="ListEmployees" element={<ListEmployees />} />
      <Route path="ListCinemas" element={<ListCinema />} />
      <Route path="ListRooms/:theaterId/rooms" element={<ListRoom />} />
      <Route path="ListSeats/:roomId/seats" element={<ListSeat />} />
      <Route path="ListSchedules" element={<ListSchedule />} />

      {/* details */}
      <Route path="DetailUser/:id" element={<DetailUser />} />
      <Route path="DetailEmployees/:id" element={<DetailEmployees />} />
      <Route path="DetailMovie/:id" element={<DetailMovies />} />

      {/* update */}
      <Route path="UpdateUser/:id" element={<UpdateUser />} />
      <Route path="UpdateEmployee/:id" element={<UpdateEmployees />} />
      <Route path="UpdateMovie/:id" element={<UpdateMovie />} />

      {/* create */}
      <Route path="CreateUser" element={<CreateUser />} />
      <Route path="CreateMovie" element={<CreateMovie />} />
      <Route
        path="CreateScheduleMovie/:id_phim"
        element={<CreateScheduleMovie />}
      />
    </Route>
  </Routes>
);

export default AdminRouter;
