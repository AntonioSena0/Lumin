package br.com.api.service;

import br.com.api.dto.response.SpeakingExerciseAiResponse;
import br.com.api.entity.Language;
import br.com.api.entity.SpeakingExercise;
import br.com.api.entity.Word;
import br.com.api.factory.ExerciseFactory;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@AllArgsConstructor
public class SpeakingExerciseServiceImpl implements SpeakingExerciseService {

    private final ExerciseFactory factory;

    @Override
    public List<SpeakingExercise> createAllSpeakingExercises(List<SpeakingExerciseAiResponse> exercises, Language language, Word word) {

        return exercises.stream()
                .map(speaking -> factory.createSpeaking(speaking, language, word))
                .toList();

    }

}
