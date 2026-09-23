package br.com.api.dto.response;

import br.com.api.domain.UserLanguageLevel;
import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;

@Builder
public record PlacementQuestionResponse(

        Long id,
        LanguageResponse language,
        UserLanguageLevel level,
        String question,
        List<String> options,
        LocalDateTime createdAt


) {}
