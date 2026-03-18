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
include_once '../../models/Order.php';
include_once '../../models/Cart.php';

$database = new Database();
$db = $database->getConnection();
$order = new Order($db);
$cart = new Cart($db);

$method = $_SERVER['REQUEST_METHOD'];
$data = json_decode(file_get_contents("php://input"));
$user_id = isset($_GET['user_id']) ? $_GET['user_id'] : (isset($data->user_id) ? $data->user_id : null);

if(!$user_id) {
    http_response_code(401);
    echo json_encode(array("message" => "Unauthorized.", "status" => "error"));
    exit;
}

switch($method) {
    case 'POST':
        if(!empty($data->shipping_address)) {
            $cart->user_id = $user_id;
            $cart_stmt = $cart->getCartItems();
            $cart_items = $cart_stmt->fetchAll(PDO::FETCH_ASSOC);

            if(empty($cart_items)) {
                http_response_code(400);
                echo json_encode(array("message" => "Cart is empty.", "status" => "error"));
                exit;
            }

            $total = 0;
            foreach($cart_items as $item) $total += ($item['price'] * $item['quantity']);

            $order->user_id = $user_id;
            $order->total_amount = $total;
            $order->shipping_address = $data->shipping_address;

            if($order->create($cart_items)) {
                $cart->clearCart(); // Success! Empty the cart
                http_response_code(201);
                echo json_encode(array("message" => "Order placed successfully.", "status" => "success", "order_id" => $order->id));
            } else {
                http_response_code(503);
                echo json_encode(array("message" => "Unable to place order. Try again."));
            }
        }
        break;

    case 'GET':
        $order->user_id = $user_id;
        $stmt = $order->readUserOrders();
        $orders_arr = array();
        $orders_arr["records"] = array();
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            // Get sub-items for each order
            $items_stmt = $order->readOrderDetails($row['id']);
            $row['items'] = $items_stmt->fetchAll(PDO::FETCH_ASSOC);
            array_push($orders_arr["records"], $row);
        }
        echo json_encode($orders_arr);
        break;
}
?>