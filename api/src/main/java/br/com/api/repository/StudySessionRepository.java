package br.com.api.repository;

import br.com.api.entity.StudySession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface StudySessionRepository extends JpaRepository<StudySession, Long> {

    @Query("SELECT ss FROM StudySession ss " +
            "JOIN FETCH ss.exercises " +
            "WHERE ss.id = :id")
    Optional<StudySession> findByIdWithExercises(@Param("id") Long id);

}
