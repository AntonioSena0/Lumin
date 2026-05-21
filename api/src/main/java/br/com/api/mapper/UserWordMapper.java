package br.com.api.mapper;

import br.com.api.dto.response.UserWordResponse;
import br.com.api.entity.UserWord;
import lombok.experimental.UtilityClass;

@UtilityClass
public class UserWordMapper {

    public UserWordResponse toUserWordResponse(UserWord userWord){

        return UserWordResponse
                .builder()
                .id(userWord.getId())
                .user(UserMapper.toUserResponse(userWord.getUser()))
                .word(WordMapper.toWordResponse(userWord.getWord()))
                .lastPracticed(userWord.getLastPracticed())
                .createdAt(userWord.getCreatedAt())
                .build();

    }

}
