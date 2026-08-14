package br.com.api.dto.response;

import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;

@JsonTypeInfo(use = JsonTypeInfo.Id.NAME, property = "type")
@JsonSubTypes({
        @JsonSubTypes.Type(value = WrittenExerciseCheckResponse.class, name = "written"),
        @JsonSubTypes.Type(value = SpeakingExerciseCheckResponse.class, name = "speaking")
})
public sealed interface ExerciseCheckResponse permits WrittenExerciseCheckResponse, SpeakingExerciseCheckResponse{
}
