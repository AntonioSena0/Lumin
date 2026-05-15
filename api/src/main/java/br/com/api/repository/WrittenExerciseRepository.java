package br.com.api.repository;

import br.com.api.entity.WrittenExercise;
import org.springframework.data.jpa.repository.JpaRepository;

public interface WrittenExerciseRepository extends JpaRepository<WrittenExercise, Long> {
}
