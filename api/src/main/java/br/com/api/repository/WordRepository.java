package br.com.api.repository;

import br.com.api.entity.Category;
import br.com.api.entity.Word;
import jakarta.persistence.QueryHint;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.QueryHints;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface WordRepository extends JpaRepository<Word, Long> {

    @Query("SELECT w FROM Word w " +
            "JOIN FETCH w.fromLanguage " +
            "JOIN FETCH w.toLanguage " +
            "JOIN FETCH w.category")
    List<Word> findAllWithRelations();

    @QueryHints(
            @QueryHint(name = "javax.persistence.query.timeout", value = "2000")
    )
    @Query("SELECT w FROM Word w " +
            "JOIN FETCH w.fromLanguage " +
            "JOIN FETCH w.toLanguage " +
            "JOIN FETCH w.category " +
            "WHERE w.id = :id")
    Optional<Word> findByIdWithRelations(@Param("id") Long id);

    @QueryHints(
            @QueryHint(name = "javax.persistence.query.timeout", value = "2000")
    )
    @Query("SELECT w FROM Word w " +
            "JOIN FETCH w.fromLanguage " +
            "JOIN FETCH w.toLanguage " +
            "JOIN FETCH w.category " +
            "WHERE w.original = :original AND w.translated = :translated AND w.category = :category")
    Optional<Word> findByOriginalAndTranslatedAndCategory(@Param("original") String original, @Param("translated") String translated, @Param("category") Category category);

    @QueryHints(
            @QueryHint(name = "javax.persistence.query.timeout", value = "2000")
    )
    @Query("SELECT w FROM Word w " +
            "JOIN FETCH w.fromLanguage " +
            "JOIN FETCH w.toLanguage " +
            "JOIN FETCH w.category " +
            "WHERE LOWER(w.original) LIKE LOWER(CONCAT('%', :q, '%')) " +
            "AND w.fromLanguage.id = :languageId")
    List<Word> findByOriginalContains(@Param("q") String q, @Param("languageId") Integer languageId);

    List<Word> findTop10ByCategoryIdAndToLanguageIdAndIdNot(Integer categoryId, Integer toLanguageId, Long id);

}