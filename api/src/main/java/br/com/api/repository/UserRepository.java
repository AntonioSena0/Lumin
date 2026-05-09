package br.com.api.repository;

import br.com.api.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByName(String name);

    Optional<User> findByEmail(String email);

    boolean existsByNameAndIdNot(String name, Long id);

    boolean existsByEmailAndIdNot(String email, Long id);

}
