package br.com.api.service;

import br.com.api.domain.UserLanguageLevel;
import br.com.api.dto.request.PlacementTestAnswerRequest;
import br.com.api.dto.request.PlacementTestSubmitRequest;
import br.com.api.dto.response.PlacementTestResultResponse;
import br.com.api.entity.Language;
import br.com.api.entity.PlacementQuestion;
import br.com.api.entity.User;
import br.com.api.entity.UserLanguageProgress;
import br.com.api.repository.LanguageRepository;
import br.com.api.repository.PlacementQuestionRepository;
import br.com.api.repository.UserLanguageProgressRepository;
import br.com.api.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.within;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class PlacementSubmitTest {

    @Mock
    private PlacementQuestionRepository questionRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private LanguageRepository languageRepository;

    @Mock
    private UserLanguageProgressRepository progressRepository;

    private PlacementQuestionServiceImpl service;

    private User user;

    private Language language;

    @BeforeEach
    void setUp() {
        service = new PlacementQuestionServiceImpl(questionRepository, userRepository, languageRepository, progressRepository);
        user = User.builder().id(1L).build();
        language = Language.builder().id(5).code("en").name("English").build();
    }

    @Test
    void accuracyAt85MapsToN3AndCompletesPlacement() {
        List<PlacementQuestion> questions = buildQuestions(20);
        stubCommon(questions);

        PlacementTestResultResponse result = service.submit(1L, 5, buildRequest(questions, 17));

        assertThat(result.level()).isEqualTo(UserLanguageLevel.N3);
        assertThat(result.placementTestCompleted()).isTrue();
        assertThat(result.score()).isEqualTo(17);
        assertThat(result.totalQuestions()).isEqualTo(20);
        assertThat(result.accuracy()).isCloseTo(0.85, within(0.0001));

        ArgumentCaptor<UserLanguageProgress> captor = ArgumentCaptor.forClass(UserLanguageProgress.class);
        verify(progressRepository).save(captor.capture());
        assertThat(captor.getValue().getLevel()).isEqualTo(UserLanguageLevel.N3);
        assertThat(captor.getValue().isPlacementTestCompleted()).isTrue();
    }

    @Test
    void accuracyAt60MapsToN2AndCompletesPlacement() {
        List<PlacementQuestion> questions = buildQuestions(20);
        stubCommon(questions);

        PlacementTestResultResponse result = service.submit(1L, 5, buildRequest(questions, 12));

        assertThat(result.level()).isEqualTo(UserLanguageLevel.N2);
        assertThat(result.placementTestCompleted()).isTrue();
        assertThat(result.score()).isEqualTo(12);
        assertThat(result.accuracy()).isCloseTo(0.60, within(0.0001));

        ArgumentCaptor<UserLanguageProgress> captor = ArgumentCaptor.forClass(UserLanguageProgress.class);
        verify(progressRepository).save(captor.capture());
        assertThat(captor.getValue().getLevel()).isEqualTo(UserLanguageLevel.N2);
        assertThat(captor.getValue().isPlacementTestCompleted()).isTrue();
    }

    @Test
    void accuracyBelow60MapsToN1AndCompletesPlacement() {
        List<PlacementQuestion> questions = buildQuestions(20);
        stubCommon(questions);

        PlacementTestResultResponse result = service.submit(1L, 5, buildRequest(questions, 8));

        assertThat(result.level()).isEqualTo(UserLanguageLevel.N1);
        assertThat(result.placementTestCompleted()).isTrue();
        assertThat(result.score()).isEqualTo(8);
        assertThat(result.accuracy()).isCloseTo(0.40, within(0.0001));

        ArgumentCaptor<UserLanguageProgress> captor = ArgumentCaptor.forClass(UserLanguageProgress.class);
        verify(progressRepository).save(captor.capture());
        assertThat(captor.getValue().getLevel()).isEqualTo(UserLanguageLevel.N1);
        assertThat(captor.getValue().isPlacementTestCompleted()).isTrue();
    }

    private void stubCommon(List<PlacementQuestion> questions) {
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(languageRepository.findById(5)).thenReturn(Optional.of(language));
        when(questionRepository.findByLanguageIdOrderByLevelAsc(5)).thenReturn(questions);
        when(progressRepository.findByIdWithRelations(1L, 5)).thenReturn(Optional.empty());
        when(progressRepository.save(any(UserLanguageProgress.class))).thenAnswer(invocation -> invocation.getArgument(0));
    }

    private List<PlacementQuestion> buildQuestions(int count) {
        List<PlacementQuestion> questions = new ArrayList<>();
        for (long i = 1; i <= count; i++) {
            questions.add(PlacementQuestion.builder()
                    .id(i)
                    .level(UserLanguageLevel.N1)
                    .question("Q" + i)
                    .correctAnswer("A")
                    .options(List.of("A", "B"))
                    .language(language)
                    .build());
        }
        return questions;
    }

    private PlacementTestSubmitRequest buildRequest(List<PlacementQuestion> questions, int correctCount) {
        List<PlacementTestAnswerRequest> answers = new ArrayList<>();
        for (int i = 0; i < questions.size(); i++) {
            String answer = i < correctCount ? "A" : "B";
            answers.add(new PlacementTestAnswerRequest(questions.get(i).getId(), answer));
        }
        return new PlacementTestSubmitRequest(answers);
    }
}
