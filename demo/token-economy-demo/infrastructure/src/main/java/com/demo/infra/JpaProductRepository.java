package com.demo.infra;

import com.demo.core.model.Product;
import com.demo.core.port.ProductRepository;
import com.demo.infra.persistence.ProductEntity;
import com.demo.infra.persistence.SpringDataProductRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public class JpaProductRepository implements ProductRepository {

    private final SpringDataProductRepository jpa;

    public JpaProductRepository(SpringDataProductRepository jpa) {
        this.jpa = jpa;
    }

    @Override
    public Optional<Product> findById(UUID id) {
        return jpa.findById(id).map(this::toDomain);
    }

    @Override
    public List<Product> findAll() {
        return jpa.findAll().stream().map(this::toDomain).toList();
    }

    @Override
    public List<Product> findByCategory(String category) {
        return jpa.findByCategory(category).stream().map(this::toDomain).toList();
    }

    @Override
    public List<Product> findAvailable() {
        return jpa.findByAvailableTrue().stream().map(this::toDomain).toList();
    }

    @Override
    public Product save(Product product) {
        return toDomain(jpa.save(toEntity(product)));
    }

    @Override
    public void deleteById(UUID id) {
        jpa.deleteById(id);
    }

    private Product toDomain(ProductEntity e) {
        return new Product(e.getId(), e.getName(), e.getDescription(),
            e.getCategory(), e.getPrice(), e.getStock(), e.isAvailable());
    }

    private ProductEntity toEntity(Product p) {
        var e = new ProductEntity();
        e.setId(p.id());
        e.setName(p.name());
        e.setDescription(p.description());
        e.setCategory(p.category());
        e.setPrice(p.price());
        e.setStock(p.stock());
        e.setAvailable(p.available());
        return e;
    }
}
