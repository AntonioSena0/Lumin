package br.com.api.dto.response;

public record WrittenExerciseCheckResponse(

        Long id,
        boolean correct,
        String correctAnswer

) {}
