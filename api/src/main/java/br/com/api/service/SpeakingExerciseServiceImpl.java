package br.com.api.service;

import br.com.api.dto.response.SpeakingExerciseResponse;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@AllArgsConstructor
public class SpeakingExerciseServiceImpl implements SpeakingExerciseService{

    @Override
    public List<SpeakingExerciseResponse> findByUserId(Long userId) {
        return List.of();
    }

    @Override
    public SpeakingExerciseResponse generateSpeakingExercise() {
        return null;
    }

    @Override
    public boolean checkAnswer(Long exerciseId, String answer) {
        return false;
    }

    @Override
    public String getCorrectAnswer(Long exerciseId) {
        return "";
    }

    @Override
    public void updateLastPracticed(Long exerciseId) {

    }
}
