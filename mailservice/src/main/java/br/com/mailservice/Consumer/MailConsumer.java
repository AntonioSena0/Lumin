package br.com.mailservice.Consumer;

import br.com.mailservice.dto.event.MailEvent;

public interface MailConsumer {

    void listenMailQueue(MailEvent event);

}
