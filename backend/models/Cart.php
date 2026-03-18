<?php
class Cart {
    private $conn;
    private $table_name = "cart_items";

    public $id;
    public $user_id;
    public $product_id;
    public $quantity;

    public function __construct($db) {
        $this->conn = $db;
    }

    public function addToCart() {
        // Check if item already in cart
        $check = "SELECT id, quantity FROM " . $this->table_name . " WHERE user_id = :user_id AND product_id = :product_id";
        $stmt_check = $this->conn->prepare($check);
        $stmt_check->bindParam(":user_id", $this->user_id);
        $stmt_check->bindParam(":product_id", $this->product_id);
        $stmt_check->execute();

        if($stmt_check->rowCount() > 0) {
            $row = $stmt_check->fetch(PDO::FETCH_ASSOC);
            $new_qty = $row['quantity'] + $this->quantity;
            $query = "UPDATE " . $this->table_name . " SET quantity = :qty WHERE id = :id";
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(":qty", $new_qty);
            $stmt->bindParam(":id", $row['id']);
        } else {
            $query = "INSERT INTO " . $this->table_name . " SET user_id=:user_id, product_id=:product_id, quantity=:quantity";
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(":user_id", $this->user_id);
            $stmt->bindParam(":product_id", $this->product_id);
            $stmt->bindParam(":quantity", $this->quantity);
        }

        return $stmt->execute();
    }

    public function getCartItems() {
        $query = "SELECT c.id, c.product_id, c.quantity, p.title, p.price, pi.image_url 
                  FROM " . $this->table_name . " c
                  JOIN products p ON c.product_id = p.id
                  LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = 1
                  WHERE c.user_id = :user_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":user_id", $this->user_id);
        $stmt->execute();
        return $stmt;
    }

    public function removeFromCart() {
        $query = "DELETE FROM " . $this->table_name . " WHERE id = :id AND user_id = :user_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":id", $this->id);
        $stmt->bindParam(":user_id", $this->user_id);
        return $stmt->execute();
    }

    public function clearCart() {
        $query = "DELETE FROM " . $this->table_name . " WHERE user_id = :user_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":user_id", $this->user_id);
        return $stmt->execute();
    }
}
?>