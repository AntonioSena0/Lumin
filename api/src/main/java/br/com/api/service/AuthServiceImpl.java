package br.com.api.service;

import br.com.api.domain.OAuthProvider;
import br.com.api.dto.request.*;
import br.com.api.dto.response.*;
import br.com.api.dto.response.OAuthResult;
import br.com.api.dto.event.PasswordChangedEvent;
import br.com.api.dto.event.UserRegisteredEvent;
import br.com.api.dto.request.PasswordResetConfirmRequest;
import br.com.api.entity.*;
import br.com.api.util.CodeGenerator;
import br.com.api.exception.BusinessException;
import br.com.api.exception.ConflictException;
import br.com.api.exception.EmailNotVerifiedException;
import br.com.api.exception.NotFoundException;
import br.com.api.exception.TooManyRequestException;
import br.com.api.exception.UnauthorizedException;
import br.com.api.mapper.UserMapper;
import br.com.api.repository.OAuthAccountRepository;
import br.com.api.repository.PasswordResetCodeRepository;
import br.com.api.repository.RefreshTokenRepository;
import br.com.api.repository.UserRepository;
import br.com.api.repository.VerificationCodeRepository;
import lombok.AllArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Optional;
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
    private final VerificationCodeServiceImpl verificationCodeService;
    private final OAuthService oAuthService;
    private final OAuthAccountRepository oAuthAccountRepository;
    private final PasswordResetCodeRepository passwordResetCodeRepository;
    private final ApplicationEventPublisher publisher;

    @Override
    @Transactional
    public AuthRegisterResponse register(UserRequest request) {

        UserMeResponse created = userService.create(request);

        issueCode(request.email(), created.name());

        return buildSession(created);

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

        if(!old.getUser().isEmailVerified()) {
            old.setRevoked(true);
            throw new EmailNotVerifiedException();
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

        if(verificationCode.getWindowStartedAt().isBefore(LocalDateTime.now().minusHours(1))){
            verificationCode.setWindowAttempts(0);
            verificationCode.setWindowStartedAt(LocalDateTime.now());
        }
        if(verificationCode.getWindowAttempts() >= 20){
            throw new TooManyRequestException("CODE_RATE_LIMITED", "Muitas tentativas. Tente novamente em uma hora");
        }

        if(!passwordEncoder.matches(request.code(), verificationCode.getCode())){
            verificationCode.setAttempts(verificationCode.getAttempts() + 1);
            verificationCode.setWindowAttempts(verificationCode.getWindowAttempts() + 1);
            verificationCodeRepository.saveAndFlush(verificationCode);
            throw new BusinessException("CODE_INVALID", "Código inválido");
        }

        verificationCodeRepository.deleteById(request.email());
        userRepository.findByEmail(request.email()).ifPresentOrElse(
                user -> user.setEmailVerified(true),
                () -> userRepository.findByPendingEmail(request.email()).ifPresent(user -> {
                    user.setEmail(request.email());
                    user.setPendingEmail(null);
                    refreshTokenRepository.revokeAllByUser(user.getId());
                }));

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

        Optional<User> user = userRepository.findByEmail(request.email())
                .or(() -> userRepository.findByPendingEmail(request.email()));
        if (user.isEmpty()) {
            return;
        }

        if (request.email().equals(user.get().getEmail()) && user.get().isEmailVerified()) {
            return;
        }

        issueCode(request.email(), user.get().getName());

    }

    @Override
    @Transactional
    public void forgotPassword(ResendRequest request) {

        passwordResetCodeRepository.findById(request.email()).ifPresent(resetCode -> {
            long seconds = Duration.between(resetCode.getLastSentAt(), LocalDateTime.now()).getSeconds();
            if(seconds < 60){
                throw new TooManyRequestException("CODE_RESEND_COOLDOWN", "Aguarde " + (60 - seconds) + "s");
            }
        });

        Optional<User> user = userRepository.findByEmail(request.email());
        if (user.isEmpty()) {
            return;
        }

        passwordResetCodeRepository.findById(request.email()).ifPresent(resetCode -> {
            long seconds = Duration.between(resetCode.getLastSentAt(), LocalDateTime.now()).getSeconds();
            if(seconds < 60){
                throw new TooManyRequestException("CODE_RESEND_COOLDOWN", "Aguarde " + (60 - seconds) + "s");
            }
        });

        String code = CodeGenerator.sixDigits();
        passwordResetCodeRepository.save(PasswordResetCode
                .builder()
                .email(request.email())
                .code(passwordEncoder.encode(code))
                .expiresAt(LocalDateTime.now().plusMinutes(10))
                .lastSentAt(LocalDateTime.now())
                .attempts(0)
                .build());
        publisher.publishEvent(UserRegisteredEvent.builder().email(request.email()).name(user.get().getName()).code(code).build());

    }

    @Override
    @Transactional
    public void resetPassword(PasswordResetConfirmRequest request) {

        String email = request.email();

        PasswordResetCode resetCode = passwordResetCodeRepository.findById(email)
                .orElseThrow(() -> new BusinessException("CODE_INVALID", "Código inválido"));

        if(resetCode.getWindowStartedAt().isBefore(LocalDateTime.now().minusHours(1))){
            resetCode.setWindowAttempts(0);
            resetCode.setWindowStartedAt(LocalDateTime.now());
        }
        if(resetCode.getWindowAttempts() >= 20){
            throw new TooManyRequestException("CODE_RATE_LIMITED", "Muitas tentativas. Tente novamente em uma hora");
        }

        if(resetCode.getExpiresAt().isBefore(LocalDateTime.now()) || resetCode.getAttempts() >= 5){
            passwordResetCodeRepository.deleteById(email);
            throw new BusinessException("CODE_INVALID", "Código inválido");
        }

        if(!passwordEncoder.matches(request.code(), resetCode.getCode())){
            resetCode.setAttempts(resetCode.getAttempts() + 1);
            resetCode.setWindowAttempts(resetCode.getWindowAttempts() + 1);
            passwordResetCodeRepository.saveAndFlush(resetCode);
            throw new BusinessException("CODE_INVALID", "Código inválido");
        }

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new NotFoundException("USER_NOT_FOUND", "Usuário não encontrado"));

        passwordResetCodeRepository.deleteById(email);
        user.setPassword(passwordEncoder.encode(request.newPassword()));
        refreshTokenRepository.revokeAllByUser(user.getId());
        publisher.publishEvent(PasswordChangedEvent.builder().email(user.getEmail()).name(user.getName()).build());

    }

    private TokenPair loginSocial(User user) {

        AuthRegisterResponse session = buildSession(UserMapper.toUserMeResponse(user));

        return session.tokenPair();

    }

    private void issueCode(String email, String name){
        verificationCodeService.issue(email, name);
    }

    @Override
    @Transactional
    public OAuthResult oauth(OAuthRequest request) {

        OAuthPendingResponse pendingResponse = oAuthService.resolveGoogle(request.code(), request.redirectUri());

        return oAuthAccountRepository.findById(new OAuthAccountId(pendingResponse.providerId(), pendingResponse.provider()))
                .map(acc -> new OAuthResult(loginSocial(acc.getUser()), null))
                .orElseGet(() -> new OAuthResult(null, pendingResponse));

    }

    @Override
    @Transactional
    public AuthRegisterResponse registerOAuth(UserOAuthRequest request) {

        if (request.provider() != OAuthProvider.GOOGLE) {
            throw new BusinessException("OAUTH_INVALID", "Provedor não suportado");
        }

        OAuthPendingResponse pending = oAuthService.resolveGoogle(request.code(), request.redirectUri());

        if (oAuthAccountRepository.existsById(new OAuthAccountId(pending.providerId(), pending.provider()))) {
            throw new ConflictException();
        }

        String randomPassword = UUID.randomUUID().toString();

        UserMeResponse created = userService.create(new UserRequest(
                request.name(),
                pending.email(),
                randomPassword,
                request.nativeLanguage(),
                request.chosenLanguage()
        ));

        oAuthAccountRepository.save(OAuthAccount
                        .builder()
                        .id(new OAuthAccountId(pending.providerId(), pending.provider()))
                        .user(userRepository.getReferenceById(created.id()))
                        .build()
        );

        if(pending.emailVerified()){
            userRepository.getReferenceById(created.id()).setEmailVerified(true);
        } else {
            verificationCodeService.issue(pending.email(), request.name());
        }

        return buildSession(created);

    }

    private AuthRegisterResponse buildSession(UserMeResponse created) {

        boolean verified = userRepository.findById(created.id())
                .orElseThrow(() -> new NotFoundException("USER_NOT_FOUND", "Usuário não encontrado"))
                .isEmailVerified();

        String access = jwtService.issue(created.id(), verified);

        RefreshToken rt = refreshTokenRepository.save(RefreshToken.builder()
                .user(userRepository.getReferenceById(created.id()))
                .expiresAt(LocalDateTime.now().plusDays(7)).revoked(false).build());

        UserMeResponse user = UserMapper.toUserMeResponse(userRepository.findByIdWithRelations(created.id())
                .orElseThrow(() -> new NotFoundException("USER_NOT_FOUND", "Usuário não encontrado")));

        return new AuthRegisterResponse(user, TokenPair.builder().access(access).refreshJti(rt.getJti().toString()).build());

    }

}
