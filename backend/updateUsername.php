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
        isset($data["currentUsername"])
        && isset($data["newUsername"])
        && isset($data["password"])
    ) {

        $errors = [];

        // Sanitize inputs
        $currentUsername = testInput($data["currentUsername"]);
        $newUsername = testInput($data["newUsername"]);
        $password = testInput($data["password"]);

        if ($currentUsername != $_SESSION["AdminName"]) {
            $errors[] = "Username Error: Wrong Current Username";
        }

        $sql = "SELECT id, password FROM admins WHERE name = :username";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(":username", $currentUsername);
        $stmt->execute();

        if ($stmt->rowCount() != 1) {
            $errors[] = "Wrong password";
        } else {
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            if (!password_verify($password, $row["password"])) {
                $errors[] = "Wrong password";
            }
        }

        if (!empty($errors)) {
            echo json_encode(["message" => implode(', ', $errors), "success" => false]);
        } else {
            $stmt = $conn->prepare("UPDATE admins SET name=:newUsername WHERE name = :currentUsername");
            $stmt->bindParam(":newUsername", $newUsername, PDO::PARAM_STR);
            $stmt->bindParam(":currentUsername", $currentUsername, PDO::PARAM_STR);
            $stmt->execute();
            echo json_encode(["message" => "Your Username is updated successfully", "success" => true]);
            $_SESSION["AdminName"] = $newUsername;
        }
    }
} catch (Exception $e) {
    echo json_encode(["message" => "Error: " . $e->getMessage(), "success" => false]);
}
$conn = null;