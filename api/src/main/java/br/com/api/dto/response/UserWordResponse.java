package br.com.api.dto.response;

import br.com.api.domain.WordDomainLevel;
import br.com.api.entity.UserWordId;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record UserWordResponse(

        UserResponse user,
        WordResponse word,
        LocalDateTime lastPracticed,
        Long correctAnswers,
        Long incorrectAnswers,
        boolean isSaved,
        WordDomainLevel level,
        LocalDateTime createdAt

) {}
