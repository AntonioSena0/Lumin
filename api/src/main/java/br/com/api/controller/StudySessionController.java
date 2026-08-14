package br.com.api.controller;

import br.com.api.dto.request.ExerciseCheckRequest;
import br.com.api.dto.response.ExerciseCheckResponse;
import br.com.api.dto.response.ExerciseResponse;
import br.com.api.dto.response.StudySessionResponse;
import org.springframework.http.ResponseEntity;

public interface StudySessionController {

    ResponseEntity<StudySessionResponse> findById(Long id);
    ResponseEntity<StudySessionResponse> startSession(Long userId, Long wordId);
    ResponseEntity<ExerciseResponse> currentExercise(Long studySessionId);
    ResponseEntity<ExerciseCheckResponse> finishExercise(Long id, Long exerciseId, ExerciseCheckRequest request);
    ResponseEntity<StudySessionResponse> finishSession(Long id, Long userId);

}
