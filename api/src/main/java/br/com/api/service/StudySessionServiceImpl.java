package br.com.api.service;

import br.com.api.domain.ExerciseCorrect;
import br.com.api.domain.SessionStatus;
import br.com.api.dto.request.ExerciseCheckRequest;
import br.com.api.dto.response.ExerciseCheckResponse;
import br.com.api.dto.response.ExerciseResponse;
import br.com.api.dto.response.StudySessionAiResponse;
import br.com.api.dto.response.StudySessionResponse;
import br.com.api.entity.*;
import br.com.api.factory.StudySessionFactory;
import br.com.api.mapper.ExerciseMapper;
import br.com.api.mapper.StudySessionMapper;
import br.com.api.normalizer.ExerciseGenerationNormalizer;
import br.com.api.repository.StudySessionRepository;
import br.com.api.repository.UserRepository;
import br.com.api.repository.WordRepository;
import br.com.api.validator.ExerciseGenerationValidator;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
    private final UserLanguageProgressService userLanguageProgressService;
    private final UserWordProgressService userWordProgressService;
    private final ExerciseGenerationValidator validator;
    private final ExerciseGenerationNormalizer normalizer;

    private StudySessionAiResponse generateValidStudySession(Word word, User user){

        RuntimeException lastException = null;

        for(int attempt = 0; attempt < 2; attempt++){

            try{
                StudySessionAiResponse response = aiService.generateStudySession(
                        word,
                        word.getFromLanguage().getName(),
                        word.getToLanguage().getName()
                );

                validator.validateBaseResponse(response);
                StudySessionAiResponse normalizedResponse = normalizer.normalize(response, word);

                return validator.validate(normalizedResponse, word);

            } catch (RuntimeException exception){
                lastException = exception;
            }

        }

        throw new RuntimeException("Não foi possível gerar uma sessão de estudos válida", lastException);
    }

    @Override
    public StudySessionResponse findById(Long id) {
        return StudySessionMapper.toStudySessionResponse(repository.findByIdWithRelations(id)
                .orElseThrow(() -> new RuntimeException("Sessão não encontrada")));
    }

    @Override
    @Transactional
    public StudySessionResponse startSession(Long userId, Long wordId) {

        User existingUser = userRepository.findByIdWithRelations(userId)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado para criar a sessão"));

        Word existingWord = wordRepository.findByIdWithRelations(wordId)
                .orElseThrow(() -> new RuntimeException("Palavra não encontrada"));

        StudySessionAiResponse aiResponse = generateValidStudySession(existingWord, existingUser);

        List<WrittenExercise> writtenExercises = writtenExerciseService.createAllWrittenExercises(aiResponse.writtenExercises(), existingWord.getToLanguage(), existingWord);
        List<SpeakingExercise> speakingExercises = speakingExerciseService.createAllSpeakingExercises(aiResponse.speakingExercises(), existingWord.getToLanguage(), existingWord);

        List<Exercise> exercises = new ArrayList<>();

        exercises.addAll(writtenExercises);
        exercises.addAll(speakingExercises);

        for (int index = 0; index < exercises.size(); index++) {
            exercises.get(index).setOrderIndex(index);
        }

        StudySession session = factory.createStudySession(existingUser, exercises);

        exercises.forEach(exercise -> exercise.setSession(session));

        return StudySessionMapper.toStudySessionResponse(repository.save(session));

    }

    @Override
    public ExerciseResponse currentExercise(Long id){

        StudySession studySession = repository.findByIdWithRelations(id)
                .orElseThrow(() -> new RuntimeException("Sessão de estudos não encontrada"));

        List<Exercise> exercises = studySession.getExercises();

        if (studySession.getCurrentIndex() >= studySession.getTotalExercises()) {
            throw new RuntimeException("Sessão finalizada");
        }

        Exercise exercise = exercises.get(studySession.getCurrentIndex());

        return ExerciseMapper.toExerciseResponse(exercise);

    }

    @Override
    @Transactional
    public ExerciseCheckResponse finishExercise(Long id, Long exerciseId, ExerciseCheckRequest request){

        StudySession studySession = repository.findByIdWithRelations(id)
                .orElseThrow(() -> new RuntimeException("Sessão de estudos não encontrada"));

        if(studySession.getCurrentIndex() >= studySession.getTotalExercises()){
            throw new RuntimeException("Sessão de estudo já encerrada");
        }

        Exercise exercise = studySession.getExercises().stream()
                .filter(e -> e.getId().equals(exerciseId))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Exercício não pertence a esta sessão"));


        if(!studySession.getCurrentIndex().equals(exercise.getOrderIndex())){
            throw new RuntimeException("Você não pode realizar esse exercício ainda");
        }

        if(exercise.isCompleted()){
            throw new RuntimeException("Exercício já realizado");
        }

        boolean correct = exercise.checkAnswer(request.answer());

        userWordProgressService.registerAnswer(studySession.getUser(), exercise.getWord(), correct);

        studySession.setCurrentIndex(studySession.getCurrentIndex() + 1);
        exercise.setCompleted(true);

        if(!correct){
            exercise.setCorrect(ExerciseCorrect.INCORRECT);
            return ExerciseMapper.toExerciseCheckResponse(exercise, false);
        }

        exercise.setCorrect(ExerciseCorrect.CORRECT);
        studySession.setScore(studySession.getScore() + 1);

        return ExerciseMapper.toExerciseCheckResponse(exercise, true);

    }

    @Override
    @Transactional
    public StudySessionResponse finishSession(Long id, Long userId) {

        StudySession session = repository.findByIdWithRelations(id)
                .orElseThrow(() -> new RuntimeException("Sessão não encontrada"));

        if(!session.getUser().getId().equals(userId)){
            throw new RuntimeException("Essa sessão não pertence a você");
        }

        if(session.getStatus() == SessionStatus.FINISHED){
            throw new RuntimeException("Você já finalizou essa sessão de estudos");
        }

        if(session.getCurrentIndex() < session.getTotalExercises()){
            throw new RuntimeException("Sessão de estudo não pode ser finalizada");
        }

        if (session.getExercises().isEmpty()) {
            throw new RuntimeException("Sessão sem exercícios");
        }

        Word sessionWord = session.getExercises().getFirst().getWord();

        userLanguageProgressService.registerFinishedSession(session.getUser(), sessionWord.getToLanguage(), session.getScore(), session.getTotalExercises());

        session.setStatus(SessionStatus.FINISHED);
        session.setFinishedAt(LocalDateTime.now());

        return StudySessionMapper.toStudySessionResponse(session);

    }
}
