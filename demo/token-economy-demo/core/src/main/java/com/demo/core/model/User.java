package com.demo.core.model;

import java.time.LocalDateTime;
import java.util.UUID;

public record User(
    UUID id,
    String username,
    String email,
    String firstName,
    String lastName,
    String role,
    boolean active,
    LocalDateTime createdAt
) {
    public String fullName() {
        return firstName + " " + lastName;
    }

    public boolean isAdmin() {
        return "ADMIN".equals(role);
    }
}
