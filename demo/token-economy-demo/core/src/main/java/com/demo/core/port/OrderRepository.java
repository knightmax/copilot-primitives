package com.demo.core.port;

import com.demo.core.model.Order;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface OrderRepository {
    Optional<Order> findById(UUID id);
    List<Order> findAll();
    List<Order> findByUserId(UUID userId);
    List<Order> findByStatus(String status);
    Order save(Order order);
}
