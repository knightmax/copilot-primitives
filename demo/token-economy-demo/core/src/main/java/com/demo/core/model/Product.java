package com.demo.core.model;

import java.math.BigDecimal;
import java.util.UUID;

public record Product(
    UUID id,
    String name,
    String description,
    String category,
    BigDecimal price,
    int stock,
    boolean available
) {
    public boolean isInStock() {
        return stock > 0 && available;
    }

    public BigDecimal discountedPrice(int percentOff) {
        var multiplier = BigDecimal.valueOf(100 - percentOff).divide(BigDecimal.valueOf(100));
        return price.multiply(multiplier);
    }
}
