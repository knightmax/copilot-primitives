package com.demo.config;

import com.demo.core.port.OrderRepository;
import com.demo.core.port.ProductRepository;
import com.demo.core.port.UserRepository;
import com.demo.core.service.OrderService;
import com.demo.core.service.ProductService;
import com.demo.core.service.UserService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class DomainConfiguration {

    @Bean
    public UserService userService(UserRepository userRepository) {
        return new UserService(userRepository);
    }

    @Bean
    public ProductService productService(ProductRepository productRepository) {
        return new ProductService(productRepository);
    }

    @Bean
    public OrderService orderService(OrderRepository orderRepository) {
        return new OrderService(orderRepository);
    }
}
