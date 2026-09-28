package br.com.api.producer;

import br.com.api.dto.event.MailEvent;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class MailProducerImpl implements MailProducer{

    private final RabbitTemplate rabbitTemplate;
    private final String exchange;
    private final String routing;

    public MailProducerImpl(
            RabbitTemplate rabbitTemplate,
            @Value("${RABBIT_EXCHANGE:mail.exchange}") String exchange,
            @Value("${RABBIT_ROUTING:mail.send}") String routing
    ) {
        this.rabbitTemplate = rabbitTemplate;
        this.exchange = exchange;
        this.routing = routing;
    }

    @Override
    public void sendCode(String to, String code) {
        rabbitTemplate.convertAndSend(
                exchange,
                routing,
                MailEvent
                        .builder()
                        .to(to)
                        .subject("Seu código Lumin")
                        .template("code")
                        .vars(Map.of("code", code))
                        .build()
        );
    }

}
