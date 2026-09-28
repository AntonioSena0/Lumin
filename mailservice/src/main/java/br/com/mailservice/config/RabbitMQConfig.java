package br.com.mailservice.config;

import org.springframework.amqp.core.*;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

@Configuration
public class RabbitMQConfig {

    @Bean
    DirectExchange mailExchange(@Value("${RABBIT_EXCHANGE:mail.exchange}") String exchange) {
        return new DirectExchange(exchange, true, false);
    }

    @Bean
    DirectExchange mailDlx() {
        return new DirectExchange("mail.dlx", true, false);
    }

    @Bean
    Queue mailQueue(@Value("${RABBIT_QUEUE:mail.queue}") String queue) {
        return QueueBuilder.durable(queue)
                .withArgument("x-dead-letter-exchange", "mail.dlx")
                .withArgument("x-dead-letter-routing-key", "mail.dlq")
                .build();
    }

    @Bean
    Queue mailDlq() {
        return QueueBuilder.durable("mail.dlq").build();
    }

    @Bean
    Binding mailBinding(
            Queue mailQueue,
            DirectExchange mailExchange,
            @Value("${RABBIT_ROUTING:mail.send}") String routing)
    {
        return BindingBuilder.bind(mailQueue).to(mailExchange).with(routing);
    }

    @Bean
    Binding mailDlqBinding(Queue mailDlq, DirectExchange mailDlx) {
        return BindingBuilder.bind(mailDlq).to(mailDlx).with("mail.dlq");
    }

    @Bean
    Jackson2JsonMessageConverter messageConverter() {
        return new Jackson2JsonMessageConverter();
    }

    @Bean
    RestTemplate restTemplate(RestTemplateBuilder builder) {
        return builder.build();
    }

}