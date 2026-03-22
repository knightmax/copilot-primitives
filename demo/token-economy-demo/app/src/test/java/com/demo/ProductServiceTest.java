package com.demo;

import com.demo.core.model.Product;
import com.demo.core.port.ProductRepository;
import com.demo.core.service.ProductService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class ProductServiceTest {

    private ProductRepository productRepository;
    private ProductService productService;

    @BeforeEach
    void setUp() {
        productRepository = mock(ProductRepository.class);
        productService = new ProductService(productRepository);
    }

    @Test
    void findAvailable_onlyInStock() {
        var p1 = new Product(UUID.randomUUID(), "Laptop", "High-end laptop", "Electronics", new BigDecimal("1299.99"), 15, true);
        var p2 = new Product(UUID.randomUUID(), "Keyboard", "Mechanical keyboard", "Electronics", new BigDecimal("89.99"), 42, true);
        when(productRepository.findAvailable()).thenReturn(List.of(p1, p2));

        var result = productService.findAvailable();

        assertEquals(2, result.size());
        assertTrue(result.stream().allMatch(Product::isInStock));
    }

    @Test
    void findByCategory_filtersCorrectly() {
        var book = new Product(UUID.randomUUID(), "Spring in Action", "Spring Boot guide", "Books", new BigDecimal("49.99"), 100, true);
        when(productRepository.findByCategory("Books")).thenReturn(List.of(book));

        var result = productService.findByCategory("Books");

        assertEquals(1, result.size());
        assertEquals("Books", result.get(0).category());
    }
}
