<?php
$host = "localhost";
$username = "root";
$password = "";

try {
    $conn = new PDO("mysql:host=$host", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Create database
    $sql = "CREATE DATABASE IF NOT EXISTS fullcart_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci";
    $conn->exec($sql);
    echo "Database created successfully<br>";
    
    // Select database
    $conn->exec("USE fullcart_db");
    
    // Create Tables
    $tables = [
        "CREATE TABLE IF NOT EXISTS users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            email VARCHAR(255) NOT NULL UNIQUE,
            password VARCHAR(255) NOT NULL,
            role ENUM('customer', 'seller', 'admin') DEFAULT 'customer',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )",
        "CREATE TABLE IF NOT EXISTS categories (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            slug VARCHAR(255) NOT NULL UNIQUE,
            parent_id INT DEFAULT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
        )",
        "CREATE TABLE IF NOT EXISTS products (
            id INT AUTO_INCREMENT PRIMARY KEY,
            seller_id INT NOT NULL,
            category_id INT NOT NULL,
            title VARCHAR(255) NOT NULL,
            slug VARCHAR(255) NOT NULL UNIQUE,
            description TEXT,
            price DECIMAL(10, 2) NOT NULL,
            stock INT DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
        )",
        "CREATE TABLE IF NOT EXISTS product_images (
            id INT AUTO_INCREMENT PRIMARY KEY,
            product_id INT NOT NULL,
            image_url VARCHAR(255) NOT NULL,
            is_primary BOOLEAN DEFAULT FALSE,
            FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
        )",
        "CREATE TABLE IF NOT EXISTS cart_items (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            product_id INT NOT NULL,
            quantity INT DEFAULT 1,
            added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
        )",
        "CREATE TABLE IF NOT EXISTS orders (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            total_amount DECIMAL(10, 2) NOT NULL,
            status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
            shipping_address TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )",
        "CREATE TABLE IF NOT EXISTS order_items (
            id INT AUTO_INCREMENT PRIMARY KEY,
            order_id INT NOT NULL,
            product_id INT NOT NULL,
            quantity INT NOT NULL,
            price DECIMAL(10, 2) NOT NULL,
            FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
            FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
        )",
        "CREATE TABLE IF NOT EXISTS reviews (
            id INT AUTO_INCREMENT PRIMARY KEY,
            product_id INT NOT NULL,
            user_id INT NOT NULL,
            rating INT NOT NULL CHECK(rating >= 1 AND rating <= 5),
            comment TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )"
    ];
    
    foreach($tables as $sql) {
        $conn->exec($sql);
    }
    echo "Tables created successfully";
    
} catch(PDOException $e) {
    echo $sql . "<br>" . $e->getMessage();
}
$conn = null;
?>