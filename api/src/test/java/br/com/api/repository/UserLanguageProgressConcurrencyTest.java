package br.com.api.repository;

import br.com.api.domain.UserLanguageLevel;
import br.com.api.entity.Avatar;
import br.com.api.entity.Language;
import br.com.api.entity.User;
import br.com.api.entity.UserLanguageProgress;
import br.com.api.entity.UserLanguageProgressId;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@ActiveProfiles("test")
class UserLanguageProgressConcurrencyTest {

    @Autowired
    private UserLanguageProgressRepository progressRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private LanguageRepository languageRepository;

    @Autowired
    private AvatarRepository avatarRepository;

    @Autowired
    private PlatformTransactionManager transactionManager;

    @Test
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    void twoConcurrentIncrementsSumAtomically() throws Exception {
        TransactionTemplate tx = new TransactionTemplate(transactionManager);
        tx.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);

        String suffix = Long.toString(System.nanoTime());
        String codeSuffix = suffix.substring(Math.max(0, suffix.length() - 4));

        Avatar avatar = tx.execute(status -> avatarRepository.save(Avatar.builder()
                .name("av-" + suffix)
                .imgUrl("http://img/" + suffix + ".png")
                .build()));
        Language nativeLanguage = tx.execute(status -> languageRepository.save(Language.builder()
                .code("N" + codeSuffix)
                .name("Native " + suffix)
                .build()));
        Language targetLanguage = tx.execute(status -> languageRepository.save(Language.builder()
                .code("T" + codeSuffix)
                .name("Target " + suffix)
                .build()));
        User user = tx.execute(status -> userRepository.save(User.builder()
                .name("xp-user-" + suffix)
                .email("xp-" + suffix + "@test.com")
                .password("secret123")
                .nativeLanguage(nativeLanguage)
                .chosenLanguage(targetLanguage)
                .avatar(avatar)
                .build()));

        Long userId = user.getId();
        Integer languageId = targetLanguage.getId();
        UserLanguageProgressId progressId = new UserLanguageProgressId(userId, languageId);

        tx.executeWithoutResult(status -> progressRepository.save(UserLanguageProgress.builder()
                .id(progressId)
                .user(user)
                .language(targetLanguage)
                .level(UserLanguageLevel.N1)
                .xp(100L)
                .totalSessions(0L)
                .totalCorrectAnswers(0L)
                .totalIncorrectAnswers(0L)
                .placementTestCompleted(false)
                .build()));

        ExecutorService pool = Executors.newFixedThreadPool(2);
        CountDownLatch ready = new CountDownLatch(2);
        CountDownLatch start = new CountDownLatch(1);
        try {
            Future<?> first = pool.submit(() -> {
                ready.countDown();
                try {
                    start.await(10, TimeUnit.SECONDS);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
                TransactionTemplate inner = new TransactionTemplate(transactionManager);
                inner.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
                inner.executeWithoutResult(s -> progressRepository.updateProgress(30L, 1, 2, UserLanguageLevel.N1, userId, languageId));
                return null;
            });
            Future<?> second = pool.submit(() -> {
                ready.countDown();
                try {
                    start.await(10, TimeUnit.SECONDS);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
                TransactionTemplate inner = new TransactionTemplate(transactionManager);
                inner.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
                inner.executeWithoutResult(s -> progressRepository.updateProgress(30L, 1, 2, UserLanguageLevel.N1, userId, languageId));
                return null;
            });

            assertThat(ready.await(10, TimeUnit.SECONDS)).isTrue();
            start.countDown();
            first.get(15, TimeUnit.SECONDS);
            second.get(15, TimeUnit.SECONDS);
        } finally {
            pool.shutdownNow();
        }

        UserLanguageProgress reloaded = tx.execute(status -> progressRepository.findById(progressId).orElseThrow());

        assertThat(reloaded.getXp()).isEqualTo(160L);
        assertThat(reloaded.getTotalSessions()).isEqualTo(2L);
        assertThat(reloaded.getTotalCorrectAnswers()).isEqualTo(2L);
        assertThat(reloaded.getTotalIncorrectAnswers()).isEqualTo(2L);

        tx.executeWithoutResult(status -> {
            progressRepository.deleteById(progressId);
            userRepository.deleteById(userId);
            languageRepository.deleteById(languageId);
            languageRepository.deleteById(nativeLanguage.getId());
            avatarRepository.deleteById(avatar.getId());
        });
    }
}
