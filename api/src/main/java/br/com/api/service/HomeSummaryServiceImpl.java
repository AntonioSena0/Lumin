package br.com.api.service;

import br.com.api.domain.UserLanguageLevel;
import br.com.api.dto.response.HomeSummaryResponse;
import br.com.api.dto.response.UserLanguageProgressResponse;
import br.com.api.dto.response.UserWordListResponse;
import br.com.api.entity.User;
import br.com.api.mapper.HomeSummaryMapper;
import br.com.api.mapper.UserWordMapper;
import br.com.api.repository.UserRepository;
import br.com.api.repository.UserWordRepository;
import lombok.AllArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@AllArgsConstructor
public class HomeSummaryServiceImpl implements HomeSummaryService{

    private final UserRepository userRepository;
    private final UserWordRepository userWordRepository;
    private final UserLanguageProgressService userLanguageProgressService;
    private final CategoryProgressService categoryProgressService;

    @Override
    public HomeSummaryResponse findByUserId(Long userId) {

        User user = userRepository.findByIdWithRelations(userId)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        UserLanguageProgressResponse languageProgress = userLanguageProgressService.getOrCreate(
                user.getId(),
                user.getChosenLanguage().getId()
        );

        List<UserWordListResponse> recentWords = userWordRepository.findRecentWordsByUserId(userId, PageRequest.of(0, 3))
                .stream()
                .map(UserWordMapper::toUserWordListResponse)
                .toList();

        List<UserWordListResponse> weakRecentWords = userWordRepository.findWeakRecentWordsByUserId(userId, PageRequest.of(0, 3))
                .stream()
                .map(UserWordMapper::toUserWordListResponse)
                .toList();

        return HomeSummaryMapper.toHomeSummaryResponse(
                user,
                languageProgress,
                userWordRepository.countByUserIdAndIsSavedTrue(userId),
                userWordRepository.countByUserIdAndLastPracticedIsNotNull(userId),
                userWordRepository.countByUserIdAndIncorrectAnswersGreaterThan(userId, 0L),
                nextLevelXp(languageProgress.level()),
                levelProgress(languageProgress.level(), languageProgress.xp()),
                recentWords,
                weakRecentWords,
                categoryProgressService.findByUserId(userId)
        );
    }

    private Long nextLevelXp(UserLanguageLevel level) {
        return switch (level) {
            case N1 -> 1000L;
            case N2 -> 3000L;
            case N3 -> null;
        };
    }

    private Double levelProgress(UserLanguageLevel level, Long xp) {
        return switch (level) {
            case N1 -> Math.min((double) xp / 1000.0, 1.0);
            case N2 -> Math.max(0.0, Math.min((double) (xp - 1000L) / 2000.0, 1.0));
            case N3 -> 1.0;
        };
    }

}
