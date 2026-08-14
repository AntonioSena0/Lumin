package br.com.api.service;

import br.com.api.dto.response.WrittenExerciseAiResponse;
import br.com.api.entity.*;
import br.com.api.factory.ExerciseFactory;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@AllArgsConstructor
public class WrittenExerciseServiceImpl implements WrittenExerciseService {

    private final ExerciseFactory factory;

    @Override
    public List<WrittenExercise> createAllWrittenExercises(List<WrittenExerciseAiResponse> exercises, Language language, Word word){
        return exercises.stream()
                .map(written -> factory.createWritten(written, language, word))
                .toList();
    }

}