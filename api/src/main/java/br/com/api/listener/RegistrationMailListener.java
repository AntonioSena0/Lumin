package br.com.api.listener;

import br.com.api.dto.event.PasswordChangedEvent;
import br.com.api.dto.event.UserRegisteredEvent;

public interface RegistrationMailListener {

    void onRegistered(UserRegisteredEvent event);

    void onPasswordChanged(PasswordChangedEvent event);

}
