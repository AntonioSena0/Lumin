package br.com.api.service;

import br.com.api.domain.WordDomainLevel;
import br.com.api.dto.response.ProfileSummaryResponse;
import br.com.api.dto.response.UserLanguageProgressResponse;
import br.com.api.dto.response.UserWordListResponse;
import br.com.api.entity.User;
import br.com.api.mapper.ProfileSummaryMapper;
import br.com.api.mapper.UserWordMapper;
import br.com.api.repository.UserRepository;
import br.com.api.repository.UserWordRepository;
import lombok.AllArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@AllArgsConstructor
public class ProfileSummaryServiceImpl implements ProfileSummaryService{

    private final UserRepository userRepository;
    private final UserWordRepository userWordRepository;
    private final UserLanguageProgressService userLanguageProgressService;
    private final CategoryProgressService categoryProgressService;

    @Override
    public ProfileSummaryResponse findByUserId(Long userId) {
        User user = userRepository.findByIdWithRelations(userId)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        List<UserLanguageProgressResponse> languagesProgress = userLanguageProgressService.findByUserId(userId);

        List<UserWordListResponse> recentWords = userWordRepository.findRecentWordsByUserId(userId, PageRequest.of(0, 5))
                .stream()
                .map(UserWordMapper::toUserWordListResponse)
                .toList();

        Long totalCorrectAnswers = languagesProgress.stream()
                .mapToLong(UserLanguageProgressResponse::totalCorrectAnswers)
                .sum();

        Long totalIncorrectAnswers = languagesProgress.stream()
                .mapToLong(UserLanguageProgressResponse::totalIncorrectAnswers)
                .sum();

        Long totalSessions = languagesProgress.stream()
                .mapToLong(UserLanguageProgressResponse::totalSessions)
                .sum();

        Double accuracy = calculateAccuracy(totalCorrectAnswers, totalIncorrectAnswers);

        return ProfileSummaryMapper.toProfileSummaryResponse(
                user,
                userWordRepository.countByUserIdAndIsSavedTrue(userId),
                userWordRepository.countByUserIdAndLastPracticedIsNotNull(userId),
                userWordRepository.countByUserIdAndIncorrectAnswersGreaterThan(userId, 0L),
                userWordRepository.countByUserIdAndLevel(userId, WordDomainLevel.FAMILIAR),
                totalSessions,
                totalCorrectAnswers,
                totalIncorrectAnswers,
                accuracy,
                userWordRepository.findLastPracticedByUserId(userId),
                languagesProgress,
                categoryProgressService.findByUserId(userId),
                recentWords
        );
    }

    private Double calculateAccuracy(Long correctAnswers, Long incorrectAnswers) {
        long totalAnswers = correctAnswers + incorrectAnswers;

        if(totalAnswers == 0){
            return 0.0;
        }

        double accuracy = (double) correctAnswers / totalAnswers;

        return Math.round(accuracy * 100.0) / 100.0;
    }

}
