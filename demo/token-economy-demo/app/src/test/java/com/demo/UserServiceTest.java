package com.demo;

import com.demo.core.model.User;
import com.demo.core.port.UserRepository;
import com.demo.core.service.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class UserServiceTest {

    private UserRepository userRepository;
    private UserService userService;

    @BeforeEach
    void setUp() {
        userRepository = mock(UserRepository.class);
        userService = new UserService(userRepository);
    }

    @Test
    void findById_returnsUser() {
        var id = UUID.randomUUID();
        var user = new User(id, "jdoe", "jdoe@example.com", "John", "Doe", "USER", true, LocalDateTime.now());
        when(userRepository.findById(id)).thenReturn(Optional.of(user));

        var result = userService.findById(id);

        assertTrue(result.isPresent());
        assertEquals("jdoe", result.get().username());
    }

    @Test
    void findAdmins_returnsOnlyAdmins() {
        var admin = new User(UUID.randomUUID(), "admin1", "admin@example.com", "Admin", "One", "ADMIN", true, LocalDateTime.now());
        when(userRepository.findByRole("ADMIN")).thenReturn(List.of(admin));

        var result = userService.findAdmins();

        assertEquals(1, result.size());
        assertTrue(result.get(0).isAdmin());
    }
}
