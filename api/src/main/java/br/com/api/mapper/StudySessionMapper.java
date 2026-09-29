package br.com.api.mapper;

import br.com.api.dto.response.StudySessionResponse;
import br.com.api.dto.response.StudySessionSummaryResponse;
import br.com.api.entity.StudySession;
import br.com.api.repository.projection.SessionWordProjection;
import lombok.experimental.UtilityClass;

@UtilityClass
public class StudySessionMapper {

    public StudySessionResponse toStudySessionResponse(StudySession studySession){

        return StudySessionResponse
                .builder()
                .id(studySession.getId())
                .totalExercises(studySession.getTotalExercises())
                .score(studySession.getScore())
                .currentIndex(studySession.getCurrentIndex())
                .status(studySession.getStatus())
                .finishedAt(studySession.getFinishedAt())
                .user(UserMapper.toUserResponse(studySession.getUser()))
                .exercises(studySession.getExercises().stream()
                        .map(ExerciseMapper::toExerciseResponse)
                        .toList())
                .createdAt(studySession.getCreatedAt())
                .updatedAt(studySession.getUpdatedAt())
                .build();

    }

    public StudySessionSummaryResponse toStudySessionSummaryResponse(StudySession studySession, SessionWordProjection word){

        return StudySessionSummaryResponse
                .builder()
                .id(studySession.getId())
                .currentIndex(studySession.getCurrentIndex())
                .totalExercises(studySession.getTotalExercises())
                .score(studySession.getScore())
                .status(studySession.getStatus())
                .finishedAt(studySession.getFinishedAt())
                .wordId(word == null ? null : word.getWordId())
                .wordOriginal(word == null ? null : word.getWordOriginal())
                .wordTranslated(word == null ? null : word.getWordTranslated())
                .languageName(word == null ? null : word.getLanguageName())
                .languageCode(word == null ? null : word.getLanguageCode())
                .createdAt(studySession.getCreatedAt())
                .build();

    }

}
