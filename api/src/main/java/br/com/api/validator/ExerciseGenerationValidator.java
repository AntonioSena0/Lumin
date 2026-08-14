package br.com.api.validator;

import br.com.api.domain.WrittenType;
import br.com.api.dto.response.SpeakingExerciseAiResponse;
import br.com.api.dto.response.StudySessionAiResponse;
import br.com.api.dto.response.WrittenExerciseAiResponse;
import br.com.api.entity.Word;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Component
public class ExerciseGenerationValidator {

    public StudySessionAiResponse validate(StudySessionAiResponse response, Word word) {
        validateBaseResponse(response);
        validateWrittenExercises(response.writtenExercises(), word);
        validateSpeakingExercises(response.speakingExercises(), word);
        return response;
    }

    public void validateBaseResponse(StudySessionAiResponse response) {
        if (response == null) {
            throw new RuntimeException("A IA não retornou exercícios");
        }

        if (response.writtenExercises() == null || response.writtenExercises().size() != 10) {
            throw new RuntimeException("A IA deve retornar exatamente 10 exercícios escritos");
        }

        if (response.speakingExercises() == null || response.speakingExercises().size() != 5) {
            throw new RuntimeException("A IA deve retornar exatamente 5 exercícios de fala");
        }
    }

    private void validateWrittenExercises(List<WrittenExerciseAiResponse> exercises, Word word) {
        if (exercises.stream().anyMatch(exercise -> exercise == null || exercise.subType() == null)) {
            throw new RuntimeException("Todos os exercícios escritos devem conter tipo válido");
        }

        Map<WrittenType, Long> quantities = exercises.stream()
                .collect(Collectors.groupingBy(WrittenExerciseAiResponse::subType, Collectors.counting()));

        validateQuantity(quantities, WrittenType.FILL_IN, 3);
        validateQuantity(quantities, WrittenType.TRANSLATE, 2);
        validateQuantity(quantities, WrittenType.MULTIPLE_CHOICE, 3);
        validateQuantity(quantities, WrittenType.REWRITE, 2);

        exercises.forEach(exercise -> validateWrittenExercise(exercise, word));
    }

    private void validateQuantity(Map<WrittenType, Long> quantities, WrittenType type, long expected) {
        if (quantities.getOrDefault(type, 0L) != expected) {
            throw new RuntimeException("Quantidade inválida para o tipo " + type);
        }
    }

    private void validateWrittenExercise(WrittenExerciseAiResponse exercise, Word word) {
        validateText(exercise.title(), "Título do exercício escrito inválido");
        validateText(exercise.instruction(), "Instrução do exercício escrito inválida");
        validateText(exercise.prompt(), "Prompt do exercício escrito inválido");

        if (exercise.subType() == null) {
            throw new RuntimeException("Tipo do exercício escrito inválido");
        }

        if (exercise.subType() == WrittenType.FILL_IN) {
            validateFillIn(exercise);
        }

        if (exercise.subType() == WrittenType.MULTIPLE_CHOICE) {
            validateMultipleChoice(exercise, word);
        }

        if (exercise.subType() == WrittenType.REWRITE) {
            validateRewrite(exercise, word);
        }

        if (exercise.subType() == WrittenType.TRANSLATE) {
            validateText(exercise.correctAnswer(), "Resposta correta do exercício de tradução inválida");
        }
    }

    private void validateFillIn(WrittenExerciseAiResponse exercise) {
        if (!exercise.prompt().contains("_____")) {
            throw new RuntimeException("Exercício FILL_IN deve conter lacuna");
        }

        validateText(exercise.correctAnswer(), "Resposta correta do exercício FILL_IN inválida");
    }

    private void validateMultipleChoice(WrittenExerciseAiResponse exercise, Word word) {
        if (exercise.options() == null || exercise.options().size() != 4) {
            throw new RuntimeException("Exercício MULTIPLE_CHOICE deve conter exatamente 4 opções");
        }

        String translatedWord = normalize(word.getTranslated());

        boolean containsCorrectAnswer = exercise.options().stream()
                .map(this::normalize)
                .anyMatch(option -> option.equals(translatedWord));

        if (!containsCorrectAnswer) {
            throw new RuntimeException("Exercício MULTIPLE_CHOICE não contém a resposta correta");
        }
    }

    private void validateRewrite(WrittenExerciseAiResponse exercise, Word word) {
        validateText(exercise.correctAnswer(), "Resposta correta do exercício REWRITE inválida");

        if (normalize(exercise.prompt()).contains(normalize(word.getTranslated()))) {
            throw new RuntimeException("Exercício REWRITE não deve entregar a palavra no prompt");
        }
    }

    private void validateSpeakingExercises(List<SpeakingExerciseAiResponse> exercises, Word word) {
        if (exercises.stream().anyMatch(exercise -> exercise == null)) {
            throw new RuntimeException("Todos os exercícios de fala devem ser válidos");
        }

        exercises.forEach(exercise -> validateSpeakingExercise(exercise, word));
    }

    private void validateSpeakingExercise(SpeakingExerciseAiResponse exercise, Word word) {
        validateText(exercise.title(), "Título do exercício de fala inválido");
        validateText(exercise.instruction(), "Instrução do exercício de fala inválida");
        validateText(exercise.prompt(), "Prompt do exercício de fala inválido");

        if (exercise.requiredWords() == null || exercise.requiredWords().isEmpty()) {
            throw new RuntimeException("Exercício de fala deve conter palavras obrigatórias");
        }

        String translatedWord = normalize(word.getTranslated());

        boolean containsRequiredWord = exercise.requiredWords().stream()
                .map(this::normalize)
                .anyMatch(requiredWord -> requiredWord.equals(translatedWord));

        if (!containsRequiredWord) {
            throw new RuntimeException("Exercício de fala deve conter a palavra estudada");
        }
    }

    private void validateText(String value, String message) {
        if (value == null || value.isBlank()) {
            throw new RuntimeException(message);
        }
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim().toLowerCase();
    }
}