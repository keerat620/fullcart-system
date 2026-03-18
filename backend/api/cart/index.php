<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once '../../config/database.php';
include_once '../../models/Cart.php';

$database = new Database();
$db = $database->getConnection();
$cart = new Cart($db);

$method = $_SERVER['REQUEST_METHOD'];
$data = json_decode(file_get_contents("php://input"));

// Simplified Auth check for prototype
$user_id = isset($_GET['user_id']) ? $_GET['user_id'] : (isset($data->user_id) ? $data->user_id : null);

if(!$user_id) {
    http_response_code(401);
    echo json_encode(array("message" => "Unauthorized. User ID required.", "status" => "error"));
    exit;
}

$cart->user_id = $user_id;

switch($method) {
    case 'POST':
        if(!empty($data->product_id) && !empty($data->quantity)) {
            $cart->product_id = $data->product_id;
            $cart->quantity = $data->quantity;
            if($cart->addToCart()) {
                http_response_code(201);
                echo json_encode(array("message" => "Product added to cart.", "status" => "success"));
            } else {
                http_response_code(503);
                echo json_encode(array("message" => "Unable to add product to cart.", "status" => "error"));
            }
        }
        break;

    case 'GET':
        $stmt = $cart->getCartItems();
        $num = $stmt->rowCount();
        if($num > 0) {
            $cart_arr = array();
            $cart_arr["records"] = array();
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                array_push($cart_arr["records"], $row);
            }
            http_response_code(200);
            echo json_encode($cart_arr);
        } else {
            http_response_code(200);
            echo json_encode(array("message" => "Cart is empty.", "records" => []));
        }
        break;

    case 'DELETE':
        if(isset($_GET['id'])) {
            $cart->id = $_GET['id'];
            if($cart->removeFromCart()) {
                http_response_code(200);
                echo json_encode(array("message" => "Product removed from cart.", "status" => "success"));
            } else {
                http_response_code(503);
                echo json_encode(array("message" => "Unable to remove product.", "status" => "error"));
            }
        } else {
            if($cart->clearCart()) {
                http_response_code(200);
                echo json_encode(array("message" => "Cart cleared.", "status" => "success"));
            } else {
                http_response_code(503);
                echo json_encode(array("message" => "Unable to clear cart.", "status" => "error"));
            }
        }
        break;
}
?>