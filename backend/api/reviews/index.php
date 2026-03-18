<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once '../../config/database.php';
include_once '../../models/Review.php';

$database = new Database();
$db = $database->getConnection();
$review = new Review($db);

$method = $_SERVER['REQUEST_METHOD'];
$data = json_decode(file_get_contents("php://input"));

switch($method) {
    case 'POST':
        if(!empty($data->product_id) && !empty($data->user_id) && !empty($data->rating)) {
            $review->product_id = $data->product_id;
            $review->user_id = $data->user_id;
            $review->rating = $data->rating;
            $review->comment = isset($data->comment) ? $data->comment : "";

            if($review->create()) {
                http_response_code(201);
                echo json_encode(array("message" => "Review submitted successfully."));
            } else {
                http_response_code(503);
                echo json_encode(array("message" => "Unable to submit review."));
            }
        }
        break;

    case 'GET':
        if(isset($_GET['product_id'])) {
            $stmt = $review->readByProduct($_GET['product_id']);
            $reviews_arr = array();
            $reviews_arr["records"] = array();
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                array_push($reviews_arr["records"], $row);
            }
            echo json_encode($reviews_arr);
        }
        break;
}
?>