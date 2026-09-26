package br.com.api.service;

import br.com.api.domain.UserLanguageLevel;
import br.com.api.dto.request.PlacementTestAnswerRequest;
import br.com.api.dto.request.PlacementTestSubmitRequest;
import br.com.api.dto.response.PlacementQuestionResponse;
import br.com.api.dto.response.PlacementTestResultResponse;
import br.com.api.entity.*;
import br.com.api.mapper.PlacementQuestionMapper;
import br.com.api.repository.LanguageRepository;
import br.com.api.repository.PlacementQuestionRepository;
import br.com.api.repository.UserLanguageProgressRepository;
import br.com.api.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@AllArgsConstructor
public class PlacementQuestionServiceImpl implements PlacementQuestionService{

    private final PlacementQuestionRepository repository;
    private final UserRepository userRepository;
    private final LanguageRepository languageRepository;
    private final UserLanguageProgressRepository userLanguageProgressRepository;

    @Override
    public List<PlacementQuestionResponse> findByLanguage(Integer languageId) {
        return repository.findByLanguageIdOrderByLevelAsc(languageId)
                .stream()
                .map(PlacementQuestionMapper::toPlacementQuestionResponse)
                .toList();
    }

    @Override
    @Transactional
    public PlacementTestResultResponse submit(Long userId, Integer languageId, PlacementTestSubmitRequest request) {

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        Language language = languageRepository.findById(languageId)
                .orElseThrow(() -> new RuntimeException("Língua não encontrada"));

        List<PlacementQuestion> questions = repository.findByLanguageIdOrderByLevelAsc(languageId);
        int correct = 0;
        int incorrect = 0;

        if (questions.isEmpty()) {
            throw new RuntimeException("Nenhuma pergunta de nivelamento encontrada para este idioma");
        }

        Map<Long, String> answersByQuestionId = request.answers()
                .stream()
                .collect(Collectors.toMap(
                        PlacementTestAnswerRequest::questionId,
                        PlacementTestAnswerRequest::answer
                ));

        for(PlacementQuestion question : questions){

            String answer = answersByQuestionId.get(question.getId());

            if(answer != null && answer.equalsIgnoreCase(question.getCorrectAnswer())) {
                correct++;
            } else {
                incorrect++;
            }
        }

        int totalQuestions = correct + incorrect;

        double accuracy = (double) correct / totalQuestions;

        UserLanguageProgress progress = levelCalculate(user, language, accuracy);

        return PlacementTestResultResponse
                .builder()
                .userId(userId)
                .languageId(languageId)
                .totalQuestions(totalQuestions)
                .score(correct)
                .accuracy(accuracy)
                .level(progress.getLevel())
                .placementTestCompleted(true)
                .build();

    }

    private UserLanguageProgress levelCalculate(User user, Language language, double accuracy) {

        UserLanguageLevel level = UserLanguageLevel.N1;

        if (accuracy >= 0.85) {
            level = UserLanguageLevel.N3;
        } else if (accuracy >= 0.60) {
            level = UserLanguageLevel.N2;
        }

        UserLanguageProgress progress = userLanguageProgressRepository
                .findByIdWithRelations(user.getId(), language.getId())
                .orElseGet(() -> UserLanguageProgress.builder()
                        .id(new UserLanguageProgressId(user.getId(), language.getId()))
                        .user(user)
                        .language(language)
                        .xp(0L)
                        .totalSessions(0L)
                        .totalCorrectAnswers(0L)
                        .totalIncorrectAnswers(0L)
                        .build());

        progress.setLevel(level);
        progress.setPlacementTestCompleted(true);
        progress.setPlacementTestCompletedAt(LocalDateTime.now());

        return userLanguageProgressRepository.save(progress);
    }

}
