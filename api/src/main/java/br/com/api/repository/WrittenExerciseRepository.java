package br.com.api.repository;

import br.com.api.entity.WrittenExercise;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface WrittenExerciseRepository extends JpaRepository<WrittenExercise, Long> {
}
