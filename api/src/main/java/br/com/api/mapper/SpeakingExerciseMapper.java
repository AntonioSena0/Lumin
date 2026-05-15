package br.com.api.mapper;

import br.com.api.dto.SpeakingExerciseResponse;
import br.com.api.entity.SpeakingExercise;
import lombok.experimental.UtilityClass;

@UtilityClass
public class SpeakingExerciseMapper {

    public SpeakingExerciseResponse toSpeakingExerciseResponse(SpeakingExercise speakingExercise){

        return SpeakingExerciseResponse
                .builder()
                .id(speakingExercise.getId())
                .title(speakingExercise.getTitle())
                .prompt(speakingExercise.getPrompt())
                .lastPracticed(speakingExercise.getLastPracticed())
                .user(UserMapper.toUserResponse(speakingExercise.getUser()))
                .language(LanguageMapper.toLanguageResponse(speakingExercise.getLanguage()))
                .word(WordMapper.toWordResponse(speakingExercise.getWord()))
                .requiredWords(speakingExercise.getRequiredWords())
                .createdAt(speakingExercise.getCreatedAt())
                .build();

    }

}
