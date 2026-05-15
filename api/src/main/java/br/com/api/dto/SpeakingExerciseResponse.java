package br.com.api.dto;

import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;

@Builder
public record SpeakingExerciseResponse (

        Long id,
        String title,
        String prompt,
        LocalDateTime lastPracticed,
        UserResponse user,
        LanguageResponse language,
        WordResponse word,
        List<String> requiredWords,
        LocalDateTime createdAt

) {}
