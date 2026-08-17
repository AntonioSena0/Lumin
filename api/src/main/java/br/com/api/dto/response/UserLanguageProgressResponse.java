package br.com.api.dto.response;

import br.com.api.domain.UserLanguageLevel;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record UserLanguageProgressResponse(

        UserResponse user,
        LanguageResponse language,
        UserLanguageLevel level,
        Long xp,
        Long totalSessions,
        Long totalCorrectAnswers,
        Long totalIncorrectAnswers,
        LocalDateTime lastPracticed,
        LocalDateTime createdAt,
        LocalDateTime updatedAt

) {}