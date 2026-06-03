package br.com.api.mapper;

import br.com.api.dto.response.StudySessionResponse;
import br.com.api.entity.StudySession;
import lombok.experimental.UtilityClass;

@UtilityClass
public class StudySessionMapper {

    public StudySessionResponse toStudySessionResponse(StudySession studySession){

        return StudySessionResponse
                .builder()
                .id(studySession.getId())
                .totalExercises(studySession.getTotalExercises())
                .score(studySession.getScore())
                .status(studySession.getStatus())
                .finishedAt(studySession.getFinishedAt())
                .userId(studySession.getUser().getId())
                .exercises(studySession.getExercises().stream()
                        .map(ExerciseMapper::toExerciseResponse)
                        .toList())
                .createdAt(studySession.getCreatedAt())
                .updatedAt(studySession.getUpdatedAt())
                .build();

    }

}
