package br.com.api.service;

import br.com.api.dto.request.ExerciseCheckRequest;
import br.com.api.dto.response.ExerciseCheckResponse;
import br.com.api.dto.response.ExerciseResponse;
import br.com.api.dto.response.StudySessionResponse;
import br.com.api.dto.response.StudySessionSummaryResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface StudySessionService {

    StudySessionResponse findById(Long id);
    Page<StudySessionSummaryResponse> findAllByUserId(Long userId, Pageable pageable);
    StudySessionResponse startSession(Long userId, Long wordId);
    ExerciseResponse currentExercise(Long id);
    ExerciseCheckResponse finishExercise(Long id, Long exerciseId, ExerciseCheckRequest request);
    StudySessionResponse finishSession(Long id, Long userId);

}
