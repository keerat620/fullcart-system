<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once '../../config/database.php';
include_once '../../models/Product.php';

$database = new Database();
$db = $database->getConnection();
$product = new Product($db);

$method = $_SERVER['REQUEST_METHOD'];
$data = json_decode(file_get_contents("php://input"));

// Auth check (Simplified)
$seller_id = isset($_GET['seller_id']) ? $_GET['seller_id'] : (isset($data->seller_id) ? $data->seller_id : null);

if(!$seller_id) {
    http_response_code(401);
    echo json_encode(array("message" => "Unauthorized. Seller ID required.", "status" => "error"));
    exit;
}

$product->seller_id = $seller_id;

switch($method) {
    case 'GET':
        if(isset($_GET['id'])) {
            $res = $product->readOne($_GET['id']);
            if($res && $res['seller_id'] == $seller_id) {
                echo json_encode($res);
            } else {
                http_response_code(404);
                echo json_encode(array("message" => "Product not found."));
            }
        } else {
            $stmt = $product->readSellerProducts($seller_id);
            $products_arr = array();
            $products_arr["records"] = array();
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                array_push($products_arr["records"], $row);
            }
            echo json_encode($products_arr);
        }
        break;

    case 'POST':
        if(!empty($data->title) && !empty($data->category_id) && !empty($data->price)) {
            $product->title = $data->title;
            $product->category_id = $data->category_id;
            $product->description = $data->description;
            $product->price = $data->price;
            $product->stock = $data->stock;
            $product->slug = strtolower(str_replace(' ', '-', $data->title)) . '-' . time();
            
            $new_id = $product->create();
            if($new_id) {
                if(!empty($data->image_url)) {
                    $product->addImage($new_id, $data->image_url, 1);
                }
                http_response_code(201);
                echo json_encode(array("message" => "Product created successfully.", "id" => $new_id));
            } else {
                http_response_code(503);
                echo json_encode(array("message" => "Unable to create product."));
            }
        }
        break;

    case 'PUT':
        if(!empty($data->id) && !empty($data->title)) {
            $product->id = $data->id;
            $product->title = $data->title;
            $product->category_id = $data->category_id;
            $product->description = $data->description;
            $product->price = $data->price;
            $product->stock = $data->stock;
            
            if($product->update()) {
                echo json_encode(array("message" => "Product updated successfully."));
            } else {
                http_response_code(503);
                echo json_encode(array("message" => "Unable to update product."));
            }
        }
        break;

    case 'DELETE':
        if(isset($_GET['id'])) {
            $product->id = $_GET['id'];
            if($product->delete()) {
                echo json_encode(array("message" => "Product deleted successfully."));
            } else {
                http_response_code(503);
                echo json_encode(array("message" => "Unable to delete product."));
            }
        }
        break;
}
?>