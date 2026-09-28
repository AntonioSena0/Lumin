package br.com.mailservice.service;

import br.com.mailservice.dto.event.MailEvent;

public interface MailService {

    void sendEmail(MailEvent event);

}
