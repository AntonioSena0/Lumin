package br.com.api.service;

import br.com.api.dto.request.UserRequest;
import br.com.api.entity.Avatar;
import br.com.api.entity.Language;
import br.com.api.entity.Setting;
import br.com.api.entity.User;
import br.com.api.exception.ConflictException;
import br.com.api.repository.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserCreateAppLanguageTest {

    @Mock private UserRepository repository;
    @Mock private LanguageRepository languageRepository;
    @Mock private AvatarRepository avatarRepository;
    @Mock private SettingRepository settingRepository;
    @Mock private PasswordEncoder passwordEncoder;
    @Mock private VerificationCodeServiceImpl verificationCodeService;
    @Mock private RefreshTokenRepository refreshTokenRepository;
    @Mock private PasswordResetCodeRepository passwordResetCodeRepository;
    @Mock private ApplicationEventPublisher publisher;

    private UserServiceImpl service;
    private Language pt;
    private Language en;

    @BeforeEach
    void setUp() {
        service = new UserServiceImpl(repository, languageRepository, avatarRepository, settingRepository,
                passwordEncoder, verificationCodeService, refreshTokenRepository, passwordResetCodeRepository, publisher);
        pt = Language.builder().id(1).code("pt-BR").name("Português (Brasil)").build();
        en = Language.builder().id(2).code("en").name("English").build();
        lenient().when(repository.findByName(any())).thenReturn(Optional.empty());
        lenient().when(repository.findByEmail(any())).thenReturn(Optional.empty());
        lenient().when(languageRepository.findById(1)).thenReturn(Optional.of(pt));
        lenient().when(languageRepository.findById(2)).thenReturn(Optional.of(en));
        lenient().when(avatarRepository.findById(1)).thenReturn(Optional.of(Avatar.builder().id(1).name("Default").imgUrl("/x.png").build()));
        lenient().when(passwordEncoder.encode(any())).thenReturn("hash");
        lenient().when(repository.save(any(User.class))).thenAnswer(inv -> {
            User u = inv.getArgument(0);
            u.setId(5L);
            return u;
        });
    }

    @Test
    void appLanguageDetectedByTheAppIsSaved() {
        service.create(new UserRequest("ana", "ana@mail.com", "12345678", 1, 2, 2));

        assertThat(savedSetting().getAppLanguage()).isEqualTo(en);
    }

    @Test
    void missingAppLanguageFallsBackToNativeLanguage() {
        service.create(new UserRequest("ana", "ana@mail.com", "12345678", 1, 2, null));

        assertThat(savedSetting().getAppLanguage()).isEqualTo(pt);
    }

    @Test
    void duplicatedEmailIsRejected() {
        when(repository.findByEmail("ana@mail.com")).thenReturn(Optional.of(new User()));

        assertThatThrownBy(() -> service.create(new UserRequest("ana", "ana@mail.com", "12345678", 1, 2, null)))
                .isInstanceOf(ConflictException.class);
        verify(repository, never()).save(any());
    }

    private Setting savedSetting() {
        ArgumentCaptor<Setting> captor = ArgumentCaptor.forClass(Setting.class);
        verify(settingRepository).save(captor.capture());
        return captor.getValue();
    }
}
