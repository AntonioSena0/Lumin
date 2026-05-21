package br.com.api.mapper;

import br.com.api.dto.response.WrittenExerciseResponse;
import br.com.api.entity.WrittenExercise;
import lombok.experimental.UtilityClass;

@UtilityClass
public class WrittenExerciseMapper {

    public WrittenExerciseResponse toWrittenExerciseResponse(WrittenExercise writtenExercise){

        return WrittenExerciseResponse
                .builder()
                .id(writtenExercise.getId())
                .title(writtenExercise.getTitle())
                .instruction(writtenExercise.getInstruction())
                .prompt(writtenExercise.getPrompt())
                .lastPracticed(writtenExercise.getLastPracticed())
                .user(UserMapper.toUserResponse(writtenExercise.getUser()))
                .language(LanguageMapper.toLanguageResponse(writtenExercise.getLanguage()))
                .word(WordMapper.toWordResponse(writtenExercise.getWord()))
                .options(writtenExercise.getOptions())
                .createdAt(writtenExercise.getCreatedAt())
                .build();

    }

}
