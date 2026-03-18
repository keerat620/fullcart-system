<?php
class Review {
    private $conn;
    private $table_name = "reviews";

    public $id;
    public $product_id;
    public $user_id;
    public $rating;
    public $comment;
    public $created_at;

    public function __construct($db) {
        $this->conn = $db;
    }

    public function create() {
        // Validate rating
        if ($this->rating < 1 || $this->rating > 5) {
            return false;
        }

        $query = "INSERT INTO " . $this->table_name . " (product_id, user_id, rating, comment) VALUES (:product_id, :user_id, :rating, :comment)";
        $stmt = $this->conn->prepare($query);
        
        $this->comment = htmlspecialchars(strip_tags($this->comment));
        
        $stmt->bindParam(":product_id", $this->product_id);
        $stmt->bindParam(":user_id", $this->user_id);
        $stmt->bindParam(":rating", $this->rating);
        $stmt->bindParam(":comment", $this->comment);
        
        return $stmt->execute();
    }

    public function readByProduct($product_id) {
        $query = "SELECT r.*, u.name as user_name 
                  FROM " . $this->table_name . " r 
                  JOIN users u ON r.user_id = u.id 
                  WHERE r.product_id = :product_id 
                  ORDER BY r.created_at DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":product_id", $product_id);
        $stmt->execute();
        return $stmt;
    }
}
?>