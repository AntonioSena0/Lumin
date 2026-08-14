package br.com.api.normalizer;

import br.com.api.domain.WrittenType;
import br.com.api.dto.response.SpeakingExerciseAiResponse;
import br.com.api.dto.response.StudySessionAiResponse;
import br.com.api.dto.response.WrittenExerciseAiResponse;
import br.com.api.entity.Word;
import br.com.api.service.ExerciseOptionService;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@Component
@AllArgsConstructor
public class ExerciseGenerationNormalizer {

    private final ExerciseOptionService exerciseOptionService;

    public StudySessionAiResponse normalize(StudySessionAiResponse response, Word word) {
        return new StudySessionAiResponse(
                normalizeWrittenExercises(response.writtenExercises(), word),
                normalizeSpeakingExercises(response.speakingExercises(), word)
        );
    }

    private List<WrittenExerciseAiResponse> normalizeWrittenExercises(List<WrittenExerciseAiResponse> exercises, Word word) {
        return exercises.stream()
                .map(exercise -> normalizeWrittenExercise(exercise, word))
                .toList();
    }

    private WrittenExerciseAiResponse normalizeWrittenExercise(WrittenExerciseAiResponse exercise, Word word) {
        if (exercise.subType() == WrittenType.MULTIPLE_CHOICE) {
            return normalizeMultipleChoice(exercise, word);
        }

        return new WrittenExerciseAiResponse(
                normalizeText(exercise.title()),
                normalizeText(exercise.instruction()),
                normalizeText(exercise.prompt()),
                normalizeText(exercise.correctAnswer()),
                List.of(),
                exercise.subType()
        );
    }

    private WrittenExerciseAiResponse normalizeMultipleChoice(WrittenExerciseAiResponse exercise, Word word) {
        String correctAnswer = normalizeText(word.getTranslated());

        return new WrittenExerciseAiResponse(
                normalizeText(exercise.title()),
                normalizeText(exercise.instruction()),
                normalizeText(exercise.prompt()),
                correctAnswer,
                exerciseOptionService.buildMultipleChoiceOptions(word, exercise.options()),
                exercise.subType()
        );

    }

    private List<SpeakingExerciseAiResponse> normalizeSpeakingExercises(List<SpeakingExerciseAiResponse> exercises, Word word) {
        return exercises.stream()
                .map(exercise -> normalizeSpeakingExercise(exercise, word))
                .toList();
    }

    private SpeakingExerciseAiResponse normalizeSpeakingExercise(SpeakingExerciseAiResponse exercise, Word word) {
        Set<String> requiredWords = new LinkedHashSet<>();

        if (exercise.requiredWords() != null) {
            exercise.requiredWords().stream()
                    .map(this::normalizeText)
                    .filter(requiredWord -> !requiredWord.isBlank())
                    .forEach(requiredWords::add);
        }

        requiredWords.add(normalizeText(word.getTranslated()));

        return new SpeakingExerciseAiResponse(
                normalizeText(exercise.title()),
                normalizeText(exercise.instruction()),
                normalizeText(exercise.prompt()),
                new ArrayList<>(requiredWords)
        );
    }

    private String normalizeText(String value) {
        return value == null ? "" : value.trim();
    }
}