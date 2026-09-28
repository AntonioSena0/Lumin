package br.com.api.service;

import br.com.api.dto.event.UserRegisteredEvent;
import br.com.api.entity.VerificationCode;
import br.com.api.repository.VerificationCodeRepository;
import br.com.api.util.CodeGenerator;
import lombok.AllArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@AllArgsConstructor
public class VerificationCodeServiceImpl implements VerificationCodeService {

    private final VerificationCodeRepository repository;
    private final PasswordEncoder passwordEncoder;
    private final ApplicationEventPublisher publisher;

    @Override
    @Transactional
    public void issue(String email, String name) {
        String code = CodeGenerator.sixDigits();
        repository.save(VerificationCode
                .builder()
                .email(email)
                .code(passwordEncoder.encode(code))
                .expiresAt(LocalDateTime.now().plusMinutes(10))
                .lastSentAt(LocalDateTime.now())
                .attempts(0)
                .build());
        publisher.publishEvent(UserRegisteredEvent
                .builder()
                .email(email)
                .name(name)
                .code(code)
                .build());
    }

    @Override
    @Transactional
    public void revoke(String email) {
        repository.deleteById(email);
    }
}
