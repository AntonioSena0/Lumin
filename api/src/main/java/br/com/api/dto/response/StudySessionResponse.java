package br.com.api.dto.response;

import br.com.api.domain.SessionStatus;
import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;

@Builder
public record StudySessionResponse(

        Long id,
        Integer totalExercises,
        Integer score,
        SessionStatus status,
        LocalDateTime finishedAt,
        Long userId,
        List<ExerciseResponse> exercises,
        LocalDateTime createdAt,
        LocalDateTime updatedAt

) {}
