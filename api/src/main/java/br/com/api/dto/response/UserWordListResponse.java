package br.com.api.dto.response;

import br.com.api.domain.WordDomainLevel;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record UserWordListResponse (
        Long wordId,
        String original,
        String translated,
        String description,
        Integer categoryId,
        String categoryName,
        Integer fromLanguageId,
        String fromLanguageCode,
        Integer toLanguageId,
        String toLanguageCode,
        boolean isSaved,
        WordDomainLevel level,
        Long correctAnswers,
        Long incorrectAnswers,
        Double accuracy,
        LocalDateTime lastPracticed,
        LocalDateTime createdAt
) {}
