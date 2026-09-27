package br.com.api.controller;

import br.com.api.dto.request.LoginRequest;
import br.com.api.dto.request.UserRequest;
import br.com.api.dto.response.AuthRegisterResponse;
import br.com.api.dto.response.TokenPair;
import br.com.api.dto.response.UserMeResponse;
import br.com.api.dto.response.UserResponse;
import br.com.api.service.AuthService;
import br.com.api.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;

import static org.springframework.http.HttpHeaders.SET_COOKIE;

@RestController
@RequestMapping("/lumin/auth")
public class AuthControllerImpl implements AuthController{

    private final AuthService service;
    private final boolean cookieSecure;

    public AuthControllerImpl(
            AuthService service,
            @Value("${cookie.secure}") boolean cookieSecure
    ){
        this.service = service;
        this.cookieSecure = cookieSecure;
    }

    @Override
    @PostMapping("/register")
    public ResponseEntity<UserMeResponse> register(@RequestBody @Valid UserRequest request) {

        AuthRegisterResponse authRegisterResponse = service.register(request);

        ResponseCookie accessToken = ResponseCookie
                .from("access", authRegisterResponse.tokenPair().access())
                .httpOnly(true).secure(cookieSecure)
                .sameSite("Lax")
                .path("/")
                .maxAge(900)
                .build();

        ResponseCookie refreshToken = ResponseCookie
                .from("refresh", authRegisterResponse.tokenPair().refreshJti())
                .httpOnly(true)
                .secure(cookieSecure)
                .sameSite("Lax")
                .path("/lumin/auth/refresh")
                .maxAge(604800)
                .build();

        return ResponseEntity.status(HttpStatus.CREATED)
                .header(SET_COOKIE, accessToken.toString())
                .header(SET_COOKIE, refreshToken.toString())
                .body(authRegisterResponse.userMeResponse());
    }

    @Override
    @PostMapping("/login")
    public ResponseEntity<Void> login(@RequestBody @Valid LoginRequest request) {

        TokenPair tokenPair = service.login(request);

        ResponseCookie accessToken = ResponseCookie
                .from("access", tokenPair.access())
                .httpOnly(true).secure(cookieSecure)
                .sameSite("Lax")
                .path("/")
                .maxAge(900)
                .build();

        ResponseCookie refreshToken = ResponseCookie
                .from("refresh", tokenPair.refreshJti())
                .httpOnly(true)
                .secure(cookieSecure)
                .sameSite("Lax")
                .path("/lumin/auth/refresh")
                .maxAge(604800)
                .build();

        return ResponseEntity.noContent()
                .header(SET_COOKIE, accessToken.toString())
                .header(SET_COOKIE, refreshToken.toString())
                .build();

    }

    @Override
    @PostMapping("/refresh")
    public ResponseEntity<Void> refresh(
            @CookieValue(name = "refresh", required = false) String refresh
    ) {
        TokenPair tokenPair = service.refresh(refresh);

        ResponseCookie accessToken = ResponseCookie
                .from("access", tokenPair.access())
                .httpOnly(true)
                .secure(cookieSecure)
                .sameSite("Lax")
                .path("/")
                .maxAge(900)
                .build();

        ResponseCookie refreshToken = ResponseCookie
                .from("refresh", tokenPair.refreshJti())
                .httpOnly(true)
                .secure(cookieSecure)
                .sameSite("Lax")
                .path("/lumin/auth/refresh")
                .maxAge(604800)
                .build();

        return ResponseEntity.noContent()
                .header(SET_COOKIE, accessToken.toString())
                .header(SET_COOKIE, refreshToken.toString())
                .build();
    }

    @Override
    @PostMapping("/logout")
    public ResponseEntity<Void> logout(
            @CookieValue(name = "refresh", required = false) String refresh
    ) {
        service.logout(refresh);

        ResponseCookie accessToken = ResponseCookie
                .from("access", "")
                .httpOnly(true)
                .secure(cookieSecure)
                .sameSite("Lax")
                .path("/")
                .maxAge(0)
                .build();

        ResponseCookie refreshToken = ResponseCookie
                .from("refresh", "")
                .httpOnly(true)
                .secure(cookieSecure)
                .sameSite("Lax")
                .path("/lumin/auth/refresh")
                .maxAge(0)
                .build();

        return ResponseEntity.noContent()
                .header(SET_COOKIE, accessToken.toString())
                .header(SET_COOKIE, refreshToken.toString())
                .build();
    }

}
