<?php
class Order {
    private $conn;
    private $table_orders = "orders";
    private $table_items = "order_items";

    public $id;
    public $user_id;
    public $total_amount;
    public $status;
    public $shipping_address;
    public $created_at;

    public function __construct($db) {
        $this->conn = $db;
    }

    public function create() {
        try {
            $this->conn->beginTransaction();

            $query = "INSERT INTO " . $this->table_orders . " (user_id, total_amount, shipping_address) VALUES (:user_id, :total_amount, :shipping_address)";
            $stmt = $this->conn->prepare($query);

            $stmt->bindParam(":user_id", $this->user_id);
            $stmt->bindParam(":total_amount", $this->total_amount);
            $stmt->bindParam(":shipping_address", $this->shipping_address);

            $stmt->execute();
            $order_id = $this->conn->lastInsertId();

            foreach($this->items as $item) {
                $query_item = "INSERT INTO " . $this->table_items . " (order_id, product_id, quantity, price) VALUES (:order_id, :product_id, :quantity, :price)";
                $stmt_item = $this->conn->prepare($query_item);
                $stmt_item->bindParam(":order_id", $order_id);
                $stmt_item->bindParam(":product_id", $item['product_id']);
                $stmt_item->bindParam(":quantity", $item['quantity']);
                $stmt_item->bindParam(":price", $item['price']);
                $stmt_item->execute();
            }
                
                // 3. Update Product Stock
                $query_stock = "UPDATE products SET stock = stock - :qty WHERE id = :pid";
                $stmt_stock = $this->conn->prepare($query_stock);
                $stmt_stock->bindParam(":qty", $item['quantity']);
                $stmt_stock->bindParam(":pid", $item['product_id']);
                $stmt_stock->execute();
            }

            $this->conn->commit();
            return true;
        } catch (Exception $e) {
            $this->conn->rollBack();
            return false;
        }
    }

    public function readUserOrders() {
        $query = "SELECT * FROM " . $this->table_orders . " WHERE user_id = :user_id ORDER BY created_at DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":user_id", $this->user_id);
        $stmt->execute();
        return $stmt;
    }

    public function readOrderDetails($order_id) {
        $query = "SELECT oi.*, p.title, pi.image_url 
                  FROM " . $this->table_items . " oi
                  JOIN products p ON oi.product_id = p.id
                  LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = 1
                  WHERE oi.order_id = :order_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":order_id", $order_id);
        $stmt->execute();
        return $stmt;
    }
}
?>