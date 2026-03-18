<?php
class Product {
    private $conn;
    private $table_name = "products";

    public $id;
    public $seller_id;
    public $category_id;
    public $title;
    public $slug;
    public $description;
    public $price;
    public $stock;
    public $image_url;

    public function __construct($db) {
        $this->conn = $db;
    }

    public function readAll($search = null, $category_id = null) {
        $query = "SELECT p.*, pi.image_url 
                  FROM " . $this->table_name . " p 
                  LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = 1";
        
        $conditions = [];
        if($search) {
            $conditions[] = " (p.title LIKE :search OR p.description LIKE :search) ";
        }
        if($category_id) {
            $conditions[] = " p.category_id = :category_id ";
        }

        if(!empty($conditions)) {
            $query .= " WHERE " . implode(" AND ", $conditions);
        }

        $query .= " ORDER BY p.created_at DESC";
        $stmt = $this->conn->prepare($query);

        if($search) {
            $search_term = "%$search%";
            $stmt->bindParam(":search", $search_term);
        }
        if($category_id) {
            $stmt->bindParam(":category_id", $category_id);
        }

        $stmt->execute();
        return $stmt;
    }

    public function readOne($id) {
        $query = "SELECT p.*, pi.image_url 
                  FROM " . $this->table_name . " p 
                  LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = 1
                  WHERE p.id = ? LIMIT 0,1";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $id);
        $stmt->execute();
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function readSellerProducts($seller_id) {
        $query = "SELECT p.*, pi.image_url 
                  FROM " . $this->table_name . " p 
                  LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = 1
                  WHERE p.seller_id = :seller_id
                  ORDER BY p.created_at DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":seller_id", $seller_id);
        $stmt->execute();
        return $stmt;
    }

    public function create() {
        $query = "INSERT INTO " . $this->table_name . " SET seller_id=:seller_id, category_id=:category_id, title=:title, slug=:slug, description=:description, price=:price, stock=:stock";
        $stmt = $this->conn->prepare($query);

        $this->title = htmlspecialchars(strip_tags($this->title));
        $this->slug = htmlspecialchars(strip_tags($this->slug));
        $this->description = htmlspecialchars(strip_tags($this->description));

        $stmt->bindParam(":seller_id", $this->seller_id);
        $stmt->bindParam(":category_id", $this->category_id);
        $stmt->bindParam(":title", $this->title);
        $stmt->bindParam(":slug", $this->slug);
        $stmt->bindParam(":description", $this->description);
        $stmt->bindParam(":price", $this->price);
        $stmt->bindParam(":stock", $this->stock);

        if($stmt->execute()) {
            return $this->conn->lastInsertId();
        }
        return false;
    }

    public function update() {
        $query = "UPDATE " . $this->table_name . " SET category_id=:category_id, title=:title, description=:description, price=:price, stock=:stock WHERE id=:id AND seller_id=:seller_id";
        $stmt = $this->conn->prepare($query);

        $this->title = htmlspecialchars(strip_tags($this->title));
        $this->description = htmlspecialchars(strip_tags($this->description));

        $stmt->bindParam(":id", $this->id);
        $stmt->bindParam(":seller_id", $this->seller_id);
        $stmt->bindParam(":category_id", $this->category_id);
        $stmt->bindParam(":title", $this->title);
        $stmt->bindParam(":description", $this->description);
        $stmt->bindParam(":price", $this->price);
        $stmt->bindParam(":stock", $this->stock);

        return $stmt->execute();
    }

    public function delete() {
        $query = "DELETE FROM " . $this->table_name . " WHERE id=:id AND seller_id=:seller_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":id", $this->id);
        $stmt->bindParam(":seller_id", $this->seller_id);
        return $stmt->execute();
    }

    public function addImage($product_id, $image_url, $is_primary = 0) {
        $query = "INSERT INTO product_images SET product_id=:product_id, image_url=:image_url, is_primary=:is_primary";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":product_id", $product_id);
        $stmt->bindParam(":image_url", $image_url);
        $stmt->bindParam(":is_primary", $is_primary);
        return $stmt->execute();
    }
}
?>