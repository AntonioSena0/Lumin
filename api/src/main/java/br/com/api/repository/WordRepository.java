package br.com.api.repository;

import br.com.api.entity.Word;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface WordRepository extends JpaRepository<Word, Long> {

    Optional<Word> findByOriginalAndTranslated(String original, String translated);

    @Query("SELECT w FROM Word w WHERE w.original LIKE CONCAT('%', :q, '%')")
    List<Word> findByOriginalContains(@Param("q") String q);

}