package br.com.api.service;

import br.com.api.dto.request.ExerciseCheckRequest;
import br.com.api.dto.response.WrittenExerciseCheckResponse;
import br.com.api.dto.response.WrittenExerciseResponse;
import br.com.api.entity.*;
import br.com.api.factory.ExerciseFactory;
import br.com.api.mapper.WrittenExerciseMapper;
import br.com.api.repository.UserRepository;
import br.com.api.repository.WordRepository;
import br.com.api.repository.WrittenExerciseRepository;
import jakarta.transaction.Transactional;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@AllArgsConstructor
public class WrittenExerciseServiceImpl implements WrittenExerciseService {

    private final AiGeneratorService aiService;
    private final ExerciseFactory factory;
    private final WrittenExerciseRepository repository;
    private final UserRepository userRepository;
    private final WordRepository wordRepository;

    @Override
    public List<WrittenExerciseResponse> findByUserId(Long userId) {
        return repository.findByUserId(userId)
                .stream()
                .map(WrittenExerciseMapper::toWrittenExerciseResponse)
                .toList();
    }

    @Override
    @Transactional
    public WrittenExerciseResponse generateNewExercise(Long userId, Long wordId){

        Word existingWord = wordRepository.findById(wordId)
                .orElseThrow(() -> new RuntimeException("Palavra não encontrada"));

        User existingUser = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        var aiResponse = aiService.generateWrittenExercise(existingWord.getOriginal(), existingUser.getNativeLanguage().getName(), existingUser.getChosenLanguage().getName());

        WrittenExercise ex = factory.createWritten(aiResponse, existingUser, existingUser.getChosenLanguage(), existingWord);

        return WrittenExerciseMapper.toWrittenExerciseResponse(repository.save(ex));

    }

    @Override
    public WrittenExerciseCheckResponse validate(Long exerciseId, ExerciseCheckRequest answer) {

        WrittenExercise exercise = repository.findById(exerciseId)
                .orElseThrow(() -> new RuntimeException("Exercício não encontrado"));

        boolean correct = exercise.checkAnswer(answer.answer());

        exercise.setLastPracticed(LocalDateTime.now());
        repository.save(exercise);

        return new WrittenExerciseCheckResponse(exerciseId, correct, correct ? null : exercise.getCorrectAnswer());

    }

    @Override
    public void delete(Long exerciseId){

        WrittenExercise exercise = repository.findById(exerciseId)
                .orElseThrow(() -> new RuntimeException("Exercício não encontrado"));

        repository.delete(exercise);

    }

}