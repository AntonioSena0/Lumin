package br.com.mailservice.config;

import org.springframework.amqp.support.converter.Jackson2JavaTypeMapper;
import org.springframework.amqp.core.*;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.rabbit.config.SimpleRabbitListenerContainerFactory;

import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.AmqpRejectAndDontRequeueException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.retry.interceptor.RetryInterceptorBuilder;
import org.springframework.retry.interceptor.RetryOperationsInterceptor;
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
        Jackson2JsonMessageConverter converter = new Jackson2JsonMessageConverter();
        converter.setTypePrecedence(Jackson2JavaTypeMapper.TypePrecedence.INFERRED);
        return converter;
    }

    @Bean
    RestTemplate restTemplate(RestTemplateBuilder builder) {
        return builder.build();
    }

    @Bean
    RetryOperationsInterceptor mailRetryInterceptor() {
        return RetryInterceptorBuilder.stateless()
                .maxAttempts(4)
                .backOffOptions(2000, 2.0, 10000)
                .recoverer((args, cause) -> {
                    throw new AmqpRejectAndDontRequeueException(cause);
                })
                .build();
    }

    @Bean
    SimpleRabbitListenerContainerFactory rabbitListenerContainerFactory(
            ConnectionFactory connectionFactory,
            RetryOperationsInterceptor mailRetryInterceptor,
            Jackson2JsonMessageConverter messageConverter) {
        SimpleRabbitListenerContainerFactory factory = new SimpleRabbitListenerContainerFactory();
        factory.setConnectionFactory(connectionFactory);
        factory.setAdviceChain(mailRetryInterceptor);
        factory.setMessageConverter(messageConverter);
        return factory;
    }

}