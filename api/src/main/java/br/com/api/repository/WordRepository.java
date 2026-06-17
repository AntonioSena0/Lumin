package br.com.api.repository;

import br.com.api.entity.Word;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
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

    @Query("SELECT w FROM Word w " +
            "JOIN FETCH w.fromLanguage " +
            "JOIN FETCH w.toLanguage " +
            "JOIN FETCH w.category " +
            "WHERE w.id = :id")
    Optional<Word> findByIdWithRelations(@Param("id") Long id);

    @Query("SELECT w FROM Word w " +
            "JOIN FETCH w.fromLanguage " +
            "JOIN FETCH w.toLanguage " +
            "JOIN FETCH w.category " +
            "WHERE w.original = :original AND w.translated = :translated")
    Optional<Word> findByOriginalAndTranslated(String original, String translated);

    @Query("SELECT w FROM Word w " +
            "JOIN FETCH w.fromLanguage " +
            "JOIN FETCH w.toLanguage " +
            "JOIN FETCH w.category " +
            "WHERE w.original LIKE :q")
    List<Word> findByOriginalContains(@Param("q") String q);

}