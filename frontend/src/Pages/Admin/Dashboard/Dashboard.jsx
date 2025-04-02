import React, { useEffect, useState } from "react";
import { BASE_URL, token } from "../../../config";
import { motion } from "framer-motion"; // Import motion từ framer-motion
import "./Dashboard.css";

const Dashboard = () => {
  const [stats, setStats] = useState({
    LichHen: "",
    ThuocVatTu: "",
    BenhNhan: "",
    BacSi: "",
  });

  useEffect(() => {
    // Fetch số liệu thống kê từ API
    const fetchStats = async () => {
      try {
        const res = await fetch(`${BASE_URL}/api/v1/dashboard/stats`, {
          method: "GET",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
        });
        const data = await res.json();
        if (res.ok) {
          setStats(data);
        } else {
          console.error(data.message);
        }
      } catch (err) {
        console.error("Lỗi khi lấy dữ liệu thống kê:", err.message);
      }
    };
    fetchStats();
  }, []);

  return (
    <div className="dashboard-ad">
      <h1 className="dashboard-title-ad">Dashboard</h1>
      <div className="dashboard-cards-ad">
        <motion.div
          className="card-ad"
          initial={{ opacity: 0, y: 20 }} // Khởi tạo card với opacity là 0 và dịch chuyển 20px
          animate={{ opacity: 1, y: 0 }} // Kết thúc card với opacity là 1 và không dịch chuyển
          transition={{ duration: 0.6 }} // Thời gian hiệu ứng là 0.6 giây
        >
          <div>
            <div className="numbers">{stats.LichHen}</div>
            <h2 className="cardName-ad">Lịch hẹn</h2>
          </div>
          <div className="iconBx">
            <img
              width="96"
              height="96"
              src="https://img.icons8.com/color/96/tear-off-calendar--v1.png"
              alt="tear-off-calendar--v1"
            />
          </div>
        </motion.div>

        <motion.div
          className="card-ad"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.2 }} // Độ trễ cho card thứ 2
        >
          <div>
            <div className="numbers">{stats.ThuocVatTu}</div>
            <h2 className="cardName-ad">Thuốc - vật tư</h2>
          </div>
          <div className="iconBx">
            <img
              width="96"
              height="96"
              src="https://img.icons8.com/color/96/pills.png"
              alt="pills"
            />
          </div>
        </motion.div>

        <motion.div
          className="card-ad"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.4 }} // Độ trễ cho card thứ 3
        >
          <div>
            <div className="numbers">{stats.BenhNhan}</div>
            <h2 className="cardName-ad">Bệnh nhân</h2>
          </div>
          <div className="iconBx">
            <img
              width="96"
              height="96"
              src="https://img.icons8.com/color/96/user.png"
              alt="user"
            />
          </div>
        </motion.div>

        <motion.div
          className="card-ad"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.6 }} // Độ trễ cho card thứ 4
        >
          <div>
            <div className="numbers">{stats.BacSi}</div>
            <h2 className="cardName-ad">Bác sĩ</h2>
          </div>
          <div className="iconBx">
            <img
              width="96"
              height="96"
              src="https://img.icons8.com/color/96/doctor-male--v1.png"
              alt="doctor-male--v1"
            />
          </div>
        </motion.div>
      </div>
    </div>
  );
};

export default Dashboard;
