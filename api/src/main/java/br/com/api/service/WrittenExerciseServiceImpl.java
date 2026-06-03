package br.com.api.service;

import br.com.api.dto.response.WrittenExerciseAiResponse;
import br.com.api.entity.*;
import br.com.api.factory.ExerciseFactory;
import br.com.api.repository.WrittenExerciseRepository;
import jakarta.transaction.Transactional;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@AllArgsConstructor
public class WrittenExerciseServiceImpl implements WrittenExerciseService {

    private final WrittenExerciseRepository repository;
    private final ExerciseFactory factory;

    @Override
    @Transactional
    public List<WrittenExercise> saveAllWrittenExercises(List<WrittenExerciseAiResponse> exercises, Language language, Word word){
        return repository.saveAll(exercises.stream()
                .map(written -> factory.createWritten(written, language, word))
                .toList());
    }

}