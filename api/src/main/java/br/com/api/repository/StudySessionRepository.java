package br.com.api.repository;

import br.com.api.entity.StudySession;
import br.com.api.repository.projection.SessionWordProjection;
import jakarta.persistence.QueryHint;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.QueryHints;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

@Repository
public interface StudySessionRepository extends JpaRepository<StudySession, Long> {

    @QueryHints(
            @QueryHint(name = "javax.persistence.query.timeout", value = "2000")
    )
    @Query("SELECT DISTINCT ss FROM StudySession ss " +
            "JOIN FETCH ss.user u " +
            "JOIN FETCH u.nativeLanguage " +
            "JOIN FETCH u.chosenLanguage " +
            "JOIN FETCH u.avatar " +
            "JOIN FETCH ss.exercises e " +
            "JOIN FETCH e.language " +
            "JOIN FETCH e.word w " +
            "JOIN FETCH w.category " +
            "JOIN FETCH w.fromLanguage " +
            "JOIN FETCH w.toLanguage " +
            "WHERE ss.id = :id")
    Optional<StudySession> findByIdWithRelations(@Param("id") Long id);

    Page<StudySession> findByUserId(@Param("userId") Long userId, Pageable pageable);

    @QueryHints(
            @QueryHint(name = "javax.persistence.query.timeout", value = "2000")
    )
    @Query(value = "SELECT " +
            "e.session_id AS sessionId, " +
            "w.id AS wordId, " +
            "w.original AS wordOriginal, " +
            "w.translated AS wordTranslated, " +
            "l.name AS languageName, " +
            "l.code AS languageCode " +
            "FROM exercises e " +
            "JOIN words w ON w.id = e.word_id " +
            "JOIN languages l ON l.id = w.to_language_id " +
            "WHERE e.session_id IN :sessionIds " +
            "GROUP BY e.session_id, w.id, w.original, w.translated, l.name, l.code " +
            "ORDER BY e.session_id ASC",
            nativeQuery = true)
    List<SessionWordProjection> findWordsBySessionIds(@Param("sessionIds") Collection<Long> sessionIds);

}
