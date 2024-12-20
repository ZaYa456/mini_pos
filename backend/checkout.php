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
        isset($data["products"])
        && !empty($data["products"])
    ) {

        // Calculate the total amount
        $totalAmount = 0;
        foreach ($data["products"] as $product) {
            $totalAmount += $product['price'] * ($product['quantity'] ?? 1);
        }

        // Generate a random sale ID between 1 and 1000000
        $saleId = random_int(1, 1000000);

        // Begin transaction
        $conn->beginTransaction();

        // Insert into the sales table
        $stmt = $conn->prepare("INSERT INTO sales (id, total_amount) VALUES (:id, :total_amount)");
        $stmt->bindParam(':id', $saleId, PDO::PARAM_INT);
        $stmt->bindParam(':total_amount', $totalAmount);
        $stmt->execute();

        // Insert into the sales_items table
        $stmt = $conn->prepare("
        INSERT INTO sales_items (sale_id, product_id, quantity, price)
        VALUES (:sale_id, :product_id, :quantity, :price)
    ");

        foreach ($data["products"] as $product) {
            $quantity = $product['quantity'] ?? 1;
            $stmt->bindParam(':sale_id', $saleId, PDO::PARAM_INT);
            $stmt->bindParam(':product_id', $product['id'], PDO::PARAM_INT);
            $stmt->bindParam(':quantity', $quantity, PDO::PARAM_INT);
            $stmt->bindParam(':price', $product['price']);
            $stmt->execute();
        }

        // Commit the transaction
        $conn->commit();

        // Return success response
        echo json_encode(["message" => "Checkout Successful", "success" => true]);
    } else {
        echo json_encode(["message" => "Error", "success" => false]);
    }
} catch (Exception $e) {
    // Rollback on error
    if ($conn->inTransaction()) {
        $conn->rollBack();
    }
    echo json_encode(["message" => "Error: " . $e->getMessage(), "success" => false]);
    exit();
}

$conn = null;
