package com.demo.core.service;

import com.demo.core.model.Product;
import com.demo.core.port.ProductRepository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public class ProductService {

    private final ProductRepository productRepository;

    public ProductService(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    public Optional<Product> findById(UUID id) {
        return productRepository.findById(id);
    }

    public List<Product> findAll() {
        return productRepository.findAll();
    }

    public List<Product> findAvailable() {
        return productRepository.findAvailable();
    }

    public List<Product> findByCategory(String category) {
        return productRepository.findByCategory(category);
    }

    public Product create(Product product) {
        return productRepository.save(product);
    }
}
