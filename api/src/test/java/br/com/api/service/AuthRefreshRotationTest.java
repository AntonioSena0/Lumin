package br.com.api.service;

import br.com.api.dto.request.LoginRequest;
import br.com.api.dto.response.TokenPair;
import br.com.api.entity.RefreshToken;
import br.com.api.entity.User;
import br.com.api.exception.UnauthorizedException;
import br.com.api.repository.RefreshTokenRepository;
import br.com.api.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AuthRefreshRotationTest {

    @Mock
    private AuthenticationManager authenticationManager;

    @Mock
    private RefreshTokenRepository refreshTokenRepository;

    @Mock
    private UserService userService;

    @Mock
    private UserRepository userRepository;

    private JwtService jwtService;

    private AuthServiceImpl service;

    @BeforeEach
    void setUp() {
        jwtService = new JwtServiceImpl("0123456789ABCDEF0123456789ABCDEF", 15);
        service = new AuthServiceImpl(authenticationManager, jwtService, refreshTokenRepository, userService, userRepository);
    }

    @Test
    void loginIssuesPairRefreshRotatesAndRevokedReuseFails() {
        User user = User.builder().id(7L).email("a@test.com").password("secret123").build();
        Authentication authentication = new UsernamePasswordAuthenticationToken(user, null, List.of());
        when(authenticationManager.authenticate(any())).thenReturn(authentication);
        when(refreshTokenRepository.save(any(RefreshToken.class))).thenAnswer(invocation -> {
            RefreshToken token = invocation.getArgument(0);
            if (token.getJti() == null) {
                token.setJti(UUID.randomUUID());
            }
            return token;
        });

        TokenPair pair = service.login(new LoginRequest("a@test.com", "password123"));

        assertThat(pair.access()).isNotBlank();
        assertThat(pair.refreshJti()).isNotBlank();
        assertThat(jwtService.getUserId(pair.access())).isEqualTo(7L);

        UUID oldJti = UUID.fromString(pair.refreshJti());
        RefreshToken old = RefreshToken.builder()
                .jti(oldJti)
                .user(user)
                .expiresAt(LocalDateTime.now().plusDays(7))
                .revoked(false)
                .build();
        when(refreshTokenRepository.findById(oldJti)).thenReturn(Optional.of(old));

        TokenPair rotated = service.refresh(pair.refreshJti());

        assertThat(rotated.access()).isNotBlank();
        assertThat(rotated.refreshJti()).isNotBlank();
        assertThat(rotated.refreshJti()).isNotEqualTo(pair.refreshJti());
        assertThat(old.isRevoked()).isTrue();
        assertThat(jwtService.getUserId(rotated.access())).isEqualTo(7L);

        assertThatThrownBy(() -> service.refresh(pair.refreshJti())).isInstanceOf(UnauthorizedException.class);

        UUID newJti = UUID.fromString(rotated.refreshJti());
        RefreshToken storedNext = RefreshToken.builder()
                .jti(newJti)
                .user(user)
                .expiresAt(LocalDateTime.now().plusDays(7))
                .revoked(false)
                .build();
        when(refreshTokenRepository.findById(newJti)).thenReturn(Optional.of(storedNext));

        TokenPair second = service.refresh(rotated.refreshJti());

        assertThat(second.access()).isNotBlank();
        assertThat(second.refreshJti()).isNotBlank();
        assertThat(second.refreshJti()).isNotEqualTo(rotated.refreshJti());
        assertThat(storedNext.isRevoked()).isTrue();
    }
}
