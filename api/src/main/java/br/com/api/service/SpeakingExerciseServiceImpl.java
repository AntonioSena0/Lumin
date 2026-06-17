package br.com.api.service;

import br.com.api.dto.response.SpeakingExerciseAiResponse;
import br.com.api.entity.Language;
import br.com.api.entity.SpeakingExercise;
import br.com.api.entity.Word;
import br.com.api.factory.ExerciseFactory;
import br.com.api.repository.SpeakingExerciseRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@AllArgsConstructor
public class SpeakingExerciseServiceImpl implements SpeakingExerciseService {

    private final SpeakingExerciseRepository repository;
    private final ExerciseFactory factory;

    @Override
    @Transactional
    public List<SpeakingExercise> saveAllSpeakingExercises(List<SpeakingExerciseAiResponse> exercises, Language language, Word word) {

        return repository.saveAll(exercises.stream()
                .map(speaking -> factory.createSpeaking(speaking, language, word))
                .toList());

    }

}
