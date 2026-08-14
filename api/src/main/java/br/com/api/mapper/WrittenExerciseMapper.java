package br.com.api.mapper;

import br.com.api.dto.response.WrittenExerciseCheckResponse;
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
                .completed(writtenExercise.isCompleted())
                .correct(writtenExercise.getCorrect())
                .subType(writtenExercise.subType)
                .language(LanguageMapper.toLanguageResponse(writtenExercise.getLanguage()))
                .word(WordMapper.toWordResponse(writtenExercise.getWord()))
                .options(writtenExercise.getOptions())
                .createdAt(writtenExercise.getCreatedAt())
                .build();

    }

    public WrittenExerciseCheckResponse toWrittenExerciseCheckResponse(WrittenExercise writtenExercise, boolean correct){

        return WrittenExerciseCheckResponse
                .builder()
                .id(writtenExercise.getId())
                .correct(correct)
                .correctAnswer(writtenExercise.getCorrectAnswer())
                .build();

    }

}
