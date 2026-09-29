package br.com.api.service;

import br.com.api.domain.OAuthProvider;
import br.com.api.dto.request.OAuthRequest;
import br.com.api.dto.response.OAuthPendingResponse;
import br.com.api.dto.response.OAuthResult;
import br.com.api.dto.response.TokenPair;
import br.com.api.entity.*;
import br.com.api.repository.OAuthAccountRepository;
import br.com.api.repository.RefreshTokenRepository;
import br.com.api.repository.UserRepository;
import br.com.api.repository.VerificationCodeRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class OAuthBranchTest {

    @Mock
    private AuthenticationManager authenticationManager;

    @Mock
    private RefreshTokenRepository refreshTokenRepository;

    @Mock
    private UserService userService;

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private VerificationCodeRepository verificationCodeRepository;

    @Mock
    private VerificationCodeServiceImpl verificationCodeService;

    @Mock
    private OAuthService oAuthService;

    @Mock
    private OAuthAccountRepository oAuthAccountRepository;

    @Mock
    private br.com.api.repository.PasswordResetCodeRepository passwordResetCodeRepository;

    @Mock
    private org.springframework.context.ApplicationEventPublisher publisher;

    private JwtService jwtService;

    private AuthServiceImpl service;

    @BeforeEach
    void setUp() {
        jwtService = new JwtServiceImpl("0123456789ABCDEF0123456789ABCDEF", 15);
        service = new AuthServiceImpl(authenticationManager, jwtService, refreshTokenRepository, userService,
                userRepository, passwordEncoder, verificationCodeRepository, verificationCodeService,
                oAuthService, oAuthAccountRepository, passwordResetCodeRepository, publisher);
    }

    @Test
    void linkedAccountIssuesTokens() {
        Language nativeLanguage = Language.builder().id(1).code("pt").name("Portugues").build();
        Language targetLanguage = Language.builder().id(2).code("en").name("English").build();
        Avatar avatar = Avatar.builder().id(1).name("Av").imgUrl("http://img/av.png").build();
        User user = User.builder().id(3L).email("o@test.com").password("secret123").emailVerified(true)
                .nativeLanguage(nativeLanguage).chosenLanguage(targetLanguage).avatar(avatar).build();
        OAuthPendingResponse pending = OAuthPendingResponse.builder()
                .email("o@test.com").name("O").provider(OAuthProvider.GOOGLE).providerId("sub-1")
                .emailVerified(true).build();
        OAuthAccountId id = new OAuthAccountId("sub-1", OAuthProvider.GOOGLE);
        OAuthAccount account = OAuthAccount.builder().id(id).user(user).build();
        when(oAuthService.resolveGoogle("code", "http://localhost", null)).thenReturn(pending);
        when(oAuthAccountRepository.findById(id)).thenReturn(Optional.of(account));
        when(userRepository.findById(3L)).thenReturn(Optional.of(user));
        when(userRepository.findByIdWithRelations(3L)).thenReturn(Optional.of(user));
        when(userRepository.getReferenceById(3L)).thenReturn(user);
        when(refreshTokenRepository.save(any(RefreshToken.class))).thenAnswer(invocation -> {
            RefreshToken token = invocation.getArgument(0);
            if (token.getJti() == null) {
                token.setJti(UUID.randomUUID());
            }
            return token;
        });

        OAuthResult result = service.oauth(new OAuthRequest(OAuthProvider.GOOGLE, "code", "http://localhost", null));

        assertThat(result.tokens()).isNotNull();
        assertThat(result.tokens().access()).isNotBlank();
        assertThat(result.pendingResponse()).isNull();
        assertThat(jwtService.getUserId(result.tokens().access())).isEqualTo(3L);
    }

    @Test
    void unknownAccountReturnsPending() {
        OAuthPendingResponse pending = OAuthPendingResponse.builder()
                .email("n@test.com").name("N").provider(OAuthProvider.GOOGLE).providerId("sub-9")
                .emailVerified(true).build();
        when(oAuthService.resolveGoogle("code", "http://localhost", null)).thenReturn(pending);
        when(oAuthAccountRepository.findById(new OAuthAccountId("sub-9", OAuthProvider.GOOGLE)))
                .thenReturn(Optional.empty());

        OAuthResult result = service.oauth(new OAuthRequest(OAuthProvider.GOOGLE, "code", "http://localhost", null));

        assertThat(result.tokens()).isNull();
        assertThat(result.pendingResponse()).isNotNull();
        assertThat(result.pendingResponse().email()).isEqualTo("n@test.com");
    }
}
