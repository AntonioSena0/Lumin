package br.com.api.dto.response;

import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;

@Builder
public record SpeakingExerciseResponse (

        Long id,
        String title,
        String prompt,
        LanguageResponse language,
        WordResponse word,
        List<String> requiredWords,
        LocalDateTime createdAt

) implements ExerciseResponse {}
