package br.com.api.exception;

public class EmailNotVerifiedException extends RuntimeException {

    public EmailNotVerifiedException() {
        super("E-mail não verificado");
    }
}
