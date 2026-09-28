package br.com.api.producer;

public interface MailProducer {

    void sendCode(String to, String code);

}
