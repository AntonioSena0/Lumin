package br.com.api.repository;

import br.com.api.entity.User;
import jakarta.persistence.QueryHint;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.QueryHints;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    @Query("SELECT u FROM User u " +
            "JOIN FETCH u.nativeLanguage " +
            "JOIN FETCH u.chosenLanguage ")
    List<User> findAllWithRelations();

    @QueryHints(
            @QueryHint(name = "javax.persistence.query.timeout", value = "2000")
    )
    @Query("SELECT u FROM User u " +
            "JOIN FETCH u.nativeLanguage " +
            "JOIN FETCH u.chosenLanguage " +
            "WHERE u.id = :id")
    Optional<User> findByIdWithRelations(@Param("id") Long id);

    @QueryHints(
            @QueryHint(name = "javax.persistence.query.timeout", value = "2000")
    )
    Optional<User> findByName(String name);

    @QueryHints(
            @QueryHint(name = "javax.persistence.query.timeout", value = "2000")
    )
    Optional<User> findByEmail(String email);

    @QueryHints(
            @QueryHint(name = "javax.persistence.query.timeout", value = "2000")
    )
    boolean existsByNameAndIdNot(String name, Long id);

    @QueryHints(
            @QueryHint(name = "javax.persistence.query.timeout", value = "2000")
    )
    boolean existsByEmailAndIdNot(String email, Long id);

}
