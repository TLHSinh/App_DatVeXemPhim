const express = require('express');
const { exec } = require('child_process');

const app = express();
const port = 3002;

// Tạo route để Flutter gọi API
app.get('/run-scripts', (req, res) => {
    exec('node serverFetchFromAPI.js & node serverFetchFromDB.js', (err, stdout, stderr) => {
        if (err) {
            res.status(500).send('Error executing scripts');
            return;
        }
        res.send('Scripts executed successfully');
    });
});

app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});
