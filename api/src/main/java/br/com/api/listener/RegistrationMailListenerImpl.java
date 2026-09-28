package br.com.api.listener;

import br.com.api.dto.event.PasswordChangedEvent;
import br.com.api.dto.event.UserRegisteredEvent;
import br.com.api.producer.MailProducer;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Component
@AllArgsConstructor
public class RegistrationMailListenerImpl implements RegistrationMailListener {

    private final MailProducer mailProducer;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void onRegistered(UserRegisteredEvent event){
        mailProducer.sendCode(event.email(), event.code());
    }

    @Override
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void onPasswordChanged(PasswordChangedEvent event){
        mailProducer.sendPasswordChanged(event.email(), event.name());
    }

}
