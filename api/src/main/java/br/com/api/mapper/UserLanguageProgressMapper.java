package br.com.api.mapper;

import br.com.api.dto.response.UserLanguageProgressResponse;
import br.com.api.entity.UserLanguageProgress;
import lombok.experimental.UtilityClass;

@UtilityClass
public class UserLanguageProgressMapper {

    public UserLanguageProgressResponse toUserLanguageProgressResponse(UserLanguageProgress progress) {
        return UserLanguageProgressResponse
                .builder()
                .user(UserMapper.toUserResponse(progress.getUser()))
                .language(LanguageMapper.toLanguageResponse(progress.getLanguage()))
                .level(progress.getLevel())
                .xp(progress.getXp())
                .totalSessions(progress.getTotalSessions())
                .totalCorrectAnswers(progress.getTotalCorrectAnswers())
                .totalIncorrectAnswers(progress.getTotalIncorrectAnswers())
                .lastPracticed(progress.getLastPracticed())
                .createdAt(progress.getCreatedAt())
                .updatedAt(progress.getUpdatedAt())
                .build();
    }

}
