<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: text/html; charset=UTF-8");
?>
<!DOCTYPE html>
<html>
<head>
    <title>Fullcart Backend Status</title>
    <style>
        body { font-family: sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background: #f0f2f5; }
        .card { background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); text-align: center; }
        h1 { color: #232f3e; }
        .status { color: #28a745; font-weight: bold; margin-bottom: 1.5rem; }
        .btn { display: inline-block; background: #febd69; color: #111; padding: 10px 20px; text-decoration: none; border-radius: 4px; font-weight: bold; }
        .btn:hover { background: #f3a847; }
    </style>
</head>
<body>
    <div class="card">
        <h1>Fullcart API</h1>
        <p class="status">System is Operational</p>
        <p>The backend services are running correctly on Render.</p>
        <div style="margin-top: 2rem;">
            <a href="setup.php" class="btn">Configure Database Tables</a>
        </div>
    </div>
</body>
</html>
