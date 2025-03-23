import express from "express";
import path from "path";
import { fileURLToPath } from "url";

const app = express();

// Xác định __dirname trong ES Module
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Cấu hình để phục vụ file assetlinks.json
app.use("/.well-known", express.static(path.join(__dirname, ".well-known")));

app.listen(8080, () => {
    console.log("Server running on http://localhost:8080");
});
