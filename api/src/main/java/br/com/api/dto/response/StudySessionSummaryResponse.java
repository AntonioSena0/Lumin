package br.com.api.dto.response;

import br.com.api.domain.SessionStatus;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record StudySessionSummaryResponse(

        Long id,
        Integer currentIndex,
        Integer totalExercises,
        Integer score,
        SessionStatus status,
        LocalDateTime finishedAt,
        Long wordId,
        String wordOriginal,
        String wordTranslated,
        String languageName,
        String languageCode,
        LocalDateTime createdAt

) {}
