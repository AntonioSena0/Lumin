package br.com.api.repository;

import br.com.api.entity.PlacementQuestion;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PlacementQuestionRepository extends JpaRepository<PlacementQuestion, Long> {

    @Query("SELECT pq FROM PlacementQuestion pq " +
            "JOIN FETCH pq.language " +
            "WHERE pq.language.id = :languageId " +
            "ORDER BY pq.level ASC")
    List<PlacementQuestion> findByLanguageIdOrderByLevelAsc(@Param("languageId") Integer languageId);

}