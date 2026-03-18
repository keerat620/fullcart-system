<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../../config/database.php';
include_once '../../models/Product.php';

$database = new Database();
$db = $database->getConnection();
$product = new Product($db);

$search = isset($_GET['search']) ? $_GET['search'] : null;
$category_id = isset($_GET['category_id']) ? $_GET['category_id'] : null;

$stmt = $product->readAll($search, $category_id);
$num = $stmt->rowCount();

if($num > 0) {
    $products_arr = array();
    $products_arr["records"] = array();

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        extract($row);
        $product_item = array(
            "id" => $id,
            "title" => $title,
            "slug" => $slug,
            "description" => $description,
            "price" => (float)$price,
            "stock" => (int)$stock,
            "image_url" => $image_url ? $image_url : "https://via.placeholder.com/200?text=No+Image"
        );
        array_push($products_arr["records"], $product_item);
    }

    http_response_code(200);
    echo json_encode($products_arr);
} else {
    http_response_code(404);
    echo json_encode(array("message" => "No products found.", "records" => []));
}
?>