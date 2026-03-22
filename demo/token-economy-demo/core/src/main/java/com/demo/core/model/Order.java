package com.demo.core.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public record Order(
    UUID id,
    UUID userId,
    List<OrderLine> lines,
    String status,
    LocalDateTime createdAt
) {
    public record OrderLine(UUID productId, int quantity, BigDecimal unitPrice) {
        public BigDecimal lineTotal() {
            return unitPrice.multiply(BigDecimal.valueOf(quantity));
        }
    }

    public BigDecimal total() {
        return lines.stream()
            .map(OrderLine::lineTotal)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    public boolean isPending() {
        return "PENDING".equals(status);
    }
}
