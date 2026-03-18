<?php
class Database {
    private $host;
    private $db_name;
    private $username;
    private $password;
    public $conn;

    public function __construct() {
        // Use environment variables for production, fallback to local defaults
        $this->host = getenv('DB_HOST') ?: "localhost";
        $this->db_name = getenv('DB_NAME') ?: "fullcart_db";
        $this->username = getenv('DB_USER') ?: "root";
        $this->password = getenv('DB_PASS') ?: "";
    }

    public function getConnection() {
        $this->conn = null;
        try {
            // Support both MySQL (local) and PostgreSQL (Render)
            $dsn = "pgsql:host=" . $this->host . ";port=5432;dbname=" . $this->db_name;
            if (strpos($this->host, 'localhost') !== false || strpos($this->host, '127.0.0.1') !== false) {
                 $dsn = "mysql:host=" . $this->host . ";dbname=" . $this->db_name;
            }
            $this->conn = new PDO($dsn, $this->username, $this->password);
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            if (strpos($dsn, 'mysql') !== false) {
                $this->conn->exec("set names utf8");
            }
        } catch(PDOException $exception) {
            // Log error instead of echoing in production
            error_log("Connection error: " . $exception->getMessage());
        }
        return $this->conn;
    }
}
?>