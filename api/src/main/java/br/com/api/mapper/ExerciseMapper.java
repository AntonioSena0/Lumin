package br.com.api.mapper;

import br.com.api.dto.response.ExerciseResponse;
import br.com.api.dto.response.SpeakingExerciseResponse;
import br.com.api.dto.response.WrittenExerciseResponse;
import br.com.api.entity.Exercise;
import br.com.api.entity.SpeakingExercise;
import br.com.api.entity.WrittenExercise;
import br.com.api.factory.ExerciseFactory;
import lombok.AllArgsConstructor;
import lombok.experimental.UtilityClass;

@UtilityClass
public class ExerciseMapper {

    public ExerciseResponse toExerciseResponse(Exercise exercise){
        return switch (exercise){
            case WrittenExercise we -> WrittenExerciseMapper.toWrittenExerciseResponse(we);
            case SpeakingExercise se -> SpeakingExerciseMapper.toSpeakingExerciseResponse(se);
            default -> throw new RuntimeException("Tipo de exercício não identificado");
        };
    }

}
