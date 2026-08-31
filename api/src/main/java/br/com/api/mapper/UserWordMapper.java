package br.com.api.mapper;

import br.com.api.dto.response.UserWordListResponse;
import br.com.api.entity.UserWord;
import lombok.experimental.UtilityClass;

@UtilityClass
public class UserWordMapper {

    public UserWordListResponse toUserWordListResponse(UserWord userWord){

        long correctAnswers = userWord.getCorrectAnswers();
        long incorrectAnswers = userWord.getIncorrectAnswers();
        long totalAnswers = correctAnswers + incorrectAnswers;

        double accuracy = totalAnswers == 0
                ? 0.0
                : (double) correctAnswers / totalAnswers;

        return UserWordListResponse
                .builder()
                .wordId(userWord.getWord().getId())
                .original(userWord.getWord().getOriginal())
                .translated(userWord.getWord().getTranslated())
                .description(userWord.getWord().getDescription())
                .categoryId(userWord.getWord().getCategory().getId())
                .categoryName(userWord.getWord().getCategory().getName())
                .fromLanguageId(userWord.getWord().getFromLanguage().getId())
                .fromLanguageCode(userWord.getWord().getFromLanguage().getCode())
                .toLanguageId(userWord.getWord().getToLanguage().getId())
                .toLanguageCode(userWord.getWord().getToLanguage().getCode())
                .isSaved(userWord.isSaved())
                .level(userWord.getLevel())
                .correctAnswers(userWord.getCorrectAnswers())
                .incorrectAnswers(userWord.getIncorrectAnswers())
                .accuracy(Math.round(accuracy * 100.0) / 100.0)
                .lastPracticed(userWord.getLastPracticed())
                .createdAt(userWord.getCreatedAt())
                .build();

    }

}
