package br.com.api.factory;

import br.com.api.dto.response.WrittenExerciseAiResponse;
import br.com.api.entity.Language;
import br.com.api.entity.User;
import br.com.api.entity.Word;
import br.com.api.entity.WrittenExercise;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class ExerciseFactory {

    public WrittenExercise createWritten(WrittenExerciseAiResponse dto, User user, Language language, Word word) {

        List<String> safeOptions = (dto.options() != null) ? dto.options() : List.of();

        return WrittenExercise
                .builder()
                .title(dto.title())
                .instruction(dto.instruction())
                .prompt(dto.prompt())
                .correctAnswer(dto.correctAnswer())
                .subType(dto.subType())
                .options(safeOptions)
                .user(user)
                .language(language)
                .word(word)
                .build();

    }

}
