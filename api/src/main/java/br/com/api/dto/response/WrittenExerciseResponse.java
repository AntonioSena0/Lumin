package br.com.api.dto.response;

import br.com.api.domain.WrittenType;
import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;

@Builder
public record WrittenExerciseResponse(

        Long id,
        String title,
        String instruction,
        String prompt,
        WrittenType subType,
        LanguageResponse language,
        WordResponse word,
        List<String> options,
        LocalDateTime createdAt

) implements ExerciseResponse{}
