<?php
try {
    require_once "connection.php";

    session_start();

    function testInput($data)
    {
        return htmlspecialchars(trim(stripslashes($data)));
    }


    function checkLogin($conn, $username, $password)
    {
        $sql = "SELECT id, password FROM admins WHERE name = :username";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(":username", $username);
        $stmt->execute();

        if ($stmt->rowCount() == 1) {
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            if (password_verify($password, $row["password"])) {
                session_regenerate_id(true); // Regenerate session ID for security
                $_SESSION["AdminName"] = $username;
                echo json_encode(["sessionId" => session_id(), "message" => "Login successful!", "success" => true]);
                exit;
            }
        }
    }

    // Read raw POST data from Flutter and decode it
    $data = json_decode(file_get_contents("php://input"), true);

    if (
        isset($data["username"]) && isset($data["password"])
    ) {
        // Get username and password from the form
        $username = testInput($data["username"]);
        $password = testInput($data["password"]);

        checkLogin($conn, $username, $password);

        echo json_encode(["message" => "Invalid username or password!", "success" => false]);
    }
} catch (Exception $e) {
    echo json_encode(["message" => "Error: " . $e->getMessage(), "success" => false]);
}
$conn = null;