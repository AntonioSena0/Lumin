package br.com.api.repository;

import br.com.api.entity.SpeakingExercise;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SpeakingExerciseRepository extends JpaRepository<SpeakingExercise, Long> {
}
