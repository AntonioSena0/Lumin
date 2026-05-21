package br.com.api.dto.response;

import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;

@Builder
public record WrittenExerciseResponse(

        Long id,
        String title,
        String instruction,
        String prompt,
        LocalDateTime lastPracticed,
        UserResponse user,
        LanguageResponse language,
        WordResponse word,
        List<String> options,
        LocalDateTime createdAt

) {}
