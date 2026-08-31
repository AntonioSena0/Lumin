package br.com.api.mapper;

import br.com.api.dto.response.CategoryProgressResponse;
import br.com.api.dto.response.HomeSummaryResponse;
import br.com.api.dto.response.UserLanguageProgressResponse;
import br.com.api.dto.response.UserWordListResponse;
import br.com.api.entity.User;
import lombok.experimental.UtilityClass;

import java.util.List;

@UtilityClass
public class HomeSummaryMapper {

    public HomeSummaryResponse toHomeSummaryResponse(User user, UserLanguageProgressResponse languageProgress, long savedWords, long practicedWords, long weakWords, Long nextLevelXp, Double levelProgress, List<UserWordListResponse> recentWords, List<UserWordListResponse> weakRecentWords, List<CategoryProgressResponse> categoriesProgress){

        return HomeSummaryResponse
                .builder()
                .userId(user.getId())
                .userName(user.getName())
                .languageId(languageProgress.language().id())
                .languageName(languageProgress.language().name())
                .languageCode(languageProgress.language().code())
                .level(languageProgress.level())
                .xp(languageProgress.xp())
                .nextLevelXp(nextLevelXp)
                .levelProgress(levelProgress)
                .savedWords(savedWords)
                .practicedWords(practicedWords)
                .weakWords(weakWords)
                .recentWords(recentWords)
                .weakRecentWords(weakRecentWords)
                .categoriesProgress(categoriesProgress)
                .build();

    }

}
