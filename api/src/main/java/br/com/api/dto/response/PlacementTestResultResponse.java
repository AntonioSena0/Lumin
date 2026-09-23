package br.com.api.dto.response;

import br.com.api.domain.UserLanguageLevel;
import lombok.Builder;

@Builder
public record PlacementTestResultResponse(

        Long userId,
        Integer languageId,
        UserLanguageLevel level,
        Integer score,
        Integer totalQuestions,
        Double accuracy,
        boolean placementTestCompleted

) {}
