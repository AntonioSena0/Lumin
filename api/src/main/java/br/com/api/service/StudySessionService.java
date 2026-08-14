package br.com.api.service;

import br.com.api.dto.request.ExerciseCheckRequest;
import br.com.api.dto.response.ExerciseCheckResponse;
import br.com.api.dto.response.ExerciseResponse;
import br.com.api.dto.response.StudySessionResponse;

public interface StudySessionService {

    StudySessionResponse findById(Long id);
    StudySessionResponse startSession(Long userId, Long wordId);
    ExerciseResponse currentExercise(Long id);
    ExerciseCheckResponse finishExercise(Long id, Long exerciseId, ExerciseCheckRequest request);
    StudySessionResponse finishSession(Long id, Long userId);

}
