package br.com.api.repository;

import br.com.api.entity.WrittenExercise;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WrittenExerciseRepository extends JpaRepository<WrittenExercise, Long> {

    List<WrittenExercise> findByUserId(Long userId);

}
