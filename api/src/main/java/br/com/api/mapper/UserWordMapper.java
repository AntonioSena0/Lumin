package br.com.api.mapper;

import br.com.api.dto.response.UserWordResponse;
import br.com.api.entity.UserWord;
import lombok.experimental.UtilityClass;

@UtilityClass
public class UserWordMapper {

    public UserWordResponse toUserWordResponse(UserWord userWord){

        return UserWordResponse
                .builder()
                .user(UserMapper.toUserResponse(userWord.getUser()))
                .word(WordMapper.toWordResponse(userWord.getWord()))
                .lastPracticed(userWord.getLastPracticed())
                .correctAnswers(userWord.getCorrectAnswers())
                .incorrectAnswers(userWord.getIncorrectAnswers())
                .isSaved(userWord.isSaved())
                .level(userWord.getLevel())
                .createdAt(userWord.getCreatedAt())
                .build();

    }

}
