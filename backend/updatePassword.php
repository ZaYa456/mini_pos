<?php
try {
    require_once "connection.php";
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

    // Check if we have all the required fields
    if (
        isset($data["username"])
        && isset($data["currentPassword"])
        && isset($data["newPassword"])
    ) {

        $errors = [];

        // Sanitize inputs
        $username = testInput($data["username"]);
        $currentPassword = testInput($data["currentPassword"]);
        $newPassword = password_hash(testInput($data["newPassword"]), PASSWORD_DEFAULT);

        if ($username != $_SESSION["AdminName"]) {
            $errors[] = "Username Error: Wrong Username";
        }

        $sql = "SELECT id, password FROM admins WHERE name = :username";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(":username", $username);
        $stmt->execute();

        if ($stmt->rowCount() != 1) {
            $errors[] = "Wrong current password";
        } else {
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            if (!password_verify($currentPassword, $row["password"])) {
                $errors[] = "Wrong current password";
            }
        }

        if (!empty($errors)) {
            echo json_encode(["message" => implode(', ', $errors), "success" => false]);
        } else {
            $stmt = $conn->prepare("UPDATE admins SET password=:newPassword WHERE name =:username");
            $stmt->bindParam(':newPassword', $newPassword, PDO::PARAM_STR);
            $stmt->bindParam(':username', $_SESSION["AdminName"], PDO::PARAM_STR);
            $stmt->execute();
            echo json_encode(["message" => "Your Password is updated successfully", "success" => true]);
        }
    }
} catch (Exception $e) {
    echo json_encode(["message" => "Error: " . $e->getMessage(), "success" => false]);
}
$conn = null;