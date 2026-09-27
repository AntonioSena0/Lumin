package br.com.api.config;

import br.com.api.exception.BusinessException;
import br.com.api.exception.ConflictException;
import br.com.api.exception.NotFoundException;
import br.com.api.exception.UnauthorizedException;
import io.jsonwebtoken.JwtException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.List;

@Slf4j
@RestControllerAdvice
public class ApplicationControllerAdvice {

    public record Field(
            String field,
            String message
    ) {};
    public record Error(
            String code,
            String message,
            List<Field> fields
    ) {};

    @ExceptionHandler({BadCredentialsException.class, UsernameNotFoundException.class, UnauthorizedException.class})
    @ResponseStatus(HttpStatus.UNAUTHORIZED)
    public Error auth() {
        return new Error("AUTH_INVALID", "Credenciais inválidas", List.of());
    }

    @ExceptionHandler(NotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public Error notFound(NotFoundException e ) {
        return new Error(e.getCode(), e.getMessage(), List.of());
    }

    @ExceptionHandler
    @ResponseStatus(HttpStatus.UNPROCESSABLE_ENTITY)
    public Error business(BusinessException e) {
        return new Error(e.getCode(), e.getMessage(), List.of());
    }

    @ExceptionHandler
    @ResponseStatus(HttpStatus.CONFLICT)
    public Error conflict(ConflictException e) {
        return new Error("REGISTER_INVALID", "Verifique os dados informados", List.of());
    }

    @ExceptionHandler
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Error validation(MethodArgumentNotValidException e) {
        var fields = e.getBindingResult().getFieldErrors()
                .stream()
                .map(f -> new Field(f.getField(), f.getDefaultMessage()))
                .toList();
        return new Error("VALIDATION", "Dados inválidos", fields);
    }

    @ExceptionHandler({JwtException.class, IllegalArgumentException.class})
    @ResponseStatus(HttpStatus.UNAUTHORIZED)
    public Error jwt() {
        return new Error("SESSION_INVALID", "Sessão inválida", List.of());
    }

    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public Error fallback(Exception e) {
        log.error("...", e);
        return new Error("INTERNAL", "Erro interno", List.of());
    }

}
