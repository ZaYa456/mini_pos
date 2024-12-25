<?php
function testInput($data)
{
    return htmlspecialchars(trim(stripslashes($data)));
}

// Read raw POST data from Flutter and decode it
$data = json_decode(file_get_contents("php://input"), true);

//Start a session to check $_SESSION['AdminName']
session_id($data["sessionId"] ?? "");
session_start();
if (!isset($_SESSION['AdminName']) || empty($_SESSION['AdminName'])) {
    echo json_encode(["message" => "Error: You are not logged in", "success" => false]);
    exit;
}
session_unset();
session_destroy();
echo json_encode(["message" => "You have successfully logged out", "success" => true]);