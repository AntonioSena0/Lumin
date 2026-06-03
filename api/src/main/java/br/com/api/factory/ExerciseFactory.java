package br.com.api.factory;

import br.com.api.dto.response.SpeakingExerciseAiResponse;
import br.com.api.dto.response.WrittenExerciseAiResponse;
import br.com.api.entity.Language;
import br.com.api.entity.SpeakingExercise;
import br.com.api.entity.Word;
import br.com.api.entity.WrittenExercise;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class ExerciseFactory {

    public WrittenExercise createWritten(WrittenExerciseAiResponse exercise, Language language, Word word) {

        List<String> safeOptions = (exercise.options() != null) ? exercise.options() : List.of();

        return WrittenExercise
                .builder()
                .title(exercise.title())
                .instruction(exercise.instruction())
                .prompt(exercise.prompt())
                .correctAnswer(exercise.correctAnswer())
                .subType(exercise.subType())
                .options(safeOptions)
                .language(language)
                .word(word)
                .build();

    }

    public SpeakingExercise createSpeaking(SpeakingExerciseAiResponse exercise, Language language, Word word){

        List<String> safeRequiredWords = (exercise.requiredWords() != null) ? exercise.requiredWords() : List.of();

        return SpeakingExercise
                .builder()
                .title(exercise.title())
                .instruction(exercise.instruction())
                .prompt(exercise.prompt())
                .requiredWords(safeRequiredWords)
                .language(language)
                .word(word)
                .build();

    }

}
