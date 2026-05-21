package br.com.api.dto.response;

import br.com.api.domain.WrittenType;

import java.util.List;

public record WrittenExerciseAiResponse(

        String title,
        String instruction,
        String prompt,
        String correctAnswer,
        List<String> options,
        WrittenType subType

) {}
