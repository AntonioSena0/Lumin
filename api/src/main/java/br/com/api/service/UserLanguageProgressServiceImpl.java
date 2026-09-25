package br.com.api.service;

import br.com.api.domain.UserLanguageLevel;
import br.com.api.dto.response.UserLanguageProgressResponse;
import br.com.api.entity.Language;
import br.com.api.entity.User;
import br.com.api.entity.UserLanguageProgress;
import br.com.api.entity.UserLanguageProgressId;
import br.com.api.mapper.UserLanguageProgressMapper;
import br.com.api.repository.LanguageRepository;
import br.com.api.repository.UserLanguageProgressRepository;
import br.com.api.repository.UserRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@AllArgsConstructor
public class UserLanguageProgressServiceImpl implements UserLanguageProgressService{

    private final UserLanguageProgressRepository repository;
    private final UserRepository userRepository;
    private final LanguageRepository languageRepository;

    @Override
    public UserLanguageProgressResponse findById(Long userId, Integer languageId) {
        return UserLanguageProgressMapper.toUserLanguageProgressResponse(repository.findByIdWithRelations(userId, languageId)
                .orElseThrow(() -> new RuntimeException("Progresso não encontrado")));
    }

    @Override
    public List<UserLanguageProgressResponse> findByUserId(Long userId) {
        return repository.findByIdUserIdWithRelations(userId).stream()
                .map(UserLanguageProgressMapper::toUserLanguageProgressResponse)
                .toList();
    }

    @Override
    @Transactional
    public UserLanguageProgressResponse getOrCreate(Long userId, Integer languageId){

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        Language language = languageRepository.findById(languageId)
                .orElseThrow(() -> new RuntimeException("Língua não encontrada"));

        UserLanguageProgress userLanguageProgress = getOrCreateEntity(user, language);

        return UserLanguageProgressMapper.toUserLanguageProgressResponse(userLanguageProgress);

    }

    @Override
    @Transactional
    public UserLanguageLevel getOrCreateLevel(User user, Language language){
        return getOrCreateEntity(user, language).getLevel();
    }

    @Override
    @Transactional
    public void registerFinishedSession(User user, Language language, Integer score, Integer totalExercises) {

        UserLanguageProgress userLanguageProgress = getOrCreateEntity(user, language);

        Long gain = score * 10L + 20L;
        long newXp = userLanguageProgress.getXp() + gain;
        UserLanguageLevel newLevel = UserLanguageProgress.levelFor(newXp, userLanguageProgress.getLevel());

        repository.updateProgress(gain, score, totalExercises, newLevel,  user.getId(), language.getId());

    }

    private UserLanguageProgress getOrCreateEntity(User user, Language language) {
        return repository.findById(new UserLanguageProgressId(user.getId(), language.getId()))
                .orElseGet(() -> {
                    UserLanguageProgress progress = new UserLanguageProgress();
                    progress.setId(new UserLanguageProgressId(user.getId(), language.getId()));
                    progress.setUser(user);
                    progress.setLanguage(language);
                    progress.setLevel(UserLanguageLevel.N1);
                    progress.setXp(0L);
                    progress.setTotalSessions(0L);
                    progress.setTotalCorrectAnswers(0L);
                    progress.setTotalIncorrectAnswers(0L);
                    progress.setPlacementTestCompleted(false);
                    return repository.save(progress);
                });
    }

}
