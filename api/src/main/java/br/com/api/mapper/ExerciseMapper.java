package br.com.api.mapper;

import br.com.api.dto.response.ExerciseCheckResponse;
import br.com.api.dto.response.ExerciseResponse;
import br.com.api.entity.Exercise;
import br.com.api.exception.BusinessException;
import br.com.api.entity.SpeakingExercise;
import br.com.api.entity.WrittenExercise;
import lombok.experimental.UtilityClass;

@UtilityClass
public class ExerciseMapper {

    public ExerciseResponse toExerciseResponse(Exercise exercise){
        return switch (exercise){
            case WrittenExercise we -> WrittenExerciseMapper.toWrittenExerciseResponse(we);
            case SpeakingExercise se -> SpeakingExerciseMapper.toSpeakingExerciseResponse(se);
            default -> throw new BusinessException("EXERCISE_TYPE_INVALID", "Tipo de exercício não identificado");
        };
    }

    public ExerciseCheckResponse toExerciseCheckResponse(Exercise exercise, boolean correct){
        return switch (exercise){
            case WrittenExercise we -> WrittenExerciseMapper.toWrittenExerciseCheckResponse(we, correct);
            case SpeakingExercise se -> SpeakingExerciseMapper.toSpeakingExerciseCheckResponse(se, correct);
            default -> throw new BusinessException("EXERCISE_TYPE_INVALID", "Tipo de exercício não identificado");
        };
    }

}
