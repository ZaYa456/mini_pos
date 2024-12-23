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

    $errors = [];
    if (isset($data["datetime"]) && isset($data["sort"])) {

        // Sanitize inputs
        $datetime = testInput($data["datetime"]);
        $sort = testInput($data["sort"]);

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
            $stmt = $conn->prepare("SELECT id, total_amount, date FROM sales WHERE DATE(date)" . ((!empty($datetime)) ? "=" : "!=") . "DATE(:datetime) ORDER BY " . (($sort == "datetime") ? "date" : "total_amount"));
            $stmt->bindParam("datetime", $datetime);
            $stmt->execute();
            $sales = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode(["sales" => $sales, "success" => true]);
        }
    } else if (isset($data["saleID"])) {

        // Validate Sale ID as numeric
        if (!preg_match("/^\d+$/", $data["saleID"])) {
            $errors[] = "Wrong Sale ID";
        }

        if (!empty($errors)) {
            echo json_encode(["message" => implode(', ', $errors), "success" => false]);
        } else {
            // Get the sale details
            $stmt = $conn->prepare("SELECT sales_items.product_id, sales_items.quantity, sales_items.price, products.name AS product_name FROM sales_items INNER JOIN products ON sales_items.product_id = products.id WHERE sales_items.sale_id = :saleID");
            $stmt->bindParam("saleID", $data["saleID"]);
            $stmt->execute();
            $sale = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode(["sale" => $sale, "success" => true]);
        }
    }
} catch (Exception $e) {
    echo json_encode(["message" => "Error: " . $e->getMessage(), "success" => false]);
}
$conn = null;