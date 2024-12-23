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
        isset($data["name"])
        && isset($data["price"])
        && isset($data["barcode"])
        && isset($data["categoryID"])
    ) {
        $errors = [];

        // Sanitize inputs
        $name = testInput($data["name"]);
        $price = testInput($data["price"]);
        $barcode = testInput($data["barcode"]);
        $categoryID = testInput($data["categoryID"]);

        // Validate category ID as numeric
        if (!preg_match("/^\d+$/", $categoryID)) {
            $errors[] = "Wrong category ID";
        }

        // If there are validation errors, send them back to Flutter
        if (!empty($errors)) {
            echo json_encode(["message" => implode(', ', $errors), "success" => false]);
        } else {
            // Insert the product into the database
            $stmt = $conn->prepare("INSERT INTO products (name, price, barcode, category_id) VALUES (:name, :price, :barcode, :categoryID)");
            $stmt->bindParam(":name", $name);
            $stmt->bindParam(":price", $price);
            $stmt->bindParam(":barcode", $barcode);
            $stmt->bindParam(":categoryID", $categoryID);
            $stmt->execute();

            // Return success response
            echo json_encode(["message" => "The new product is created successfully", "success" => true]);
        }
    } else {
        // Handle missing fields
        echo json_encode(["message" => "All fields are required", "success" => false]);
    }
} catch (Exception $e) {
    echo json_encode(["message" => "Error: " . $e->getMessage(), "success" => false]);
    exit();
}

$conn = null;
