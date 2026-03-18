<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: text/html; charset=UTF-8");
include_once 'config/database.php';

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    die("Connection failed. Check your environment variables.");
}

try {
    echo "<h1>Seeding Database...</h1>";

    // 1. Ensure a default seller exists
    $query = "SELECT id FROM users WHERE role = 'seller' LIMIT 1";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if(!$user) {
        $pass = password_hash('password123', PASSWORD_DEFAULT);
        $db->exec("INSERT INTO users (name, email, password, role) VALUES ('Demo Seller', 'seller@example.com', '$pass', 'seller')");
        $user_id = $db->lastInsertId();
        echo "<p>Created default seller account.</p>";
    } else {
        $user_id = $user['id'];
        echo "<p>Using existing seller account.</p>";
    }

    // 2. Insert Categories
    $categories = [
        ['Electronics', 'electronics'],
        ['Fashion', 'fashion'],
        ['Home & Kitchen', 'home-kitchen'],
        ['Books', 'books'],
        ['Beauty & Personal Care', 'beauty']
    ];

    foreach($categories as $cat) {
        $stmt = $db->prepare("INSERT INTO categories (name, slug) VALUES (?, ?) ON CONFLICT (slug) DO NOTHING");
        $stmt->execute($cat);
    }
    echo "<p>Categories initialized.</p>";

    // Get category mapping
    $stmt = $db->query("SELECT id, name FROM categories");
    $cat_ids = $stmt->fetchAll(PDO::FETCH_KEY_PAIR);

    // 3. Insert initial Products
    $products = [
        [$user_id, array_search('Electronics', $cat_ids), 'Wireless Noise Cancelling Headphones', 'hp-1', 'High quality sound with active noise cancellation.', 299.99, 50, 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500'],
        [$user_id, array_search('Electronics', $cat_ids), 'Smart Watch Series 7', 'sw-7', 'Stay connected and track your health goals.', 399.00, 30, 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500'],
        [$user_id, array_search('Fashion', $cat_ids), 'Classic Leather Jacket', 'lj-1', 'Premium leather jacket for a timeless look.', 199.99, 20, 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=500'],
        [$user_id, array_search('Home & Kitchen', $cat_ids), 'Modern Coffee Maker', 'cm-1', 'Brew the perfect cup every morning.', 89.00, 40, 'https://images.unsplash.com/photo-1520970014086-2208d157c9e2?w=500']
    ];

    foreach($products as $prod) {
        // Use ON CONFLICT for products as well
        $stmt = $db->prepare("INSERT INTO products (seller_id, category_id, title, slug, description, price, stock) VALUES (?, ?, ?, ?, ?, ?, ?) ON CONFLICT (slug) DO NOTHING");
        $stmt->execute([$prod[0], $prod[1], $prod[2], $prod[3], $prod[4], $prod[5], $prod[6]]);
        
        // Find the product ID (either newly inserted or existing)
        $id_stmt = $db->prepare("SELECT id FROM products WHERE slug = ?");
        $id_stmt->execute([$prod[3]]);
        $prod_id = $id_stmt->fetchColumn();

        if($prod_id) {
            // Check if image already exists
            $img_check = $db->prepare("SELECT id FROM product_images WHERE product_id = ?");
            $img_check->execute([$prod_id]);
            if (!$img_check->fetch()) {
                $stmt = $db->prepare("INSERT INTO product_images (product_id, image_url, is_primary) VALUES (?, ?, TRUE)");
                $stmt->execute([$prod_id, $prod[7]]);
            }
        }
    }

    echo "<h2>Success!</h2><p>Database seeding completed.</p>";
    echo "<p>You can now use the frontend or mobile app to browse products.</p>";

} catch(PDOException $e) {
    echo "<h3>Error:</h3><p>" . $e->getMessage() . "</p>";
}
?>