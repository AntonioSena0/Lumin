package br.com.api.dto.response;

import java.util.List;

public record SpeakingExerciseAiResponse(

        String title,
        String instruction,
        String prompt,
        List<String> requiredWords

) {}
