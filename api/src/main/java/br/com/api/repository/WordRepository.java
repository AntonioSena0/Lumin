package br.com.api.repository;

import br.com.api.entity.Word;
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
            "WHERE w.original = :original AND w.translated = :translated")
    Optional<Word> findByOriginalAndTranslated(String original, String translated);

    @QueryHints(
            @QueryHint(name = "javax.persistence.query.timeout", value = "2000")
    )
    @Query("SELECT w FROM Word w " +
            "JOIN FETCH w.fromLanguage " +
            "JOIN FETCH w.toLanguage " +
            "JOIN FETCH w.category " +
            "WHERE w.original LIKE :q AND w.fromLanguage.id = :languageId")
    List<Word> findByOriginalContains(@Param("q") String q, @Param("languageId") Integer languageId);

}