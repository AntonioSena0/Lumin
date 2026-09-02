package br.com.api.repository;

import br.com.api.domain.WordDomainLevel;
import br.com.api.entity.UserWord;
import br.com.api.entity.UserWordId;
import br.com.api.repository.projection.CategoryProgressProjection;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface UserWordRepository extends JpaRepository<UserWord, UserWordId>, JpaSpecificationExecutor<UserWord> {

    @Query("SELECT uw FROM UserWord uw " +
        "JOIN FETCH uw.word w " +
        "JOIN FETCH w.category " +
        "JOIN FETCH w.fromLanguage " +
        "JOIN FETCH w.toLanguage " +
        "WHERE uw.user.id = :userId " +
        "AND uw.word.id = :wordId")
    Optional<UserWord> findByUserIdAndWordIdWithRelations(@Param("userId") Long userId, @Param("wordId") Long wordId);

    @Query(value = "SELECT " +
            "c.id AS categoryId, " +
            "c.name AS categoryName, " +
            "c.description AS categoryDescription, " +
            "COUNT(uw.word_id) AS totalWords, " +
            "COALESCE(SUM(CASE WHEN uw.is_saved = true THEN 1 ELSE 0 END), 0) AS savedWords, " +
            "COALESCE(SUM(CASE WHEN uw.last_practiced IS NOT NULL THEN 1 ELSE 0 END), 0) AS practicedWords, " +
            "COALESCE(SUM(CASE WHEN uw.incorrect_answers > 0 THEN 1 ELSE 0 END), 0) AS weakWords, " +
            "COALESCE(SUM(CASE WHEN uw.level = 'DISCOVERED' THEN 1 ELSE 0 END), 0) AS discoveredWords, " +
            "COALESCE(SUM(CASE WHEN uw.level = 'PRACTICING' THEN 1 ELSE 0 END), 0) AS practicingWords, " +
            "COALESCE(SUM(CASE WHEN uw.level = 'FAMILIAR' THEN 1 ELSE 0 END), 0) AS familiarWords, " +
            "COALESCE(SUM(uw.correct_answers), 0) AS correctAnswers, " +
            "COALESCE(SUM(uw.incorrect_answers), 0) AS incorrectAnswers, " +
            "MAX(uw.last_practiced) AS lastPracticed " +
            "FROM users_words uw " +
            "JOIN words w ON w.id = uw.word_id " +
            "JOIN categories c ON c.id = w.category_id " +
            "WHERE uw.user_id = :userId " +
            "GROUP BY c.id, c.name, c.description " +
            "ORDER BY lastPracticed DESC NULLS LAST, c.name ASC",
            nativeQuery = true)
    List<CategoryProgressProjection> findCategoryProgressByUserId(@Param("userId") Long userId);

    long countByUserIdAndIsSavedTrue(Long userId);

    long countByUserIdAndLastPracticedIsNotNull(Long userId);

    long countByUserIdAndIncorrectAnswersGreaterThan(Long userId, Long incorrectAnswers);

    long countByUserIdAndLevel(Long userId, WordDomainLevel level);

    @Query("SELECT MAX(uw.lastPracticed) FROM UserWord uw " +
            "WHERE uw.user.id = :userId")
    LocalDateTime findLastPracticedByUserId(@Param("userId") Long userId);

    @Query("SELECT uw FROM UserWord uw " +
            "JOIN FETCH uw.word w " +
            "JOIN FETCH w.category " +
            "JOIN FETCH w.fromLanguage " +
            "JOIN FETCH w.toLanguage " +
            "WHERE uw.user.id = :userId " +
            "AND uw.lastPracticed IS NOT NULL " +
            "ORDER BY uw.lastPracticed DESC")
    List<UserWord> findRecentWordsByUserId(@Param("userId") Long userId, Pageable pageable);

    @Query("SELECT uw FROM UserWord uw " +
            "JOIN FETCH uw.word w " +
            "JOIN FETCH w.category " +
            "JOIN FETCH w.fromLanguage " +
            "JOIN FETCH w.toLanguage " +
            "WHERE uw.user.id = :userId " +
            "AND uw.incorrectAnswers > 0 " +
            "ORDER BY uw.incorrectAnswers DESC, uw.lastPracticed DESC")
    List<UserWord> findWeakRecentWordsByUserId(@Param("userId") Long userId, Pageable pageable);

}
