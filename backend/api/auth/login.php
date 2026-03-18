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
include_once '../../models/User.php';

$database = new Database();
$db = $database->getConnection();
$user = new User($db);

$data = json_decode(file_get_contents("php://input"));

if(!empty($data->email) && !empty($data->password)) {
    $user->email = $data->email;
    $user->password = $data->password;

    if($user->login()) {
        // Generating a dummy token for now since no JWT lib is installed.
        // In a real app, use JWT.
        $token = base64_encode(json_encode(array("id" => $user->id, "exp" => time() + 3600)));
        
        http_response_code(200);
        echo json_encode(array(
            "message" => "Login successful.",
            "status" => "success",
            "token" => $token,
            "user" => array(
                "id" => $user->id,
                "name" => $user->name,
                "email" => $user->email,
                "role" => $user->role
            )
        ));
    } else {
        http_response_code(401);
        echo json_encode(array("message" => "Login failed. Invalid email or password.", "status" => "error"));
    }
} else {
    http_response_code(400);
    echo json_encode(array("message" => "Unable to login. Data is incomplete.", "status" => "error"));
}
?>