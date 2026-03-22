package com.demo.core.port;

import com.demo.core.model.User;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserRepository {
    Optional<User> findById(UUID id);
    List<User> findAll();
    List<User> findByRole(String role);
    User save(User user);
    void deleteById(UUID id);
}
