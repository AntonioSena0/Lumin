package br.com.api.dto.response;

import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;

@JsonTypeInfo(use = JsonTypeInfo.Id.NAME, property = "type")
@JsonSubTypes({
        @JsonSubTypes.Type(value = WrittenExerciseResponse.class, name = "written"),
        @JsonSubTypes.Type(value = SpeakingExerciseResponse.class, name = "speaking")
})
public sealed interface ExerciseResponse permits WrittenExerciseResponse, SpeakingExerciseResponse {
}
