package com.demo.infra;

import com.demo.core.model.User;
import com.demo.core.port.UserRepository;
import com.demo.infra.persistence.SpringDataUserRepository;
import com.demo.infra.persistence.UserEntity;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public class JpaUserRepository implements UserRepository {

    private final SpringDataUserRepository jpa;

    public JpaUserRepository(SpringDataUserRepository jpa) {
        this.jpa = jpa;
    }

    @Override
    public Optional<User> findById(UUID id) {
        return jpa.findById(id).map(this::toDomain);
    }

    @Override
    public List<User> findAll() {
        return jpa.findAll().stream().map(this::toDomain).toList();
    }

    @Override
    public List<User> findByRole(String role) {
        return jpa.findByRole(role).stream().map(this::toDomain).toList();
    }

    @Override
    public User save(User user) {
        return toDomain(jpa.save(toEntity(user)));
    }

    @Override
    public void deleteById(UUID id) {
        jpa.deleteById(id);
    }

    private User toDomain(UserEntity e) {
        return new User(e.getId(), e.getUsername(), e.getEmail(),
            e.getFirstName(), e.getLastName(), e.getRole(),
            e.isActive(), e.getCreatedAt());
    }

    private UserEntity toEntity(User u) {
        var e = new UserEntity();
        e.setId(u.id());
        e.setUsername(u.username());
        e.setEmail(u.email());
        e.setFirstName(u.firstName());
        e.setLastName(u.lastName());
        e.setRole(u.role());
        e.setActive(u.active());
        e.setCreatedAt(u.createdAt());
        return e;
    }
}
