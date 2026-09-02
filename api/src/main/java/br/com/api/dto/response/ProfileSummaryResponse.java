package br.com.api.dto.response;

import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;

@Builder
public record ProfileSummaryResponse(

        Long userId,
        String userName,
        String email,
        LanguageResponse nativeLanguage,
        LanguageResponse chosenLanguage,
        Long savedWords,
        Long practicedWords,
        Long weakWords,
        Long familiarWords,
        Long totalSessions,
        Long totalCorrectAnswers,
        Long totalIncorrectAnswers,
        Double accuracy,
        LocalDateTime lastPracticed,
        List<UserLanguageProgressResponse> languagesProgress,
        List<CategoryProgressResponse> categoriesProgress,
        List<UserWordListResponse> recentWords

) {}
