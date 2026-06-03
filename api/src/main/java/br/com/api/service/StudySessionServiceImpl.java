package br.com.api.service;

import br.com.api.domain.SessionStatus;
import br.com.api.dto.response.StudySessionAiResponse;
import br.com.api.dto.response.StudySessionResponse;
import br.com.api.entity.*;
import br.com.api.factory.StudySessionFactory;
import br.com.api.mapper.StudySessionMapper;
import br.com.api.repository.StudySessionRepository;
import br.com.api.repository.UserRepository;
import br.com.api.repository.WordRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@AllArgsConstructor
public class StudySessionServiceImpl implements StudySessionService{

    private final AiGeneratorService aiService;
    private final StudySessionRepository repository;
    private final StudySessionFactory factory;
    private final UserRepository userRepository;
    private final WordRepository wordRepository;
    private final WrittenExerciseService writtenExerciseService;
    private final SpeakingExerciseService speakingExerciseService;

    @Override
    public StudySessionResponse findById(Long id) {
        return StudySessionMapper.toStudySessionResponse(repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Sessão não encontrada")));
    }

    @Override
    public StudySessionResponse startSession(Long userId, Long wordId) {

        User existingUser = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado para criar a sessão"));

        Word existingWord = wordRepository.findById(wordId)
                .orElseThrow(() -> new RuntimeException("Palavra não encontrada"));

        StudySessionAiResponse aiResponse = aiService.generateStudySession(
                existingWord,
                existingUser.getNativeLanguage().getName(),
                existingUser.getChosenLanguage().getName()
        );

        List<WrittenExercise> writtenExercises = writtenExerciseService.saveAllWrittenExercises(aiResponse.writtenExercises(), existingUser.getChosenLanguage(), existingWord);
        List<SpeakingExercise> speakingExercises = speakingExerciseService.saveAllSpeakingExercises(aiResponse.speakingExercises(), existingUser.getChosenLanguage(), existingWord);

        List<Exercise> exercises = new ArrayList<>();

        exercises.addAll(writtenExercises);
        exercises.addAll(speakingExercises);

        StudySession session = factory.createStudySession(existingUser, exercises);

        exercises.forEach(exercise -> exercise.setSession(session));

        return StudySessionMapper.toStudySessionResponse(repository.save(session));

    }

    @Override
    public StudySessionResponse finishSession(Long id) {

        StudySession session = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Sessão não encontrada"));

        session.setStatus(SessionStatus.FINISHED);
        session.setFinishedAt(LocalDateTime.now());

        return StudySessionMapper.toStudySessionResponse(repository.save(session));

    }
}
