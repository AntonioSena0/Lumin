package br.com.api.service;

import br.com.api.dto.request.ExerciseCheckRequest;
import br.com.api.dto.response.WrittenExerciseCheckResponse;
import br.com.api.dto.response.WrittenExerciseResponse;

import java.util.List;

public interface WrittenExerciseService {

    List<WrittenExerciseResponse> findByUserId(Long userId);
    WrittenExerciseResponse generateNewExercise(Long userId, Long wordId);
    WrittenExerciseCheckResponse validate(Long id, ExerciseCheckRequest answer);
    void delete(Long exerciseId);

}