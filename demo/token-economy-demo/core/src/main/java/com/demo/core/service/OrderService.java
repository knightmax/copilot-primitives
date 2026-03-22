package com.demo.core.service;

import com.demo.core.model.Order;
import com.demo.core.port.OrderRepository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public class OrderService {

    private final OrderRepository orderRepository;

    public OrderService(OrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }

    public Optional<Order> findById(UUID id) {
        return orderRepository.findById(id);
    }

    public List<Order> findAll() {
        return orderRepository.findAll();
    }

    public List<Order> findByUser(UUID userId) {
        return orderRepository.findByUserId(userId);
    }

    public List<Order> findPending() {
        return orderRepository.findByStatus("PENDING");
    }

    public Order create(Order order) {
        return orderRepository.save(order);
    }
}
