package br.com.api.service;

import br.com.api.dto.request.LoginRequest;
import br.com.api.dto.request.UserRequest;
import br.com.api.dto.response.AuthRegisterResponse;
import br.com.api.dto.response.TokenPair;
import br.com.api.dto.response.UserResponse;
import br.com.api.entity.RefreshToken;
import br.com.api.entity.User;
import br.com.api.repository.RefreshTokenRepository;
import br.com.api.repository.UserRepository;
import lombok.AllArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@AllArgsConstructor
public class AuthServiceImpl implements AuthService{

    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final RefreshTokenRepository refreshTokenRepository;
    private final UserService userService;
    private final UserRepository userRepository;

    @Override
    @Transactional
    public AuthRegisterResponse register(UserRequest request) {

        UserResponse created = userService.create(request);

        String access = jwtService.issue(created.id());
        RefreshToken refreshToken = refreshTokenRepository.save(RefreshToken
                        .builder()
                        .user(userRepository.getReferenceById(created.id()))
                        .expiresAt(LocalDateTime.now().plusDays(7))
                        .revoked(false)
                        .build()
        );

        return AuthRegisterResponse
                .builder()
                .tokenPair(
                    TokenPair
                            .builder()
                            .access(access)
                            .refreshJti(refreshToken.getJti().toString())
                            .build()
                )
                .userResponse(created)
                .build();

    }

    @Override
    @Transactional
    public TokenPair login(LoginRequest request) {

        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.email(), request.password())
        );

        User user = (User) authentication.getPrincipal();
        String access = jwtService.issue(user.getId());
        RefreshToken refreshToken = refreshTokenRepository.save(RefreshToken
                .builder()
                .user(user)
                .expiresAt(LocalDateTime.now().plusDays(7))
                .revoked(false)
                .build()
        );

        return TokenPair
                .builder()
                .access(access)
                .refreshJti(refreshToken.getJti().toString())
                .build();
    }

    @Override
    @Transactional
    public TokenPair refresh(String refreshJti) {

        if(refreshJti == null){
            throw new RuntimeException("Sessão inválida");
        }

        UUID jti = UUID.fromString(refreshJti);

        RefreshToken old = refreshTokenRepository.findById(jti)
                .orElseThrow(() -> new RuntimeException("Sessão inválida"));

        if(old.isRevoked() || old.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("Sessão expirada");
        }

        old.setRevoked(true);
        String access = jwtService.issue(old.getUser().getId());
        RefreshToken next = refreshTokenRepository.save(RefreshToken
                        .builder()
                        .user(old.getUser())
                        .expiresAt(LocalDateTime.now().plusDays(7))
                        .revoked(false)
                        .build());

        return TokenPair
                .builder()
                .access(access)
                .refreshJti(next.getJti().toString())
                .build();
    }

    @Override
    @Transactional
    public void logout(String refreshJti) {

        if(refreshJti == null){
            return;
        }

        try {
            UUID jti = UUID.fromString(refreshJti);
            refreshTokenRepository.findById(jti).ifPresent(refreshToken -> refreshToken.setRevoked(true));
        } catch (IllegalArgumentException e){

        }

    }
}
