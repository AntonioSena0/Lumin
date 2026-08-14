package br.com.api.factory;

import br.com.api.domain.ExerciseCorrect;
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

        return WrittenExercise
                .builder()
                .title(exercise.title())
                .instruction(exercise.instruction())
                .prompt(exercise.prompt())
                .completed(false)
                .correct(ExerciseCorrect.UNEVALUATED)
                .correctAnswer(exercise.correctAnswer())
                .subType(exercise.subType())
                .options(exercise.options())
                .language(language)
                .word(word)
                .build();

    }

    public SpeakingExercise createSpeaking(SpeakingExerciseAiResponse exercise, Language language, Word word) {

        return SpeakingExercise
                .builder()
                .title(exercise.title())
                .instruction(exercise.instruction())
                .prompt(exercise.prompt())
                .completed(false)
                .correct(ExerciseCorrect.UNEVALUATED)
                .requiredWords(exercise.requiredWords())
                .language(language)
                .word(word)
                .build();

    }
}
