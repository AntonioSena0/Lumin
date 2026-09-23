package br.com.api.repository;

import br.com.api.entity.PlacementQuestion;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PlacementQuestionRepository extends JpaRepository<PlacementQuestion, Long> {

    @EntityGraph(attributePaths = {"language"})
    List<PlacementQuestion> findByLanguageIdOrderByLevelAsc(Integer languageId);

}