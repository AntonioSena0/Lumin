package br.com.api.dto.response;

import java.util.List;

public record StudySessionAiResponse(

        List<WrittenExerciseAiResponse> writtenExercises,
        List<SpeakingExerciseAiResponse> speakingExercises

) {}
