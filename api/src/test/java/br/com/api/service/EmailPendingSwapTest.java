package br.com.api.service;

import br.com.api.dto.request.UserPatchRequest;
import br.com.api.entity.Language;
import br.com.api.entity.User;
import br.com.api.repository.AvatarRepository;
import br.com.api.repository.LanguageRepository;
import br.com.api.repository.PasswordResetCodeRepository;
import br.com.api.repository.RefreshTokenRepository;
import br.com.api.repository.SettingRepository;
import br.com.api.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class EmailPendingSwapTest {

    @Mock
    private UserRepository repository;

    @Mock
    private LanguageRepository languageRepository;

    @Mock
    private AvatarRepository avatarRepository;

    @Mock
    private SettingRepository settingRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private VerificationCodeServiceImpl verificationCodeService;

    @Mock
    private RefreshTokenRepository refreshTokenRepository;

    @Mock
    private PasswordResetCodeRepository passwordResetCodeRepository;

    @Mock
    private ApplicationEventPublisher publisher;

    private UserServiceImpl service;

    @BeforeEach
    void setUp() {
        service = new UserServiceImpl(repository, languageRepository, avatarRepository, settingRepository,
                passwordEncoder, verificationCodeService, refreshTokenRepository, passwordResetCodeRepository,
                publisher);
    }

    private User userWithRelations(Long id, String email) {
        br.com.api.entity.Language nativeLanguage = br.com.api.entity.Language.builder().id(1).code("pt").name("Portugues").build();
        br.com.api.entity.Language targetLanguage = br.com.api.entity.Language.builder().id(2).code("en").name("English").build();
        br.com.api.entity.Avatar avatar = br.com.api.entity.Avatar.builder().id(1).name("Av").imgUrl("http://img/av.png").build();
        return User.builder().id(id).email(email).name("A").emailVerified(true)
                .nativeLanguage(nativeLanguage).chosenLanguage(targetLanguage).avatar(avatar).build();
    }

    @Test
    void sameEmailIsNoOp() {
        User user = userWithRelations(1L, "a@test.com");
        when(repository.findByIdWithRelations(1L)).thenReturn(Optional.of(user));

        service.parcialUpdate(1L, new UserPatchRequest(null, "a@test.com", null, null));

        assertThat(user.getPendingEmail()).isNull();
        assertThat(user.getEmail()).isEqualTo("a@test.com");
        assertThat(user.isEmailVerified()).isTrue();
        verify(verificationCodeService, never()).issue(any(), any());
    }

    @Test
    void changedEmailBecomesPendingKeepingCurrent() {
        User user = userWithRelations(1L, "a@test.com");
        when(repository.findByIdWithRelations(1L)).thenReturn(Optional.of(user));

        service.parcialUpdate(1L, new UserPatchRequest(null, "b@test.com", null, null));

        assertThat(user.getEmail()).isEqualTo("a@test.com");
        assertThat(user.getPendingEmail()).isEqualTo("b@test.com");
        assertThat(user.isEmailVerified()).isTrue();
        verify(verificationCodeService).issue("b@test.com", "A");
        verify(refreshTokenRepository, never()).revokeAllByUser(any());
    }
}
