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
        Integer currentIndex,
        SessionStatus status,
        LocalDateTime finishedAt,
        UserResponse user,
        List<ExerciseResponse> exercises,
        LocalDateTime createdAt,
        LocalDateTime updatedAt

) {}
