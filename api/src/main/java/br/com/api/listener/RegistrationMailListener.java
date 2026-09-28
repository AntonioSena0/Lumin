package br.com.api.listener;

import br.com.api.dto.event.UserRegisteredEvent;

public interface RegistrationMailListener {

    void onRegistered(UserRegisteredEvent event);

}
