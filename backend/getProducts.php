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
    
    if (isset($data["search"]) && isset($data["categoryID"]) && isset($data["sort"])) {

        $errors = [];
        // Sanitize inputs
        $search = "%" . testInput($data["search"]) . "%";
        $categoryID = testInput($data["categoryID"]);
        $sort = testInput($data["sort"]);

        // Validate category ID as numeric
        if (!preg_match("/^\d+$/", $categoryID)) {
            $errors[] = "Wrong category ID";
        }

        // Note:
        // If you have more than 2 sorting options uncomment the following statements and change the ternary operation in the query to string interpolation: $sort
        // Define allowed sorting columns to prevent SQL injection
        // $allowedSortFields = ["products_name", "price"];
        // if (!in_array($sort, $allowedSortFields)) {
        //     $sort = "products_name"; // default to "products_name" if an invalid sort is provided
        // }

        if (!empty($errors)) {
            echo json_encode(["message" => implode(', ', $errors), "success" => false]);
        } else {
            // NOTE: You can"t use parameter binding with ORDER BY in the sql query
            $stmt = $conn->prepare("SELECT products.id, products.name AS products_name, products.price, products.barcode, categories.name AS category_name FROM products INNER JOIN categories ON products.category_id=categories.id WHERE products.name LIKE :search AND products.category_id" . (($categoryID == 0) ? "!=" : "=") . ":categoryID ORDER BY " . (($sort == "products_name") ? "products_name" : "price"));
            $stmt->bindParam("search", $search);
            $stmt->bindParam("categoryID", $categoryID);
            $stmt->execute();
            $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode(["products" => $products, "success" => true]);
        }
    } elseif (isset($data["barcode"])) {
        // Sanitize inputs
        $barcode = testInput($data["barcode"]);

        $stmt = $conn->prepare("SELECT products.id, products.name AS products_name, products.price, products.barcode, categories.name AS category_name FROM products INNER JOIN categories ON products.category_id=categories.id WHERE products.barcode=:barcode");
        $stmt->bindParam("barcode", $barcode);
        $stmt->execute();
        if ($product = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $product["quantity"] = 1;
            echo json_encode(['product' => $product, 'success' => true]);
        } else {
            echo json_encode(['message' => 'Product not found', 'success' => false]);
        }
    } else {
        $stmt = $conn->prepare("SELECT products.id, products.name AS products_name, products.price, products.barcode, categories.name AS category_name FROM products INNER JOIN categories ON products.category_id=categories.id");
        $stmt->execute();
        $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode(["products" => $products, "success" => true]);
    }
} catch (Exception $e) {
    echo json_encode(["message" => "Error: " . $e->getMessage(), "success" => false]);
}
$conn = null;