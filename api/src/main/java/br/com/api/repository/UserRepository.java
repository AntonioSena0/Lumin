package br.com.api.repository;

import br.com.api.entity.User;
import jakarta.persistence.QueryHint;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.QueryHints;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    @Query(value = "SELECT u FROM User u " +
            "JOIN FETCH u.nativeLanguage " +
            "JOIN FETCH u.chosenLanguage " +
            "JOIN FETCH u.avatar",
            countQuery = "SELECT COUNT(u) FROM User u")
    Page<User> findAllWithRelations(Pageable pageable);

    @QueryHints(
            @QueryHint(name = "javax.persistence.query.timeout", value = "2000")
    )
    @Query(value = "SELECT u FROM User u " +
            "JOIN FETCH u.nativeLanguage " +
            "JOIN FETCH u.chosenLanguage " +
            "JOIN FETCH u.avatar " +
            "WHERE u.id = :id",
            countQuery = "SELECT COUNT(u) FROM User u " +
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

    Optional<User> findByPendingEmail(String pendingEmail);

    @QueryHints(
            @QueryHint(name = "javax.persistence.query.timeout", value = "2000")
    )
    boolean existsByNameAndIdNot(String name, Long id);

    @QueryHints(
            @QueryHint(name = "javax.persistence.query.timeout", value = "2000")
    )
    boolean existsByEmailAndIdNot(String email, Long id);

    /** Pesquisa usuários pelo nome sem diferenciar maiúsculas de minúsculas. */
    @Query(value = "SELECT u FROM User u " +
            "JOIN FETCH u.nativeLanguage " +
            "JOIN FETCH u.chosenLanguage " +
            "JOIN FETCH u.avatar " +
            "WHERE LOWER(u.name) LIKE LOWER(CONCAT('%', :q, '%'))",
            countQuery = "SELECT COUNT(u) FROM User u WHERE LOWER(u.name) LIKE LOWER(CONCAT('%', :q, '%'))")
    Page<User> searchByName(@Param("q") String q, Pageable pageable);

    /** Lista os usuários que seguem o usuário informado. */
    @Query(value = "SELECT u FROM User u " +
            "JOIN FETCH u.nativeLanguage " +
            "JOIN FETCH u.chosenLanguage " +
            "JOIN FETCH u.avatar " +
            "WHERE u.id IN (SELECT f.id.followerId FROM Follow f WHERE f.id.followedId = :userId)",
            countQuery = "SELECT COUNT(f) FROM Follow f WHERE f.id.followedId = :userId")
    Page<User> findFollowersOf(@Param("userId") Long userId, Pageable pageable);

    /** Lista os usuários seguidos pelo usuário informado. */
    @Query(value = "SELECT u FROM User u " +
            "JOIN FETCH u.nativeLanguage " +
            "JOIN FETCH u.chosenLanguage " +
            "JOIN FETCH u.avatar " +
            "WHERE u.id IN (SELECT f.id.followedId FROM Follow f WHERE f.id.followerId = :userId)",
            countQuery = "SELECT COUNT(f) FROM Follow f WHERE f.id.followerId = :userId")
    Page<User> findFollowedBy(@Param("userId") Long userId, Pageable pageable);

}
