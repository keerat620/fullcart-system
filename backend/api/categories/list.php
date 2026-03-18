<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

header("Content-Type: application/json; charset=UTF-8");

include_once '../../config/database.php';
include_once '../../models/Category.php';

$database = new Database();
$db = $database->getConnection();
$category = new Category($db);

$stmt = $category->readAll();
$num = $stmt->rowCount();

if($num > 0) {
    $categories_arr = array();
    $categories_arr["records"] = array();

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        extract($row);
        $category_item = array(
            "id" => $id,
            "name" => $name,
            "slug" => $slug,
            "parent_id" => $parent_id
        );
        array_push($categories_arr["records"], $category_item);
    }

    http_response_code(200);
    echo json_encode($categories_arr);
} else {
    http_response_code(404);
    echo json_encode(array("message" => "No categories found.", "status" => "error"));
}
?>