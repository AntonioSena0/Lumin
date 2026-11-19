package br.com.api.normalizer;

import br.com.api.domain.WrittenType;
import br.com.api.dto.response.SpeakingExerciseAiResponse;
import br.com.api.dto.response.StudySessionAiResponse;
import br.com.api.dto.response.WrittenExerciseAiResponse;
import br.com.api.entity.Category;
import br.com.api.entity.Language;
import br.com.api.entity.Word;
import br.com.api.repository.WordRepository;
import br.com.api.service.ExerciseOptionServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.lenient;

@ExtendWith(MockitoExtension.class)
class ExerciseGenerationNormalizerTest {

    @Mock
    private WordRepository wordRepository;

    private ExerciseGenerationNormalizer normalizer;
    private Word word;

    @BeforeEach
    void setUp() {
        normalizer = new ExerciseGenerationNormalizer(new ExerciseOptionServiceImpl(wordRepository));
        word = Word.builder().id(1L).original("teclado").translated("keyboard")
                .category(Category.builder().id(3).build())
                .toLanguage(Language.builder().id(2).build())
                .build();
        lenient().when(wordRepository.findTop10ByCategoryIdAndToLanguageIdAndIdNot(any(), any(), any()))
                .thenReturn(List.of("mouse", "monitor", "laptop", "printer"));
    }

    @Test
    void fillInGetsAWordBankWithTheAnswer() {
        WrittenExerciseAiResponse result = normalizeOne(written(WrittenType.FILL_IN, "She cleaned the _____.", "keyboard"));

        assertThat(result.options()).hasSize(4).contains("keyboard").doesNotHaveDuplicates();
    }

    @Test
    void translateGetsEverySentenceBlockPlusDistractors() {
        WrittenExerciseAiResponse result = normalizeOne(written(WrittenType.TRANSLATE, "O teclado está na mesa.", "The keyboard is on the desk."));

        assertThat(result.options()).contains("The", "keyboard", "is", "on", "the", "desk");
        assertThat(result.options().size()).isGreaterThan(6);
    }

    @Test
    void rewriteAlsoBecomesSentenceBlocks() {
        WrittenExerciseAiResponse result = normalizeOne(written(WrittenType.REWRITE, "She replaced the typing device.", "She replaced the keyboard."));

        assertThat(result.options()).contains("She", "replaced", "the", "keyboard");
    }

    @Test
    void multipleChoiceKeepsFourOptionsWithTheAnswer() {
        WrittenExerciseAiResponse result = normalizeOne(written(WrittenType.MULTIPLE_CHOICE, "Which item?", "keyboard"));

        assertThat(result.options()).hasSize(4).contains("keyboard");
    }

    private WrittenExerciseAiResponse written(WrittenType type, String prompt, String answer) {
        return new WrittenExerciseAiResponse("t", "i", prompt, answer, List.of("mouse"), type);
    }

    private WrittenExerciseAiResponse normalizeOne(WrittenExerciseAiResponse exercise) {
        StudySessionAiResponse response = normalizer.normalize(
                new StudySessionAiResponse(List.of(exercise), List.<SpeakingExerciseAiResponse>of()), word);
        return response.writtenExercises().getFirst();
    }
}
