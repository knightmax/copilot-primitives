package com.demo.core.port;

import com.demo.core.model.Product;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ProductRepository {
    Optional<Product> findById(UUID id);
    List<Product> findAll();
    List<Product> findByCategory(String category);
    List<Product> findAvailable();
    Product save(Product product);
    void deleteById(UUID id);
}
