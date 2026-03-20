<?php
// Restrict CORS to only Netlify frontends
$allowed_origins = [
    "https://fullcart-frontend.netlify.app",
    "https://fastidious-kataifi-5fc23e.netlify.app"
];
$origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : '';
if (in_array($origin, $allowed_origins)) {
    header("Access-Control-Allow-Origin: $origin");
}
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

header("Content-Type: application/json; charset=UTF-8");

include_once '../../config/database.php';
include_once '../../models/User.php';

$database = new Database();
$db = $database->getConnection();
$user = new User($db);

$data = json_decode(file_get_contents("php://input"));

if(!empty($data->name) && !empty($data->email) && !empty($data->password)) {
    $user->name = $data->name;
    $user->email = $data->email;
    $user->password = $data->password;
    $user->role = isset($data->role) ? $data->role : 'customer';

    if($user->emailExists()) {
        http_response_code(400);
        echo json_encode(array("message" => "Email already registered.", "status" => "error"));
    } else if($user->register()) {
        http_response_code(201);
        echo json_encode(array("message" => "User was created.", "status" => "success"));
    } else {
        http_response_code(503);
        echo json_encode(array("message" => "Unable to create user.", "status" => "error"));
    }
} else {
    http_response_code(400);
    echo json_encode(array("message" => "Unable to create user. Data is incomplete.", "status" => "error"));
}
?>