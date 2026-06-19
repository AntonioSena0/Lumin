package br.com.api.repository;

import br.com.api.entity.StudySession;
import jakarta.persistence.QueryHint;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.QueryHints;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface StudySessionRepository extends JpaRepository<StudySession, Long> {

    @QueryHints(
            @QueryHint(name = "javax.persistence.query.timeout", value = "2000")
    )
    @Query("SELECT ss FROM StudySession ss " +
            "JOIN FETCH ss.user " +
            "JOIN FETCH ss.exercises " +
            "WHERE ss.id = :id")
    Optional<StudySession> findByIdWithRelations(@Param("id") Long id);

}
