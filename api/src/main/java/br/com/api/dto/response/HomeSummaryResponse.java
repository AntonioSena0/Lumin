package br.com.api.dto.response;

import br.com.api.domain.UserLanguageLevel;
import lombok.Builder;

import java.util.List;

@Builder
public record HomeSummaryResponse(

        Long userId,
        String userName,
        Integer languageId,
        String languageName,
        String languageCode,
        UserLanguageLevel level,
        Long xp,
        Long nextLevelXp,
        Double levelProgress,
        Long savedWords,
        Long practicedWords,
        Long weakWords,
        List<UserWordListResponse> recentWords,
        List<UserWordListResponse> weakRecentWords,
        List<CategoryProgressResponse> categoriesProgress

) {}
