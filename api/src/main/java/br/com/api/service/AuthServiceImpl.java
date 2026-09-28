package br.com.api.service;

import br.com.api.dto.request.LoginRequest;
import br.com.api.dto.request.ResendRequest;
import br.com.api.dto.request.UserRequest;
import br.com.api.dto.request.VerifyRequest;
import br.com.api.dto.response.AuthRegisterResponse;
import br.com.api.dto.response.TokenPair;
import br.com.api.dto.response.UserMeResponse;
import br.com.api.entity.RefreshToken;
import br.com.api.entity.User;
import br.com.api.exception.BusinessException;
import br.com.api.exception.EmailNotVerifiedException;
import br.com.api.exception.NotFoundException;
import br.com.api.exception.TooManyRequestException;
import br.com.api.exception.UnauthorizedException;
import br.com.api.repository.RefreshTokenRepository;
import br.com.api.repository.UserRepository;
import br.com.api.repository.VerificationCodeRepository;
import lombok.AllArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
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
    private final PasswordEncoder passwordEncoder;
    private final VerificationCodeRepository verificationCodeRepository;
    private final ApplicationEventPublisher publisher;
    private final VerificationCodeServiceImpl verificationCodeService;

    @Override
    @Transactional
    public AuthRegisterResponse register(UserRequest request) {

        UserMeResponse created = userService.create(request);

        issueCode(request.email(), created.name());

        String access = jwtService.issue(created.id(), false);
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
                .userMeResponse(created)
                .build();

    }

    @Override
    @Transactional
    public TokenPair login(LoginRequest request) {

        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.email(), request.password())
        );

        User user = (User) authentication.getPrincipal();

        if (!user.isEmailVerified()) {
            verificationCodeRepository.findById(user.getEmail()).ifPresentOrElse(
                    verificationCode -> {
                        long seconds = java.time.Duration.between(verificationCode.getLastSentAt(), LocalDateTime.now()).getSeconds();
                        if (seconds >= 60) {
                            issueCode(user.getEmail(), user.getName());
                        }
                    },
                    () -> issueCode(user.getEmail(), user.getName()));
            throw new EmailNotVerifiedException();
        }

        String access = jwtService.issue(user.getId(), true);
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
            throw new UnauthorizedException();
        }

        UUID jti = UUID.fromString(refreshJti);

        RefreshToken old = refreshTokenRepository.findById(jti)
                .orElseThrow(UnauthorizedException::new);

        if(old.isRevoked() || old.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new UnauthorizedException();
        }

        old.setRevoked(true);
        String access = jwtService.issue(old.getUser().getId(), old.getUser().isEmailVerified());
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

    @Override
    @Transactional
    public void verify(VerifyRequest request) {

        VerificationCode verificationCode = verificationCodeRepository.findById(request.email())
                .orElseThrow(() -> new BusinessException("CODE_INVALID", "Código inválido"));

        if(verificationCode.getExpiresAt().isBefore(LocalDateTime.now()) || verificationCode.getAttempts() >= 5){
            verificationCodeRepository.deleteById(request.email());
            throw new BusinessException("CODE_INVALID", "Código inválido");
        }

        if(!passwordEncoder.matches(request.code(), verificationCode.getCode())){
            verificationCode.setAttempts(verificationCode.getAttempts() + 1);
            verificationCodeRepository.saveAndFlush(verificationCode);
            throw new BusinessException("CODE_INVALID", "Código inválido");
        }

        verificationCodeRepository.deleteById(request.email());
        userRepository.findByEmail(request.email()).ifPresent(user -> user.setEmailVerified(true));

    }

    @Override
    @Transactional
    public void resend(ResendRequest request) {

        verificationCodeRepository.findById(request.email()).ifPresent(verificationCode -> {
            long seconds = Duration.between(verificationCode.getLastSentAt(), LocalDateTime.now()).getSeconds();
            if(seconds < 60){
                throw new TooManyRequestException("CODE_RESEND_COOLDOWN", "Aguarde " + (60 - seconds) + "s");
            }
        });

        User user = userRepository.findByEmail(request.email())
                .orElseThrow(() -> new NotFoundException("USER_NOT_FOUND", "Usuário não encontrado"));

        if (user.isEmailVerified()) {
            return;
        }

        issueCode(request.email(), user.getName());

    }

    private void issueCode(String email, String name){
        verificationCodeService.issue(email, name);
    }

}
