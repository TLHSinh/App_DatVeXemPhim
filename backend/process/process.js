const { exec } = require('child_process');

// Chạy cả hai file JS song song
exec('node serverFetchFromAPI.js & node serverFetchFromDB.js', (err, stdout, stderr) => {
    if (err) {
        console.error('Error executing the command:', err);
        return;
    }
    console.log('Output:', stdout);
    console.error('Error Output:', stderr);
});
