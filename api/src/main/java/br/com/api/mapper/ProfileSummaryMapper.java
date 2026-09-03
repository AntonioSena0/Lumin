package br.com.api.mapper;

import br.com.api.dto.response.CategoryProgressResponse;
import br.com.api.dto.response.ProfileSummaryResponse;
import br.com.api.dto.response.UserLanguageProgressResponse;
import br.com.api.dto.response.UserWordListResponse;
import br.com.api.entity.User;
import lombok.experimental.UtilityClass;

import java.time.LocalDateTime;
import java.util.List;

@UtilityClass
public class ProfileSummaryMapper {

    public ProfileSummaryResponse toProfileSummaryResponse(User user, Long savedWords, Long practicedWords, Long weakWords, Long familiarWords, Long totalSessions, Long totalCorrectAnswers, Long totalIncorrectAnswers, Double accuracy, LocalDateTime lastPracticed, List<UserLanguageProgressResponse> languagesProgress, List<CategoryProgressResponse> categoriesProgress, List<UserWordListResponse> recentWords) {
        return ProfileSummaryResponse
                .builder()
                .userId(user.getId())
                .userName(user.getName())
                .email(user.getEmail())
                .avatar(AvatarMapper.toAvatarResponse(user.getAvatar()))
                .nativeLanguage(LanguageMapper.toLanguageResponse(user.getNativeLanguage()))
                .chosenLanguage(LanguageMapper.toLanguageResponse(user.getChosenLanguage()))
                .savedWords(savedWords)
                .practicedWords(practicedWords)
                .weakWords(weakWords)
                .familiarWords(familiarWords)
                .totalSessions(totalSessions)
                .totalCorrectAnswers(totalCorrectAnswers)
                .totalIncorrectAnswers(totalIncorrectAnswers)
                .accuracy(accuracy)
                .lastPracticed(lastPracticed)
                .languagesProgress(languagesProgress)
                .categoriesProgress(categoriesProgress)
                .recentWords(recentWords)
                .build();
    }

}
