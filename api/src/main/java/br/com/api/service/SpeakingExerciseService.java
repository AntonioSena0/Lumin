package br.com.api.service;

import br.com.api.dto.response.SpeakingExerciseResponse;

import java.util.List;

public interface SpeakingExerciseService {

    List<SpeakingExerciseResponse> findByUserId(Long userId);
    SpeakingExerciseResponse generateSpeakingExercise();
    boolean checkAnswer(Long exerciseId, String answer);
    String getCorrectAnswer(Long exerciseId);
    void updateLastPracticed(Long exerciseId);

}
