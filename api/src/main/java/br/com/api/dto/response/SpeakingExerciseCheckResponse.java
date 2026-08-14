package br.com.api.dto.response;

import lombok.Builder;

@Builder
public record SpeakingExerciseCheckResponse(

        Long id,
        boolean correct

) implements ExerciseCheckResponse {}
