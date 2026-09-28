package br.com.api.exception;

public class TooManyRequestException extends RuntimeException {

    private final String code;
    public TooManyRequestException(String code, String message) { super(message); this.code = code; }

    public String getCode() {
        return code;
    }

}
