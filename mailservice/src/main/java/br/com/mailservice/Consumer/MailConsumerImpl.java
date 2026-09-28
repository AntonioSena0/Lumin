package br.com.mailservice.Consumer;

import br.com.mailservice.dto.event.MailEvent;
import br.com.mailservice.service.MailService;
import lombok.AllArgsConstructor;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Component;

@Component
@AllArgsConstructor
public class MailConsumerImpl implements MailConsumer{

    private final MailService service;

    @Override
    @RabbitListener(queues = "${RABBIT_QUEUE:mail.queue}")
    public void listenMailQueue(@Payload MailEvent event) {
        service.sendEmail(event);
    }

}
